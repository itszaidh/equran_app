from deep_translator import GoogleTranslator

translated = GoogleTranslator(source='en', target='de').translate("Settings")
print(f"Translated 'Settings' -> '{translated}'")
