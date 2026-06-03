import os
import re
import json

# Target directories and files
LIB_DIR = "/home/yousuf/Documents/Personal Projects/equran_app/lib"
EN_ARB_PATH = os.path.join(LIB_DIR, "l10n", "app_en.arb")

# Regex to find Text('...') or Text("...") or Text(r'...')
# Also matching variations like const Text('...')
TEXT_WIDGET_REGEX = re.compile(r'\bText\(\s*r?([\'"])(.*?)\1\s*[,)]')
TEXT_WIDGET_CONST_REGEX = re.compile(r'\bconst\s+Text\(\s*r?([\'"])(.*?)\1\s*[,)]')
# Regex for child/title/subtitle/label/hintText/tooltip with hardcoded string
STRING_LITERAL_REGEX = re.compile(r'\b(?:title|subtitle|label|tooltip|hintText|labelText|content):\s*(?:const\s+)?(?:Text\(\s*)?r?([\'"])(.*?)\1')

# Emojis, symbols, empty strings, asset paths, routes, and simple codes to ignore
IGNORE_PATTERNS = [
    r'^[0-9\s:°•🎉✨]*$',  # numbers, spaces, punctuation, specific emojis/symbols
    r'^assets/.*',          # asset paths
    r'^/.*',                # routes
    r'^[a-z_]+$',           # lowecase identifiers/keys
]

def load_existing_keys():
    if not os.path.exists(EN_ARB_PATH):
        return {}
    with open(EN_ARB_PATH, 'r', encoding='utf-8') as f:
        try:
            return json.load(f)
        except Exception as e:
            print(f"Error reading ARB file: {e}")
            return {}

def should_ignore(s):
    if not s or s.strip() == "":
        return True
    for pattern in IGNORE_PATTERNS:
        if re.match(pattern, s):
            return True
    # If it is just a single character like '•' or '🎉'
    if len(s.strip()) <= 1:
        return True
    return False

def scan_files():
    existing_arb = load_existing_keys()
    existing_values = {v.lower().strip(): k for k, v in existing_arb.items() if isinstance(v, str)}

    results = []

    for root, dirs, files in os.walk(LIB_DIR):
        # Exclude l10n folder
        if "l10n" in root.split(os.sep):
            continue

        for file in files:
            if not file.endswith(".dart"):
                continue

            file_path = os.path.join(root, file)
            rel_path = os.path.relpath(file_path, LIB_DIR)

            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                lines = content.split('\n')

            # Scan line by line for simpler context reporting
            for idx, line in enumerate(lines):
                # Ignore comments
                if line.strip().startswith("//") or line.strip().startswith("/*"):
                    continue

                # Look for Text('...')
                for match in TEXT_WIDGET_REGEX.finditer(line):
                    val = match.group(2)
                    if not should_ignore(val):
                        # Check if this exact text exists in ARB
                        val_clean = val.strip().lower()
                        existing_key = existing_values.get(val_clean, None)
                        results.append({
                            "file": rel_path,
                            "line": idx + 1,
                            "match_type": "TextWidget",
                            "value": val,
                            "existing_key": existing_key
                        })

                # Look for named string arguments
                for match in STRING_LITERAL_REGEX.finditer(line):
                    val = match.group(2)
                    if not should_ignore(val):
                        val_clean = val.strip().lower()
                        existing_key = existing_values.get(val_clean, None)
                        results.append({
                            "file": rel_path,
                            "line": idx + 1,
                            "match_type": "StringProperty",
                            "value": val,
                            "existing_key": existing_key
                        })

    # Remove duplicates within the same line
    unique_results = []
    seen = set()
    for res in results:
        key = (res["file"], res["line"], res["value"])
        if key not in seen:
            seen.add(key)
            unique_results.append(res)

    return unique_results

if __name__ == "__main__":
    found_strings = scan_files()
    
    # Group by file
    grouped = {}
    for res in found_strings:
        file = res["file"]
        if file not in grouped:
            grouped[file] = []
        grouped[file].append(res)

    print(f"Total hardcoded strings found: {len(found_strings)}")
    print(f"Already in ARB: {len([r for r in found_strings if r['existing_key'] is not None])}")
    print(f"New strings to localize: {len([r for r in found_strings if r['existing_key'] is None])}\n")

    for file, res_list in sorted(grouped.items()):
        new_res = [r for r in res_list if r["existing_key"] is None]
        if new_res:
            print(f"=== {file} ({len(new_res)} new strings) ===")
            for r in new_res:
                print(f"  Line {r['line']}: {r['value']}")
            print()
