import json
import os
import shutil

def migrate_uthmani_and_shard_indopak(source_json_path, text_dir):
    uthmani_dir = os.path.join(text_dir, 'uthmani')
    indopak_dir = os.path.join(text_dir, 'indopak')
    
    # 1. Create pristine directory layout
    os.makedirs(uthmani_dir, exist_ok=True)
    os.makedirs(indopak_dir, exist_ok=True)
    
    # 2. Migrate existing Uthmani JSON files to the uthmani subfolder
    print("📦 Migrating Uthmani JSON files...")
    migrated_count = 0
    for i in range(1, 115):
        old_path = os.path.join(text_dir, f"{i}.json")
        new_path = os.path.join(uthmani_dir, f"{i}.json")
        if os.path.exists(old_path):
            shutil.copy2(old_path, new_path)
            os.remove(old_path)
            migrated_count += 1
    print(f"✅ Migrated {migrated_count} Uthmani JSON files successfully.")
    
    # 3. Clean and shard IndoPak raw JSON
    print("⚙️ Parsing and sharding IndoPak raw data...")
    if not os.path.exists(source_json_path):
        raise FileNotFoundError(f"Source JSON file not found at: {source_json_path}")
        
    with open(source_json_path, 'r', encoding='utf-8') as f:
        raw_data = json.load(f)
        
    surahs_list = raw_data.get('data', {}).get('surahs', [])
    if not surahs_list:
        # Fallback if standard structure is flat or under "verses"
        surahs_list = raw_data.get('verses', raw_data.get('data', []))
        
    sharded_count = 0
    
    for surah in surahs_list:
        surah_num = int(surah.get('number', surah.get('surah_number', 0)))
        if surah_num == 0:
            continue
            
        ayahs = surah.get('ayahs', [])
        clean_ayahs = []
        
        for ayah in ayahs:
            verse_text = ayah.get('text', ayah.get('text_indopak', '')).strip()
            # Strip BOM (Byte Order Mark) if present (e.g. \ufeff)
            if verse_text.startswith('\ufeff'):
                verse_text = verse_text.replace('\ufeff', '')
                
            clean_ayahs.append({
                "surah": surah_num,
                "ayah": int(ayah.get('numberInSurah', ayah.get('verse_number', 0))),
                "text": verse_text
            })
            
        output_file_path = os.path.join(indopak_dir, f"{surah_num}.json")
        with open(output_file_path, 'w', encoding='utf-8') as out_f:
            json.dump({"ayahs": clean_ayahs}, out_f, ensure_ascii=False, indent=2)
        sharded_count += 1
            
    print(f"🚀 Sharding Complete: {sharded_count} streamlined IndoPak JSON blocks written successfully.")

if __name__ == '__main__':
    source_json = '/home/yousuf/Documents/Personal Projects/equran-app/assets/data/quran/quran-indopak.json'
    text_directory = '/home/yousuf/Documents/Personal Projects/equran-app/assets/data/quran/text'
    migrate_uthmani_and_shard_indopak(source_json, text_directory)
