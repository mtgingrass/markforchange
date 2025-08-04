#!/usr/bin/env python3
"""
Create posts.json for the blog scroll section
This script is used as a fallback if R is not available
"""

import json
import os
import re
from datetime import datetime
from pathlib import Path

def extract_yaml_frontmatter(content):
    """Extract YAML frontmatter from file content"""
    pattern = r'^---\s*\n(.*?)\n---'
    match = re.match(pattern, content, re.DOTALL)
    if match:
        yaml_content = match.group(1)
        # Simple YAML parsing for our needs
        metadata = {}
        for line in yaml_content.split('\n'):
            if ':' in line:
                key, value = line.split(':', 1)
                key = key.strip()
                value = value.strip().strip('"').strip("'")
                if key == 'categories':
                    # Handle categories list
                    value = [cat.strip() for cat in value.strip('[]').split(',')]
                metadata[key] = value
        return metadata, content[match.end():]
    return {}, content

def get_first_paragraph(content):
    """Extract first paragraph of content for description"""
    lines = content.strip().split('\n')
    paragraph = []
    skip_callout = False
    
    for line in lines:
        line = line.strip()
        
        # Skip callout blocks
        if line.startswith(':::') and '{.callout' in line:
            skip_callout = True
            continue
        if skip_callout and line == ':::':
            skip_callout = False
            continue
        if skip_callout:
            continue
            
        # Skip headers and empty lines
        if line and not line.startswith('#') and not line.startswith('!['):
            paragraph.append(line)
            if len(' '.join(paragraph)) > 150:
                break
        elif paragraph:
            break
    
    return ' '.join(paragraph)[:150] + '...' if paragraph else ''

def process_posts():
    """Process all posts and create posts.json"""
    posts = []
    posts_dir = Path('posts')
    
    if not posts_dir.exists():
        return []
    
    for post_dir in posts_dir.iterdir():
        if post_dir.is_dir():
            qmd_file = post_dir / 'index.qmd'
            if qmd_file.exists():
                with open(qmd_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                metadata, body = extract_yaml_frontmatter(content)
                
                if 'title' in metadata and 'date' in metadata:
                    post_info = {
                        'title': metadata.get('title', ''),
                        'date': metadata.get('date', ''),
                        'categories': metadata.get('categories', []),
                        'path': f'posts/{post_dir.name}/'
                    }
                    
                    # Add description
                    if 'description' in metadata:
                        post_info['description'] = metadata['description']
                    elif 'summary' in metadata:
                        post_info['description'] = metadata['summary']
                    else:
                        post_info['description'] = get_first_paragraph(body)
                    
                    posts.append(post_info)
    
    # Sort by date (newest first)
    posts.sort(key=lambda x: x['date'], reverse=True)
    
    return posts

def main():
    """Main function"""
    posts = process_posts()
    
    with open('posts.json', 'w', encoding='utf-8') as f:
        json.dump(posts, f, indent=2, ensure_ascii=False)
    
    print(f"Created posts.json with {len(posts)} posts")

if __name__ == '__main__':
    main()