import asyncio
import os
import re
import subprocess
from typing import List
import logging
from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from pydantic import BaseModel, Field
import uvicorn

from moviepy import concatenate_videoclips, VideoFileClip
from pydantic_ai import Agent
from pydantic_ai.models.gemini import GeminiModel
from pydantic_ai.providers.google_gla import GoogleGLAProvider
from config import api_key
import nest_asyncio

nest_asyncio.apply()

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

app = FastAPI(
    title="Manim Video Generator API",
    description="AI-powered video generation API using Manim and Gemini",
    version="1.0.0"
)

gemini_llm = GeminiModel('gemini-2.0-flash', provider=GoogleGLAProvider(api_key=api_key))

class VideoRequest(BaseModel):
    prompt: str = Field(..., description="The concept or topic to generate a video for")
    video_name: str = Field(default="generated_video", description="Name for the output video file")

class VideoResponse(BaseModel):
    message: str
    video_path: str
    status: str

class HealthResponse(BaseModel):
    status: str
    message: str

class ChapterDescription(BaseModel):
    title: str = Field(description="Title of the chapter.")
    explanation: str = Field(description="Detailed explanation of the chapter's content, including how Manim should visualize it. Be very specific with Manim instructions, including animations, shapes, positions, colors, and timing. Include LaTeX for mathematical formulas. Specify scene transitions.")

class VideoOutline(BaseModel):
    title: str = Field(description="Title of the entire video.")
    chapters: List[ChapterDescription] = Field(description="List of chapters in the video.")

class ManimCode(BaseModel):
    code: str = Field(description="Complete Manim code for the chapter. Include all necessary imports. The code should create a single scene. Add comments to explain the code. Do not include any comments that are not valid Python comments. Ensure the code is runnable.")

outline_agent = Agent(
    model=gemini_llm,
    result_type=VideoOutline,
    system_prompt="""
    You are an expert educational content creator specializing in creating engaging video outlines for complex topics.
    
    Your task is to break down any concept into 2-3 clear, progressive chapters that build understanding step-by-step.
    Each chapter should be 30-60 seconds when animated, focusing on one key concept or step.
    
    For each chapter, provide:
    1. A clear, descriptive title
    2. Detailed visualization instructions including:
       - Specific Manim objects to create (circles, squares, arrows, text, etc.)
       - Exact positioning and sizing (use coordinates like UP, DOWN, LEFT, RIGHT)
       - Animation sequences with timing (Create, Transform, Move, FadeIn, etc.)
       - Color schemes (use specific colors like RED, BLUE, GREEN, YELLOW)
       - Mathematical formulas in LaTeX format
       - Scene transitions and camera movements
    
    Focus on creating visual stories that make abstract concepts concrete and memorable.
    Use progressive complexity: start simple, build to more complex visualizations.
    """
)

manim_agent = Agent(
    model=gemini_llm,
    result_type=ManimCode,
    system_prompt="""
    You are a Manim expert specializing in creating beautiful, educational animations.
    
    Generate complete, runnable Manim code that:
    - Uses proper imports (manim, numpy, etc.)
    - Creates a single Scene class with a descriptive name
    - Implements smooth, professional animations
    - Uses consistent styling and colors
    - Includes helpful comments explaining each step
    - Handles timing and pacing appropriately
    - Uses LaTeX for mathematical expressions
    - Implements proper scene structure with construct method
    
    Code requirements:
    - Must be syntactically correct Python
    - Include all necessary imports
    - Use descriptive variable names
    - Add comments for complex operations
    - Ensure proper indentation and formatting
    - Test for common Manim patterns and best practices
    """
)

code_fixer_agent = Agent(
    model=gemini_llm,
    result_type=ManimCode,
    system_prompt="""
    You are a Manim debugging expert with deep knowledge of common errors and their solutions.
    
    Analyze the provided error message and code to:
    1. Identify the specific issue (syntax, import, method, etc.)
    2. Provide a corrected version that maintains the original intent
    3. Add error prevention measures
    4. Ensure the code follows Manim best practices
    
    Common fixes include:
    - Adding missing imports
    - Correcting method names and parameters
    - Fixing syntax errors
    - Adjusting timing and animation sequences
    - Resolving coordinate system issues
    - Fixing LaTeX formatting
    
    Always preserve the educational intent while ensuring technical correctness.
    """
)

def create_manim_code(chapter: ChapterDescription) -> str:
    logging.info(f"Creating Manim code for chapter: {chapter.title}")
    result = manim_agent.run_sync(f"Title: {chapter.title}. Visualization: {chapter.explanation}")
    return result.data.code

def debug_manim_code(error: str, code: str) -> str:
    logging.info(f"Debugging Manim code due to error: {error}")
    result = code_fixer_agent.run_sync(f"Error: {error}\nCode: {code}")
    return result.data.code

def create_video_outline(concept: str) -> VideoOutline:
    logging.info(f"Creating video outline for: {concept}")
    result = outline_agent.run_sync(concept)
    return result.data

def render_manim_scene(code: str, chapter_num: int) -> str:
    with open("temp.py", "w") as f:
        f.write(code)
        temp_file = f.name

    process = None
    try:
        command = ["manim", temp_file, "-ql", "--disable_caching"]
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, text=True)
        stdout, stderr = process.communicate(timeout=60)

        if process.returncode == 0:
            logging.info(f"Manim render successful for chapter {chapter_num}")
            logging.debug(f"Manim stdout: {stdout}")
            logging.debug(f"Manim stderr: {stderr}")
        else:
            error_msg = f"Manim render failed for chapter {chapter_num} with return code {process.returncode}: {stdout} {stderr}"
            logging.error(error_msg.split('\n')[-1])
            raise subprocess.CalledProcessError(process.returncode, command, output=stdout.encode(), stderr=stderr.encode())

    except subprocess.TimeoutExpired:
        logging.error(f"Manim process timed out for chapter {chapter_num}")
        process.kill() if process else None
        raise
    except FileNotFoundError:
        logging.error("Manim command not found. Ensure Manim is installed and in PATH.")
        raise

    match = re.search(r"class\s+(\w+)\(Scene\):", code)
    class_name = match.group(1) if match else None
    return f"{class_name}.mp4" if class_name else ValueError(f"Could not extract class name from Manim code for chapter {chapter_num}")

async def generate_video(concept: str, video_name: str = "generated_video") -> str:
    logging.info(f"Generating video for concept: {concept}")
    outline = create_video_outline(concept)
    logging.info(f"Video outline created: {outline}")

    video_files = []
    for i, chapter in enumerate(outline.chapters):
        logging.info(f"Processing chapter {i + 1}: {chapter.title}")
        manim_code = create_manim_code(chapter)
        logging.debug(f"Generated Manim code for chapter {i + 1}: {manim_code}")

        success = False
        attempts = 0
        max_attempts = 2

        while attempts < max_attempts and not success:
            try:
                video_file = render_manim_scene(manim_code, i + 1)
                video_files.append(video_file)
                logging.info(f"Video file created for chapter {i + 1}: {video_file}")
                success = True
            except subprocess.CalledProcessError as e:
                attempts += 1
                logging.error(f"Manim execution failed for chapter {i + 1} (Attempt {attempts}): {e}")
                logging.info("Attempting to fix the code...")
                manim_code = debug_manim_code(str(e), manim_code)
                logging.debug(f"Fixed Manim code (Attempt {attempts}): {manim_code}")
            except ValueError as e:
                logging.error(f"Error processing Manim code for chapter {i + 1}: {e}")
                raise HTTPException(status_code=500, detail=f"Error processing chapter {i + 1}: {e}")
            except FileNotFoundError:
                logging.error("Manim not found. Please ensure it's installed and in your PATH.")
                raise HTTPException(status_code=500, detail="Manim not found. Please ensure it's installed and in your PATH.")
            except subprocess.TimeoutExpired:
                logging.error(f"Manim process timed out for chapter {i + 1}. Attempting to fix...")
                manim_code = debug_manim_code("Manim process timed out.", manim_code)
                logging.debug(f"Fixed Manim code (Attempt {attempts}): {manim_code}")

        if not success:
            logging.error(f"Failed to generate video for chapter {i + 1} after {max_attempts} attempts. Skipping chapter.")
            continue

    final_video_path = None
    if video_files:
        logging.info("Combining video files...")
        try:
            clips = [VideoFileClip(f"./media/videos/temp/480p15/{video_file}") for video_file in video_files]
            final_video_path = f"{video_name}.mp4"
            final_clip = concatenate_videoclips(clips)
            final_clip.write_videofile(final_video_path, codec="libx264", audio_codec="aac")
            final_clip.close()

            logging.info(f"Final video created: {final_video_path}")

            for video_file in video_files:
                try:
                    os.remove(video_file)
                    logging.info(f"Deleted intermediate video file: {video_file}")
                except Exception as e:
                    logging.error(f"Error deleting intermediate video file {video_file}: {e}")
        except Exception as e:
            logging.error(f"Error combining video files: {e}")
            raise HTTPException(status_code=500, detail=f"Error combining video files: {e}")
    else:
        logging.warning("No video files to combine.")
        raise HTTPException(status_code=500, detail="No video files were generated.")

    return final_video_path

@app.get("/", response_model=HealthResponse)
async def root():
    return HealthResponse(
        status="healthy",
        message="Manim Video Generator API is running. Use /docs for API documentation."
    )

@app.get("/health", response_model=HealthResponse)
async def health_check():
    return HealthResponse(
        status="healthy",
        message="API is operational"
    )

@app.post("/generate-video", response_model=VideoResponse)
async def create_video(request: VideoRequest):
    try:
        logging.info(f"Received video generation request: {request.prompt}")
        
        video_path = await generate_video(request.prompt, request.video_name)
        
        return VideoResponse(
            message="Video generated successfully",
            video_path=video_path,
            status="completed"
        ) if os.path.exists(video_path) else HTTPException(status_code=500, detail="Video file was not created")
            
    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"Unexpected error during video generation: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {str(e)}")

@app.get("/download/{video_name}")
async def download_video(video_name: str):
    video_path = f"{video_name}.mp4"
    
    if not os.path.exists(video_path):
        raise HTTPException(status_code=404, detail="Video file not found")
    
    return FileResponse(
        path=video_path,
        media_type="video/mp4",
        filename=video_path
    )

@app.get("/videos")
async def list_videos():
    videos = [file for file in os.listdir(".") if file.endswith(".mp4") and file != "final.mp4"]
    return {"videos": videos}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)