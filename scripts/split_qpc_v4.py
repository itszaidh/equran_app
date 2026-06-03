import json
import os

def main():
    input_file = '/home/yousuf/Documents/Personal Projects/equran_app/assets/data/quran/text/qpc-v4.json'
    output_dir = '/home/yousuf/Documents/Personal Projects/equran_app/assets/data/quran/text/qpc-v4'
    
    print(f"Loading {input_file}...")
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    print("Grouping words by surah and ayah...")
    # Group by surah -> ayah -> word_number -> text
    grouped = {}
    for key, val in data.items():
        surah = int(val['surah'])
        ayah = int(val['ayah'])
        word = int(val['word'])
        text = val['text']
        
        if surah not in grouped:
            grouped[surah] = {}
        if ayah not in grouped[surah]:
            grouped[surah][ayah] = {}
        grouped[surah][ayah][word] = text
        
    print(f"Creating output directory: {output_dir}")
    os.makedirs(output_dir, exist_ok=True)
    
    print("Writing files...")
    for surah in range(1, 115):
        if surah not in grouped:
            print(f"Warning: Surah {surah} not found in dataset!")
            continue
            
        ayahs_list = []
        # Sort ayahs numerically
        sorted_ayahs = sorted(grouped[surah].keys())
        for ayah in sorted_ayahs:
            # Sort words of the ayah numerically
            sorted_words = sorted(grouped[surah][ayah].keys())
            words_text = [grouped[surah][ayah][w] for w in sorted_words]
            ayah_text = " ".join(words_text)
            
            ayahs_list.append({
                "surah": surah,
                "ayah": ayah,
                "text": ayah_text
            })
            
        output_file = os.path.join(output_dir, f"{surah}.json")
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump({"ayahs": ayahs_list}, f, ensure_ascii=False, indent=2)
            
    print("Transformation completed successfully!")

if __name__ == "__main__":
    main()
