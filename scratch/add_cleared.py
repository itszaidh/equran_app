import json
import os

key = "locationCleared"
translations = {
    "en": "Location cleared.",
    "ar": "تم مسح الموقع.",
    "bn": "অবস্থান সাফ করা হয়েছে।",
    "id": "Lokasi dibersihkan.",
    "tr": "Konum temizlendi.",
    "ur": "مقام صاف کر دیا گیا۔"
}

l10n_dir = "lib/l10n"
for lang, text in translations.items():
    file_path = os.path.join(l10n_dir, f"app_{lang}.arb")
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Insert key
        data[key] = text
        
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"Added locationCleared to {file_path}")
