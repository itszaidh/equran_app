import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'eQuran'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @quran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quran;

  /// No description provided for @prayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get prayer;

  /// No description provided for @duas.
  ///
  /// In en, this message translates to:
  /// **'Duas'**
  String get duas;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @qibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qibla;

  /// No description provided for @tasbih.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get tasbih;

  /// No description provided for @asmaUlHusna.
  ///
  /// In en, this message translates to:
  /// **'Asma-ul-Husna'**
  String get asmaUlHusna;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @vibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable haptic feedback when navigating.'**
  String get vibrationSubtitle;

  /// No description provided for @showReadingHistory.
  ///
  /// In en, this message translates to:
  /// **'Show reading history'**
  String get showReadingHistory;

  /// No description provided for @showReadingHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shows you up to 7 last read Surahs.'**
  String get showReadingHistorySubtitle;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @generalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App behavior and history'**
  String get generalSubtitle;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get reading;

  /// No description provided for @readingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quran display and translation'**
  String get readingSubtitle;

  /// No description provided for @cardView.
  ///
  /// In en, this message translates to:
  /// **'Card View'**
  String get cardView;

  /// No description provided for @cardViewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Displays each verse separately, or all in one page.'**
  String get cardViewSubtitle;

  /// No description provided for @displayTranslation.
  ///
  /// In en, this message translates to:
  /// **'Display Translation'**
  String get displayTranslation;

  /// No description provided for @displayTranslationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display translation for each verse in card view.'**
  String get displayTranslationSubtitle;

  /// No description provided for @displayTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Display Transliteration'**
  String get displayTransliteration;

  /// No description provided for @displayTransliterationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show transliteration for each verse in card view.'**
  String get displayTransliterationSubtitle;

  /// No description provided for @dailyQuranGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Quran goal'**
  String get dailyQuranGoal;

  /// No description provided for @dailyQuranGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} ayahs per day'**
  String dailyQuranGoalSubtitle(int count);

  /// No description provided for @translation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// No description provided for @reciter.
  ///
  /// In en, this message translates to:
  /// **'Reciter'**
  String get reciter;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @audioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reciter and playback'**
  String get audioSubtitle;

  /// No description provided for @downloadableResources.
  ///
  /// In en, this message translates to:
  /// **'Downloadable Resources'**
  String get downloadableResources;

  /// No description provided for @downloadableResourcesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tafsir and audio timing packs'**
  String get downloadableResourcesSubtitle;

  /// No description provided for @prayerTimesSettings.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times Settings'**
  String get prayerTimesSettings;

  /// No description provided for @prayerTimesSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage location, method, Asr, time format, and offsets.'**
  String get prayerTimesSettingsSubtitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Theme, color, and display mode'**
  String get appearanceSubtitle;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeMode;

  /// No description provided for @colorScheme.
  ///
  /// In en, this message translates to:
  /// **'Color scheme'**
  String get colorScheme;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @dataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Backup, restore, or clear saved local data'**
  String get dataSubtitle;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup data'**
  String get backupData;

  /// No description provided for @backupDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Exports favourites, reading history, reciter, text sizes, and all settings.'**
  String get backupDataSubtitle;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore data'**
  String get restoreData;

  /// No description provided for @restoreDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restores favourites, reading history, reciter, text sizes, and saved settings from a backup file.'**
  String get restoreDataSubtitle;

  /// No description provided for @clearReadingHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear reading history'**
  String get clearReadingHistory;

  /// No description provided for @clearReadingHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Removes last read, resume positions, and Quran reading progress.'**
  String get clearReadingHistorySubtitle;

  /// No description provided for @clearFavourites.
  ///
  /// In en, this message translates to:
  /// **'Clear Favourites'**
  String get clearFavourites;

  /// No description provided for @clearFavouritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Removes saved ayahs, folders, notes, tags, and favourites.'**
  String get clearFavouritesSubtitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @continueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get continueReading;

  /// No description provided for @lastRead.
  ///
  /// In en, this message translates to:
  /// **'Last Read'**
  String get lastRead;

  /// No description provided for @beginWithQuran.
  ///
  /// In en, this message translates to:
  /// **'Quran Reading'**
  String get beginWithQuran;

  /// No description provided for @startReadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start reading and your place will appear here.'**
  String get startReadingSubtitle;

  /// No description provided for @startReading.
  ///
  /// In en, this message translates to:
  /// **'Start reading'**
  String get startReading;

  /// No description provided for @continueListening.
  ///
  /// In en, this message translates to:
  /// **'Continue Listening'**
  String get continueListening;

  /// No description provided for @beginListeningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Listen to the recitation and your place will appear here.'**
  String get beginListeningSubtitle;

  /// No description provided for @startReadingRoutine.
  ///
  /// In en, this message translates to:
  /// **'Start a reading routine'**
  String get startReadingRoutine;

  /// No description provided for @buildDailyQuranHabit.
  ///
  /// In en, this message translates to:
  /// **'Build a daily Quran habit'**
  String get buildDailyQuranHabit;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @readingRoutine.
  ///
  /// In en, this message translates to:
  /// **'Reading Routine'**
  String get readingRoutine;

  /// No description provided for @continueRoutine.
  ///
  /// In en, this message translates to:
  /// **'Continue Routine'**
  String get continueRoutine;

  /// No description provided for @dailyQuranCompanion.
  ///
  /// In en, this message translates to:
  /// **'Daily Quran Companion'**
  String get dailyQuranCompanion;

  /// No description provided for @dailyQuranCompanionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick up your recitation and daily tools'**
  String get dailyQuranCompanionSubtitle;

  /// No description provided for @dailyTools.
  ///
  /// In en, this message translates to:
  /// **'Daily Tools'**
  String get dailyTools;

  /// No description provided for @dailyToolsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fast access to the essentials'**
  String get dailyToolsSubtitle;

  /// No description provided for @exploreAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'Explore all features'**
  String get exploreAllFeatures;

  /// No description provided for @dailyAyah.
  ///
  /// In en, this message translates to:
  /// **'Daily Ayah'**
  String get dailyAyah;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @surahs.
  ///
  /// In en, this message translates to:
  /// **'Surahs'**
  String get surahs;

  /// No description provided for @juz.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get juz;

  /// No description provided for @pages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pages;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @quranJourney.
  ///
  /// In en, this message translates to:
  /// **'Quran Journey'**
  String get quranJourney;

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get nextPrayer;

  /// No description provided for @prayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimes;

  /// No description provided for @exploreQibla.
  ///
  /// In en, this message translates to:
  /// **'Explore Qibla'**
  String get exploreQibla;

  /// No description provided for @tasbihCounter.
  ///
  /// In en, this message translates to:
  /// **'Tasbih Counter'**
  String get tasbihCounter;

  /// No description provided for @duasAndAzkar.
  ///
  /// In en, this message translates to:
  /// **'Duas & Azkar'**
  String get duasAndAzkar;

  /// No description provided for @readingPlans.
  ///
  /// In en, this message translates to:
  /// **'Reading Plans'**
  String get readingPlans;

  /// No description provided for @quranStatistics.
  ///
  /// In en, this message translates to:
  /// **'Quran Statistics'**
  String get quranStatistics;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @dua.
  ///
  /// In en, this message translates to:
  /// **'Dua'**
  String get dua;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// No description provided for @searchQuran.
  ///
  /// In en, this message translates to:
  /// **'Search Quran'**
  String get searchQuran;

  /// No description provided for @searchHintSurah.
  ///
  /// In en, this message translates to:
  /// **'Surah name or number...'**
  String get searchHintSurah;

  /// No description provided for @searchHintJuz.
  ///
  /// In en, this message translates to:
  /// **'Juz number or surah name...'**
  String get searchHintJuz;

  /// No description provided for @searchHintPage.
  ///
  /// In en, this message translates to:
  /// **'Page number, surah, or juz...'**
  String get searchHintPage;

  /// No description provided for @searchHintSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved ayah, surah, note, or number...'**
  String get searchHintSaved;

  /// No description provided for @searchHintText.
  ///
  /// In en, this message translates to:
  /// **'Search Quran Arabic or translation...'**
  String get searchHintText;

  /// No description provided for @savedAyahs.
  ///
  /// In en, this message translates to:
  /// **'Saved Ayahs'**
  String get savedAyahs;

  /// No description provided for @ayahNumber.
  ///
  /// In en, this message translates to:
  /// **'Ayah {number}'**
  String ayahNumber(int number);

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @audioOptions.
  ///
  /// In en, this message translates to:
  /// **'Audio Options'**
  String get audioOptions;

  /// No description provided for @dismissPlayer.
  ///
  /// In en, this message translates to:
  /// **'Dismiss player'**
  String get dismissPlayer;

  /// No description provided for @playbackOptions.
  ///
  /// In en, this message translates to:
  /// **'Playback options'**
  String get playbackOptions;

  /// No description provided for @previousAyah.
  ///
  /// In en, this message translates to:
  /// **'Previous ayah'**
  String get previousAyah;

  /// No description provided for @nextAyah.
  ///
  /// In en, this message translates to:
  /// **'Next ayah'**
  String get nextAyah;

  /// No description provided for @autoPlayback.
  ///
  /// In en, this message translates to:
  /// **'Auto Playback'**
  String get autoPlayback;

  /// No description provided for @repeatInterval.
  ///
  /// In en, this message translates to:
  /// **'Repeat Interval'**
  String get repeatInterval;

  /// No description provided for @downloadSurahAudio.
  ///
  /// In en, this message translates to:
  /// **'Download Surah Audio'**
  String get downloadSurahAudio;

  /// No description provided for @deleteDownloadedAudio.
  ///
  /// In en, this message translates to:
  /// **'Delete Downloaded Audio'**
  String get deleteDownloadedAudio;

  /// No description provided for @deleteDownloadQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Download?'**
  String get deleteDownloadQuestion;

  /// No description provided for @removeDownloadFromOffline.
  ///
  /// In en, this message translates to:
  /// **'Remove {title} from offline storage?'**
  String removeDownloadFromOffline(String title);

  /// No description provided for @deletedDownload.
  ///
  /// In en, this message translates to:
  /// **'Deleted {title}'**
  String deletedDownload(String title);

  /// No description provided for @deleteAllDownloadsQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete All Downloads?'**
  String get deleteAllDownloadsQuestion;

  /// No description provided for @deleteAllDownloadsBody.
  ///
  /// In en, this message translates to:
  /// **'This will remove {count} downloaded audio files ({size}).'**
  String deleteAllDownloadsBody(int count, String size);

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @deletedAllDownloadedAudio.
  ///
  /// In en, this message translates to:
  /// **'Deleted all downloaded audio.'**
  String get deletedAllDownloadedAudio;

  /// No description provided for @offlineAudio.
  ///
  /// In en, this message translates to:
  /// **'Offline Audio'**
  String get offlineAudio;

  /// No description provided for @surahAyahSummary.
  ///
  /// In en, this message translates to:
  /// **'{surahCount} surahs • {ayahCount} ayahs'**
  String surahAyahSummary(int surahCount, int ayahCount);

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @cleanupPreview.
  ///
  /// In en, this message translates to:
  /// **'Cleanup preview'**
  String get cleanupPreview;

  /// No description provided for @downloadedSurahs.
  ///
  /// In en, this message translates to:
  /// **'Downloaded surahs'**
  String get downloadedSurahs;

  /// No description provided for @downloadedAyahs.
  ///
  /// In en, this message translates to:
  /// **'Downloaded ayahs'**
  String get downloadedAyahs;

  /// No description provided for @potentialSpaceToFree.
  ///
  /// In en, this message translates to:
  /// **'Potential space to free'**
  String get potentialSpaceToFree;

  /// No description provided for @cleanupDoesNotRemoveData.
  ///
  /// In en, this message translates to:
  /// **'Cleanup never removes favourites, notes, reading plans, Quran text, or settings.'**
  String get cleanupDoesNotRemoveData;

  /// No description provided for @reviewDeletion.
  ///
  /// In en, this message translates to:
  /// **'Review deletion'**
  String get reviewDeletion;

  /// No description provided for @noDownloadedAudioYet.
  ///
  /// In en, this message translates to:
  /// **'No downloaded audio yet.'**
  String get noDownloadedAudioYet;

  /// No description provided for @downloadedAudioEmpty.
  ///
  /// In en, this message translates to:
  /// **'Downloaded surahs and ayahs will appear here grouped by reciter.'**
  String get downloadedAudioEmpty;

  /// No description provided for @ayahs.
  ///
  /// In en, this message translates to:
  /// **'Ayahs'**
  String get ayahs;

  /// No description provided for @deleteDownload.
  ///
  /// In en, this message translates to:
  /// **'Delete download'**
  String get deleteDownload;

  /// No description provided for @playbackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback Speed'**
  String get playbackSpeed;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission required'**
  String get locationPermissionRequired;

  /// No description provided for @unableToReconnect.
  ///
  /// In en, this message translates to:
  /// **'Unable to reconnect'**
  String get unableToReconnect;

  /// No description provided for @reciterOptions.
  ///
  /// In en, this message translates to:
  /// **'Reciter Options'**
  String get reciterOptions;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeModeSystem;

  /// No description provided for @themeModeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeModeDialogTitle;

  /// No description provided for @themeModeDarkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Always use night mode.'**
  String get themeModeDarkSubtitle;

  /// No description provided for @themeModeLightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Always use light mode.'**
  String get themeModeLightSubtitle;

  /// No description provided for @themeModeSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow the system theme.'**
  String get themeModeSystemSubtitle;

  /// No description provided for @colorSchemeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Color Scheme'**
  String get colorSchemeDialogTitle;

  /// No description provided for @translationLanguage.
  ///
  /// In en, this message translates to:
  /// **'Translation language'**
  String get translationLanguage;

  /// No description provided for @notDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Not downloaded'**
  String get notDownloaded;

  /// No description provided for @playbackRate.
  ///
  /// In en, this message translates to:
  /// **'Playback Rate'**
  String get playbackRate;

  /// No description provided for @arabicTextSize.
  ///
  /// In en, this message translates to:
  /// **'Arabic text size'**
  String get arabicTextSize;

  /// No description provided for @translationTextSize.
  ///
  /// In en, this message translates to:
  /// **'Translation text size'**
  String get translationTextSize;

  /// No description provided for @resourcesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Resources unavailable'**
  String get resourcesUnavailable;

  /// No description provided for @resourcesManifestUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the resource manifest.'**
  String get resourcesManifestUnavailable;

  /// No description provided for @tafsir.
  ///
  /// In en, this message translates to:
  /// **'Tafsir'**
  String get tafsir;

  /// No description provided for @audioTimings.
  ///
  /// In en, this message translates to:
  /// **'Audio Timings'**
  String get audioTimings;

  /// No description provided for @translations.
  ///
  /// In en, this message translates to:
  /// **'Translations'**
  String get translations;

  /// No description provided for @refreshManifest.
  ///
  /// In en, this message translates to:
  /// **'Refresh manifest'**
  String get refreshManifest;

  /// No description provided for @checkGithubReleases.
  ///
  /// In en, this message translates to:
  /// **'Check GitHub releases for changes'**
  String get checkGithubReleases;

  /// No description provided for @noResourcesListed.
  ///
  /// In en, this message translates to:
  /// **'No resources listed in the manifest.'**
  String get noResourcesListed;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @translationUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This translation is not supported yet.'**
  String get translationUnsupported;

  /// No description provided for @translationNotInManifest.
  ///
  /// In en, this message translates to:
  /// **'This translation is not in the resource manifest.'**
  String get translationNotInManifest;

  /// No description provided for @downloadTranslationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Download {name}?'**
  String downloadTranslationQuestion(String name);

  /// No description provided for @translationNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'This translation is not installed on this device. {size}'**
  String translationNotInstalled(String size);

  /// No description provided for @installedResource.
  ///
  /// In en, this message translates to:
  /// **'Installed {name}.'**
  String installedResource(String name);

  /// No description provided for @unableInstallResource.
  ///
  /// In en, this message translates to:
  /// **'Unable to install this resource.'**
  String get unableInstallResource;

  /// No description provided for @deleteResourceQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteResourceQuestion(String name);

  /// No description provided for @deleteResourceBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the downloaded files from this device.'**
  String get deleteResourceBody;

  /// No description provided for @deletedResource.
  ///
  /// In en, this message translates to:
  /// **'Deleted {name}.'**
  String deletedResource(String name);

  /// No description provided for @ayahsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Ayahs per day'**
  String get ayahsPerDay;

  /// No description provided for @enterGoalRange.
  ///
  /// In en, this message translates to:
  /// **'Enter a goal from 1 to 1000 ayahs'**
  String get enterGoalRange;

  /// No description provided for @clearReadingHistoryWarning.
  ///
  /// In en, this message translates to:
  /// **'WARNING: This will clear last read, resume positions, statistics, and routine day progress.'**
  String get clearReadingHistoryWarning;

  /// No description provided for @clearFavouritesWarning.
  ///
  /// In en, this message translates to:
  /// **'WARNING: This will clear every saved ayah, folder, note, tag, and favourite.'**
  String get clearFavouritesWarning;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'NO'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'YES'**
  String get yes;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreBackup;

  /// No description provided for @restoreBackupWarning.
  ///
  /// In en, this message translates to:
  /// **'This will replace your current favourites, reading history, and saved settings with the contents of the backup file.'**
  String get restoreBackupWarning;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @backupReadyToShare.
  ///
  /// In en, this message translates to:
  /// **'Backup file ready to share.'**
  String get backupReadyToShare;

  /// No description provided for @backupSavedTo.
  ///
  /// In en, this message translates to:
  /// **'Backup saved to {path}'**
  String backupSavedTo(String path);

  /// No description provided for @unableCreateBackup.
  ///
  /// In en, this message translates to:
  /// **'Unable to create the backup file.'**
  String get unableCreateBackup;

  /// No description provided for @restoredBackupSummary.
  ///
  /// In en, this message translates to:
  /// **'Restored {favouritesCount} favourites, {readingHistoryCount} history entries, and {settingsCount} settings.'**
  String restoredBackupSummary(
    int favouritesCount,
    int readingHistoryCount,
    int settingsCount,
  );

  /// No description provided for @unableRestoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Unable to restore the selected backup.'**
  String get unableRestoreBackup;

  /// No description provided for @locationAndCalculationSettings.
  ///
  /// In en, this message translates to:
  /// **'Location and calculation settings'**
  String get locationAndCalculationSettings;

  /// No description provided for @quranSearch.
  ///
  /// In en, this message translates to:
  /// **'Quran Search'**
  String get quranSearch;

  /// No description provided for @searchArabicAndTranslation.
  ///
  /// In en, this message translates to:
  /// **'Search Arabic and translation'**
  String get searchArabicAndTranslation;

  /// No description provided for @recitationsAndAudioControls.
  ///
  /// In en, this message translates to:
  /// **'Recitations and audio controls'**
  String get recitationsAndAudioControls;

  /// No description provided for @compassAndDirection.
  ///
  /// In en, this message translates to:
  /// **'Compass and direction'**
  String get compassAndDirection;

  /// No description provided for @offlineAudioAndCleanup.
  ///
  /// In en, this message translates to:
  /// **'Offline audio and cleanup'**
  String get offlineAudioAndCleanup;

  /// No description provided for @plansGoalsProgress.
  ///
  /// In en, this message translates to:
  /// **'Plans, goals, and progress'**
  String get plansGoalsProgress;

  /// No description provided for @calmDhikrCounter.
  ///
  /// In en, this message translates to:
  /// **'Calm dhikr counter'**
  String get calmDhikrCounter;

  /// No description provided for @the99BeautifulNames.
  ///
  /// In en, this message translates to:
  /// **'The 99 Beautiful Names'**
  String get the99BeautifulNames;

  /// No description provided for @worshipTrendsAndStreaks.
  ///
  /// In en, this message translates to:
  /// **'Worship trends and streaks'**
  String get worshipTrendsAndStreaks;

  /// No description provided for @fontsReciterAppBehavior.
  ///
  /// In en, this message translates to:
  /// **'Fonts, reciter, app behavior'**
  String get fontsReciterAppBehavior;

  /// No description provided for @switchLightOrNightMode.
  ///
  /// In en, this message translates to:
  /// **'Switch light or night mode'**
  String get switchLightOrNightMode;

  /// No description provided for @yourIslamicCompanion.
  ///
  /// In en, this message translates to:
  /// **'Your Islamic Companion'**
  String get yourIslamicCompanion;

  /// No description provided for @moreHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Qibla, downloads, settings, plans, and tools gathered in one quiet place.'**
  String get moreHeroSubtitle;

  /// No description provided for @openRoutine.
  ///
  /// In en, this message translates to:
  /// **'Open routine'**
  String get openRoutine;

  /// No description provided for @aboutAppBody.
  ///
  /// In en, this message translates to:
  /// **'eQuran is a modern Quran companion designed for focused reading, listening, and daily reflection.'**
  String get aboutAppBody;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @downloadEquran.
  ///
  /// In en, this message translates to:
  /// **'Download eQuran'**
  String get downloadEquran;

  /// No description provided for @downloadEquranShareText.
  ///
  /// In en, this message translates to:
  /// **'Download eQuran on F-Droid: {url}'**
  String downloadEquranShareText(String url);

  /// No description provided for @unableOpenShareSheet.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the share sheet.'**
  String get unableOpenShareSheet;

  /// No description provided for @aboutThisApp.
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get aboutThisApp;

  /// No description provided for @appDetailsAndVersion.
  ///
  /// In en, this message translates to:
  /// **'App details and version'**
  String get appDetailsAndVersion;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share app'**
  String get shareApp;

  /// No description provided for @shareAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send eQuran to others'**
  String get shareAppSubtitle;

  /// No description provided for @feedbackContact.
  ///
  /// In en, this message translates to:
  /// **'Feedback / Contact'**
  String get feedbackContact;

  /// No description provided for @feedbackContactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Report issues or email support'**
  String get feedbackContactSubtitle;

  /// No description provided for @reportIssues.
  ///
  /// In en, this message translates to:
  /// **'Report issues'**
  String get reportIssues;

  /// No description provided for @reportIssuesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open the GitHub issue tracker.'**
  String get reportIssuesSubtitle;

  /// No description provided for @unableOpenIssueTracker.
  ///
  /// In en, this message translates to:
  /// **'Unable to open issue tracker.'**
  String get unableOpenIssueTracker;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email support'**
  String get emailSupport;

  /// No description provided for @unableOpenEmailClient.
  ///
  /// In en, this message translates to:
  /// **'Unable to open email client.'**
  String get unableOpenEmailClient;

  /// No description provided for @feedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'We appreciate your feedback and suggestions.'**
  String get feedbackThanks;

  /// No description provided for @browseBySurah.
  ///
  /// In en, this message translates to:
  /// **'Browse by Surah'**
  String get browseBySurah;

  /// No description provided for @browseByJuz.
  ///
  /// In en, this message translates to:
  /// **'Browse by Juz'**
  String get browseByJuz;

  /// No description provided for @browseByPage.
  ///
  /// In en, this message translates to:
  /// **'Browse by page'**
  String get browseByPage;

  /// No description provided for @closeSearch.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get closeSearch;

  /// No description provided for @noSurahsFound.
  ///
  /// In en, this message translates to:
  /// **'No surahs found.'**
  String get noSurahsFound;

  /// No description provided for @ayahRange.
  ///
  /// In en, this message translates to:
  /// **'Ayah {start}-{end}'**
  String ayahRange(int start, int end);

  /// No description provided for @juzNumber.
  ///
  /// In en, this message translates to:
  /// **'Juz {number}'**
  String juzNumber(int number);

  /// No description provided for @prayerNameFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerNameFajr;

  /// No description provided for @prayerNameSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayerNameSunrise;

  /// No description provided for @prayerNameDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerNameDhuhr;

  /// No description provided for @prayerNameAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerNameAsr;

  /// No description provided for @prayerNameMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerNameMaghrib;

  /// No description provided for @prayerNameIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerNameIsha;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

  /// No description provided for @middleOfNight.
  ///
  /// In en, this message translates to:
  /// **'Middle of night'**
  String get middleOfNight;

  /// No description provided for @lastThirdStarts.
  ///
  /// In en, this message translates to:
  /// **'Last third starts'**
  String get lastThirdStarts;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// No description provided for @chooseOnMap.
  ///
  /// In en, this message translates to:
  /// **'Choose on map'**
  String get chooseOnMap;

  /// No description provided for @enterCoordinatesManually.
  ///
  /// In en, this message translates to:
  /// **'Enter coordinates manually'**
  String get enterCoordinatesManually;

  /// No description provided for @locationUseNotice.
  ///
  /// In en, this message translates to:
  /// **'Your location is only used for prayer time calculation.'**
  String get locationUseNotice;

  /// No description provided for @timesCalculatedLocally.
  ///
  /// In en, this message translates to:
  /// **'Times are calculated locally on your device.'**
  String get timesCalculatedLocally;

  /// No description provided for @prayerTimesNeedLocation.
  ///
  /// In en, this message translates to:
  /// **'Prayer times need a location'**
  String get prayerTimesNeedLocation;

  /// No description provided for @prayerTimesLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Calculate Fajr, Dhuhr, Asr, Maghrib and Isha for your exact location.'**
  String get prayerTimesLocationSubtitle;

  /// No description provided for @setUpLocation.
  ///
  /// In en, this message translates to:
  /// **'Set up location'**
  String get setUpLocation;

  /// No description provided for @chooseLocationForNextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Choose a location to show the next prayer time here.'**
  String get chooseLocationForNextPrayer;

  /// No description provided for @prayerTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'{prayer} Time'**
  String prayerTimeTitle(String prayer);

  /// No description provided for @prayerBeginsIn.
  ///
  /// In en, this message translates to:
  /// **'{prayer} begins in {countdown}'**
  String prayerBeginsIn(String prayer, String countdown);

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @hoursMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String hoursMinutesShort(int hours, int minutes);

  /// No description provided for @exactAlarmPermissionOff.
  ///
  /// In en, this message translates to:
  /// **'Exact alarm permission is off. Prayer reminders may be delayed.'**
  String get exactAlarmPermissionOff;

  /// No description provided for @zawal.
  ///
  /// In en, this message translates to:
  /// **'Zawal'**
  String get zawal;

  /// No description provided for @sunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunset;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @prohibitedTimeEndsIn.
  ///
  /// In en, this message translates to:
  /// **'Prohibited time ends in {countdown}'**
  String prohibitedTimeEndsIn(String countdown);

  /// No description provided for @selectPrayerDate.
  ///
  /// In en, this message translates to:
  /// **'Select prayer date'**
  String get selectPrayerDate;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get appSettings;

  /// No description provided for @unableGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to get location.'**
  String get unableGetLocation;

  /// No description provided for @qiblaBearingUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Current location coordinates are unavailable.'**
  String get qiblaBearingUnavailable;

  /// No description provided for @currentLocationTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Current location timed out. Check location services and try again.'**
  String get currentLocationTimedOut;

  /// No description provided for @compassUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Compass unavailable. Use the bearing shown.'**
  String get compassUnavailable;

  /// No description provided for @qiblaCalibrationHint.
  ///
  /// In en, this message translates to:
  /// **'For best accuracy, hold your phone flat and move it in a figure-8 to calibrate.'**
  String get qiblaCalibrationHint;

  /// No description provided for @compassAccuracyLow.
  ///
  /// In en, this message translates to:
  /// **'Compass accuracy may be low.'**
  String get compassAccuracyLow;

  /// No description provided for @compassAccuracyLowWithDegrees.
  ///
  /// In en, this message translates to:
  /// **'Compass accuracy may be low ({degrees}°).'**
  String compassAccuracyLowWithDegrees(int degrees);

  /// No description provided for @qiblaLocationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Turn on location services to use Qibla.'**
  String get qiblaLocationServicesDisabled;

  /// No description provided for @qiblaLocationPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Location permission is needed to calculate Qibla from your current device location.'**
  String get qiblaLocationPermissionNeeded;

  /// No description provided for @qiblaLocationPermissionBlocked.
  ///
  /// In en, this message translates to:
  /// **'Location permission is blocked. Enable it from app settings to use Qibla.'**
  String get qiblaLocationPermissionBlocked;

  /// No description provided for @qiblaLocationUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'We could not read your current location. Check location services and try again.'**
  String get qiblaLocationUnavailableMessage;

  /// No description provided for @bearingDegrees.
  ///
  /// In en, this message translates to:
  /// **'Bearing {degrees}°'**
  String bearingDegrees(String degrees);

  /// No description provided for @targetDegrees.
  ///
  /// In en, this message translates to:
  /// **'Target {degrees}°'**
  String targetDegrees(String degrees);

  /// No description provided for @headingDegrees.
  ///
  /// In en, this message translates to:
  /// **'Heading {degrees}°'**
  String headingDegrees(String degrees);

  /// No description provided for @heading.
  ///
  /// In en, this message translates to:
  /// **'Heading'**
  String get heading;

  /// No description provided for @facingQibla.
  ///
  /// In en, this message translates to:
  /// **'Facing Qibla'**
  String get facingQibla;

  /// No description provided for @turnRightDegrees.
  ///
  /// In en, this message translates to:
  /// **'Turn right {degrees}°'**
  String turnRightDegrees(int degrees);

  /// No description provided for @turnLeftDegrees.
  ///
  /// In en, this message translates to:
  /// **'Turn left {degrees}°'**
  String turnLeftDegrees(int degrees);

  /// No description provided for @refreshCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Refresh current location'**
  String get refreshCurrentLocation;

  /// No description provided for @findingYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Finding your location'**
  String get findingYourLocation;

  /// No description provided for @currentLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Current location required'**
  String get currentLocationRequired;

  /// No description provided for @qiblaRequiresLocation.
  ///
  /// In en, this message translates to:
  /// **'Qibla requires live current location from this device. Enable location services and permission to continue.'**
  String get qiblaRequiresLocation;

  /// No description provided for @findingLocation.
  ///
  /// In en, this message translates to:
  /// **'Finding location'**
  String get findingLocation;

  /// No description provided for @currentLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Current location unavailable'**
  String get currentLocationUnavailable;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocation;

  /// No description provided for @distanceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Distance unavailable'**
  String get distanceUnavailable;

  /// No description provided for @kilometersToKaaba.
  ///
  /// In en, this message translates to:
  /// **'{distance} km to Kaaba'**
  String kilometersToKaaba(String distance);

  /// No description provided for @resetCounter.
  ///
  /// In en, this message translates to:
  /// **'Reset counter'**
  String get resetCounter;

  /// No description provided for @recentSessions.
  ///
  /// In en, this message translates to:
  /// **'Recent sessions'**
  String get recentSessions;

  /// No description provided for @haptics.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get haptics;

  /// No description provided for @countSomeDhikrFirst.
  ///
  /// In en, this message translates to:
  /// **'Count some dhikr first'**
  String get countSomeDhikrFirst;

  /// No description provided for @dhikrSessionSaved.
  ///
  /// In en, this message translates to:
  /// **'Dhikr session saved'**
  String get dhikrSessionSaved;

  /// No description provided for @postPrayerDhikr.
  ///
  /// In en, this message translates to:
  /// **'Post-prayer dhikr'**
  String get postPrayerDhikr;

  /// No description provided for @postPrayerDhikrComplete.
  ///
  /// In en, this message translates to:
  /// **'Post-prayer dhikr complete'**
  String get postPrayerDhikrComplete;

  /// No description provided for @dhikrComplete.
  ///
  /// In en, this message translates to:
  /// **'{label} complete'**
  String dhikrComplete(String label);

  /// No description provided for @todayMetric.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayMetric;

  /// No description provided for @rounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get rounds;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @savedDhikrSessionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Saved dhikr sessions will appear here.'**
  String get savedDhikrSessionsEmpty;

  /// No description provided for @dhikrSessionCounted.
  ///
  /// In en, this message translates to:
  /// **'{count} of {target} counted • {time}'**
  String dhikrSessionCounted(int count, int target, String time);

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @locationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Used only for prayer time calculations'**
  String get locationSubtitle;

  /// No description provided for @useCurrentLocationDescription.
  ///
  /// In en, this message translates to:
  /// **'Save this device\'s location for prayer calculations.'**
  String get useCurrentLocationDescription;

  /// No description provided for @moveMapUnderPin.
  ///
  /// In en, this message translates to:
  /// **'Move the map under a centered pin.'**
  String get moveMapUnderPin;

  /// No description provided for @enterLatitudeAndLongitude.
  ///
  /// In en, this message translates to:
  /// **'Enter latitude and longitude.'**
  String get enterLatitudeAndLongitude;

  /// No description provided for @clearSavedLocation.
  ///
  /// In en, this message translates to:
  /// **'Clear saved location'**
  String get clearSavedLocation;

  /// No description provided for @clearSavedLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer times will pause until you choose again.'**
  String get clearSavedLocationSubtitle;

  /// No description provided for @calculation.
  ///
  /// In en, this message translates to:
  /// **'Calculation'**
  String get calculation;

  /// No description provided for @calculationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Method, Asr, high latitude, and time format'**
  String get calculationSubtitle;

  /// No description provided for @calculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation method'**
  String get calculationMethod;

  /// No description provided for @asrMethod.
  ///
  /// In en, this message translates to:
  /// **'Asr method'**
  String get asrMethod;

  /// No description provided for @highLatitudeAdjustment.
  ///
  /// In en, this message translates to:
  /// **'High latitude adjustment'**
  String get highLatitudeAdjustment;

  /// No description provided for @highLatitudeAdjustmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Used when Fajr or Isha are difficult to calculate in far northern or southern locations.'**
  String get highLatitudeAdjustmentSubtitle;

  /// No description provided for @timeFormat.
  ///
  /// In en, this message translates to:
  /// **'Time format'**
  String get timeFormat;

  /// No description provided for @useLocationTimezone.
  ///
  /// In en, this message translates to:
  /// **'Use location timezone'**
  String get useLocationTimezone;

  /// No description provided for @locationTimezoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the timezone of the saved location instead of this device\'s timezone.'**
  String get locationTimezoneSubtitle;

  /// No description provided for @customMethod.
  ///
  /// In en, this message translates to:
  /// **'Custom Method'**
  String get customMethod;

  /// No description provided for @fajrAngle.
  ///
  /// In en, this message translates to:
  /// **'Fajr angle'**
  String get fajrAngle;

  /// No description provided for @ishaMode.
  ///
  /// In en, this message translates to:
  /// **'Isha mode'**
  String get ishaMode;

  /// No description provided for @maghribAngle.
  ///
  /// In en, this message translates to:
  /// **'Maghrib angle'**
  String get maghribAngle;

  /// No description provided for @leaveBlankToUseSunset.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to use sunset.'**
  String get leaveBlankToUseSunset;

  /// No description provided for @fixedIshaTime.
  ///
  /// In en, this message translates to:
  /// **'Fixed Isha time'**
  String get fixedIshaTime;

  /// No description provided for @latestIshaTime.
  ///
  /// In en, this message translates to:
  /// **'Latest Isha time'**
  String get latestIshaTime;

  /// No description provided for @baseIshaAngle.
  ///
  /// In en, this message translates to:
  /// **'Base Isha angle'**
  String get baseIshaAngle;

  /// No description provided for @baseIshaInterval.
  ///
  /// In en, this message translates to:
  /// **'Base Isha interval'**
  String get baseIshaInterval;

  /// No description provided for @ishaAngle.
  ///
  /// In en, this message translates to:
  /// **'Isha angle'**
  String get ishaAngle;

  /// No description provided for @ishaInterval.
  ///
  /// In en, this message translates to:
  /// **'Isha interval'**
  String get ishaInterval;

  /// No description provided for @leaveBlankToUseBaseIshaAngle.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to use the base Isha angle.'**
  String get leaveBlankToUseBaseIshaAngle;

  /// No description provided for @useIshaAngle.
  ///
  /// In en, this message translates to:
  /// **'Use Isha angle'**
  String get useIshaAngle;

  /// No description provided for @minutesAfterMaghrib.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes after Maghrib'**
  String minutesAfterMaghrib(int minutes);

  /// No description provided for @prohibitedTimes.
  ///
  /// In en, this message translates to:
  /// **'Prohibited Times'**
  String get prohibitedTimes;

  /// No description provided for @prohibitedTimesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sunrise, Zawal and Sunset windows'**
  String get prohibitedTimesSubtitle;

  /// No description provided for @sunriseProhibitedTime.
  ///
  /// In en, this message translates to:
  /// **'Sunrise prohibited time'**
  String get sunriseProhibitedTime;

  /// No description provided for @sunriseProhibitedTimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes after Sunrise'**
  String sunriseProhibitedTimeMinutes(int minutes);

  /// No description provided for @zawalProhibitedTime.
  ///
  /// In en, this message translates to:
  /// **'Zawal prohibited time'**
  String get zawalProhibitedTime;

  /// No description provided for @zawalProhibitedTimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes before Dhuhr'**
  String zawalProhibitedTimeMinutes(int minutes);

  /// No description provided for @sunsetProhibitedTime.
  ///
  /// In en, this message translates to:
  /// **'Sunset prohibited time'**
  String get sunsetProhibitedTime;

  /// No description provided for @sunsetProhibitedTimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes before Maghrib'**
  String sunsetProhibitedTimeMinutes(int minutes);

  /// No description provided for @prayerReminders.
  ///
  /// In en, this message translates to:
  /// **'Prayer Reminders'**
  String get prayerReminders;

  /// No description provided for @prayerRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications before each prayer'**
  String get prayerRemindersSubtitle;

  /// No description provided for @prayerRemindersEnabled.
  ///
  /// In en, this message translates to:
  /// **'Prayer reminders'**
  String get prayerRemindersEnabled;

  /// No description provided for @prayerRemindersEnabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified before each prayer time.'**
  String get prayerRemindersEnabledSubtitle;

  /// No description provided for @notificationsPermission.
  ///
  /// In en, this message translates to:
  /// **'Notifications permission'**
  String get notificationsPermission;

  /// No description provided for @exactAlarmPermission.
  ///
  /// In en, this message translates to:
  /// **'Exact alarm / alarms & reminders permission'**
  String get exactAlarmPermission;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @notificationPermissionOff.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is off.'**
  String get notificationPermissionOff;

  /// No description provided for @exactAlarmPermissionDisabled.
  ///
  /// In en, this message translates to:
  /// **'Exact alarm permission is disabled. Prayer reminders may be delayed.'**
  String get exactAlarmPermissionDisabled;

  /// No description provided for @openAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Open app settings'**
  String get openAppSettings;

  /// No description provided for @requestPermission.
  ///
  /// In en, this message translates to:
  /// **'Request permission'**
  String get requestPermission;

  /// No description provided for @openAlarmPermissionSettings.
  ///
  /// In en, this message translates to:
  /// **'Open alarm permission settings'**
  String get openAlarmPermissionSettings;

  /// No description provided for @chooseLocationBeforeReminders.
  ///
  /// In en, this message translates to:
  /// **'Choose a location before reminders can be scheduled.'**
  String get chooseLocationBeforeReminders;

  /// No description provided for @notifyAtSavedPrayerTime.
  ///
  /// In en, this message translates to:
  /// **'Notify at the saved prayer time.'**
  String get notifyAtSavedPrayerTime;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @atPrayerTime.
  ///
  /// In en, this message translates to:
  /// **'At prayer time'**
  String get atPrayerTime;

  /// No description provided for @minutesBefore.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes before'**
  String minutesBefore(int minutes);

  /// No description provided for @schedule1MinuteExactTest.
  ///
  /// In en, this message translates to:
  /// **'Schedule 1-minute exact test'**
  String get schedule1MinuteExactTest;

  /// No description provided for @schedule1MinuteExactTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Uses the prayer reminder scheduler.'**
  String get schedule1MinuteExactTestSubtitle;

  /// No description provided for @offsetsAreAppliedAfterBaseCalculation.
  ///
  /// In en, this message translates to:
  /// **'Offsets are applied after the base calculation. Use positive or negative minutes only when you need to match a trusted local timetable.'**
  String get offsetsAreAppliedAfterBaseCalculation;

  /// No description provided for @manualOffsets.
  ///
  /// In en, this message translates to:
  /// **'Manual Offsets'**
  String get manualOffsets;

  /// No description provided for @manualOffsetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fine tune calculated times'**
  String get manualOffsetsSubtitle;

  /// No description provided for @noManualAdjustment.
  ///
  /// In en, this message translates to:
  /// **'No manual adjustment'**
  String get noManualAdjustment;

  /// No description provided for @positiveOrNegativeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{value} minutes'**
  String positiveOrNegativeMinutes(int value);

  /// No description provided for @prayerTimesExperimental.
  ///
  /// In en, this message translates to:
  /// **'Prayer times are currently experimental and may differ from local mosque or official timetables. Please verify before relying on them.'**
  String get prayerTimesExperimental;

  /// No description provided for @bestMethodAfterLocationSaved.
  ///
  /// In en, this message translates to:
  /// **'Best method after location is saved'**
  String get bestMethodAfterLocationSaved;

  /// No description provided for @minutesBeforePrayer.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min before prayer'**
  String minutesBeforePrayer(int minutes);

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @enablePrayerTracking.
  ///
  /// In en, this message translates to:
  /// **'Enable prayer tracking'**
  String get enablePrayerTracking;

  /// No description provided for @trackYourDailyPrayers.
  ///
  /// In en, this message translates to:
  /// **'Track your daily prayers'**
  String get trackYourDailyPrayers;

  /// No description provided for @trackYourDailyPrayersDescription.
  ///
  /// In en, this message translates to:
  /// **'Log each prayer privately on your device. Your data never leaves your phone.'**
  String get trackYourDailyPrayersDescription;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get maybeLater;

  /// No description provided for @logEachPrayerPrivately.
  ///
  /// In en, this message translates to:
  /// **'Log each prayer privately on your device. Your data never leaves your phone.'**
  String get logEachPrayerPrivately;

  /// No description provided for @enablePrayerTrackingLabel.
  ///
  /// In en, this message translates to:
  /// **'Enable prayer tracking →'**
  String get enablePrayerTrackingLabel;

  /// No description provided for @somePrayersNotYetAvailable.
  ///
  /// In en, this message translates to:
  /// **'Some prayers were not yet available and were not saved.'**
  String get somePrayersNotYetAvailable;

  /// No description provided for @prayerLogSaved.
  ///
  /// In en, this message translates to:
  /// **'Prayer log saved'**
  String get prayerLogSaved;

  /// No description provided for @addNewFolder.
  ///
  /// In en, this message translates to:
  /// **'New Folder'**
  String get addNewFolder;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNote;

  /// No description provided for @moveToFolder.
  ///
  /// In en, this message translates to:
  /// **'Move to folder'**
  String get moveToFolder;

  /// No description provided for @editTags.
  ///
  /// In en, this message translates to:
  /// **'Edit tags'**
  String get editTags;

  /// No description provided for @savedAyah.
  ///
  /// In en, this message translates to:
  /// **'Saved ayah'**
  String get savedAyah;

  /// No description provided for @removeSavedAyah.
  ///
  /// In en, this message translates to:
  /// **'Remove saved ayah?'**
  String get removeSavedAyah;

  /// No description provided for @removeSavedAyahBody.
  ///
  /// In en, this message translates to:
  /// **'This will remove the ayah from your saved library.'**
  String get removeSavedAyahBody;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @personalLibrary.
  ///
  /// In en, this message translates to:
  /// **'Personal Library'**
  String get personalLibrary;

  /// No description provided for @savedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} saved'**
  String savedCount(int count);

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @manageFolders.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manageFolders;

  /// No description provided for @surahLabel.
  ///
  /// In en, this message translates to:
  /// **'{surahName} • Ayah {ayah}'**
  String surahLabel(String surahName, Object ayah);

  /// No description provided for @showTafsir.
  ///
  /// In en, this message translates to:
  /// **'Show tafsir'**
  String get showTafsir;

  /// No description provided for @saveToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Save to library'**
  String get saveToLibrary;

  /// No description provided for @folderTagsAndNote.
  ///
  /// In en, this message translates to:
  /// **'Folder, tags, and private note'**
  String get folderTagsAndNote;

  /// No description provided for @ayahDetails.
  ///
  /// In en, this message translates to:
  /// **'Ayah details'**
  String get ayahDetails;

  /// No description provided for @newFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get newFolder;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @translationOption.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translationOption;

  /// No description provided for @showAyahTranslation.
  ///
  /// In en, this message translates to:
  /// **'Show ayah translation'**
  String get showAyahTranslation;

  /// No description provided for @transliterationOption.
  ///
  /// In en, this message translates to:
  /// **'Transliteration'**
  String get transliterationOption;

  /// No description provided for @showAyahTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Show ayah transliteration'**
  String get showAyahTransliteration;

  /// No description provided for @cardViewOption.
  ///
  /// In en, this message translates to:
  /// **'Card View'**
  String get cardViewOption;

  /// No description provided for @readOneAyahPerCard.
  ///
  /// In en, this message translates to:
  /// **'Read one ayah per card'**
  String get readOneAyahPerCard;

  /// No description provided for @chooseAnAction.
  ///
  /// In en, this message translates to:
  /// **'Choose an action'**
  String get chooseAnAction;

  /// No description provided for @playThisAyah.
  ///
  /// In en, this message translates to:
  /// **'Play this ayah'**
  String get playThisAyah;

  /// No description provided for @shareImage.
  ///
  /// In en, this message translates to:
  /// **'Share image'**
  String get shareImage;

  /// No description provided for @searchCategories.
  ///
  /// In en, this message translates to:
  /// **'Search categories'**
  String get searchCategories;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @noMatchingCategories.
  ///
  /// In en, this message translates to:
  /// **'No matching categories'**
  String get noMatchingCategories;

  /// No description provided for @trySearchingArabicWord.
  ///
  /// In en, this message translates to:
  /// **'Try searching with another Arabic word or phrase.'**
  String get trySearchingArabicWord;

  /// No description provided for @duasUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Duas unavailable'**
  String get duasUnavailable;

  /// No description provided for @hisnAlMuslimNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Hisn al Muslim could not be loaded from the offline asset.'**
  String get hisnAlMuslimNotLoaded;

  /// No description provided for @retryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

  /// No description provided for @noDuasFound.
  ///
  /// In en, this message translates to:
  /// **'No duas found'**
  String get noDuasFound;

  /// No description provided for @offlineHisnAlMuslimEmpty.
  ///
  /// In en, this message translates to:
  /// **'The offline Hisn al Muslim file did not contain any duas.'**
  String get offlineHisnAlMuslimEmpty;

  /// No description provided for @hisnAlMuslim.
  ///
  /// In en, this message translates to:
  /// **'Hisn al Muslim'**
  String get hisnAlMuslim;

  /// No description provided for @arabicCategoriesDuasOffline.
  ///
  /// In en, this message translates to:
  /// **'{categoryCount} Arabic categories - {duaCount} duas offline'**
  String arabicCategoriesDuasOffline(int categoryCount, int duaCount);

  /// No description provided for @favouriteDuas.
  ///
  /// In en, this message translates to:
  /// **'Favourite duas'**
  String get favouriteDuas;

  /// No description provided for @favourite.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get favourite;

  /// No description provided for @removeFavourite.
  ///
  /// In en, this message translates to:
  /// **'Remove favourite'**
  String get removeFavourite;

  /// No description provided for @saveDuasHere.
  ///
  /// In en, this message translates to:
  /// **'Save duas here for quick access'**
  String get saveDuasHere;

  /// No description provided for @savedDuasCount.
  ///
  /// In en, this message translates to:
  /// **'{count} saved {label}'**
  String savedDuasCount(int count, String label);

  /// No description provided for @tasbihAndDhikr.
  ///
  /// In en, this message translates to:
  /// **'Tasbih and dhikr'**
  String get tasbihAndDhikr;

  /// No description provided for @calmCounterDailyPresets.
  ///
  /// In en, this message translates to:
  /// **'A calm counter with daily presets'**
  String get calmCounterDailyPresets;

  /// No description provided for @duaCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {label}'**
  String duaCount(int count, Object label);

  /// No description provided for @favouriteDuasPage.
  ///
  /// In en, this message translates to:
  /// **'Favourite duas'**
  String get favouriteDuasPage;

  /// No description provided for @favouritesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Favourites unavailable'**
  String get favouritesUnavailable;

  /// No description provided for @savedDuasNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Saved duas could not be loaded right now.'**
  String get savedDuasNotLoaded;

  /// No description provided for @noFavouriteDuasYet.
  ///
  /// In en, this message translates to:
  /// **'No favourite duas yet.'**
  String get noFavouriteDuasYet;

  /// No description provided for @tapHeartToSave.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any dua card to save it here.'**
  String get tapHeartToSave;

  /// No description provided for @categoryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Category unavailable'**
  String get categoryUnavailable;

  /// No description provided for @categoryNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'This Hisn al Muslim category could not be loaded.'**
  String get categoryNotLoaded;

  /// No description provided for @categoryNoDuas.
  ///
  /// In en, this message translates to:
  /// **'No duas found'**
  String get categoryNoDuas;

  /// No description provided for @categoryDoesNotContainDuas.
  ///
  /// In en, this message translates to:
  /// **'This category does not contain any duas.'**
  String get categoryDoesNotContainDuas;

  /// No description provided for @downloadTimings.
  ///
  /// In en, this message translates to:
  /// **'Download timings?'**
  String get downloadTimings;

  /// No description provided for @reciterNeedsTimings.
  ///
  /// In en, this message translates to:
  /// **'This reciter needs audio timings before synced ayah text can be shown. {size}'**
  String reciterNeedsTimings(String size);

  /// No description provided for @timingsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Timings unavailable for this reciter.'**
  String get timingsUnavailable;

  /// No description provided for @timingsUnavailableSurah.
  ///
  /// In en, this message translates to:
  /// **'Timings unavailable for this surah.'**
  String get timingsUnavailableSurah;

  /// No description provided for @unableToInstallTimings.
  ///
  /// In en, this message translates to:
  /// **'Unable to install timings.'**
  String get unableToInstallTimings;

  /// No description provided for @installedLabel.
  ///
  /// In en, this message translates to:
  /// **'Installed {name}.'**
  String installedLabel(String name);

  /// No description provided for @installed.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get installed;

  /// No description provided for @noTafsirSourcesSelected.
  ///
  /// In en, this message translates to:
  /// **'No Tafsir sources selected'**
  String get noTafsirSourcesSelected;

  /// No description provided for @chooseTafsirSourcesFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose one or more Tafsir sources first.'**
  String get chooseTafsirSourcesFirst;

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get go;

  /// No description provided for @deleteDownloadedMp3.
  ///
  /// In en, this message translates to:
  /// **'Delete downloaded MP3'**
  String get deleteDownloadedMp3;

  /// No description provided for @deleteDownloadedAyah.
  ///
  /// In en, this message translates to:
  /// **'Delete Downloaded Ayah?'**
  String get deleteDownloadedAyah;

  /// No description provided for @downloadAllAyahs.
  ///
  /// In en, this message translates to:
  /// **'Download All Ayahs?'**
  String get downloadAllAyahs;

  /// No description provided for @downloadAllAyahsConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will download audio for all {count} ayahs in this surah ({size}).'**
  String downloadAllAyahsConfirm(int count, String size);

  /// No description provided for @surahOption.
  ///
  /// In en, this message translates to:
  /// **'Surah'**
  String get surahOption;

  /// No description provided for @reciterOption.
  ///
  /// In en, this message translates to:
  /// **'Reciter'**
  String get reciterOption;

  /// No description provided for @sleepTimerOption.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get sleepTimerOption;

  /// No description provided for @shuffleOption.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffleOption;

  /// No description provided for @shuffleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Randomize after surah ends'**
  String get shuffleSubtitle;

  /// No description provided for @loopCurrentSurah.
  ///
  /// In en, this message translates to:
  /// **'Loop current surah'**
  String get loopCurrentSurah;

  /// No description provided for @loopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Repeat the current surah'**
  String get loopSubtitle;

  /// No description provided for @downloadTimingsResource.
  ///
  /// In en, this message translates to:
  /// **'Download timings'**
  String get downloadTimingsResource;

  /// No description provided for @timingsNeedToBeDownloaded.
  ///
  /// In en, this message translates to:
  /// **'This reciter needs audio timings before synced ayah text can be shown. {size}'**
  String timingsNeedToBeDownloaded(String size);

  /// No description provided for @intervalOption.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get intervalOption;

  /// No description provided for @intervalRepeatOption.
  ///
  /// In en, this message translates to:
  /// **'Interval repeat'**
  String get intervalRepeatOption;

  /// No description provided for @repeatEachAyahOption.
  ///
  /// In en, this message translates to:
  /// **'Repeat each ayah'**
  String get repeatEachAyahOption;

  /// No description provided for @resetPlaybackOptions.
  ///
  /// In en, this message translates to:
  /// **'Reset playback options'**
  String get resetPlaybackOptions;

  /// No description provided for @surahOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Surah'**
  String get surahOptionLabel;

  /// No description provided for @searchCategoriesDua.
  ///
  /// In en, this message translates to:
  /// **'Search categories'**
  String get searchCategoriesDua;

  /// No description provided for @savedAyahLibrary.
  ///
  /// In en, this message translates to:
  /// **'Saved Ayah'**
  String get savedAyahLibrary;

  /// No description provided for @autoAdvancesToNextPreset.
  ///
  /// In en, this message translates to:
  /// **'Auto-advances to {nextPreset}'**
  String autoAdvancesToNextPreset(String nextPreset);

  /// No description provided for @previousDhikr.
  ///
  /// In en, this message translates to:
  /// **'Previous dhikr'**
  String get previousDhikr;

  /// No description provided for @nextDhikr.
  ///
  /// In en, this message translates to:
  /// **'Next dhikr'**
  String get nextDhikr;

  /// No description provided for @counts33To33To34.
  ///
  /// In en, this message translates to:
  /// **'{target} counts • 33 → 33 → 34'**
  String counts33To33To34(int target);

  /// No description provided for @assalamuAlaikum.
  ///
  /// In en, this message translates to:
  /// **'Assalamu Alaikum'**
  String get assalamuAlaikum;

  /// No description provided for @continueYourJourneyToday.
  ///
  /// In en, this message translates to:
  /// **'Continue your journey today'**
  String get continueYourJourneyToday;

  /// No description provided for @onStreakDay.
  ///
  /// In en, this message translates to:
  /// **'You\'re on a {streak}-day streak — keep going'**
  String onStreakDay(int streak);

  /// No description provided for @todaysWorship.
  ///
  /// In en, this message translates to:
  /// **'Today\'s worship'**
  String get todaysWorship;

  /// No description provided for @ayahsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ayahs'**
  String get ayahsLabel;

  /// No description provided for @dhikrLabel.
  ///
  /// In en, this message translates to:
  /// **'Dhikr'**
  String get dhikrLabel;

  /// No description provided for @duasLabel.
  ///
  /// In en, this message translates to:
  /// **'Duas'**
  String get duasLabel;

  /// No description provided for @salahLabel.
  ///
  /// In en, this message translates to:
  /// **'Salah'**
  String get salahLabel;

  /// No description provided for @dayStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get dayStreakLabel;

  /// No description provided for @dailyQuranGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'DAILY QURAN GOAL'**
  String get dailyQuranGoalLabel;

  /// No description provided for @salah.
  ///
  /// In en, this message translates to:
  /// **'Salah'**
  String get salah;

  /// No description provided for @quranLabel.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quranLabel;

  /// No description provided for @tasbihLabel.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get tasbihLabel;

  /// No description provided for @activityHistory.
  ///
  /// In en, this message translates to:
  /// **'Activity History'**
  String get activityHistory;

  /// No description provided for @streaksLabel.
  ///
  /// In en, this message translates to:
  /// **'Streaks'**
  String get streaksLabel;

  /// No description provided for @weekRange.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get weekRange;

  /// No description provided for @monthRange.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get monthRange;

  /// No description provided for @yearRange.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearRange;

  /// No description provided for @allTimeRange.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTimeRange;

  /// No description provided for @noPrayerYet.
  ///
  /// In en, this message translates to:
  /// **'No prayer yet'**
  String get noPrayerYet;

  /// No description provided for @noDayYet.
  ///
  /// In en, this message translates to:
  /// **'No day yet'**
  String get noDayYet;

  /// No description provided for @noSurahYet.
  ///
  /// In en, this message translates to:
  /// **'No surah yet'**
  String get noSurahYet;

  /// No description provided for @noDhikrYet.
  ///
  /// In en, this message translates to:
  /// **'No dhikr yet'**
  String get noDhikrYet;

  /// No description provided for @noCategoryYet.
  ///
  /// In en, this message translates to:
  /// **'No category yet'**
  String get noCategoryYet;

  /// No description provided for @dhikrLabelSimple.
  ///
  /// In en, this message translates to:
  /// **'Dhikr'**
  String get dhikrLabelSimple;

  /// No description provided for @readingOptions.
  ///
  /// In en, this message translates to:
  /// **'Reading options'**
  String get readingOptions;

  /// No description provided for @navigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigation;

  /// No description provided for @goToAyah.
  ///
  /// In en, this message translates to:
  /// **'Go to ayah'**
  String get goToAyah;

  /// No description provided for @jumpToAyahIn.
  ///
  /// In en, this message translates to:
  /// **'Jump to ayah in {surahName}'**
  String jumpToAyahIn(String surahName);

  /// No description provided for @displayAndSharing.
  ///
  /// In en, this message translates to:
  /// **'Display and sharing'**
  String get displayAndSharing;

  /// No description provided for @showLatinTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Show Latin transliteration'**
  String get showLatinTransliteration;

  /// No description provided for @chooseTranslationShownOnCards.
  ///
  /// In en, this message translates to:
  /// **'Choose the translation shown on cards'**
  String get chooseTranslationShownOnCards;

  /// No description provided for @chooseDownloadedExplanations.
  ///
  /// In en, this message translates to:
  /// **'Choose downloaded explanations'**
  String get chooseDownloadedExplanations;

  /// No description provided for @shareCurrentAyah.
  ///
  /// In en, this message translates to:
  /// **'Share current ayah'**
  String get shareCurrentAyah;

  /// No description provided for @createImageForThisAyah.
  ///
  /// In en, this message translates to:
  /// **'Create an image for this ayah'**
  String get createImageForThisAyah;

  /// No description provided for @tafsirSources.
  ///
  /// In en, this message translates to:
  /// **'Tafsir Sources'**
  String get tafsirSources;

  /// No description provided for @setPrayerLocation.
  ///
  /// In en, this message translates to:
  /// **'Set prayer location'**
  String get setPrayerLocation;

  /// No description provided for @ayahLabel.
  ///
  /// In en, this message translates to:
  /// **'Ayah {number}'**
  String ayahLabel(int number);

  /// No description provided for @versesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} verses'**
  String versesCount(int count);

  /// No description provided for @surahVerseCount.
  ///
  /// In en, this message translates to:
  /// **'{surahName} • {count} verses'**
  String surahVerseCount(String surahName, int count);

  /// No description provided for @noJuzResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No juz results found.'**
  String get noJuzResultsFound;

  /// No description provided for @surahCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 surah} other{{count} surahs}}'**
  String surahCount(num count);

  /// No description provided for @surahRange.
  ///
  /// In en, this message translates to:
  /// **'{startSurah} {startVerse} - {endSurah} {endVerse}'**
  String surahRange(
    Object endSurah,
    Object endVerse,
    Object startSurah,
    Object startVerse,
  );

  /// No description provided for @recentQuranTextSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Quran text searches'**
  String get recentQuranTextSearches;

  /// No description provided for @searchResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String searchResultCount(num count);

  /// No description provided for @searchQuranText.
  ///
  /// In en, this message translates to:
  /// **'Search Quran text'**
  String get searchQuranText;

  /// No description provided for @searchQuranTextEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Use this tab for Arabic words or translation text. Surah search stays in the Surahs tab.'**
  String get searchQuranTextEmptyMessage;

  /// No description provided for @noQuranTextResults.
  ///
  /// In en, this message translates to:
  /// **'No Quran text results'**
  String get noQuranTextResults;

  /// No description provided for @noAyahSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No ayahs matched \"{query}\". Try another Arabic word or phrase.'**
  String noAyahSearchResults(Object query);

  /// No description provided for @optionalNote.
  ///
  /// In en, this message translates to:
  /// **'Optional note...'**
  String get optionalNote;

  /// No description provided for @ayahOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Ayah {current} of {total}'**
  String ayahOfTotal(Object current, Object total);

  /// No description provided for @noMatchingSavedAyahs.
  ///
  /// In en, this message translates to:
  /// **'No matching saved ayahs.'**
  String get noMatchingSavedAyahs;

  /// No description provided for @saveAyahsNotesHere.
  ///
  /// In en, this message translates to:
  /// **'Save ayahs, notes, and reflections here.'**
  String get saveAyahsNotesHere;

  /// No description provided for @savedAyahLibraryHint.
  ///
  /// In en, this message translates to:
  /// **'Favourite ayahs quickly, or add folders, tags, and private notes from the reading options.'**
  String get savedAyahLibraryHint;

  /// No description provided for @privateNote.
  ///
  /// In en, this message translates to:
  /// **'Private note'**
  String get privateNote;

  /// No description provided for @writeReflectionHint.
  ///
  /// In en, this message translates to:
  /// **'Write a reflection...'**
  String get writeReflectionHint;

  /// No description provided for @createFolder.
  ///
  /// In en, this message translates to:
  /// **'Create folder'**
  String get createFolder;

  /// No description provided for @tagsHint.
  ///
  /// In en, this message translates to:
  /// **'gratitude, duas'**
  String get tagsHint;

  /// No description provided for @unsorted.
  ///
  /// In en, this message translates to:
  /// **'Unsorted'**
  String get unsorted;

  /// No description provided for @removeSavedAyahDetailsBody.
  ///
  /// In en, this message translates to:
  /// **'This will remove the note, tags, folder, and favourite state for this ayah.'**
  String get removeSavedAyahDetailsBody;

  /// No description provided for @folderName.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get folderName;

  /// No description provided for @folderNameHint.
  ///
  /// In en, this message translates to:
  /// **'Reflections'**
  String get folderNameHint;

  /// No description provided for @libraryFolders.
  ///
  /// In en, this message translates to:
  /// **'Library folders'**
  String get libraryFolders;

  /// No description provided for @defaultSavedAyahDestination.
  ///
  /// In en, this message translates to:
  /// **'Default destination for saved ayahs'**
  String get defaultSavedAyahDestination;

  /// No description provided for @savedAyahCollection.
  ///
  /// In en, this message translates to:
  /// **'Saved ayah collection'**
  String get savedAyahCollection;

  /// No description provided for @renameFolder.
  ///
  /// In en, this message translates to:
  /// **'Rename folder'**
  String get renameFolder;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @deleteFolderQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete {folder}?'**
  String deleteFolderQuestion(Object folder);

  /// No description provided for @deleteFolderBody.
  ///
  /// In en, this message translates to:
  /// **'Saved ayahs in this folder will be moved to Unsorted.'**
  String get deleteFolderBody;

  /// No description provided for @quranRecitation.
  ///
  /// In en, this message translates to:
  /// **'Quran Player'**
  String get quranRecitation;

  /// No description provided for @openPlayer.
  ///
  /// In en, this message translates to:
  /// **'Open Player'**
  String get openPlayer;

  /// No description provided for @resumeRecitation.
  ///
  /// In en, this message translates to:
  /// **'Resume recitation{progress}'**
  String resumeRecitation(Object progress);

  /// No description provided for @ayahsToday.
  ///
  /// In en, this message translates to:
  /// **'ayahs today'**
  String get ayahsToday;

  /// No description provided for @lettersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} letters'**
  String lettersCount(Object count);

  /// No description provided for @dayStreakCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day streak} other{{count} day streak}}'**
  String dayStreakCount(num count);

  /// No description provided for @ayahsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 ayah} other{{count} ayahs}}'**
  String ayahsCount(num count);

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysCount(num count);

  /// No description provided for @todaysPortionComplete.
  ///
  /// In en, this message translates to:
  /// **'Today\'s portion complete'**
  String get todaysPortionComplete;

  /// No description provided for @catchUpAyahsIncluded.
  ///
  /// In en, this message translates to:
  /// **'Includes {count} catch-up ayahs'**
  String catchUpAyahsIncluded(Object count);

  /// No description provided for @ayahsRemainingToday.
  ///
  /// In en, this message translates to:
  /// **'{count} ayahs remaining today'**
  String ayahsRemainingToday(Object count);

  /// No description provided for @todaysPortion.
  ///
  /// In en, this message translates to:
  /// **'Today\'s portion: {count} ayahs'**
  String todaysPortion(Object count);

  /// No description provided for @surahIntroMeta.
  ///
  /// In en, this message translates to:
  /// **'{revelation} · {verseCount} VERSES · JUZ\' {juz}'**
  String surahIntroMeta(Object juz, Object revelation, Object verseCount);

  /// No description provided for @makkah.
  ///
  /// In en, this message translates to:
  /// **'MAKKAH'**
  String get makkah;

  /// No description provided for @madinah.
  ///
  /// In en, this message translates to:
  /// **'MADINAH'**
  String get madinah;

  /// No description provided for @currentAyahOnly.
  ///
  /// In en, this message translates to:
  /// **'Current ayah only'**
  String get currentAyahOnly;

  /// No description provided for @surahAyahRange.
  ///
  /// In en, this message translates to:
  /// **'{surahName} {startAyah} → {endAyah}'**
  String surahAyahRange(Object endAyah, Object startAyah, Object surahName);

  /// No description provided for @intervalEndBeforeStartError.
  ///
  /// In en, this message translates to:
  /// **'Choose an end ayah that is the same as or after the start ayah.'**
  String get intervalEndBeforeStartError;

  /// No description provided for @intervalRange.
  ///
  /// In en, this message translates to:
  /// **'Interval range'**
  String get intervalRange;

  /// No description provided for @intervalRangeHint.
  ///
  /// In en, this message translates to:
  /// **'Select a start and end ayah. Ranges can cross surahs.'**
  String get intervalRangeHint;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @customizeRecitationBehavior.
  ///
  /// In en, this message translates to:
  /// **'Customize recitation behavior'**
  String get customizeRecitationBehavior;

  /// No description provided for @recitation.
  ///
  /// In en, this message translates to:
  /// **'Recitation'**
  String get recitation;

  /// No description provided for @timing.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get timing;

  /// No description provided for @ayahDelay.
  ///
  /// In en, this message translates to:
  /// **'Ayah delay'**
  String get ayahDelay;

  /// No description provided for @audioDownloads.
  ///
  /// In en, this message translates to:
  /// **'Audio downloads'**
  String get audioDownloads;

  /// No description provided for @surahAudioDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Surah audio downloaded'**
  String get surahAudioDownloaded;

  /// No description provided for @allAyahsAvailableOffline.
  ///
  /// In en, this message translates to:
  /// **'All ayahs are available offline'**
  String get allAyahsAvailableOffline;

  /// No description provided for @downloadEveryAyahInSurah.
  ///
  /// In en, this message translates to:
  /// **'Download every ayah in this surah'**
  String get downloadEveryAyahInSurah;

  /// No description provided for @downloadingCurrentAyah.
  ///
  /// In en, this message translates to:
  /// **'Downloading current ayah'**
  String get downloadingCurrentAyah;

  /// No description provided for @deleteCurrentAyahAudio.
  ///
  /// In en, this message translates to:
  /// **'Delete current ayah audio'**
  String get deleteCurrentAyahAudio;

  /// No description provided for @downloadCurrentAyah.
  ///
  /// In en, this message translates to:
  /// **'Download current ayah'**
  String get downloadCurrentAyah;

  /// No description provided for @intervalPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'{position} {kind}'**
  String intervalPickerTitle(Object kind, Object position);

  /// No description provided for @noDelay.
  ///
  /// In en, this message translates to:
  /// **'No delay'**
  String get noDelay;

  /// No description provided for @secondsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 second} other{{count} seconds}}'**
  String secondsCount(num count);

  /// No description provided for @tafsirNeedsDownload.
  ///
  /// In en, this message translates to:
  /// **'This Tafsir needs to be downloaded first. {size}'**
  String tafsirNeedsDownload(Object size);

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloading;

  /// No description provided for @noTafsirTextForAyah.
  ///
  /// In en, this message translates to:
  /// **'No tafsir text available for this ayah.'**
  String get noTafsirTextForAyah;

  /// No description provided for @noTafsirResourcesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Tafsir resources available'**
  String get noTafsirResourcesAvailable;

  /// No description provided for @enterAyahRange.
  ///
  /// In en, this message translates to:
  /// **'Enter an ayah number from 1 to {total}'**
  String enterAyahRange(Object total);

  /// No description provided for @ayahNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Ayah number'**
  String get ayahNumberHint;

  /// No description provided for @downloadingSurahAyahs.
  ///
  /// In en, this message translates to:
  /// **'Downloading {surahName} ayahs'**
  String downloadingSurahAyahs(Object surahName);

  /// No description provided for @downloadedSurahAyahs.
  ///
  /// In en, this message translates to:
  /// **'Downloaded {surahName} ayahs'**
  String downloadedSurahAyahs(Object surahName);

  /// No description provided for @downloadedAllAyahsFor.
  ///
  /// In en, this message translates to:
  /// **'Downloaded all ayahs for {surahName}'**
  String downloadedAllAyahsFor(Object surahName);

  /// No description provided for @failedDownloadSurahAyahs.
  ///
  /// In en, this message translates to:
  /// **'Failed to download {surahName} ayahs.'**
  String failedDownloadSurahAyahs(Object surahName);

  /// No description provided for @downloadAllAyahsForSurah.
  ///
  /// In en, this message translates to:
  /// **'Download all ayah audio for {surahName} for offline listening?'**
  String downloadAllAyahsForSurah(Object surahName);

  /// No description provided for @removedFromFavourites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favourites.'**
  String get removedFromFavourites;

  /// No description provided for @savedAyahsOrganizedHint.
  ///
  /// In en, this message translates to:
  /// **'Saved ayahs can be organized into folders and tags.'**
  String get savedAyahsOrganizedHint;

  /// No description provided for @playerOptions.
  ///
  /// In en, this message translates to:
  /// **'Player options'**
  String get playerOptions;

  /// No description provided for @chooseSurah.
  ///
  /// In en, this message translates to:
  /// **'Choose Surah'**
  String get chooseSurah;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @downloadMp3.
  ///
  /// In en, this message translates to:
  /// **'Download MP3'**
  String get downloadMp3;

  /// No description provided for @availableOffline.
  ///
  /// In en, this message translates to:
  /// **'Available offline'**
  String get availableOffline;

  /// No description provided for @notSaved.
  ///
  /// In en, this message translates to:
  /// **'Not saved'**
  String get notSaved;

  /// No description provided for @playback.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get playback;

  /// No description provided for @sleepTimerOptions.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer options'**
  String get sleepTimerOptions;

  /// No description provided for @endOfSurah.
  ///
  /// In en, this message translates to:
  /// **'End of surah'**
  String get endOfSurah;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @sleepingSoon.
  ///
  /// In en, this message translates to:
  /// **'sleeping soon'**
  String get sleepingSoon;

  /// No description provided for @sleepingInMinutes.
  ///
  /// In en, this message translates to:
  /// **'sleeping in {minutes, plural, =1{1 minute} other{{minutes} minutes}}'**
  String sleepingInMinutes(num minutes);

  /// No description provided for @pendingLabel.
  ///
  /// In en, this message translates to:
  /// **'{label} pending'**
  String pendingLabel(Object label);

  /// No description provided for @loadingSyncedAyah.
  ///
  /// In en, this message translates to:
  /// **'Loading synced ayah'**
  String get loadingSyncedAyah;

  /// No description provided for @syncedAyahUnavailableReciter.
  ///
  /// In en, this message translates to:
  /// **'Synced ayah display is unavailable for this reciter'**
  String get syncedAyahUnavailableReciter;

  /// No description provided for @syncedAyahUnavailableSurah.
  ///
  /// In en, this message translates to:
  /// **'Synced ayah display is unavailable for this surah'**
  String get syncedAyahUnavailableSurah;

  /// No description provided for @downloadTimingsToSyncAyahs.
  ///
  /// In en, this message translates to:
  /// **'Download timings to sync ayahs for this reciter'**
  String get downloadTimingsToSyncAyahs;

  /// No description provided for @unableToPlaySurahAudio.
  ///
  /// In en, this message translates to:
  /// **'Unable to play surah audio.'**
  String get unableToPlaySurahAudio;

  /// No description provided for @downloadingName.
  ///
  /// In en, this message translates to:
  /// **'Downloading {name}'**
  String downloadingName(Object name);

  /// No description provided for @downloadedName.
  ///
  /// In en, this message translates to:
  /// **'Downloaded {name}'**
  String downloadedName(Object name);

  /// No description provided for @failedDownloadName.
  ///
  /// In en, this message translates to:
  /// **'Failed to download {name}'**
  String failedDownloadName(Object name);

  /// No description provided for @failedDownloadSurahAudio.
  ///
  /// In en, this message translates to:
  /// **'Failed to download surah audio.'**
  String get failedDownloadSurahAudio;

  /// No description provided for @deletedMp3Name.
  ///
  /// In en, this message translates to:
  /// **'Deleted {name} MP3'**
  String deletedMp3Name(Object name);

  /// No description provided for @failedDeleteDownloadedSurah.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete downloaded surah.'**
  String get failedDeleteDownloadedSurah;

  /// No description provided for @deleteDownloadedMp3Question.
  ///
  /// In en, this message translates to:
  /// **'Delete Downloaded MP3?'**
  String get deleteDownloadedMp3Question;

  /// No description provided for @removeSurahFromOffline.
  ///
  /// In en, this message translates to:
  /// **'This will remove {name} from offline storage.'**
  String removeSurahFromOffline(Object name);

  /// No description provided for @offlineReady.
  ///
  /// In en, this message translates to:
  /// **'Offline ready'**
  String get offlineReady;

  /// No description provided for @streaming.
  ///
  /// In en, this message translates to:
  /// **'Streaming'**
  String get streaming;

  /// No description provided for @showAyahText.
  ///
  /// In en, this message translates to:
  /// **'Show ayah text'**
  String get showAyahText;

  /// No description provided for @hideAyahText.
  ///
  /// In en, this message translates to:
  /// **'Hide ayah text'**
  String get hideAyahText;

  /// No description provided for @themeSchemeEmeraldGreen.
  ///
  /// In en, this message translates to:
  /// **'Emerald Green'**
  String get themeSchemeEmeraldGreen;

  /// No description provided for @themeSchemeEmeraldGreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The original calm eQuran palette.'**
  String get themeSchemeEmeraldGreenSubtitle;

  /// No description provided for @themeSchemeSapphireBlue.
  ///
  /// In en, this message translates to:
  /// **'Sapphire Blue'**
  String get themeSchemeSapphireBlue;

  /// No description provided for @themeSchemeSapphireBlueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deep navy with sapphire and muted cyan accents.'**
  String get themeSchemeSapphireBlueSubtitle;

  /// No description provided for @themeSchemeRoyalPurple.
  ///
  /// In en, this message translates to:
  /// **'Royal Purple'**
  String get themeSchemeRoyalPurple;

  /// No description provided for @themeSchemeRoyalPurpleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Midnight purple with royal violet highlights.'**
  String get themeSchemeRoyalPurpleSubtitle;

  /// No description provided for @themeSchemeSepia.
  ///
  /// In en, this message translates to:
  /// **'Sepia'**
  String get themeSchemeSepia;

  /// No description provided for @themeSchemeSepiaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Warm parchment, brown, and soft gold tones.'**
  String get themeSchemeSepiaSubtitle;

  /// No description provided for @themeSchemeBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get themeSchemeBlack;

  /// No description provided for @themeSchemeBlackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AMOLED black with restrained teal accents.'**
  String get themeSchemeBlackSubtitle;

  /// No description provided for @themeSchemeRubyRed.
  ///
  /// In en, this message translates to:
  /// **'Ruby Red'**
  String get themeSchemeRubyRed;

  /// No description provided for @themeSchemeRubyRedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deep maroon surfaces with elegant ruby highlights.'**
  String get themeSchemeRubyRedSubtitle;

  /// No description provided for @enterLatitudeLongitude.
  ///
  /// In en, this message translates to:
  /// **'Enter latitude and longitude.'**
  String get enterLatitudeLongitude;

  /// No description provided for @chooseLocationBeforeCalculating.
  ///
  /// In en, this message translates to:
  /// **'Choose a location before calculating'**
  String get chooseLocationBeforeCalculating;

  /// No description provided for @usingDeviceTimezone.
  ///
  /// In en, this message translates to:
  /// **'Using this device timezone.'**
  String get usingDeviceTimezone;

  /// No description provided for @usingDeviceTimezoneUntilLocationAvailable.
  ///
  /// In en, this message translates to:
  /// **'Using device timezone until the location timezone is available.'**
  String get usingDeviceTimezoneUntilLocationAvailable;

  /// No description provided for @displayPrayerTimesUsingTimezone.
  ///
  /// In en, this message translates to:
  /// **'Display prayer times using {timezone}.'**
  String displayPrayerTimesUsingTimezone(Object timezone);

  /// No description provided for @remindersOff.
  ///
  /// In en, this message translates to:
  /// **'Reminders off'**
  String get remindersOff;

  /// No description provided for @remindersOnWaitingLocation.
  ///
  /// In en, this message translates to:
  /// **'On, waiting for location'**
  String get remindersOnWaitingLocation;

  /// No description provided for @allPrayerRemindersOn.
  ///
  /// In en, this message translates to:
  /// **'All prayer reminders on'**
  String get allPrayerRemindersOn;

  /// No description provided for @remindersEnabledCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reminders enabled'**
  String remindersEnabledCount(Object count);

  /// No description provided for @checkingNotificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Checking notification permission...'**
  String get checkingNotificationPermission;

  /// No description provided for @permissionStatusNeedsRetry.
  ///
  /// In en, this message translates to:
  /// **'Permission status needs a retry.'**
  String get permissionStatusNeedsRetry;

  /// No description provided for @localNotificationsScheduled.
  ///
  /// In en, this message translates to:
  /// **'Local notifications are scheduled on this device.'**
  String get localNotificationsScheduled;

  /// No description provided for @notificationPermissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Notification permission granted.'**
  String get notificationPermissionGranted;

  /// No description provided for @notificationPermissionOffEnable.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is off. Enable it to receive prayer reminders.'**
  String get notificationPermissionOffEnable;

  /// No description provided for @prayerRemindersUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Prayer reminders are not supported on this platform.'**
  String get prayerRemindersUnsupported;

  /// No description provided for @checkingExactAlarmPermission.
  ///
  /// In en, this message translates to:
  /// **'Checking exact alarm permission...'**
  String get checkingExactAlarmPermission;

  /// No description provided for @exactAlarmStatusNeedsRetry.
  ///
  /// In en, this message translates to:
  /// **'Exact alarm status needs a retry.'**
  String get exactAlarmStatusNeedsRetry;

  /// No description provided for @alarmPermissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Alarms & reminders permission granted.'**
  String get alarmPermissionGranted;

  /// No description provided for @exactAlarmPermissionNotRequired.
  ///
  /// In en, this message translates to:
  /// **'Exact alarm permission is not required on this platform.'**
  String get exactAlarmPermissionNotRequired;

  /// No description provided for @hisnCategoryCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'This Hisn al Muslim category could not be loaded.'**
  String get hisnCategoryCouldNotLoad;

  /// No description provided for @categoryContainsNoDuas.
  ///
  /// In en, this message translates to:
  /// **'This category does not contain any duas.'**
  String get categoryContainsNoDuas;

  /// No description provided for @couldNotUpdateDua.
  ///
  /// In en, this message translates to:
  /// **'Could not update dua favourite.'**
  String get couldNotUpdateDua;

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActions;

  /// No description provided for @duaCopied.
  ///
  /// In en, this message translates to:
  /// **'Dua copied.'**
  String get duaCopied;

  /// No description provided for @hisnAlMuslimDua.
  ///
  /// In en, this message translates to:
  /// **'Hisn al Muslim dua'**
  String get hisnAlMuslimDua;

  /// No description provided for @copyText.
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get copyText;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Share text'**
  String get shareText;

  /// No description provided for @prayerStats.
  ///
  /// In en, this message translates to:
  /// **'Prayer Stats'**
  String get prayerStats;

  /// No description provided for @quranStats.
  ///
  /// In en, this message translates to:
  /// **'Quran Stats'**
  String get quranStats;

  /// No description provided for @tasbihStats.
  ///
  /// In en, this message translates to:
  /// **'Tasbih Stats'**
  String get tasbihStats;

  /// No description provided for @duaStats.
  ///
  /// In en, this message translates to:
  /// **'Dua Stats'**
  String get duaStats;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @onTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get onTime;

  /// No description provided for @late.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get late;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @log.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get log;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @notYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get notYet;

  /// No description provided for @onTimeThisWeek.
  ///
  /// In en, this message translates to:
  /// **'On time this week'**
  String get onTimeThisWeek;

  /// No description provided for @lateThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Late this week'**
  String get lateThisWeek;

  /// No description provided for @bestPrayer.
  ///
  /// In en, this message translates to:
  /// **'Best prayer'**
  String get bestPrayer;

  /// No description provided for @currentFajrStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Fajr streak'**
  String get currentFajrStreak;

  /// No description provided for @startLoggingFajr.
  ///
  /// In en, this message translates to:
  /// **'Start logging Fajr to track your progress.'**
  String get startLoggingFajr;

  /// No description provided for @fajrVeryConsistent.
  ///
  /// In en, this message translates to:
  /// **'Mashallah, your Fajr is very consistent.'**
  String get fajrVeryConsistent;

  /// No description provided for @fajrGettingStronger.
  ///
  /// In en, this message translates to:
  /// **'Good effort, Fajr is getting stronger.'**
  String get fajrGettingStronger;

  /// No description provided for @fajrEveryAttemptCounts.
  ///
  /// In en, this message translates to:
  /// **'Fajr is a challenge, every attempt counts.'**
  String get fajrEveryAttemptCounts;

  /// No description provided for @fajrConsistency.
  ///
  /// In en, this message translates to:
  /// **'Fajr consistency'**
  String get fajrConsistency;

  /// No description provided for @todaysPrayers.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Prayers'**
  String get todaysPrayers;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get saving;

  /// No description provided for @availableAfter.
  ///
  /// In en, this message translates to:
  /// **'Available after {time}'**
  String availableAfter(Object time);

  /// No description provided for @quranActivity.
  ///
  /// In en, this message translates to:
  /// **'Quran activity'**
  String get quranActivity;

  /// No description provided for @ayahsRead.
  ///
  /// In en, this message translates to:
  /// **'Ayahs Read'**
  String get ayahsRead;

  /// No description provided for @lettersRead.
  ///
  /// In en, this message translates to:
  /// **'Letters Read'**
  String get lettersRead;

  /// No description provided for @activeDays.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get activeDays;

  /// No description provided for @mostActiveDay.
  ///
  /// In en, this message translates to:
  /// **'Most active day'**
  String get mostActiveDay;

  /// No description provided for @ayahsReadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ayahs read'**
  String ayahsReadCount(Object count);

  /// No description provided for @recitationsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} recitations'**
  String recitationsCount(Object count);

  /// No description provided for @surahProgress.
  ///
  /// In en, this message translates to:
  /// **'Surah Progress'**
  String get surahProgress;

  /// No description provided for @surahsComplete.
  ///
  /// In en, this message translates to:
  /// **'{completed} / {total} Surahs complete'**
  String surahsComplete(Object completed, Object total);

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @showAllSurahs.
  ///
  /// In en, this message translates to:
  /// **'Show all {count} surahs'**
  String showAllSurahs(Object count);

  /// No description provided for @quranCompletions.
  ///
  /// In en, this message translates to:
  /// **'Quran Completions'**
  String get quranCompletions;

  /// No description provided for @fullCompletions.
  ///
  /// In en, this message translates to:
  /// **'Full completions'**
  String get fullCompletions;

  /// No description provided for @completeAllSurahsForFirstKhatm.
  ///
  /// In en, this message translates to:
  /// **'Complete all {count} Surahs to record your first Khatm'**
  String completeAllSurahsForFirstKhatm(Object count);

  /// No description provided for @khatmDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Khatm {number} · {date}'**
  String khatmDateLabel(Object date, Object number);

  /// No description provided for @startFirstTasbihSession.
  ///
  /// In en, this message translates to:
  /// **'Start your first Tasbih session'**
  String get startFirstTasbihSession;

  /// No description provided for @totalDhikr.
  ///
  /// In en, this message translates to:
  /// **'Total dhikr'**
  String get totalDhikr;

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get dailyAverage;

  /// No description provided for @openDuaToBeginHistory.
  ///
  /// In en, this message translates to:
  /// **'Open a dua to begin your Duas history'**
  String get openDuaToBeginHistory;

  /// No description provided for @duasViewed.
  ///
  /// In en, this message translates to:
  /// **'Duas viewed'**
  String get duasViewed;

  /// No description provided for @viewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} views'**
  String viewsCount(Object count);

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @activeDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active day} other{{count} active days}}'**
  String activeDaysCount(num count);

  /// No description provided for @monthlyActivitySummary.
  ///
  /// In en, this message translates to:
  /// **'{activeDays} · Best day: {bestDay} · {totalActions} total actions'**
  String monthlyActivitySummary(
    Object activeDays,
    Object bestDay,
    Object totalActions,
  );

  /// No description provided for @dhikrCount.
  ///
  /// In en, this message translates to:
  /// **'{count} dhikr'**
  String dhikrCount(Object count);

  /// No description provided for @duasCount.
  ///
  /// In en, this message translates to:
  /// **'{count} duas'**
  String duasCount(Object count);

  /// No description provided for @quranStreak.
  ///
  /// In en, this message translates to:
  /// **'Quran streak'**
  String get quranStreak;

  /// No description provided for @tasbihStreak.
  ///
  /// In en, this message translates to:
  /// **'Tasbih streak'**
  String get tasbihStreak;

  /// No description provided for @overallStreak.
  ///
  /// In en, this message translates to:
  /// **'Overall streak'**
  String get overallStreak;

  /// No description provided for @dayWorshipStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} day worship streak'**
  String dayWorshipStreak(Object count);

  /// No description provided for @weekShortLabel.
  ///
  /// In en, this message translates to:
  /// **'W{week}'**
  String weekShortLabel(Object week);

  /// No description provided for @youReadMostOn.
  ///
  /// In en, this message translates to:
  /// **'You read most on {day}'**
  String youReadMostOn(Object day);

  /// No description provided for @startReadingToUnlockInsights.
  ///
  /// In en, this message translates to:
  /// **'Start reading to unlock insights'**
  String get startReadingToUnlockInsights;

  /// No description provided for @readingUpFromLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Reading up {percent}% from last week'**
  String readingUpFromLastWeek(Object percent);

  /// No description provided for @readingDownFromLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Reading down {percent}% from last week'**
  String readingDownFromLastWeek(Object percent);

  /// No description provided for @youVisitSurahMostOften.
  ///
  /// In en, this message translates to:
  /// **'You visit {surahName} most often'**
  String youVisitSurahMostOften(Object surahName);

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @mondayShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mondayShort;

  /// No description provided for @tuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesdayShort;

  /// No description provided for @wednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesdayShort;

  /// No description provided for @thursdayShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursdayShort;

  /// No description provided for @fridayShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fridayShort;

  /// No description provided for @saturdayShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturdayShort;

  /// No description provided for @sundayShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sundayShort;

  /// No description provided for @mondayInitial.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get mondayInitial;

  /// No description provided for @tuesdayInitial.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get tuesdayInitial;

  /// No description provided for @wednesdayInitial.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get wednesdayInitial;

  /// No description provided for @thursdayInitial.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get thursdayInitial;

  /// No description provided for @fridayInitial.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get fridayInitial;

  /// No description provided for @saturdayInitial.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get saturdayInitial;

  /// No description provided for @sundayInitial.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get sundayInitial;

  /// No description provided for @mondays.
  ///
  /// In en, this message translates to:
  /// **'Mondays'**
  String get mondays;

  /// No description provided for @tuesdays.
  ///
  /// In en, this message translates to:
  /// **'Tuesdays'**
  String get tuesdays;

  /// No description provided for @wednesdays.
  ///
  /// In en, this message translates to:
  /// **'Wednesdays'**
  String get wednesdays;

  /// No description provided for @thursdays.
  ///
  /// In en, this message translates to:
  /// **'Thursdays'**
  String get thursdays;

  /// No description provided for @fridays.
  ///
  /// In en, this message translates to:
  /// **'Fridays'**
  String get fridays;

  /// No description provided for @saturdays.
  ///
  /// In en, this message translates to:
  /// **'Saturdays'**
  String get saturdays;

  /// No description provided for @sundays.
  ///
  /// In en, this message translates to:
  /// **'Sundays'**
  String get sundays;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @januaryShort.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get januaryShort;

  /// No description provided for @februaryShort.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get februaryShort;

  /// No description provided for @marchShort.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get marchShort;

  /// No description provided for @aprilShort.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get aprilShort;

  /// No description provided for @mayShort.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get mayShort;

  /// No description provided for @juneShort.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get juneShort;

  /// No description provided for @julyShort.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get julyShort;

  /// No description provided for @augustShort.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get augustShort;

  /// No description provided for @septemberShort.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get septemberShort;

  /// No description provided for @octoberShort.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get octoberShort;

  /// No description provided for @novemberShort.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get novemberShort;

  /// No description provided for @decemberShort.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get decemberShort;

  /// No description provided for @dailyQuoteSmallDeeds.
  ///
  /// In en, this message translates to:
  /// **'Small deeds, sincerely done, grow beautifully.'**
  String get dailyQuoteSmallDeeds;

  /// No description provided for @dailyQuoteBeginAgain.
  ///
  /// In en, this message translates to:
  /// **'Begin again with remembrance and gratitude.'**
  String get dailyQuoteBeginAgain;

  /// No description provided for @dailyQuoteSteadyHeart.
  ///
  /// In en, this message translates to:
  /// **'A steady heart returns to Allah each day.'**
  String get dailyQuoteSteadyHeart;

  /// No description provided for @dailyQuoteGentleConsistent.
  ///
  /// In en, this message translates to:
  /// **'Let today\'s worship be gentle and consistent.'**
  String get dailyQuoteGentleConsistent;

  /// No description provided for @dailyQuoteEveryAyah.
  ///
  /// In en, this message translates to:
  /// **'Every ayah read is light for the journey.'**
  String get dailyQuoteEveryAyah;

  /// No description provided for @dailyWorshipComplete.
  ///
  /// In en, this message translates to:
  /// **'Mashallah! Daily worship complete'**
  String get dailyWorshipComplete;

  /// No description provided for @greatProgressKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Great progress, keep going'**
  String get greatProgressKeepGoing;

  /// No description provided for @everyDeedCountsKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Every deed counts, keep going'**
  String get everyDeedCountsKeepGoing;

  /// No description provided for @startYourWorshipForToday.
  ///
  /// In en, this message translates to:
  /// **'Start your worship for today'**
  String get startYourWorshipForToday;

  /// No description provided for @totalRead.
  ///
  /// In en, this message translates to:
  /// **'Total read'**
  String get totalRead;

  /// No description provided for @estimatedLettersRead.
  ///
  /// In en, this message translates to:
  /// **'Estimated letters read'**
  String get estimatedLettersRead;

  /// No description provided for @rewardIsWithAllah.
  ///
  /// In en, this message translates to:
  /// **'Reward is with Allah.'**
  String get rewardIsWithAllah;

  /// No description provided for @totalZakahWealth.
  ///
  /// In en, this message translates to:
  /// **'Total wealth must be at least 200 to calculate Zakah.'**
  String get totalZakahWealth;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
