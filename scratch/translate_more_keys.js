const fs = require('fs');
const path = require('path');
const https = require('https');

const OUTPUT_DIR = '/home/yousuf/Documents/Personal Projects/equran_app/lib/l10n';

const NEW_KEYS = {
  "chooseLocationManually": "Choose location manually",
  "saveLocation": "Save location",
  "coordinatesForPrayerTimes": "Coordinates for prayer times",
  "manualLocationDescription": "Enter the latitude and longitude for the city, area, or address you want to use.",
  "manualLocationPrivacyNotice": "Saved on this device and used only for local prayer-time calculation.",
  "manualLocation": "Manual location",
  "savedLocation": "Saved location",
  "useThisLocation": "Use this location",
  "selectedLocation": "Selected location",
  "openStreetMapContributors": "OpenStreetMap contributors",
  "validationEnterField": "Enter {field}.",
  "validationShouldBeNumber": "{field} should be a number.",
  "validationMustBeBetween": "{field} must be between {min} and {max}."
};

const NEW_METADATA_KEYS = {
  "@validationEnterField": {
    "placeholders": {
      "field": {
        "type": "String"
      }
    }
  },
  "@validationShouldBeNumber": {
    "placeholders": {
      "field": {
        "type": "String"
      }
    }
  },
  "@validationMustBeBetween": {
    "placeholders": {
      "field": {
        "type": "String"
      },
      "min": {
        "type": "String"
      },
      "max": {
        "type": "String"
      }
    }
  }
};

const TARGET_LANGS = {
  'ar': 'Arabic',
  'id': 'Indonesian',
  'ur': 'Urdu',
  'tr': 'Turkish',
  'bn': 'Bengali'
};

const BATCH_SIZE = 15;

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function translateText(text, targetLang) {
  return new Promise((resolve, reject) => {
    const placeholders = [];
    const processedText = text.replace(/\{([^}]+)\}/g, (match) => {
      placeholders.push(match);
      return `__TOKEN_${placeholders.length - 1}__`;
    });

    const url = `https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=${targetLang}&dt=t&q=${encodeURIComponent(processedText)}`;
    
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
          let translatedText = parsed[0].map(item => item[0]).join('');
          
          for (let i = 0; i < placeholders.length; i++) {
            const tokenRegex = new RegExp(`__\\s*TOKEN\\s*_${i}\\s*__`, 'gi');
            translatedText = translatedText.replace(tokenRegex, placeholders[i]);
          }
          resolve(translatedText);
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

async function translateWithRetry(key, value, langCode, langName) {
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
      console.warn(`[WARN] Failed to translate "${key}" to ${langName} (Attempt ${attempts}/4): ${err.message}. Retrying in ${waitTime}ms...`);
      await sleep(waitTime);
    }
  }

  return result;
}

async function main() {
  // Update English file directly with new keys
  const enPath = path.join(OUTPUT_DIR, 'app_en.arb');
  console.log(`Updating English file: ${enPath}...`);
  const enContent = JSON.parse(fs.readFileSync(enPath, 'utf8'));

  for (const [key, value] of Object.entries(NEW_KEYS)) {
    enContent[key] = value;
  }
  for (const [key, value] of Object.entries(NEW_METADATA_KEYS)) {
    enContent[key] = value;
  }

  fs.writeFileSync(enPath, JSON.stringify(enContent, null, 2), 'utf8');
  console.log('Successfully updated English file.');

  // For other languages, translate and merge
  const translatableEntries = Object.entries(NEW_KEYS);

  for (const [langCode, langName] of Object.entries(TARGET_LANGS)) {
    console.log(`\n--- Starting incremental translations for ${langName} (${langCode}) ---`);
    const langPath = path.join(OUTPUT_DIR, `app_${langCode}.arb`);
    if (!fs.existsSync(langPath)) {
      console.error(`File not found: ${langPath}`);
      continue;
    }

    const langContent = JSON.parse(fs.readFileSync(langPath, 'utf8'));
    const translatedKeys = {};

    for (let i = 0; i < translatableEntries.length; i += BATCH_SIZE) {
      const batch = translatableEntries.slice(i, i + BATCH_SIZE);
      const promises = batch.map(([key, value]) => {
        return translateWithRetry(key, value, langCode, langName).then(translated => {
          return { key, translated };
        });
      });

      const results = await Promise.all(promises);
      for (const res of results) {
        translatedKeys[res.key] = res.translated;
      }

      console.log(`Processed ${Math.min(i + BATCH_SIZE, translatableEntries.length)}/${translatableEntries.length} keys for ${langName}...`);
      await sleep(250);
    }

    // Merge into original content
    for (const [key, value] of Object.entries(translatedKeys)) {
      langContent[key] = value;
    }
    for (const [key, value] of Object.entries(NEW_METADATA_KEYS)) {
      langContent[key] = value;
    }

    fs.writeFileSync(langPath, JSON.stringify(langContent, null, 2), 'utf8');
    console.log(`Merged and saved translations to ${langPath}`);
  }

  console.log('\nAll incremental translations completed successfully!');
}

main().catch(err => {
  console.error('Fatal incremental translation error:', err);
  process.exit(1);
});
