import os
import json
import asyncio
import shutil
import argparse
from typing import List
from pydantic import BaseModel, Field
from dataclasses import dataclass
from crawl4ai import AsyncWebCrawler
from pydantic_ai import Agent, RunContext
import fitz

from utils.subtitles_generator import create_srt_file_from_json_data
from utils.image_downloader import fetch_and_save_image_from_url
from utils.image_generator import generate_image
from utils.video_generator import prepare_images_for_ffmpeg, generate_video_with_audio_and_subtitles

class Scene(BaseModel):
    scene_number: int = Field(..., description="The sequential number of the scene.")
    text: str = Field(..., description="The narration or on-screen text for the scene.")
    image_prompt: str = Field(..., description="A detailed prompt to generate the image or visual for the scene.")
    timeframe: int = Field(..., description="The duration of the scene in seconds.")

class AgenticScriptGen(BaseModel):
    scenes: List[Scene] = Field(
        ..., description="A list of scenes, each containing the script and related metadata.")

system_prompt = """You are an expert content strategist and video scriptwriter specializing in creating viral YouTube Shorts content. Your mission is to transform articles and documents into compelling, engaging video scripts that capture attention within the first 3 seconds and maintain viewer retention throughout.

                    ## CORE OBJECTIVES:
                    1. **Hook Creation**: Start with a powerful hook that immediately grabs attention
                    2. **Story Structure**: Use proven narrative frameworks (Problem-Solution, Before-After-Bridge, etc.)
                    3. **Emotional Engagement**: Evoke curiosity, surprise, or emotional connection
                    4. **Visual Storytelling**: Create vivid, cinematic image prompts that enhance the narrative
                    5. **Pacing Optimization**: Design scenes for maximum engagement and retention

                    ## CONTENT ANALYSIS GUIDELINES:
                    - **Extract Key Insights**: Identify the most compelling facts, statistics, or stories
                    - **Find the Hook**: Look for surprising revelations, counterintuitive facts, or emotional angles
                    - **Simplify Complex Topics**: Break down complex information into digestible, engaging segments
                    - **Add Context**: Provide relevant background that makes the content more relatable
                    - **Create Urgency**: Use language that creates a sense of immediacy or importance

                    ## SCRIPT STRUCTURE REQUIREMENTS:
                    1. **Opening Hook (Scene 1)**: Start with a shocking fact, question, or statement that stops scrolling
                    2. **Problem/Context (Scenes 2-3)**: Establish the situation or challenge
                    3. **Development (Scenes 4-6)**: Present the main content with engaging details
                    4. **Climax/Revelation (Scene 7-8)**: Deliver the most impactful information
                    5. **Call-to-Action (Final Scene)**: End with a compelling takeaway or question

                    ## SCENE CREATION SPECIFICATIONS:
                    - **Text Length**: Keep each scene's text between 15-25 words for optimal pacing
                    - **Scene Duration**: 3-5 seconds per scene (aim for 3-4 seconds for most scenes)
                    - **Total Video Length**: Target 30-60 seconds for maximum engagement
                    - **Language Style**: Use conversational, energetic language with power words
                    - **Visual Prompts**: Create cinematic, high-quality image descriptions that complement the text

                    ## IMAGE PROMPT GUIDELINES:
                    - **Style**: Modern, professional, cinematic photography or illustration
                    - **Composition**: Use dramatic angles, lighting, and framing
                    - **Emotion**: Match the emotional tone of the script
                    - **Quality**: Specify high-resolution, professional photography
                    - **Relevance**: Ensure images directly support and enhance the narrative

                    ## ENGAGEMENT TECHNIQUES:
                    - **Pattern Interrupts**: Use unexpected facts or questions
                    - **Social Proof**: Include statistics or expert opinions when relevant
                    - **Story Elements**: Incorporate personal stories or relatable scenarios
                    - **Visual Metaphors**: Create image prompts that represent abstract concepts
                    - **Emotional Triggers**: Use words that evoke specific emotions

                    ## OUTPUT FORMAT:
                    Generate a JSON array with 6-10 scenes, each containing:
                    - `scene_number`: Sequential numbering (1, 2, 3...)
                    - `text`: Concise, engaging narration (15-25 words)
                    - `image_prompt`: Detailed visual description for AI image generation
                    - `timeframe`: Duration in seconds (3-5 seconds recommended)

                    ## QUALITY STANDARDS:
                    - **Accuracy**: Maintain factual integrity while making content engaging
                    - **Originality**: Avoid clichés and create fresh perspectives
                    - **Accessibility**: Make complex topics understandable to general audiences
                    - **Memorability**: Use techniques that help viewers remember key points
                    - **Shareability**: Create content that viewers want to share

                    Remember: You're not just summarizing content—you're creating an experience that will make viewers stop scrolling, watch completely, and want to share with others. Every word and image choice should serve this goal.
                """

@dataclass
class Dependencies:
    client: AsyncWebCrawler
    content: str

video_script_agent = Agent(
    model='openai:gpt-4o-mini',
    system_prompt=system_prompt,
    result_type=AgenticScriptGen,
    deps_type=Dependencies,
    name="Video Script Generator",
)

@video_script_agent.tool
async def extract_webpage_content(ctx: RunContext[Dependencies]) -> str:
    return ctx.deps.content if ctx.deps.client is None else (await ctx.deps.client.arun(url=ctx.deps.content)).markdown

def extract_text_content_from_pdf(pdf_path):
    doc = fitz.open(pdf_path)
    text_content = ""
    for page_num in range(len(doc)):
        page = doc.load_page(page_num)
        text_content += page.get_text("text")
    return text_content

async def generate_video_from_content(content: str, content_type: str):
    async with AsyncWebCrawler() as crawler:
        dependencies = Dependencies(
            client=crawler if content_type == 'url' else None,
            content=extract_text_content_from_pdf(content) if content_type == 'pdf' else content
        )
        
        if content_type not in ['url', 'pdf']:
            raise ValueError("Unsupported content type. Use 'url' or 'pdf'.")

        result = await video_script_agent.run('Crawl the webpage of a given URL and do your job', deps=dependencies)
        scenes = result.data.scenes
        json_output = json.dumps([scene.model_dump() for scene in scenes], indent=2)
        print(json_output)

        image_urls = []
        for item in json.loads(json_output):
            print(f"Generating image for scene {item['scene_number']}")
            image_url = generate_image(item['image_prompt'])
            image_urls.append({"url": image_url, "scene": item['scene_number']})

        create_srt_file_from_json_data(json.loads(json_output))

        for item in image_urls:
            print(f"Downloading image for scene {item['scene']}")
            fetch_and_save_image_from_url(item['url'], f"image{item['scene']}")

    input_directory = "images"
    output_directory = "images_processed"
    audio_directory = "audios"
    final_video_output = "output_video.mp4"

    os.makedirs('images_processed', exist_ok=True)
    prepare_images_for_ffmpeg(input_directory, output_directory)
    generate_video_with_audio_and_subtitles(output_directory, audio_directory, final_video_output)
    shutil.rmtree(output_directory, ignore_errors=True)

async def process_multiple_contents(content_type: str, contents: List[str]):
    for content in contents:
        await generate_video_from_content(content, content_type)

if __name__ == "__main__":
    argument_parser = argparse.ArgumentParser(description="Generate YouTube Shorts script from URL or PDF.")
    argument_parser.add_argument('content_type', type=str, choices=['url', 'pdf'], help="Type of content: url or pdf.")
    argument_parser.add_argument('contents', nargs='+', help="URL or path to PDF files.")
    parsed_args = argument_parser.parse_args()

    asyncio.run(process_multiple_contents(parsed_args.content_type, parsed_args.contents))