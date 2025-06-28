import os
import requests
import subprocess

url = "https://api.deepgram.com/v1/speak?model=aura-luna-en"
headers = {
    'Authorization': f'Token {os.environ.get("DEEPGRAM_API_KEY")}',
    'Content-Type': 'text/plain'
}

def fetch_audio_duration(audio_path):
    try:
        command = [
            "ffprobe", "-i", audio_path,
            "-show_entries", "format=duration",
            "-v", "quiet", "-of", "csv=p=0"
        ]
        result = subprocess.run(
            command, capture_output=True, text=True, check=True)
        return float(result.stdout.strip())
    except Exception as e:
        print(f"Error getting audio duration: {e}")
        return 0

def create_audio_and_get_duration(text, scene):
    return None if not text or not scene else _create_audio_and_get_duration(text, scene)

def _create_audio_and_get_duration(text, scene):
    os.makedirs('audios', exist_ok=True)
    response = requests.request("POST", url, headers=headers, data=text)
    if response.status_code == 200:
        audio_path = f'audios/scene{scene}.mp3'
        with open(audio_path, 'wb') as f:
            f.write(response.content)
        print(f"Audio file saved successfully as '{audio_path}'")
        duration = fetch_audio_duration(audio_path)
        return duration
    else:
        print(f"Error: {response.text}")
        return None
