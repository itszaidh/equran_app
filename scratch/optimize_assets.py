import os
import glob
import json
import subprocess

def optimize_images():
    print("=== OPTIMIZING IMAGES (Lossless -> Lossy WebP q80) ===")
    image_paths = glob.glob('assets/media/images/app/*.webp') + ['assets/media/images/icon.webp']
    total_old_size = 0
    total_new_size = 0
    
    for path in image_paths:
        if not os.path.exists(path):
            continue
        old_size = os.path.getsize(path)
        total_old_size += old_size
        
        # Temp file to verify conversion is smaller/successful
        temp_path = path + '.tmp.webp'
        try:
            # Use 'convert' to compress
            cmd = ['convert', path, '-quality', '80', temp_path]
            subprocess.run(cmd, check=True, stderr=subprocess.DEVNULL)
            
            if os.path.exists(temp_path):
                new_size = os.path.getsize(temp_path)
                if new_size < old_size:
                    os.replace(temp_path, path)
                    total_new_size += new_size
                    print(f"Compressed {os.path.basename(path)}: {old_size/1024:.1f} KB -> {new_size/1024:.1f} KB (saved {(old_size-new_size)/1024:.1f} KB)")
                else:
                    os.remove(temp_path)
                    total_new_size += old_size
                    print(f"Skipped {os.path.basename(path)} (no size benefit): {old_size/1024:.1f} KB")
        except Exception as e:
            if os.path.exists(temp_path):
                os.remove(temp_path)
            total_new_size += old_size
            print(f"Failed to compress {os.path.basename(path)}: {e}")
            
    saved = total_old_size - total_new_size
    print(f"IMAGE SUMMARY: Old size: {total_old_size/1024:.1f} KB | New size: {total_new_size/1024:.1f} KB | Saved: {saved/1024:.1f} KB ({saved/total_old_size*100:.1f}%)")
    print()

def minify_json():
    print("=== MINIFYING JSON FILES ===")
    json_patterns = [
        'assets/data/**/*.json',
    ]
    
    total_old_size = 0
    total_new_size = 0
    file_count = 0
    modified_count = 0
    
    # We walk recursively to find all JSON files
    for root, dirs, files in os.walk('assets/data'):
        for file in files:
            if file.endswith('.json'):
                path = os.path.join(root, file)
                file_count += 1
                old_size = os.path.getsize(path)
                total_old_size += old_size
                
                try:
                    with open(path, 'r', encoding='utf-8') as fh:
                        data = json.load(fh)
                    
                    # Convert to minified string with separators (no spaces)
                    minified = json.dumps(data, ensure_ascii=False, separators=(',', ':'))
                    minified_bytes = minified.encode('utf-8')
                    new_size = len(minified_bytes)
                    
                    if new_size < old_size:
                        with open(path, 'w', encoding='utf-8') as fh:
                            fh.write(minified)
                        total_new_size += new_size
                        modified_count += 1
                    else:
                        total_new_size += old_size
                except Exception as e:
                    total_new_size += old_size
                    print(f"Failed to minify {path}: {e}")
                    
    saved = total_old_size - total_new_size
    print(f"JSON SUMMARY: Total files: {file_count} | Minified: {modified_count} | Old size: {total_old_size/1024:.1f} KB | New size: {total_new_size/1024:.1f} KB | Saved: {saved/1024:.1f} KB")

if __name__ == '__main__':
    optimize_images()
    minify_json()
