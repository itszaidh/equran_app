import os
import json

L10N_DIR = "/home/yousuf/Documents/Personal Projects/equran_app/lib/l10n"

SELECT_CURRENCIES = {
  "en": {
    "selectCurrency": "Select Currency"
  },
  "ar": {
    "selectCurrency": "اختر العملة"
  },
  "bn": {
    "selectCurrency": "মুদ্রা নির্বাচন করুন"
  },
  "id": {
    "selectCurrency": "Pilih Mata Uang"
  },
  "tr": {
    "selectCurrency": "Para Birimi Seç"
  },
  "ur": {
    "selectCurrency": "کرنسی منتخب کریں"
  }
}

def update_arb_file(lang, new_kv):
    file_path = os.path.join(L10N_DIR, f"app_{lang}.arb")
    if not os.path.exists(file_path):
        print(f"ARB file not found: {file_path}")
        return

    with open(file_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    # Merge new key-values
    for k, v in new_kv.items():
        data[k] = v

    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Updated {file_path}")

if __name__ == "__main__":
    for lang, kv in SELECT_CURRENCIES.items():
        update_arb_file(lang, kv)
