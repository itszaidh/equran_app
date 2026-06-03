import urllib.request
import json
import os
import zipfile

# Source URLs for German translations from Tanzil
TRANSLATIONS = {
    "de_bubenheim": {
        "url": "https://tanzil.net/trans/de.bubenheim",
        "key": "bubenheim"
    },
    "de_nadeem": {
        "url": "https://tanzil.net/trans/de.bubenheim", # Nadeem uses the same source content, with a different key as requested
        "key": "nadeem"
    },
    "de_aburida": {
        "url": "https://tanzil.net/trans/de.aburida",
        "key": "aburida"
    }
}

OUTPUT_DIR = "build/german_translations"

def download_and_parse(url):
    print(f"Downloading translation from {url}...")
    try:
        response = urllib.request.urlopen(url)
        content = response.read().decode('utf-8')
    except Exception as e:
        print(f"Error downloading translation: {e}")
        return None

    lines = content.strip().split('\n')
    parsed_verses = []
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
        parts = line.split('|')
        if len(parts) >= 3:
            try:
                surah = int(parts[0])
                ayah = int(parts[1])
                text = parts[2]
                parsed_verses.append({
                    'surah': surah,
                    'ayah': ayah,
                    'text': text
                })
            except ValueError:
                # Handle headers or non-integer lines if any
                continue
                
    print(f"Successfully parsed {len(parsed_verses)} verses.")
    return parsed_verses

def save_translation_json(verses, key, folder_name):
    folder_path = os.path.join(OUTPUT_DIR, folder_name)
    os.makedirs(folder_path, exist_ok=True)
    
    # Group verses by surah
    surah_groups = {}
    for verse in verses:
        surah = verse['surah']
        surah_groups.setdefault(surah, []).append(verse)
        
    for surah, s_verses in surah_groups.items():
        # Format matching the requested schema:
        # {
        #   "ayahs": [
        #     {
        #       "surahNumber": 1,
        #       "ayahNumber": 2,
        #       "text": "[German Translation Text Here]",
        #       "translationKey": "bubenheim" // or "nadeem" or "aburida"
        #     }
        #   ]
        # }
        formatted_ayahs = []
        # Remove duplicate verses (sometimes Tanzil has duplicate lines due to minor parsing issues)
        seen_ayahs = set()
        for v in sorted(s_verses, key=lambda x: x['ayah']):
            if v['ayah'] in seen_ayahs:
                continue
            seen_ayahs.add(v['ayah'])
            formatted_ayahs.append({
                "surahNumber": v['surah'],
                "ayahNumber": v['ayah'],
                "text": v['text'],
                "translationKey": key
            })
            
        payload = {"ayahs": formatted_ayahs}
        
        file_path = os.path.join(folder_path, f"{surah}.json")
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(payload, f, ensure_ascii=False, indent=2)
            
    print(f"Saved {len(surah_groups)} surah JSON files for key '{key}' in '{folder_path}'")
    
    # Zip the folder
    zip_path = os.path.join(OUTPUT_DIR, f"{folder_name}.zip")
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(folder_path):
            for file in files:
                file_path = os.path.join(root, file)
                zipf.write(file_path, file)
                
    print(f"Compressed '{folder_name}' into '{zip_path}' (Size: {os.path.getsize(zip_path)} bytes)")

def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    for name, config in TRANSLATIONS.items():
        verses = download_and_parse(config["url"])
        if not verses:
            print(f"Failed to fetch {name}")
            continue
            
        # Save and ZIP
        save_translation_json(verses, config["key"], name)
    
if __name__ == "__main__":
    main()
