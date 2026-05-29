#!/usr/bin/env python3
"""
High-quality Arabic-to-Latin transliteration for dua texts.
Uses diacritics to produce accurate phonetic transliteration.
"""

import json
import glob
import os
import re

# Define vowel diacritics (Unicode combining marks)
FATHA = 'َ'       # a
DAMMA = 'ُ'       # u
KASRA = 'ِ'       # i
SUKUN = 'ْ'       # silent (no vowel)
SHADDA = 'ّ'      # gemination (double consonant)
FATHATAN = 'ً'    # an
DAMMATAN = 'ٌ'    # un
KASRATAN = 'ٍ'    # in

# Alif variants
ALIF = 'ا'
ALIF_HAMZA_TOP = 'أ'    # hamza on alif
ALIF_HAMZA_BELOW = 'إ'  # hamza below alif
WAW_HAMZA = 'ؤ'
YA_HAMZA = 'ئ'
HAMZA = 'ء'

# Consonant base characters (with their default transliteration)
CONSONANTS = {
    'ب': 'b',   # ba
    'ت': 't',   # ta
    'ث': 'th',  # tha
    'ج': 'j',   # jim
    'ح': 'h',   # Ha -> h
    'خ': 'kh',  # kha
    'د': 'd',   # dal
    'ذ': 'dh',  # dhal
    'ر': 'r',   # ra
    'ز': 'z',   # zay
    'س': 's',   # sin
    'ش': 'sh',  # shin
    'ص': 's',   # Sad -> s
    'ض': 'd',   # Dad -> d
    'ط': 't',   # Ta -> t
    'ظ': 'z',   # Dha -> z
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
}

# Alif can be:
# - a carrier for hamza -> hamza sound + vowel
# - a long vowel 'a' when it follows a fatha
# - a glottal stop at word start

def transliterate_arabic(text: str) -> str:
    """
    Transliterate Arabic text using diacritics.
    Handles complex combinations like alif-lam, hamza variants, shadda, etc.
    """
    if not text:
        return ''

    has_braces = '{' in text or '}' in text
    clean_text = text.replace('{', '').replace('}', '')

    result = []
    chars = list(clean_text)
    i = 0
    prev_was_vowel = False
    prev_consonant = None

    while i < len(chars):
        ch = chars[i]

        # Skip tatweel and zero-width chars
        if ch in ('ـ', '‌', '‍', '⁠'):
            i += 1
            continue

        # Skip spaces and punctuation
        if ch in ' \t\n':
            if result and result[-1] != ' ':
                result.append(' ')
            prev_was_vowel = False
            prev_consonant = None
            i += 1
            continue

        if ch in '.,;:!?()[]""''/\-*':
            result.append(ch)
            prev_was_vowel = False
            prev_consonant = None
            i += 1
            continue

        # Collect all diacritics attached to this base character
        base = ch
        diacritics = []
        j = i + 1
        while j < len(chars) and is_diacritic(chars[j]):
            diacritics.append(chars[j])
            j += 1

        # Get the vowel from diacritics
        vowel = None
        has_shadda = False
        for d in diacritics:
            if d == FATHA:
                vowel = 'a'
            elif d == DAMMA:
                vowel = 'u'
            elif d == KASRA:
                vowel = 'i'
            elif d == FATHATAN:
                vowel = 'an'
            elif d == DAMMATAN:
                vowel = 'un'
            elif d == KASRATAN:
                vowel = 'in'
            elif d == SHADDA:
                has_shadda = True
            # sukun means no vowel

        # Now process the base character
        if base == ALIF:
            # Alif is tricky:
            # - If it has fatha, it's a glottal stop + a
            # - If it follows a fatha on prev char, it's a long 'a'
            # - At word start, it might just be a carrier
            if vowel:
                if vowel == 'a':
                    result.append("'a")
                elif vowel == 'u':
                    result.append("'u")
                elif vowel == 'i':
                    result.append("'i")
                else:
                    result.append("'" + vowel)
            elif prev_was_vowel:
                # Long vowel a (alif madda or just long)
                result.append('a')
            else:
                # Bare alif - at word start, might be hamza carrier
                result.append("'")
            prev_was_vowel = bool(vowel)
            prev_consonant = None

        elif base == ALIF_HAMZA_TOP:
            # Hamza on alif + vowel
            if vowel == 'a':
                result.append("'a")
            elif vowel == 'u':
                result.append("'u")
            elif vowel == 'i':
                result.append("'i")
            else:
                result.append("'")
            prev_was_vowel = True
            prev_consonant = None

        elif base == ALIF_HAMZA_BELOW:
            if vowel == 'a':
                result.append("'a")
            elif vowel == 'i':
                result.append("'i")
            else:
                result.append("'i")  # default for hamza below
            prev_was_vowel = True
            prev_consonant = None

        elif base == WAW_HAMZA:
            result.append("'u")
            prev_was_vowel = True
            prev_consonant = None

        elif base == YA_HAMZA:
            result.append("'i")
            prev_was_vowel = True
            prev_consonant = None

        elif base == HAMZA:
            if vowel == 'a':
                result.append("'a")
            elif vowel == 'u':
                result.append("'u")
            elif vowel == 'i':
                result.append("'i")
            else:
                result.append("'")
            prev_was_vowel = True
            prev_consonant = None

        elif base == 'ة':  # ta marbuta
            # Usually pronounced 'ah' at end of word
            if vowel:
                result.append('t' + vowel)
            else:
                # Check if next significant char is a space/punctuation (end of word)
                next_significant = None
                for k in range(j, len(chars)):
                    if chars[k] not in ('ـ', '‌', '‍', '⁠') and not is_diacritic(chars[k]):
                        next_significant = chars[k]
                        break
                if next_significant in (' ', ')', '}', ',', '.', ';', '!', '?', None):
                    result.append('ah')
                else:
                    result.append('t')
            prev_was_vowel = True
            prev_consonant = None

        elif base == 'ى':  # alif maksura
            if vowel:
                result.append('y' + vowel)
            else:
                result.append('a')
            prev_was_vowel = True
            prev_consonant = None

        elif base in CONSONANTS:
            consonant = CONSONANTS[base]

            # Special: detect al- (definite article)
            # Pattern: alif + lam at word start
            if consonant == 'l' and len(result) > 0 and result[-1] == 'a' and result[-2] == "'":
                # We have 'al so far, make it "al-"
                result[-1] = 'al'
                result.append('-')
                # Sun letter assimilation: check if next consonant is a sun letter
                # (t, th, d, dh, r, z, s, sh, S, D, T, Z, l, n)
                next_base = None
                for k in range(j, len(chars)):
                    if not is_diacritic(chars[k]):
                        next_base = chars[k]
                        break
                if next_base in ('ت', 'ث', 'د', 'ذ', 'ر', 'ز',
                                 'س', 'ش', 'ص', 'ض', 'ط', 'ظ',
                                 'ل', 'ن'):
                    # Sun letter - assimilate: al-s -> as-s
                    sun_consonant = CONSONANTS.get(next_base, '')
                    result.pop()  # remove -
                    result.append(sun_consonant)
                    result.append('-')
                prev_was_vowel = False
                prev_consonant = 'l'
                i = j
                continue

            # Add shadda (gemination)
            if has_shadda:
                result.append(consonant)

            result.append(consonant)

            # Add vowel
            if vowel:
                result.append(vowel)
                prev_was_vowel = True
            else:
                prev_was_vowel = False

            prev_consonant = consonant

        elif base == 'و':  # standalone waw
            if vowel:
                if vowel == 'a':
                    result.append('w')
                else:
                    result.append('w' + vowel)
            else:
                # Long vowel 'u' or consonant 'w'
                if prev_was_vowel:
                    result.append('u')
                else:
                    result.append('w')
            prev_was_vowel = bool(vowel or prev_was_vowel)
            prev_consonant = None

        elif base == 'ي':  # standalone ya
            if vowel:
                result.append('y' + vowel)
            else:
                if prev_was_vowel:
                    result.append('i')
                else:
                    result.append('y')
            prev_was_vowel = bool(vowel or prev_was_vowel)
            prev_consonant = None

        # Unknown character - skip
        i = j

    # Join and clean up
    translit = ''.join(result)

    # Remove extra spaces
    translit = re.sub(r' +', ' ', translit)
    translit = translit.strip()

    # Post-processing fixes
    translit = translit.replace("'a'", "'")  # fix doubled hamza
    translit = translit.replace("'i'", "'")
    translit = translit.replace("'u'", "'")

    # Remove trailing apostrophe
    translit = translit.rstrip("'")

    # Capitalize first letter
    if translit:
        translit = translit[0].upper() + translit[1:]

    # Add braces back for Quran verses
    if has_braces:
        translit = '{' + translit + '}'

    return translit


def is_diacritic(ch: str) -> bool:
    """Check if character is an Arabic diacritic."""
    return ch in (FATHA, DAMMA, KASRA, SUKUN, SHADDA, FATHATAN, DAMMATAN, KASRATAN)


def process_file(path: str):
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    texts = data.get('text', [])
    modified = False

    for item in texts:
        if isinstance(item, dict):
            arabic = item.get('text', '')
            if arabic and arabic.strip():
                new_translit = transliterate_arabic(arabic.strip())
                if new_translit and new_translit != item.get('transliteration', ''):
                    item['transliteration'] = new_translit
                    modified = True

    if modified:
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        return True
    return False


def main():
    categories_dir = os.path.join(
        os.path.dirname(__file__), '..',
        'assets', 'data', 'dua', 'hisn', 'categories'
    )
    categories_dir = os.path.abspath(categories_dir)

    files = sorted(glob.glob(os.path.join(categories_dir, '*.json')))
    updated = 0

    for path in files:
        if process_file(path):
            updated += 1
            print(f"Updated {os.path.basename(path)}")

    print(f"\nUpdated {updated}/{len(files)} files")


if __name__ == '__main__':
    main()
