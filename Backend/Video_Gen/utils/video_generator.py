import os
import subprocess
from PIL import Image
import pysrt

FONT_SIZE = 50
FONT_COLOR = "white"
FONT = "Arial"
BORDER_WIDTH = 1.2
BORDER_COLOR = "darkgray"
SUBTITLE_X_POSITION = "(w-tw)/2"
SUBTITLE_BOTTOM_GAP = 60
SUBTITLE_MARGIN = 30
SUBTITLE_VERTICAL_ALIGNMENT = "bottom"
ADD_SUBTITLES = True

def extract_subtitle_texts_from_srt(srt_file):
    try:
        subs = pysrt.open(srt_file)
        return [sub.text.replace('\n', ' ') for sub in subs]
    except Exception as e:
        print(f"Error reading SRT file: {e}")
        return []

def wrap_text_for_subtitles(text, max_width, font_size=FONT_SIZE, font_path=None):
    effective_width = max_width * 0.8
    char_width = font_size * 0.6
    space_width = font_size * 0.3
    lines = []
    current_line = []
    current_line_width = 0
    for word in text.split():
        word_width = len(word) * char_width + space_width
        if current_line_width + word_width <= effective_width:
            current_line.append(word)
            current_line_width += word_width
        else:
            lines.append(' '.join(current_line)) if current_line else None
            current_line = [word]
            current_line_width = word_width
    lines.append(' '.join(current_line)) if current_line else None
    return lines

def get_subtitle_vertical_position(total_lines, font_size, line_spacing, video_height, alignment):
    total_height = total_lines * font_size + (total_lines - 1) * line_spacing
    margin = SUBTITLE_MARGIN
    return margin if alignment == "top" else (video_height - total_height) // 2 if alignment == "center" else video_height - total_height - margin - SUBTITLE_BOTTOM_GAP if alignment == "bottom" else (_ for _ in ()).throw(ValueError("Invalid subtitle alignment"))

def fit_image_to_vertical_16_9(input_path, output_path):
    img = Image.open(input_path)
    width, height = img.size
    target_width = 1080
    target_height = 1920
    width_ratio = target_width / width
    height_ratio = target_height / height
    scale_ratio = min(width_ratio, height_ratio)
    new_width = int(width * scale_ratio)
    new_height = int(height * scale_ratio)
    img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
    new_img = Image.new('RGB', (target_width, target_height), (0, 0, 0))
    paste_x = (target_width - new_width) // 2
    paste_y = (target_height - new_height) // 2
    new_img.paste(img, (paste_x, paste_y))
    new_img.save(output_path, quality=100)

def prepare_images_for_ffmpeg(input_dir, output_dir):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    image_count = 1
    for filename in sorted(os.listdir(input_dir)):
        if filename.endswith((".jpg", ".jpeg", ".png")):
            input_path = os.path.join(input_dir, filename)
            output_path = os.path.join(output_dir, f"image{image_count}.jpg")
            fit_image_to_vertical_16_9(input_path, output_path) if not os.path.exists(output_path) else None
            image_count += 1

def fetch_audio_duration_ffmpeg(audio_path):
    try:
        command = [
            "ffmpeg", "-i", audio_path,
            "-vn", "-f", "null", "-"
        ]
        result = subprocess.run(command, stderr=subprocess.PIPE, text=True)
        for line in result.stderr.splitlines():
            if "Duration" in line:
                duration_str = line.split()[1].rstrip(',')
                h, m, s = duration_str.split(":")
                return float(h) * 3600 + float(m) * 60 + float(s)
        print(f"Duration not found in FFmpeg output for {audio_path}")
        return None
    except Exception as e:
        print(f"Error getting audio duration: {e}")
        return None

def build_subtitle_filter(wrapped_subtitles, audio_duration):
    if not wrapped_subtitles:
        return "null"
    filter_complex = []
    line_spacing = 20
    video_height = 1920
    total_lines = len(wrapped_subtitles)
    vertical_position = get_subtitle_vertical_position(
        total_lines, FONT_SIZE, line_spacing, video_height, SUBTITLE_VERTICAL_ALIGNMENT)
    for idx, seg_text in enumerate(wrapped_subtitles):
        seg_text = seg_text.replace("'", "'\\''").replace(":", "\\:")
        y_position = vertical_position + (FONT_SIZE + line_spacing) * idx
        filter_complex.append(
            f"drawtext=text='{seg_text}':fontcolor={FONT_COLOR}:fontsize={FONT_SIZE}:"
            f"font='{FONT}':"
            f"box=1:boxcolor=black@0.5:boxborderw=5:"
            f"x={SUBTITLE_X_POSITION}:y={y_position}:line_spacing={line_spacing}:"
            f"fix_bounds=true:enable='between(t,0,{audio_duration})'"
        )
    return ','.join(filter_complex)

def generate_video_with_audio_and_subtitles(output_dir, audio_dir, output_video):
    try:
        watermark_path = "watermark_100Agents.png"
        watermark_exists = os.path.exists(watermark_path)
        watermark_padding_top = 30
        base_dir = os.getcwd()
        concat_list_path = os.path.join(base_dir, "concat_list.txt")
        subtitles = extract_subtitle_texts_from_srt('subtitles.srt')
        audio_files = [f for f in sorted(os.listdir(audio_dir)) if f.endswith('.mp3')]
        scene_count = len(audio_files)
        total_duration = sum(fetch_audio_duration_ffmpeg(os.path.join(audio_dir, f"scene{i}.mp3")) for i in range(1, len(subtitles) + 1))
        with open(concat_list_path, "w", encoding='utf-8') as f:
            print(f"Found {scene_count} audio files")
            for i in range(1, scene_count + 1):
                image_path = os.path.join(output_dir, f"image{i}.jpg")
                audio_path = os.path.join(audio_dir, f"scene{i}.mp3")
                temp_video = os.path.join(base_dir, f"temp_scene_{i}.mp4")
                if not (os.path.exists(image_path) and os.path.exists(audio_path)):
                    print(f"Missing files for scene {i}")
                    continue
                audio_duration = fetch_audio_duration_ffmpeg(audio_path)
                if audio_duration is None:
                    print(f"Could not determine duration for {audio_path}")
                    continue
                print(f"Processing scene {i} with duration {audio_duration} seconds")
                subtitle_text = subtitles[i - 1] if ADD_SUBTITLES and i - 1 < len(subtitles) else ""
                wrapped_subtitles = wrap_text_for_subtitles(subtitle_text, max_width=1080 - 40) if ADD_SUBTITLES else []
                print(f"Wrapped subtitles for scene {i}: {wrapped_subtitles}") if ADD_SUBTITLES else None
                subtitle_filter = build_subtitle_filter(wrapped_subtitles, audio_duration) if ADD_SUBTITLES else "null"
                bg_music_path = "bg_music.mp3"
                bg_music_exists = os.path.exists(bg_music_path)
                command = [
                    "ffmpeg", "-y",
                    "-loop", "1",
                    "-t", str(audio_duration),
                    "-i", image_path,
                    "-i", audio_path
                ]
                if watermark_exists:
                    command += ["-i", watermark_path, "-filter_complex",
                        f"[0][2]overlay=(W-w)/2:{watermark_padding_top}[bg]; [bg]{subtitle_filter},fade=t=in:st=0:d=1,fade=t=out:st={total_duration-0.5}:d=0.5"]
                else:
                    command += ["-filter_complex",
                        f"{subtitle_filter},fade=t=in:st=0:d=1,fade=t=out:st={total_duration-0.5}:d=0.5"]
                command += [
                    "-pix_fmt", "yuv420p",
                    "-shortest",
                    "-avoid_negative_ts", "make_zero",
                    "-r", "30",
                    temp_video
                ]
                print(f"Creating scene {i} with watermark & timed subtitles..." if ADD_SUBTITLES else f"Creating scene {i} without subtitles")
                subprocess.run(command, check=True)
                f.write(f"file '{os.path.abspath(temp_video)}'\n")
        if not os.path.exists(concat_list_path):
            raise Exception("Concat list file was not created")
        with open(concat_list_path, 'r') as f:
            content = f.read().strip()
            if not content:
                raise Exception("Concat list file is empty")
            print("Concat file content:")
            print(content)
        bg_music_path = "bg_music.mp3"
        bg_music_exists = os.path.exists(bg_music_path)
        filter_complex_str = (
            f"[0:v]fade=t=in:st=0:d=1,fade=t=out:st={total_duration-0.5}:d=0.5[v]; "
            if bg_music_exists else
            f"[0:v]fade=t=in:st=0:d=1,fade=t=out:st={total_duration-0.5}:d=0.5[v]; [0:a]anull[a]"
        )
        final_command = [
            "ffmpeg", "-y",
            "-f", "concat",
            "-safe", "0",
            "-i", concat_list_path,
            "-map", "[v]",
            "-c:a", "aac",
            "-pix_fmt", "yuv420p",
            "-shortest",
            output_video
        ]
        print("Combining all scenes with background music...")
        print("Running command:", ' '.join(final_command))
        result = subprocess.run(
            final_command, stderr=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
        if result.returncode != 0:
            print("FFmpeg stderr output:")
            print(result.stderr)
            raise subprocess.CalledProcessError(
                result.returncode, final_command)
        print("Video created successfully!")
        for i in range(1, scene_count + 1):
            temp_file = os.path.join(base_dir, f"temp_scene_{i}.mp4")
            os.remove(temp_file) if os.path.exists(temp_file) else None
        os.remove(concat_list_path)
    except subprocess.CalledProcessError as e:
        print(f"FFmpeg Error: {e}")
        print("Command output:", e.output if hasattr(e, 'output') else 'No output available')
    except Exception as e:
        print(f"Error: {e}")
