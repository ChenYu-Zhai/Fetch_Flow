#!/usr/bin/env python3
# 安装: pip install moviepy

import os
from moviepy.editor import VideoFileClip

def convert_all_mp4_to_gif(width=720, fps=10):
    """转换当前文件夹所有MP4文件为GIF"""
    
    mp4_files = [f for f in os.listdir('.') if f.lower().endswith('.mp4')]
    
    if not mp4_files:
        print("⚠️  未找到MP4文件")
        return
    
    print(f"🎬 发现 {len(mp4_files)} 个MP4文件")
    print(f"📐 参数: 宽度={width}px, 帧率={fps}fps")
    print("=" * 50)
    
    for i, filename in enumerate(mp4_files, 1):
        try:
            output_name = filename.rsplit('.', 1)[0] + '.gif'
            
            print(f"[{i}/{len(mp4_files)}] 🔄 转换: {filename}")
            
            clip = VideoFileClip(filename)
            clip_resized = clip.resize(width=width)
            clip_resized.fps = fps
            clip_resized.write_gif(
                output_name,
                fps=fps,
                program='ffmpeg',
                opt='optimizeTransparency',
                fuzz=5
            )
            
            clip.close()
            clip_resized.close()
            
            print(f"   ✅ 完成: {output_name}")
            
        except Exception as e:
            print(f"   ❌ 失败: {filename} - {str(e)}")
    
    print("=" * 50)
    print("🎉 全部转换完成！")

if __name__ == '__main__':
    convert_all_mp4_to_gif(width=720, fps=10)