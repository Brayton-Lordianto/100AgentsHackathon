import re
from .tts import generate_audio

def convert_seconds_to_srt_timestamp(seconds):
    milliseconds = int((seconds - int(seconds)) * 1000)
    time_formatted = (
        f"{int(seconds // 3600):02}:"
        f"{int((seconds % 3600) // 60):02}:"
        f"{int(seconds % 60):02},"
        f"{milliseconds:03}"
    )
    return time_formatted

def remove_emojis_and_special_chars(text):
    pattern = re.compile(
        "["
        u"\U0001F600-\U0001F64F"
        u"\U0001F300-\U0001F5FF"
        u"\U0001F680-\U0001F6FF"
        u"\U0001F1E0-\U0001F1FF"
        u"\U00002702-\U000027B0"
        u"\U000024C2-\U0001F251"
        "]+", flags=re.UNICODE
    )
    text = pattern.sub(r'', text)
    text = re.sub(r'[^A-Za-z0-9\s.,?!-]', '', text)
    return text

def create_srt_file_from_json_data(json_output, output_srt_path="subtitles.srt"):
    try:
        subtitles = []
        current_time = 0.0

        for item in json_output:
            scene_number = item["scene_number"]
            text = item["text"]

            text = remove_emojis_and_special_chars(text)

            print(f"Generating audio for scene {scene_number}")
            duration = generate_audio(text, scene_number)

            start_time = current_time if duration else current_time
            end_time = current_time + duration if duration else current_time

            start_time_formatted = convert_seconds_to_srt_timestamp(start_time) if duration else ""
            end_time_formatted = convert_seconds_to_srt_timestamp(end_time) if duration else ""

            subtitles.append(f"{scene_number}") if duration else None
            subtitles.append(f"{start_time_formatted} --> {end_time_formatted}") if duration else None
            subtitles.append(text) if duration else None
            subtitles.append("") if duration else None

            current_time = end_time if duration else current_time

        with open(output_srt_path, "w", encoding="utf-8") as srt_file:
            srt_file.write("\n".join(subtitles))
        print(f"SRT file generated successfully: {output_srt_path}")

    except Exception as e:
        print(f"Error generating SRT file: {e}")
