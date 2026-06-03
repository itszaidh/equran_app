from deep_translator import GoogleTranslator

translator = GoogleTranslator(source='en', target='de')
print("Download {name}?:", translator.translate("Download {name}?"))
print("surahCount:", translator.translate("{count, plural, =1{1 surah} other{{count} surahs}}"))
print("deleteAllDownloadsBody:", translator.translate("This will remove {count} downloaded audio files ({size})."))
