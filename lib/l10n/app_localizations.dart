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
  /// **'Prayer Times settings'**
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
  /// **'Begin with the Quran'**
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
