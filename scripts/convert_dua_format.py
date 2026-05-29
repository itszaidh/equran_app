#!/usr/bin/env python3
"""
Convert Hisn al-Muslim dua category JSON files to add transliteration
and translation fields to each dua item.

Converts:
  { "id": "004", "title": "...", "text": ["arabic1"], "footnote": ["ref1"] }

To:
  {
    "id": "004",
    "title": "...",
    "text": [
      {
        "text": "arabic1",
        "transliteration": "...",
        "translation": "...",
        "translations": {
          "en": "...",
          "bn": "...",
          "id": "...",
          "tr": "...",
          "ur": "..."
        },
        "reference": "ref1"
      }
    ],
    "footnote": ["ref1"]
  }

The existing repository parser (_parseDua) already supports objects
inside the text array, reading keys: text, transliteration, translation,
translations, reference, count, notes, source.
"""

import json
import glob
import os

# Mapping for basic Arabic-to-Latin transliteration
ARABIC_TO_LATIN = {
    # Letters
    'ا': 'a',   # alif
    'ب': 'b',   # ba
    'ت': 't',   # ta
    'ث': 'th',  # tha
    'ج': 'j',   # jim
    'ح': 'H',   # Ha
    'خ': 'kh',  # kha
    'د': 'd',   # dal
    'ذ': 'dh',  # dhal
    'ر': 'r',   # ra
    'ز': 'z',   # zay
    'س': 's',   # sin
    'ش': 'sh',  # shin
    'ص': 'S',   # Sad
    'ض': 'D',   # Dad
    'ط': 'T',   # Ta
    'ظ': 'Z',   # Dha
    'ع': "'",   # ayn
    'غ': 'gh',  # ghayn
    'ف': 'f',   # fa
    'ق': 'q',   # qaf
    'ك': 'k',   # kaf
    'ل': 'l',   # lam
    'م': 'm',   # mim
    'ن': 'n',   # nun
    'ه': 'h',   # ha
    'و': 'w',   # waw
    'ي': 'y',   # ya
    'ء': "'",   # hamza
    'أ': "'",   # hamza on alif
    'إ': "'",   # hamza below alif
    'ؤ': "'",   # hamza on waw
    'ئ': "'",   # hamza on ya
    'ى': 'a',   # alif maksura
    'ة': 'ah',  # ta marbuta
    # Vowels/diacritics
    'َ': 'a',   # fatha
    'ُ': 'u',   # damma
    'ِ': 'i',   # kasra
    'ً': 'an',  # fathatan
    'ٌ': 'un',  # dammatan
    'ٍ': 'in',  # kasratan
    'ْ': '',    # sukun
    'ّ': '',    # shadda (doubling handled separately)
}


def transliterate_arabic(text: str) -> str:
    """Generate basic Latin transliteration from Arabic text."""
    result = []
    prev_char = None

    for ch in text:
        if ch == ' ':
            result.append(' ')
            prev_char = None
        elif ch in '.,;:!?()[]{}""\'"':
            result.append(ch)
            prev_char = None
        elif ch == 'ـ':  # tatweel - skip
            continue
        elif ch == 'ّ':  # shadda - double previous consonant
            if result and result[-1] != ' ':
                result.append(result[-1])
        elif ch in ARABIC_TO_LATIN:
            val = ARABIC_TO_LATIN[ch]
            result.append(val)
            prev_char = ch
        else:
            # Skip unknown characters
            pass

    # Join and post-process
    translit = ''.join(result)

    # Common replacements
    translit = translit.replace(' a', 'a')
    translit = translit.replace(' u', 'u')
    translit = translit.replace(' i', 'i')

    # Capitalize first letter of each sentence/word appropriately
    # Simple: just ensure it starts with uppercase
    if translit:
        translit = translit[0].upper() + translit[1:]

    return translit.strip()


def convert_file(path: str) -> dict:
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    texts = data.get('text', [])
    if isinstance(texts, str):
        texts = [texts]

    footnotes = data.get('footnote', [])
    if isinstance(footnotes, str):
        footnotes = [footnotes]

    new_texts = []
    for i, item in enumerate(texts):
        if isinstance(item, dict):
            # Already an object - skip or extend
            new_texts.append(item)
            continue

        arabic = item
        reference = footnotes[i] if i < len(footnotes) else None

        # Generate transliteration
        translit = transliterate_arabic(arabic)

        # Create the structured dua object
        dua_obj = {
            'text': arabic,
            'transliteration': translit,
            'translation': '',  # Placeholder - to be filled
            'translations': {
                'en': '',
                'bn': '',
                'id': '',
                'tr': '',
                'ur': '',
            },
        }
        if reference:
            dua_obj['reference'] = reference

        new_texts.append(dua_obj)

    # Update data
    data['text'] = new_texts
    return data


def main():
    categories_dir = os.path.join(
        os.path.dirname(__file__), '..',
        'assets', 'data', 'dua', 'hisn', 'categories'
    )
    categories_dir = os.path.abspath(categories_dir)

    files = sorted(glob.glob(os.path.join(categories_dir, '*.json')))
    print(f"Found {len(files)} category files")

    total_duas = 0
    for path in files:
        new_data = convert_file(path)
        total_duas += len(new_data['text'])

        with open(path, 'w', encoding='utf-8') as f:
            json.dump(new_data, f, ensure_ascii=False, indent=2)

        print(f"Converted {os.path.basename(path)}: {len(new_data['text'])} duas")

    print(f"\nTotal duas converted: {total_duas}")


if __name__ == '__main__':
    main()
