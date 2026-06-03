import json

with open('lib/l10n/app_en.arb', 'r', encoding='utf-8') as f:
    data = json.load(f)

translatable_keys = [k for k in data.keys() if not k.startswith('@')]
metadata_keys = [k for k in data.keys() if k.startswith('@')]

print(f"Total keys: {len(data)}")
print(f"Translatable keys: {len(translatable_keys)}")
print(f"Metadata (@) keys: {len(metadata_keys)}")
