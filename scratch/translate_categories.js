const fs = require('fs');
const path = require('path');
const https = require('https');

const PROJECT_DIR = '/home/yousuf/Documents/Personal Projects/equran_app';
const INDEX_JSON_PATH = path.join(PROJECT_DIR, 'assets/data/dua/hisn/index.json');
const DART_OUTPUT_PATH = path.join(PROJECT_DIR, 'lib/duas/hisn_category_translations.dart');

const TARGET_LANGS = {
  'en': 'English',
  'id': 'Indonesian',
  'ur': 'Urdu',
  'tr': 'Turkish',
  'bn': 'Bengali'
};

const BATCH_SIZE = 10;

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function translateText(text, targetLang) {
  return new Promise((resolve, reject) => {
    // Source language is Arabic (sl=ar)
    const url = `https://translate.googleapis.com/translate_a/single?client=gtx&sl=ar&tl=${targetLang}&dt=t&q=${encodeURIComponent(text)}`;
    
    https.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          if (res.statusCode !== 200) {
            return reject(new Error(`Status ${res.statusCode}`));
          }
          const parsed = JSON.parse(data);
          if (!parsed || !parsed[0]) {
            return reject(new Error('Invalid response structure'));
          }
          const translatedText = parsed[0].map(item => item[0]).join('');
          resolve(translatedText.trim());
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

async function translateWithRetry(id, value, langCode, langName) {
  let success = false;
  let attempts = 0;
  let result = value;

  while (!success && attempts < 4) {
    try {
      result = await translateText(value, langCode);
      success = true;
    } catch (err) {
      attempts++;
      const waitTime = attempts * 1500;
      console.warn(`[WARN] Failed to translate ID ${id} ("${value}") to ${langName} (Attempt ${attempts}/4): ${err.message}. Retrying in ${waitTime}ms...`);
      await sleep(waitTime);
    }
  }

  return result;
}

async function main() {
  console.log(`Reading category index from: ${INDEX_JSON_PATH}...`);
  if (!fs.existsSync(INDEX_JSON_PATH)) {
    console.error(`Index file not found at ${INDEX_JSON_PATH}`);
    process.exit(1);
  }

  const rawIndex = fs.readFileSync(INDEX_JSON_PATH, 'utf8');
  const index = JSON.parse(rawIndex);
  console.log(`Found ${index.length} categories to translate.`);

  const translations = {};
  for (const langCode of Object.keys(TARGET_LANGS)) {
    translations[langCode] = {};
  }

  for (const langCode of Object.keys(TARGET_LANGS)) {
    const langName = TARGET_LANGS[langCode];
    console.log(`\n--- Translating to ${langName} (${langCode}) ---`);

    for (let i = 0; i < index.length; i += BATCH_SIZE) {
      const batch = index.slice(i, i + BATCH_SIZE);
      const promises = batch.map(category => {
        return translateWithRetry(category.id, category.title, langCode, langName).then(translated => {
          return { id: category.id, translated };
        });
      });

      const results = await Promise.all(promises);
      for (const res of results) {
        translations[langCode][res.id] = res.translated;
      }

      console.log(`Progress: ${Math.min(i + BATCH_SIZE, index.length)}/${index.length} categories translated.`);
      await sleep(300); // Friendly pause between batches to avoid IP blocks
    }
  }

  console.log(`\nGenerating Dart translation file at ${DART_OUTPUT_PATH}...`);

  let dartCode = `// GENERATED FILE - DO NOT EDIT MANUALLY
// Generated on ${new Date().toISOString()}

import 'package:flutter/material.dart';

const Map<String, Map<String, String>> hisnCategoryTranslations = {
`;

  for (const langCode of Object.keys(TARGET_LANGS)) {
    dartCode += `  '${langCode}': {\n`;
    for (const category of index) {
      const translated = translations[langCode][category.id]
        .replace(/'/g, "\\'")
        .replace(/"/g, '\\"');
      dartCode += `    '${category.id}': '${translated}',\n`;
    }
    dartCode += `  },\n`;
  }

  dartCode += `};

String getLocalizedCategoryTitle(BuildContext context, String id, String fallbackArabic) {
  final String languageCode = Localizations.localeOf(context).languageCode;
  return hisnCategoryTranslations[languageCode]?[id] ?? fallbackArabic;
}
`;

  fs.writeFileSync(DART_OUTPUT_PATH, dartCode, 'utf8');
  console.log('Dart translation map generated successfully!');
}

main().catch(err => {
  console.error('Fatal translation generation error:', err);
  process.exit(1);
});
