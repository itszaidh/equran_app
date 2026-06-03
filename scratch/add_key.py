import json
import os

key = "highLatitudeMosqueNotice"
translations = {
    "en": "Some high-latitude mosque timetables use fixed or capped Isha times during summer.",
    "ar": "تستخدم بعض جداول المساجد في خطوط العرض العليا أوقات عشاء ثابتة أو محددة خلال فصل الصيف.",
    "bn": "কিছু উচ্চ-অক্ষাংশ মসজিদের সময়সূচী গ্রীষ্মকালে নির্দিষ্ট বা ক্যাপড এশার সময় ব্যবহার করে।",
    "id": "Beberapa jadwal masjid di lintang tinggi menggunakan waktu Isya yang tetap atau dibatasi selama musim panas.",
    "tr": "Bazı yüksek enlem cami takvimleri yaz aylarında sabit veya sınırlı Yatsı vakitleri kullanır.",
    "ur": "کچھ اونچے عرض بلد والے مسجد کے ٹائم ٹیبل گرمیوں کے دوران عشاء کے مقررہ یا محدود اوقات استعمال کرتے ہیں۔"
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
        print(f"Added key to {file_path}")
