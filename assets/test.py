#!/usr/bin/env python3
import argparse
import json
from pathlib import Path
from collections import defaultdict


def split_quran_json(input_file: Path, output_dir: Path) -> None:
    with input_file.open("r", encoding="utf-8") as f:
        data = json.load(f)

    surahs: dict[int, list[dict]] = defaultdict(list)

    for key, text in data.items():
        try:
            surah_str, ayah_str = key.split(":", 1)
            surah = int(surah_str)
            ayah = int(ayah_str)
        except ValueError:
            print(f"Skipping invalid key: {key}")
            continue

        surahs[surah].append({
            "surah": surah,
            "ayah": ayah,
            "text": text,
        })

    output_dir.mkdir(parents=True, exist_ok=True)

    for surah, ayahs in surahs.items():
        ayahs.sort(key=lambda item: item["ayah"])

        output_data = {
            "ayahs": ayahs
        }

        output_file = output_dir / f"{surah}.json"

        with output_file.open("w", encoding="utf-8") as f:
            json.dump(output_data, f, ensure_ascii=False, indent=2)

        print(f"Wrote {output_file}")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Split Quran JSON keyed as x:y into separate surah JSON files."
    )
    parser.add_argument("input", help="Input JSON file")
    parser.add_argument("output_dir", help="Output folder")

    args = parser.parse_args()

    split_quran_json(
        input_file=Path(args.input),
        output_dir=Path(args.output_dir),
    )


if __name__ == "__main__":
    main()
