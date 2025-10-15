#!/usr/bin/env python3
"""
Example: Automated File Organizer
This script demonstrates organizing files by extension
"""
import os
import shutil
import argparse
from pathlib import Path
import sys

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from modules.logger import setup_logger

# Setup logger
logger = setup_logger(__name__)


def organize_files(source_dir: str, dry_run: bool = False):
    """
    Organize files in directory by their extension
    
    Args:
        source_dir: Directory to organize
        dry_run: If True, only show what would be done
    """
    source_path = Path(source_dir)
    
    if not source_path.exists():
        logger.error(f"Directory does not exist: {source_dir}")
        return
    
    logger.info(f"Organizing files in: {source_dir}")
    
    # File extension categories
    categories = {
        'Images': ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.svg'],
        'Documents': ['.pdf', '.doc', '.docx', '.txt', '.xlsx', '.pptx'],
        'Videos': ['.mp4', '.avi', '.mkv', '.mov', '.wmv'],
        'Audio': ['.mp3', '.wav', '.flac', '.aac'],
        'Archives': ['.zip', '.rar', '.7z', '.tar', '.gz'],
        'Scripts': ['.py', '.sh', '.ps1', '.bat', '.js']
    }
    
    files_moved = 0
    
    # Iterate through files
    for file_path in source_path.iterdir():
        if not file_path.is_file():
            continue
        
        # Get file extension
        ext = file_path.suffix.lower()
        
        # Find category
        category = 'Others'
        for cat, extensions in categories.items():
            if ext in extensions:
                category = cat
                break
        
        # Create category directory
        category_dir = source_path / category
        
        if dry_run:
            logger.info(f"[DRY RUN] Would move: {file_path.name} -> {category}/")
        else:
            category_dir.mkdir(exist_ok=True)
            dest_path = category_dir / file_path.name
            
            # Handle duplicate names
            counter = 1
            while dest_path.exists():
                dest_path = category_dir / f"{file_path.stem}_{counter}{file_path.suffix}"
                counter += 1
            
            shutil.move(str(file_path), str(dest_path))
            logger.info(f"Moved: {file_path.name} -> {category}/")
            files_moved += 1
    
    if dry_run:
        logger.info("Dry run completed. No files were moved.")
    else:
        logger.info(f"Organization completed. Moved {files_moved} files.")


def main():
    parser = argparse.ArgumentParser(description='Organize files by extension')
    parser.add_argument('directory', help='Directory to organize')
    parser.add_argument('--dry-run', action='store_true', 
                       help='Show what would be done without making changes')
    
    args = parser.parse_args()
    
    try:
        organize_files(args.directory, args.dry_run)
    except Exception as e:
        logger.error(f"Error: {e}")
        return 1
    
    return 0


if __name__ == '__main__':
    exit(main())
