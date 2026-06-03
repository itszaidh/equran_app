import re
from deep_translator import GoogleTranslator

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

translator = GoogleTranslator(source='en', target='de')
print("Download {name}?:", translate_with_protection("Download {name}?", translator))
print("deleteAllDownloadsBody:", translate_with_protection("This will remove {count} downloaded audio files ({size}).", translator))
