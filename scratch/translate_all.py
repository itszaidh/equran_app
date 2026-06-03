import json
import os
import re
import time
from deep_translator import GoogleTranslator

# 8 plural keys with manual high-quality German translations
PLURAL_TRANSLATIONS = {
    "surahCount": "{count, plural, =1{1 Sure} other{{count} Suren}}",
    "searchResultCount": "{count, plural, =1{1 Ergebnis} other{{count} Ergebnisse}}",
    "dayStreakCount": "{count, plural, =1{1-Tage-Serie} other{{count}-Tage-Serie}}",
    "ayahsCount": "{count, plural, =1{1 Ayah} other{{count} Ayahs}}",
    "daysCount": "{count, plural, =1{1 Tag} other{{count} Tage}}",
    "secondsCount": "{count, plural, =1{1 Sekunde} other{{count} Sekunden}}",
    "sleepingInMinutes": "Einschlafen in {minutes, plural, =1{1 Minute} other{{minutes} Minuten}}",
    "activeDaysCount": "{count, plural, =1{1 aktiver Tag} other{{count} aktive Tage}}",
}

CACHE_FILE = "scratch/translation_cache.json"

def load_cache():
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception:
            return {}
    return {}

def save_cache(cache):
    with open(CACHE_FILE, 'w', encoding='utf-8') as f:
        json.dump(cache, f, ensure_ascii=False, indent=2)

def translate_with_protection(text, translator):
    # Find all matches of {...}
    placeholders = re.findall(r'\{[a-zA-Z0-9_]+\}', text)
    protected_text = text
    mapping = {}
    for i, p in enumerate(placeholders):
        token = f"XYZ{i}XYZ"
        mapping[token] = p
        protected_text = protected_text.replace(p, token)
        
    translated = translator.translate(protected_text)
    
    for token, original in mapping.items():
        num = token.replace("XYZ", "")
        pattern = re.compile(rf'X\s*Y\s*Z\s*{num}\s*X\s*Y\s*Z', re.IGNORECASE)
        translated = pattern.sub(original, translated)
        
    return translated

def main():
    with open('lib/l10n/app_en.arb', 'r', encoding='utf-8') as f:
        en_data = json.load(f)

    # Add 'german' key to English data so it gets translated as well
    if 'german' not in en_data:
        en_data['german'] = 'German'
        # Add metadata for German key
        en_data['@german'] = {}

    cache = load_cache()
    translator = GoogleTranslator(source='en', target='de')
    
    de_data = {}
    
    # We want to preserve the order of keys as in app_en.arb
    total_keys = len(en_data)
    processed = 0
    
    print(f"Starting translation of {total_keys} keys...")
    
    for key, value in en_data.items():
        processed += 1
        
        # 1. Casing of locale key
        if key == "@@locale":
            de_data[key] = "de"
            continue
            
        # 2. Metadata keys (starts with @)
        if key.startswith('@'):
            de_data[key] = value
            continue
            
        # 3. Predefined Plural keys
        if key in PLURAL_TRANSLATIONS:
            de_data[key] = PLURAL_TRANSLATIONS[key]
            continue
            
        # Check cache first
        if key in cache:
            de_data[key] = cache[key]
            continue
            
        # 4. Standard strings
        success = False
        attempts = 0
        translated_value = ""
        while not success and attempts < 5:
            try:
                translated_value = translate_with_protection(value, translator)
                success = True
            except Exception as e:
                attempts += 1
                print(f"Error translating '{key}': {e}. Retrying ({attempts}/5)...")
                time.sleep(2)
                
        if not success:
            print(f"Failed to translate key '{key}'. Using English fallback.")
            translated_value = value
            
        de_data[key] = translated_value
        cache[key] = translated_value
        
        # Save cache every 20 keys
        if processed % 20 == 0:
            save_cache(cache)
            print(f"Progress: {processed}/{total_keys} keys processed.")
            
        # Sleep to avoid rate limiting
        time.sleep(0.15)
        
    save_cache(cache)
    
    # Save target file
    with open('lib/l10n/app_de.arb', 'w', encoding='utf-8') as f:
        json.dump(de_data, f, ensure_ascii=False, indent=2)
        
    print("Translation completed successfully!")

if __name__ == "__main__":
    main()
