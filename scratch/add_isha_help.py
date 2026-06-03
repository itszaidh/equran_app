import json
import os

key = "latestIshaTimeHelp"
translations = {
    "en": "Use calculated Isha, but do not allow it later than {time}.",
    "ar": "استخدم وقت العشاء المحسوب، ولكن لا تسمح به بعد {time}.",
    "bn": "হিসাবকৃত এশা ব্যবহার করুন, তবে {time} এর পরে অনুমতি দেবেন না।",
    "id": "Gunakan waktu Isya yang dihitung, tetapi jangan biarkan lebih lambat dari {time}.",
    "tr": "Hesaplanan Yatsı vaktini kullanın, ancak {time} vaktinden sonrasına izin vermeyin.",
    "ur": "عشاء کے حساب شدہ وقت کا استعمال کریں، لیکن اسے {time} سے بعد کی اجازت نہ دیں۔"
}

l10n_dir = "lib/l10n"
for lang, text in translations.items():
    file_path = os.path.join(l10n_dir, f"app_{lang}.arb")
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Insert key
        data[key] = text
        # Add metadata for placeholder in en
        if lang == "en":
            data[f"@{key}"] = {
                "placeholders": {
                    "time": {
                        "type": "String"
                    }
                }
            }
        
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"Added latestIshaTimeHelp to {file_path}")
