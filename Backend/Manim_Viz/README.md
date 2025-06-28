# Manim Video Generator Module

🚀 **Automatically generate high-quality explanatory videos from text prompts using AI and Manim animations via REST API.**

This project combines the power of Google's Gemini AI with Manim (Mathematical Animation Engine) to create educational videos through a RESTful API. Simply send a POST request with your concept, and the system will generate a complete video with animations, explanations, and visualizations.

## ✨ Features

- **REST API Interface**: Simple HTTP endpoints for video generation
- **AI-Powered Content Generation**: Uses Gemini AI to understand prompts and create educational content
- **Professional Animations**: Leverages Manim for high-quality mathematical and educational animations
- **Automatic Error Correction**: Built-in code fixing capabilities for robust video generation
- **Modular Architecture**: Generates videos in chapters for better organization
- **LaTeX Support**: Full mathematical formula rendering with LaTeX
- **File Management**: Download generated videos and list available videos

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed:

- **Python 3.8+**
- **Git**
- **Google Gemini API Key** ([Get one here](https://makersuite.google.com/app/apikey))

## 📦 Installation

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd Manim_Viz
```

### 2. Set Up Virtual Environment (Recommended)

```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure API Key

1. Copy the existing `config.py` file (it should already exist)
2. Open `config.py` and add your Gemini API key:

```python
api_key = 'your-google-gemini-api-key-here'
```

## 🚀 Usage

### Start the API Server

```bash
python app.py
```

The API server will start on `http://localhost:8000`

### API Documentation

Once the server is running, you can access:
- **Interactive API Docs**: `http://localhost:8000/docs` (Swagger UI)
- **Alternative API Docs**: `http://localhost:8000/redoc` (ReDoc)

## 📋 API Endpoints

### 1. Health Check

**GET** `/health`

Check if the API is running properly.

**Response:**
```json
{
  "status": "healthy",
  "message": "API is operational"
}
```

### 2. Generate Video

**POST** `/generate-video`

Generate a video from a text prompt.

**Request Body:**
```json
{
  "prompt": "Explain the concept of derivatives in calculus",
  "video_name": "derivatives_tutorial"
}
```

**Response:**
```json
{
  "message": "Video generated successfully",
  "video_path": "derivatives_tutorial.mp4",
  "status": "completed"
}
```

### 3. Download Video

**GET** `/download/{video_name}`

Download a generated video file.

**Example:** `GET /download/derivatives_tutorial`

Returns the video file as a downloadable MP4.

### 4. List Videos

**GET** `/videos`

List all available generated videos.

**Response:**
```json
{
  "videos": [
    "derivatives_tutorial.mp4",
    "integration_basics.mp4"
  ]
}
```

## 🔧 Example Usage

### Using curl

```bash
# Generate a video
curl -X POST "http://localhost:8000/generate-video" \
     -H "Content-Type: application/json" \
     -d '{"prompt": "Explain the Pythagorean theorem", "video_name": "pythagorean_theorem"}'

# Download the video
curl -O "http://localhost:8000/download/pythagorean_theorem"

# List all videos
curl "http://localhost:8000/videos"
```

### Using Python requests

```python
import requests

# Generate video
response = requests.post(
    "http://localhost:8000/generate-video",
    json={
        "prompt": "Explain the concept of derivatives in calculus",
        "video_name": "derivatives_tutorial"
    }
)
print(response.json())

# Download video
video_response = requests.get("http://localhost:8000/download/derivatives_tutorial")
with open("derivatives_tutorial.mp4", "wb") as f:
    f.write(video_response.content)
```

## 📋 How It Works

1. **API Request**: Send a POST request with your prompt to `/generate-video`
2. **Prompt Processing**: Your text prompt is analyzed by Gemini AI to understand the concept
3. **Outline Generation**: The AI creates a structured video outline with 2-3 progressive chapters (30-60 seconds each)
4. **Animation Creation**: Each chapter is converted into professional Manim code with detailed visualizations
5. **Video Rendering**: Manim renders high-quality animations with smooth transitions and proper timing
6. **Error Correction**: If any errors occur, the system automatically attempts to fix them using advanced debugging
7. **Video Assembly**: All chapters are combined into a final MP4 video with consistent quality
8. **Response**: API returns the video path and status for easy integration

## 📁 Output

- **Generated Videos**: Saved as `{video_name}.mp4` in the project directory
- **Temporary Files**: Automatically cleaned up after generation
- **Logs**: Detailed logging for debugging and monitoring

## 🎯 Example Use Cases

- **Educational Content**: Create videos explaining mathematical concepts, physics, chemistry
- **Tutorial Videos**: Generate step-by-step instructional content
- **Presentation Aids**: Create animated visualizations for presentations
- **Learning Materials**: Develop interactive educational resources
- **API Integration**: Integrate video generation into your applications

## 🔧 Troubleshooting

### Common Issues

1. **"Manim command not found"**
   - Ensure Manim is properly installed: `pip install manim`
   - Check that Manim is in your system PATH

2. **API Key Errors**
   - Verify your Gemini API key is correct in `config.py`
   - Ensure you have sufficient API credits

3. **Video Generation Fails**
   - Check the console logs for detailed error messages
   - Ensure you have sufficient disk space for video files
   - Try simpler prompts for complex topics

4. **API Connection Issues**
   - Ensure the server is running on the correct port
   - Check firewall settings if accessing remotely
   - Verify the API endpoint URLs

### Performance Tips

- Use a virtual environment to avoid dependency conflicts
- Ensure sufficient RAM (4GB+) for video rendering
- Close other applications during video generation for better performance
- Consider running the API on a server with good computational resources

## 📚 Dependencies

- **fastapi**: Modern web framework for building APIs
- **uvicorn**: ASGI server for running FastAPI
- **pydantic_ai**: AI agent framework
- **manim**: Mathematical animation engine
- **moviepy**: Video editing and concatenation
- **pydantic**: Data validation
- **nest_asyncio**: Async support

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the terms specified in the LICENSE file.

## 🙏 Acknowledgments

- [Manim Community](https://www.manim.community/) for the animation engine
- [Google Gemini](https://ai.google.dev/) for AI capabilities
- [FastAPI](https://fastapi.tiangolo.com/) for the web framework

---

**Note**: This project requires an active internet connection for AI processing and may take several minutes to generate videos depending on complexity and system performance.