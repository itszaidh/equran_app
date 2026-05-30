import json
import os
import shutil

def shard_uthmani(source_json_path, uthmani_dir):
    # 1. Create/Ensure pristine directory layout
    os.makedirs(uthmani_dir, exist_ok=True)
    
    # 2. Clean and shard Uthmani raw JSON
    print("⚙️ Parsing and sharding Uthmani raw data...")
    if not os.path.exists(source_json_path):
        raise FileNotFoundError(f"Source JSON file not found at: {source_json_path}")
        
    with open(source_json_path, 'r', encoding='utf-8') as f:
        raw_data = json.load(f)
        
    surahs_list = raw_data.get('data', {}).get('surahs', [])
    if not surahs_list:
        surahs_list = raw_data.get('verses', raw_data.get('data', []))
        
    sharded_count = 0
    
    for surah in surahs_list:
        surah_num = int(surah.get('number', surah.get('surah_number', 0)))
        if surah_num == 0:
            continue
            
        ayahs = surah.get('ayahs', [])
        clean_ayahs = []
        
        for ayah in ayahs:
            verse_text = ayah.get('text', '').strip()
            # Strip BOM (Byte Order Mark) if present (e.g. \ufeff)
            if verse_text.startswith('\ufeff'):
                verse_text = verse_text.replace('\ufeff', '')
            # Replace soft-hyphens or other unnecessary control chars if any
            verse_text = verse_text.strip()
                
            clean_ayahs.append({
                "surah": surah_num,
                "ayah": int(ayah.get('numberInSurah', ayah.get('verse_number', 0))),
                "text": verse_text
            })
            
        output_file_path = os.path.join(uthmani_dir, f"{surah_num}.json")
        with open(output_file_path, 'w', encoding='utf-8') as out_f:
            json.dump({"ayahs": clean_ayahs}, out_f, ensure_ascii=True, indent=2)
        sharded_count += 1
            
    print(f"🚀 Sharding Complete: {sharded_count} streamlined Uthmani JSON blocks written successfully.")

if __name__ == '__main__':
    source_json = '/home/yousuf/Documents/Personal Projects/equran-app/assets/data/quran/text/quran-uthmani.json'
    uthmani_directory = '/home/yousuf/Documents/Personal Projects/equran-app/assets/data/quran/text/uthmani'
    shard_uthmani(source_json, uthmani_directory)
