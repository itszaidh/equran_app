// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'إي قرآن';

  @override
  String get home => 'الرئيسية';

  @override
  String get quran => 'القرآن';

  @override
  String get prayer => 'الصلاة';

  @override
  String get duas => 'الأدعية';

  @override
  String get more => 'المزيد';

  @override
  String get settings => 'الإعدادات';

  @override
  String get downloads => 'التنزيلات';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get qibla => 'القبلة';

  @override
  String get tasbih => 'التسبيح';

  @override
  String get asmaUlHusna => 'الأسماء الحسنى';

  @override
  String get language => 'اللغة';

  @override
  String get systemDefault => 'لغة النظام';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get vibration => 'الاهتزاز';

  @override
  String get vibrationSubtitle => 'تمكين الاهتزاز التفاعلي عند التنقل.';

  @override
  String get showReadingHistory => 'عرض سجل القراءة';

  @override
  String get showReadingHistorySubtitle => 'يعرض آخر 7 سور تم قراءتها.';

  @override
  String get general => 'عام';

  @override
  String get generalSubtitle => 'سلوك التطبيق والسجل';

  @override
  String get reading => 'القراءة';

  @override
  String get readingSubtitle => 'عرض المصحف والترجمة';

  @override
  String get cardView => 'عرض الآيات الفردية';

  @override
  String get cardViewSubtitle =>
      'يعرض كل آية بشكل مستقل، أو كل آيات السورة في صفحة واحدة.';

  @override
  String get displayTranslation => 'عرض الترجمة';

  @override
  String get displayTranslationSubtitle =>
      'عرض ترجمة كل آية في وضع عرض الآيات الفردية.';

  @override
  String get displayTransliteration => 'عرض اللفظ الصوتي للآيات';

  @override
  String get displayTransliterationSubtitle =>
      'عرض اللفظ الصوتي للآيات بالحروف اللاتينية في وضع عرض الآيات الفردية.';

  @override
  String get dailyQuranGoal => 'الورد اليومي';

  @override
  String dailyQuranGoalSubtitle(int count) {
    return '$count آية يومياً';
  }

  @override
  String get translation => 'الترجمة';

  @override
  String get reciter => 'القارئ';

  @override
  String get audio => 'الصوتيات';

  @override
  String get audioSubtitle => 'القارئ والتشغيل';

  @override
  String get downloadableResources => 'الموارد القابلة للتنزيل';

  @override
  String get downloadableResourcesSubtitle => 'كتب التفسير ومزامنة الصوتيات';

  @override
  String get prayerTimesSettings => 'إعدادات أوقات الصلاة';

  @override
  String get prayerTimesSettingsSubtitle =>
      'إدارة الموقع، طريقة الحساب، العصر، صيغة الوقت، والفروقات.';

  @override
  String get appearance => 'المظهر';

  @override
  String get appearanceSubtitle => 'المظهر، الألوان، ووضع الشاشة';

  @override
  String get themeMode => 'وضع السمة';

  @override
  String get colorScheme => 'سمة الألوان';

  @override
  String get data => 'البيانات';

  @override
  String get dataSubtitle =>
      'النسخ الاحتياطي أو استعادة أو مسح البيانات المحفوظة محلياً';

  @override
  String get backupData => 'نسخ احتياطي للبيانات';

  @override
  String get backupDataSubtitle =>
      'تصدير المفضلة، سجل القراءة، القارئ، أحجام النصوص، وكافة الإعدادات.';

  @override
  String get restoreData => 'استعادة البيانات';

  @override
  String get restoreDataSubtitle =>
      'استعادة المفضلة وسجل القراءة والقارئ وأحجام النصوص والإعدادات المحفوظة من ملف النسخ الاحتياطي.';

  @override
  String get clearReadingHistory => 'مسح سجل القراءة';

  @override
  String get clearReadingHistorySubtitle =>
      'يزيل آخر قراءة ومواقع الاستئناف وتقدم القراءة.';

  @override
  String get clearFavourites => 'مسح المفضلة';

  @override
  String get clearFavouritesSubtitle =>
      'يزيل كل الآيات المحفوظة والمجلدات والملاحظات والوسوم والمفضلة.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get download => 'تنزيل';

  @override
  String get update => 'تحديث';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get continueReading => 'متابعة القراءة';

  @override
  String get lastRead => 'آخر قراءة';

  @override
  String get beginWithQuran => 'ابدأ مع القرآن';

  @override
  String get startReadingSubtitle => 'ابدأ القراءة وسيظهر مكان توقفك هنا.';

  @override
  String get startReading => 'ابدأ القراءة';

  @override
  String get continueListening => 'متابعة الاستماع';

  @override
  String get beginListeningSubtitle =>
      'استمع إلى التلاوة وسيظهر موضع استماعك هنا.';

  @override
  String get startReadingRoutine => 'ابدأ ورداً يومياً';

  @override
  String get buildDailyQuranHabit => 'اجعل قراءة القرآن عادة يومية';

  @override
  String get start => 'ابدأ';

  @override
  String get readingRoutine => 'الورد اليومي';

  @override
  String get continueRoutine => 'متابعة الورد';

  @override
  String get dailyQuranCompanion => 'الرفيق اليومي للقرآن';

  @override
  String get dailyQuranCompanionSubtitle =>
      'تابع تلاوتك واستخدم أدواتك اليومية';

  @override
  String get dailyTools => 'الأدوات اليومية';

  @override
  String get dailyToolsSubtitle => 'وصول سريع للأدوات الأساسية';

  @override
  String get exploreAllFeatures => 'استكشف كافة الميزات';

  @override
  String get dailyAyah => 'آية اليوم';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get surahs => 'السور';

  @override
  String get juz => 'الأجزاء';

  @override
  String get pages => 'الصفحات';

  @override
  String get saved => 'المحفوظات';

  @override
  String get quranJourney => 'رحلة القرآن';

  @override
  String get nextPrayer => 'الصلاة القادمة';

  @override
  String get prayerTimes => 'أوقات الصلاة';

  @override
  String get exploreQibla => 'اتجاه القبلة';

  @override
  String get tasbihCounter => 'مسبحة التسبيح';

  @override
  String get duasAndAzkar => 'الأدعية والأذكار';

  @override
  String get readingPlans => 'خطط القراءة';

  @override
  String get quranStatistics => 'إحصائيات القرآن';

  @override
  String get search => 'البحث';

  @override
  String get dua => 'الدعاء';

  @override
  String get player => 'المشغل';

  @override
  String get searchQuran => 'البحث في القرآن';

  @override
  String get searchHintSurah => 'اسم السورة أو رقمها...';

  @override
  String get searchHintJuz => 'رقم الجزء أو اسم السورة...';

  @override
  String get searchHintPage => 'رقم الصفحة أو السورة أو الجزء...';

  @override
  String get searchHintSaved => 'آية محفوظة، سورة، ملاحظة، أو رقم...';

  @override
  String get searchHintText => 'ابحث في نص القرآن أو الترجمة...';

  @override
  String get savedAyahs => 'الآيات المحفوظة';

  @override
  String ayahNumber(int number) {
    return 'الآية $number';
  }

  @override
  String get play => 'تشغيل';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get next => 'التالي';

  @override
  String get previous => 'السابق';

  @override
  String get repeat => 'تكرار';

  @override
  String get audioOptions => 'خيارات الصوت';

  @override
  String get dismissPlayer => 'إخفاء المشغل';

  @override
  String get playbackOptions => 'خيارات التشغيل';

  @override
  String get previousAyah => 'الآية السابقة';

  @override
  String get nextAyah => 'الآية التالية';

  @override
  String get autoPlayback => 'التشغيل التلقائي';

  @override
  String get repeatInterval => 'تكرار المقطع';

  @override
  String get downloadSurahAudio => 'تنزيل صوت السورة';

  @override
  String get deleteDownloadedAudio => 'حذف الصوت المنزّل';

  @override
  String get deleteDownloadQuestion => 'حذف التنزيل؟';

  @override
  String removeDownloadFromOffline(String title) {
    return 'إزالة $title من التخزين دون اتصال؟';
  }

  @override
  String deletedDownload(String title) {
    return 'تم حذف $title';
  }

  @override
  String get deleteAllDownloadsQuestion => 'حذف كل التنزيلات؟';

  @override
  String deleteAllDownloadsBody(int count, String size) {
    return 'سيؤدي ذلك إلى إزالة $count من ملفات الصوت المنزّلة ($size).';
  }

  @override
  String get deleteAll => 'حذف الكل';

  @override
  String get deletedAllDownloadedAudio => 'تم حذف كل الصوتيات المنزّلة.';

  @override
  String get offlineAudio => 'الصوت دون اتصال';

  @override
  String surahAyahSummary(int surahCount, int ayahCount) {
    return '$surahCount سورة • $ayahCount آية';
  }

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get cleanupPreview => 'معاينة التنظيف';

  @override
  String get downloadedSurahs => 'السور المنزّلة';

  @override
  String get downloadedAyahs => 'الآيات المنزّلة';

  @override
  String get potentialSpaceToFree => 'المساحة الممكن تحريرها';

  @override
  String get cleanupDoesNotRemoveData =>
      'لا يزيل التنظيف المفضلة أو الملاحظات أو خطط القراءة أو نص القرآن أو الإعدادات.';

  @override
  String get reviewDeletion => 'مراجعة الحذف';

  @override
  String get noDownloadedAudioYet => 'لا توجد صوتيات منزّلة بعد.';

  @override
  String get downloadedAudioEmpty =>
      'ستظهر السور والآيات المنزّلة هنا مجمّعة حسب القارئ.';

  @override
  String get ayahs => 'الآيات';

  @override
  String get deleteDownload => 'حذف التنزيل';

  @override
  String get playbackSpeed => 'سرعة التشغيل';

  @override
  String get locationPermissionRequired => 'يلزم السماح بالوصول إلى الموقع';

  @override
  String get unableToReconnect => 'تعذّر إعادة الاتصال';

  @override
  String get reciterOptions => 'خيارات القارئ';

  @override
  String get close => 'إغلاق';

  @override
  String get theme => 'السمة';

  @override
  String get themeModeDark => 'داكن';

  @override
  String get themeModeLight => 'فاتح';

  @override
  String get themeModeSystem => 'تلقائي';

  @override
  String get themeModeDialogTitle => 'وضع السمة';

  @override
  String get themeModeDarkSubtitle => 'استخدام الوضع الليلي دائماً.';

  @override
  String get themeModeLightSubtitle => 'استخدام الوضع الفاتح دائماً.';

  @override
  String get themeModeSystemSubtitle => 'اتباع إعدادات النظام.';

  @override
  String get colorSchemeDialogTitle => 'سمة الألوان';

  @override
  String get translationLanguage => 'لغة الترجمة';

  @override
  String get notDownloaded => 'غير منزّلة';

  @override
  String get playbackRate => 'سرعة التشغيل';

  @override
  String get arabicTextSize => 'حجم النص العربي';

  @override
  String get translationTextSize => 'حجم نص الترجمة';

  @override
  String get resourcesUnavailable => 'الموارد غير متاحة';

  @override
  String get resourcesManifestUnavailable => 'تعذّر تحميل قائمة الموارد.';

  @override
  String get tafsir => 'التفسير';

  @override
  String get audioTimings => 'توقيتات الصوت';

  @override
  String get translations => 'الترجمات';

  @override
  String get refreshManifest => 'تحديث قائمة الموارد';

  @override
  String get checkGithubReleases => 'التحقق من إصدارات GitHub';

  @override
  String get noResourcesListed => 'لا توجد موارد مدرجة في القائمة.';

  @override
  String get selected => 'محدد';

  @override
  String get translationUnsupported => 'هذه الترجمة غير مدعومة حالياً.';

  @override
  String get translationNotInManifest =>
      'هذه الترجمة غير موجودة في قائمة الموارد.';

  @override
  String downloadTranslationQuestion(String name) {
    return 'تنزيل $name؟';
  }

  @override
  String translationNotInstalled(String size) {
    return 'هذه الترجمة غير مثبتة على هذا الجهاز. $size';
  }

  @override
  String installedResource(String name) {
    return 'تم تثبيت $name.';
  }

  @override
  String get unableInstallResource => 'تعذّر تثبيت هذا المورد.';

  @override
  String deleteResourceQuestion(String name) {
    return 'حذف $name؟';
  }

  @override
  String get deleteResourceBody =>
      'سيؤدي ذلك إلى إزالة الملفات المنزّلة من هذا الجهاز.';

  @override
  String deletedResource(String name) {
    return 'تم حذف $name.';
  }

  @override
  String get ayahsPerDay => 'آيات يومياً';

  @override
  String get enterGoalRange => 'أدخل هدفاً من 1 إلى 1000 آية';

  @override
  String get clearReadingHistoryWarning =>
      'تحذير: سيؤدي ذلك إلى مسح آخر قراءة، ومواضع الاستئناف، والإحصائيات، وتقدم الورد.';

  @override
  String get clearFavouritesWarning =>
      'تحذير: سيؤدي ذلك إلى مسح كل الآيات المحفوظة والمجلدات والملاحظات والوسوم والمفضلة.';

  @override
  String get no => 'لا';

  @override
  String get yes => 'نعم';

  @override
  String get restoreBackup => 'استعادة نسخة احتياطية';

  @override
  String get restoreBackupWarning =>
      'سيؤدي ذلك إلى استبدال المفضلة وسجل القراءة والإعدادات الحالية بمحتويات ملف النسخة الاحتياطية.';

  @override
  String get restore => 'استعادة';

  @override
  String get backupReadyToShare => 'ملف النسخة الاحتياطية جاهز للمشاركة.';

  @override
  String backupSavedTo(String path) {
    return 'تم حفظ النسخة الاحتياطية في $path';
  }

  @override
  String get unableCreateBackup => 'تعذّر إنشاء ملف النسخة الاحتياطية.';

  @override
  String restoredBackupSummary(
    int favouritesCount,
    int readingHistoryCount,
    int settingsCount,
  ) {
    return 'تمت استعادة $favouritesCount من المفضلة، و$readingHistoryCount من عناصر السجل، و$settingsCount من الإعدادات.';
  }

  @override
  String get unableRestoreBackup => 'تعذّرت استعادة النسخة الاحتياطية المحددة.';

  @override
  String get locationAndCalculationSettings => 'إعدادات الموقع والحساب';

  @override
  String get quranSearch => 'البحث في القرآن';

  @override
  String get searchArabicAndTranslation => 'البحث في النص العربي والترجمة';

  @override
  String get recitationsAndAudioControls => 'التلاوات وخيارات الصوت';

  @override
  String get compassAndDirection => 'البوصلة والاتجاه';

  @override
  String get offlineAudioAndCleanup => 'الصوت دون اتصال وإدارة الملفات';

  @override
  String get plansGoalsProgress => 'الخطط والأهداف والتقدم';

  @override
  String get calmDhikrCounter => 'عدّاد ذكر هادئ';

  @override
  String get the99BeautifulNames => 'الأسماء الحسنى التسعة والتسعون';

  @override
  String get worshipTrendsAndStreaks => 'اتجاهات العبادة والسلاسل';

  @override
  String get fontsReciterAppBehavior => 'الخطوط والقارئ وسلوك التطبيق';

  @override
  String get switchLightOrNightMode => 'التبديل بين الوضع الفاتح والليلي';

  @override
  String get yourIslamicCompanion => 'رفيقك الإسلامي';

  @override
  String get moreHeroSubtitle =>
      'القبلة والتنزيلات والإعدادات والخطط والأدوات في مكان هادئ واحد.';

  @override
  String get openRoutine => 'فتح الورد';

  @override
  String get aboutAppBody =>
      'إي قرآن رفيق قرآني حديث صُمّم للقراءة المركزة والاستماع والتدبر اليومي.';

  @override
  String versionLabel(String version) {
    return 'الإصدار $version';
  }

  @override
  String get downloadEquran => 'تنزيل إي قرآن';

  @override
  String downloadEquranShareText(String url) {
    return 'نزّل إي قرآن من F-Droid: $url';
  }

  @override
  String get unableOpenShareSheet => 'تعذّر فتح نافذة المشاركة.';

  @override
  String get aboutThisApp => 'عن التطبيق';

  @override
  String get appDetailsAndVersion => 'تفاصيل التطبيق والإصدار';

  @override
  String get shareApp => 'مشاركة التطبيق';

  @override
  String get shareAppSubtitle => 'إرسال إي قرآن للآخرين';

  @override
  String get feedbackContact => 'الملاحظات والتواصل';

  @override
  String get feedbackContactSubtitle => 'الإبلاغ عن مشكلة أو مراسلة الدعم';

  @override
  String get reportIssues => 'الإبلاغ عن المشاكل';

  @override
  String get reportIssuesSubtitle => 'فتح صفحة المشاكل على GitHub.';

  @override
  String get unableOpenIssueTracker => 'تعذّر فتح صفحة المشاكل.';

  @override
  String get emailSupport => 'مراسلة الدعم';

  @override
  String get unableOpenEmailClient => 'تعذّر فتح تطبيق البريد.';

  @override
  String get feedbackThanks => 'نقدّر ملاحظاتك واقتراحاتك.';

  @override
  String get browseBySurah => 'تصفح حسب السورة';

  @override
  String get browseByJuz => 'تصفح حسب الجزء';

  @override
  String get browseByPage => 'تصفح حسب الصفحة';

  @override
  String get closeSearch => 'إغلاق البحث';

  @override
  String get noSurahsFound => 'لم يتم العثور على سور.';

  @override
  String ayahRange(int start, int end) {
    return 'الآيات $start-$end';
  }

  @override
  String juzNumber(int number) {
    return 'الجزء $number';
  }

  @override
  String get prayerNameFajr => 'الفجر';

  @override
  String get prayerNameSunrise => 'الشروق';

  @override
  String get prayerNameDhuhr => 'الظهر';

  @override
  String get prayerNameAsr => 'العصر';

  @override
  String get prayerNameMaghrib => 'المغرب';

  @override
  String get prayerNameIsha => 'العشاء';

  @override
  String get today => 'اليوم';

  @override
  String get previousDay => 'اليوم السابق';

  @override
  String get nextDay => 'اليوم التالي';

  @override
  String get middleOfNight => 'منتصف الليل';

  @override
  String get lastThirdStarts => 'بداية الثلث الأخير';

  @override
  String get useCurrentLocation => 'استخدام الموقع الحالي';

  @override
  String get chooseOnMap => 'اختيار من الخريطة';

  @override
  String get enterCoordinatesManually => 'إدخال الإحداثيات يدوياً';

  @override
  String get locationUseNotice => 'يُستخدم موقعك فقط لحساب أوقات الصلاة.';

  @override
  String get timesCalculatedLocally => 'تُحسب الأوقات محلياً على جهازك.';

  @override
  String get prayerTimesNeedLocation => 'تحتاج أوقات الصلاة إلى موقع';

  @override
  String get prayerTimesLocationSubtitle =>
      'احسب الفجر والظهر والعصر والمغرب والعشاء حسب موقعك الدقيق.';

  @override
  String get setUpLocation => 'إعداد الموقع';

  @override
  String get chooseLocationForNextPrayer =>
      'اختر موقعاً لعرض وقت الصلاة القادمة هنا.';

  @override
  String prayerTimeTitle(String prayer) {
    return 'وقت $prayer';
  }

  @override
  String prayerBeginsIn(String prayer, String countdown) {
    return 'يبدأ $prayer بعد $countdown';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes د';
  }

  @override
  String hoursMinutesShort(int hours, int minutes) {
    return '$hours س $minutes د';
  }

  @override
  String get exactAlarmPermissionOff =>
      'إذن المنبهات الدقيقة متوقف. قد تتأخر تذكيرات الصلاة.';

  @override
  String get zawal => 'الزوال';

  @override
  String get sunset => 'الغروب';

  @override
  String get morning => 'الصباح';

  @override
  String prohibitedTimeEndsIn(String countdown) {
    return 'ينتهي وقت النهي بعد $countdown';
  }

  @override
  String get selectPrayerDate => 'اختر تاريخ الصلاة';

  @override
  String get appSettings => 'إعدادات التطبيق';

  @override
  String get unableGetLocation => 'تعذّر الحصول على الموقع.';

  @override
  String get qiblaBearingUnavailable => 'إحداثيات الموقع الحالي غير متاحة.';

  @override
  String get currentLocationTimedOut =>
      'انتهت مهلة تحديد الموقع الحالي. تحقق من خدمات الموقع ثم أعد المحاولة.';

  @override
  String get compassUnavailable =>
      'البوصلة غير متاحة. استخدم درجة الاتجاه المعروضة.';

  @override
  String get qiblaCalibrationHint =>
      'لأفضل دقة، أمسك الهاتف بشكل مستوٍ وحرّكه على شكل رقم 8 لمعايرة البوصلة.';

  @override
  String get compassAccuracyLow => 'قد تكون دقة البوصلة منخفضة.';

  @override
  String compassAccuracyLowWithDegrees(int degrees) {
    return 'قد تكون دقة البوصلة منخفضة ($degrees°).';
  }

  @override
  String get qiblaLocationServicesDisabled =>
      'فعّل خدمات الموقع لاستخدام القبلة.';

  @override
  String get qiblaLocationPermissionNeeded =>
      'يلزم إذن الموقع لحساب القبلة من موقع جهازك الحالي.';

  @override
  String get qiblaLocationPermissionBlocked =>
      'إذن الموقع محظور. فعّله من إعدادات التطبيق لاستخدام القبلة.';

  @override
  String get qiblaLocationUnavailableMessage =>
      'تعذّر قراءة موقعك الحالي. تحقق من خدمات الموقع ثم أعد المحاولة.';

  @override
  String bearingDegrees(String degrees) {
    return 'الاتجاه $degrees°';
  }

  @override
  String targetDegrees(String degrees) {
    return 'الهدف $degrees°';
  }

  @override
  String headingDegrees(String degrees) {
    return 'اتجاه الجهاز $degrees°';
  }

  @override
  String get heading => 'اتجاه الجهاز';

  @override
  String get facingQibla => 'أنت باتجاه القبلة';

  @override
  String turnRightDegrees(int degrees) {
    return 'اتجه يميناً $degrees°';
  }

  @override
  String turnLeftDegrees(int degrees) {
    return 'اتجه يساراً $degrees°';
  }

  @override
  String get refreshCurrentLocation => 'تحديث الموقع الحالي';

  @override
  String get findingYourLocation => 'جارٍ تحديد موقعك';

  @override
  String get currentLocationRequired => 'الموقع الحالي مطلوب';

  @override
  String get qiblaRequiresLocation =>
      'تحتاج القبلة إلى الموقع الحالي من هذا الجهاز. فعّل خدمات الموقع والإذن للمتابعة.';

  @override
  String get findingLocation => 'جارٍ تحديد الموقع';

  @override
  String get currentLocationUnavailable => 'الموقع الحالي غير متاح';

  @override
  String get currentLocation => 'الموقع الحالي';

  @override
  String get distanceUnavailable => 'المسافة غير متاحة';

  @override
  String kilometersToKaaba(String distance) {
    return '$distance كم إلى الكعبة';
  }

  @override
  String get resetCounter => 'إعادة ضبط العداد';

  @override
  String get recentSessions => 'الجلسات الأخيرة';

  @override
  String get haptics => 'الاهتزاز';

  @override
  String get countSomeDhikrFirst => 'ابدأ بعدّ بعض الذكر أولاً';

  @override
  String get dhikrSessionSaved => 'تم حفظ جلسة الذكر';

  @override
  String get postPrayerDhikr => 'أذكار ما بعد الصلاة';

  @override
  String get postPrayerDhikrComplete => 'اكتملت أذكار ما بعد الصلاة';

  @override
  String dhikrComplete(String label) {
    return 'اكتمل $label';
  }

  @override
  String get todayMetric => 'اليوم';

  @override
  String get rounds => 'الجولات';

  @override
  String get streak => 'السلسلة';

  @override
  String get savedDhikrSessionsEmpty => 'ستظهر جلسات الذكر المحفوظة هنا.';

  @override
  String dhikrSessionCounted(int count, int target, String time) {
    return 'تم عدّ $count من $target • $time';
  }

  @override
  String get location => 'الموقع';

  @override
  String get locationSubtitle => 'يُستخدم فقط لحساب أوقات الصلاة';

  @override
  String get useCurrentLocationDescription =>
      'حفظ موقع هذا الجهاز لحساب أوقات الصلاة.';

  @override
  String get moveMapUnderPin => 'حرّك الخريطة تحت دبوس مركز.';

  @override
  String get enterLatitudeAndLongitude => 'إدخال خط العرض وخط الطول.';

  @override
  String get clearSavedLocation => 'مسح الموقع المحفوظ';

  @override
  String get clearSavedLocationSubtitle =>
      'ستتوقف أوقات الصلاة حتى تختار مجدداً.';

  @override
  String get calculation => 'الحساب';

  @override
  String get calculationSubtitle => 'الطريقة، العصر، العرض العالي، وصيغة الوقت';

  @override
  String get calculationMethod => 'طريقة الحساب';

  @override
  String get asrMethod => 'طريقة العصر';

  @override
  String get highLatitudeAdjustment => 'ضبط العرض العالي';

  @override
  String get highLatitudeAdjustmentSubtitle =>
      'يُستخدم عندما يصعب حساب الفجر والعشاء في المواقع الشمالية أو الجنوبية البعيدة.';

  @override
  String get timeFormat => 'صيغة الوقت';

  @override
  String get useLocationTimezone => 'استخدام المنطقة الزمنية للموقع';

  @override
  String get locationTimezoneSubtitle =>
      'استخدام المنطقة الزمنية للموقع المحفوظ بدلاً من منطقة هذا الجهاز.';

  @override
  String get customMethod => 'طريقة مخصصة';

  @override
  String get fajrAngle => 'زاوية الفجر';

  @override
  String get ishaMode => 'وضع العشاء';

  @override
  String get maghribAngle => 'زاوية المغرب';

  @override
  String get leaveBlankToUseSunset => 'اتركه فارغاً لاستخدام وقت الغروب.';

  @override
  String get fixedIshaTime => 'وقت العشاء الثابت';

  @override
  String get latestIshaTime => 'أحدث وقت للعشاء';

  @override
  String get baseIshaAngle => 'زاوية العشاء الأساسية';

  @override
  String get baseIshaInterval => 'فترة العشاء الأساسية';

  @override
  String get ishaAngle => 'زاوية العشاء';

  @override
  String get ishaInterval => 'فترة العشاء';

  @override
  String get leaveBlankToUseBaseIshaAngle =>
      'اتركه فارغاً لاستخدام زاوية العشاء الأساسية.';

  @override
  String get useIshaAngle => 'استخدام زاوية العشاء';

  @override
  String minutesAfterMaghrib(int minutes) {
    return '$minutes دقيقة بعد المغرب';
  }

  @override
  String get prohibitedTimes => 'أوقات النهي';

  @override
  String get prohibitedTimesSubtitle => 'فترات الشروق والزوال والغروب';

  @override
  String get sunriseProhibitedTime => 'وقت النهي بعد الشروق';

  @override
  String sunriseProhibitedTimeMinutes(int minutes) {
    return '$minutes دقيقة بعد الشروق';
  }

  @override
  String get zawalProhibitedTime => 'وقت النهي عند الزوال';

  @override
  String zawalProhibitedTimeMinutes(int minutes) {
    return '$minutes دقيقة قبل الظهر';
  }

  @override
  String get sunsetProhibitedTime => 'وقت النهي قبل الغروب';

  @override
  String sunsetProhibitedTimeMinutes(int minutes) {
    return '$minutes دقيقة قبل المغرب';
  }

  @override
  String get prayerReminders => 'تذكيرات الصلاة';

  @override
  String get prayerRemindersSubtitle => 'إشعارات قبل كل صلاة';

  @override
  String get prayerRemindersEnabled => 'تذكيرات الصلاة';

  @override
  String get prayerRemindersEnabledSubtitle =>
      'احصل على إشعار قبل كل وقت صلاة.';

  @override
  String get notificationsPermission => 'إذن الإشعارات';

  @override
  String get exactAlarmPermission => 'إذن المنبه الدقيق / المنبهات والتذكيرات';

  @override
  String get enable => 'تفعيل';

  @override
  String get open => 'فتح';

  @override
  String get notificationPermissionOff => 'إذن الإشعارات متوقف.';

  @override
  String get exactAlarmPermissionDisabled =>
      'إذن المنبه الدقيق متوقف. قد تتأخر تذكيرات الصلاة.';

  @override
  String get openAppSettings => 'فتح إعدادات التطبيق';

  @override
  String get requestPermission => 'طلب الإذن';

  @override
  String get openAlarmPermissionSettings => 'فتح إعدادات إذن المنبه';

  @override
  String get chooseLocationBeforeReminders =>
      'اختر موقعاً قبل جدولة التذكيرات.';

  @override
  String get notifyAtSavedPrayerTime => 'إشعار في وقت الصلاة المحفوظ.';

  @override
  String get reminderTime => 'وقت التذكير';

  @override
  String get atPrayerTime => 'عند وقت الصلاة';

  @override
  String minutesBefore(int minutes) {
    return '$minutes دقيقة قبل';
  }

  @override
  String get schedule1MinuteExactTest => 'جدولة اختبار دقيقة واحدة';

  @override
  String get schedule1MinuteExactTestSubtitle => 'يستخدم جدولة تذكير الصلاة.';

  @override
  String get offsetsAreAppliedAfterBaseCalculation =>
      'تُطبّق الفروقات بعد الحساب الأساسي. استخدم دقائق موجبة أو سالبة فقط عندما تحتاج لمطابقة جدول زمني محلي موثوق.';

  @override
  String get manualOffsets => 'الفروقات اليدوية';

  @override
  String get manualOffsetsSubtitle => 'ضبط دقيق للأوقات المحسوبة';

  @override
  String get noManualAdjustment => 'لا يوجد ضبط يدوي';

  @override
  String positiveOrNegativeMinutes(int value) {
    return '$value دقيقة';
  }

  @override
  String get prayerTimesExperimental =>
      'أوقات الصلاة حالياً تجريبية وقد تختلف عن أوقات المسجد المحلي أو الجداول الرسمية. يرجى التحقق قبل الاعتماد عليها.';

  @override
  String get bestMethodAfterLocationSaved => 'أفضل طريقة بعد حفظ الموقع';

  @override
  String minutesBeforePrayer(int minutes) {
    return '$minutes د قبل الصلاة';
  }

  @override
  String get clear => 'مسح';

  @override
  String get enablePrayerTracking => 'تفعيل تتبع الصلاة';

  @override
  String get trackYourDailyPrayers => 'تتبع صلواتك اليومية';

  @override
  String get trackYourDailyPrayersDescription =>
      'سجّل كل صلاة بشكل خاص على جهازك. لا تغادر بياناتك هاتفك أبداً.';

  @override
  String get maybeLater => 'ربما لاحقاً';

  @override
  String get logEachPrayerPrivately =>
      'سجّل كل صلاة بشكل خاص على جهازك. لا تغادر بياناتك هاتفك أبداً.';

  @override
  String get enablePrayerTrackingLabel => 'تفعيل تتبع الصلاة ←';

  @override
  String get somePrayersNotYetAvailable =>
      'لم تكن بعض الصلوات متاحة بعد ولم يتم حفظها.';

  @override
  String get prayerLogSaved => 'تم حفظ سجل الصلاة';

  @override
  String get addNewFolder => 'مجلد جديد';

  @override
  String get editNote => 'تعديل الملاحظة';

  @override
  String get moveToFolder => 'نقل إلى مجلد';

  @override
  String get editTags => 'تعديل الوسوم';

  @override
  String get savedAyah => 'آية محفوظة';

  @override
  String get removeSavedAyah => 'إزالة الآية المحفوظة؟';

  @override
  String get removeSavedAyahBody =>
      'سيؤدي ذلك إلى إزالة الآية من مكتبتك المحفوظة.';

  @override
  String get remove => 'إزالة';

  @override
  String get personalLibrary => 'المكتبة الشخصية';

  @override
  String savedCount(int count) {
    return '$count محفوظ';
  }

  @override
  String get all => 'الكل';

  @override
  String get favourites => 'المفضلة';

  @override
  String get notes => 'الملاحظات';

  @override
  String get folders => 'المجلدات';

  @override
  String get tags => 'الوسوم';

  @override
  String get manageFolders => 'إدارة';

  @override
  String surahLabel(String surahName, Object ayah) {
    return '$surahName • الآية $ayah';
  }

  @override
  String get showTafsir => 'عرض التفسير';

  @override
  String get saveToLibrary => 'حفظ في المكتبة';

  @override
  String get folderTagsAndNote => 'المجلد، الوسوم، وملاحظة خاصة';

  @override
  String get ayahDetails => 'تفاصيل الآية';

  @override
  String get newFolder => 'مجلد جديد';

  @override
  String get create => 'إنشاء';

  @override
  String get translationOption => 'الترجمة';

  @override
  String get showAyahTranslation => 'عرض ترجمة الآية';

  @override
  String get transliterationOption => 'اللفظ الصوتي';

  @override
  String get showAyahTransliteration => 'عرض اللفظ الصوتي للآية';

  @override
  String get cardViewOption => 'عرض الآيات الفردية';

  @override
  String get readOneAyahPerCard => 'قراءة آية واحدة لكل بطاقة';

  @override
  String get chooseAnAction => 'اختر إجراء';

  @override
  String get playThisAyah => 'تشغيل هذه الآية';

  @override
  String get shareImage => 'مشاركة صورة';

  @override
  String get searchCategories => 'البحث في التصنيفات';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get categories => 'التصنيفات';

  @override
  String get noMatchingCategories => 'لا توجد تصنيفات مطابقة';

  @override
  String get trySearchingArabicWord => 'جرب البحث بكلمة أو عبارة عربية أخرى.';

  @override
  String get duasUnavailable => 'الأدعية غير متاحة';

  @override
  String get hisnAlMuslimNotLoaded =>
      'لم يمكن تحميل حصن المسلم من الأصل دون اتصال.';

  @override
  String get retryAction => 'إعادة المحاولة';

  @override
  String get noDuasFound => 'لم يتم العثور على أدعية';

  @override
  String get offlineHisnAlMuslimEmpty =>
      'لم يحتوي ملف حصن المسلم دون الاتصال على أي أدعية.';

  @override
  String get hisnAlMuslim => 'حصن المسلم';

  @override
  String arabicCategoriesDuasOffline(int categoryCount, int duaCount) {
    return '$categoryCount تصنيف عربي - $duaCount دعاء دون اتصال';
  }

  @override
  String get favouriteDuas => 'الأدعية المفضلة';

  @override
  String get favourite => 'إضافة إلى المفضلة';

  @override
  String get removeFavourite => 'إزالة من المفضلة';

  @override
  String get saveDuasHere => 'احفظ الأدعية هنا للوصول السريع';

  @override
  String savedDuasCount(int count, String label) {
    return '$count محفوظ $label';
  }

  @override
  String get tasbihAndDhikr => 'التسبيح والذكر';

  @override
  String get calmCounterDailyPresets => 'عداد هادئ مع إعدادات يومية';

  @override
  String duaCount(int count, Object label) {
    return '$count $label';
  }

  @override
  String get favouriteDuasPage => 'الأدعية المفضلة';

  @override
  String get favouritesUnavailable => 'المفضلة غير متاحة';

  @override
  String get savedDuasNotLoaded => 'لم يمكن تحميل الأدعية المحفوظة الآن.';

  @override
  String get noFavouriteDuasYet => 'لا توجد أدعية مفضلة بعد.';

  @override
  String get tapHeartToSave => 'انقر على القلب في أي بطاقة دعاء لحفظها هنا.';

  @override
  String get categoryUnavailable => 'التصنيف غير متاح';

  @override
  String get categoryNotLoaded => 'لم يمكن تحميل هذا التصنيف من حصن المسلم.';

  @override
  String get categoryNoDuas => 'لم يتم العثور على أدعية';

  @override
  String get categoryDoesNotContainDuas => 'هذا التصنيف لا يحتوي على أي أدعية.';

  @override
  String get downloadTimings => 'تنزيل التوقيتات؟';

  @override
  String reciterNeedsTimings(String size) {
    return 'يحتاج هذا القارئ إلى توقيتات صوتية قبل إظهار نص الآيات متزامناً. $size';
  }

  @override
  String get timingsUnavailable => 'التوقيتات غير متاحة لهذا القارئ.';

  @override
  String get timingsUnavailableSurah => 'التوقيتات غير متاحة لهذه السورة.';

  @override
  String get unableToInstallTimings => 'تعذّر تثبيت التوقيتات.';

  @override
  String installedLabel(String name) {
    return 'تم تثبيت $name.';
  }

  @override
  String get installed => 'مثبت';

  @override
  String get noTafsirSourcesSelected => 'لم يتم اختيار مصادر التفسير';

  @override
  String get chooseTafsirSourcesFirst =>
      'اختر مصدراً واحداً أو أكثر للتفسير أولاً.';

  @override
  String get choose => 'اختيار';

  @override
  String get go => 'انتقل';

  @override
  String get deleteDownloadedMp3 => 'حذف MP3 المنزّل';

  @override
  String get deleteDownloadedAyah => 'حذف الآية المنزّلة؟';

  @override
  String get downloadAllAyahs => 'تنزيل كل الآيات؟';

  @override
  String downloadAllAyahsConfirm(int count, String size) {
    return 'سيؤدي ذلك إلى تنزيل الصوت لجميع $count آية في هذه السورة ($size).';
  }

  @override
  String get surahOption => 'السورة';

  @override
  String get reciterOption => 'القارئ';

  @override
  String get sleepTimerOption => 'مؤقت النوم';

  @override
  String get shuffleOption => 'ترتيب عشوائي';

  @override
  String get shuffleSubtitle => 'عشوائية بعد انتهاء السورة';

  @override
  String get loopCurrentSurah => 'تكرار السورة الحالية';

  @override
  String get loopSubtitle => 'تكرار السورة الحالية';

  @override
  String get downloadTimingsResource => 'تنزيل التوقيتات';

  @override
  String timingsNeedToBeDownloaded(String size) {
    return 'يحتاج هذا القارئ إلى توقيتات صوتية قبل إظهار نص الآيات متزامناً. $size';
  }

  @override
  String get intervalOption => 'الفاصل';

  @override
  String get intervalRepeatOption => 'تكرار الفاصل';

  @override
  String get repeatEachAyahOption => 'تكرار كل آية';

  @override
  String get resetPlaybackOptions => 'إعادة ضبط خيارات التشغيل';

  @override
  String get surahOptionLabel => 'السورة';

  @override
  String get searchCategoriesDua => 'البحث في التصنيفات';

  @override
  String get savedAyahLibrary => 'الآية المحفوظة';

  @override
  String autoAdvancesToNextPreset(String nextPreset) {
    return 'يتقدم تلقائياً إلى $nextPreset';
  }

  @override
  String get previousDhikr => 'الذكر السابق';

  @override
  String get nextDhikr => 'الذكر التالي';

  @override
  String counts33To33To34(int target) {
    return '$target عدد • 33 → 33 → 34';
  }

  @override
  String get assalamuAlaikum => 'السلام عليكم';

  @override
  String get continueYourJourneyToday => 'تابع رحلتك اليوم';

  @override
  String onStreakDay(int streak) {
    return 'أنت على سلسلة $streak يوم - استمر';
  }

  @override
  String get todaysWorship => 'عبادة اليوم';

  @override
  String get ayahsLabel => 'الآيات';

  @override
  String get dhikrLabel => 'الذكر';

  @override
  String get duasLabel => 'الأدعية';

  @override
  String get salahLabel => 'الصلاة';

  @override
  String get dayStreakLabel => 'سلسلة الأيام';

  @override
  String get dailyQuranGoalLabel => 'الورد اليومي للقرآن';

  @override
  String get salah => 'الصلاة';

  @override
  String get quranLabel => 'القرآن';

  @override
  String get tasbihLabel => 'التسبيح';

  @override
  String get activityHistory => 'سجل النشاط';

  @override
  String get streaksLabel => 'السلاسل';

  @override
  String get weekRange => 'أسبوع';

  @override
  String get monthRange => 'شهر';

  @override
  String get yearRange => 'سنة';

  @override
  String get allTimeRange => 'كل الوقت';

  @override
  String get noPrayerYet => 'لا صلاة بعد';

  @override
  String get noDayYet => 'لا يوم بعد';

  @override
  String get noSurahYet => 'لا سورة بعد';

  @override
  String get noDhikrYet => 'لا ذكر بعد';

  @override
  String get noCategoryYet => 'لا تصنيف بعد';

  @override
  String get dhikrLabelSimple => 'ذكر';

  @override
  String get readingOptions => 'خيارات القراءة';

  @override
  String get navigation => 'التنقل';

  @override
  String get goToAyah => 'انتقل إلى الآية';

  @override
  String jumpToAyahIn(String surahName) {
    return 'انتقل إلى آية في $surahName';
  }

  @override
  String get displayAndSharing => 'العرض والمشاركة';

  @override
  String get showLatinTransliteration => 'عرض اللفظ الصوتي اللاتيني';

  @override
  String get chooseTranslationShownOnCards =>
      'اختر الترجمة المعروضة على البطاقات';

  @override
  String get chooseDownloadedExplanations => 'اختر التفسيرات المنزّلة';

  @override
  String get shareCurrentAyah => 'مشاركة الآية الحالية';

  @override
  String get createImageForThisAyah => 'إنشاء صورة لهذه الآية';

  @override
  String get tafsirSources => 'مصادر التفسير';

  @override
  String get setPrayerLocation => 'تعيين موقع الصلاة';

  @override
  String ayahLabel(int number) {
    return 'الآية $number';
  }

  @override
  String versesCount(int count) {
    return '$count آية';
  }

  @override
  String surahVerseCount(String surahName, int count) {
    return '$surahName • $count آية';
  }

  @override
  String get noJuzResultsFound => 'لم يتم العثور على أجزاء.';

  @override
  String surahCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سورة',
      few: '$count سور',
      two: 'سورتان',
      one: 'سورة واحدة',
    );
    return '$_temp0';
  }

  @override
  String surahRange(
    Object endSurah,
    Object endVerse,
    Object startSurah,
    Object startVerse,
  ) {
    return '$startSurah $startVerse - $endSurah $endVerse';
  }

  @override
  String get recentQuranTextSearches => 'عمليات البحث الأخيرة في نص القرآن';

  @override
  String searchResultCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة',
      few: '$count نتائج',
      two: 'نتيجتان',
      one: 'نتيجة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get searchQuranText => 'البحث في نص القرآن';

  @override
  String get searchQuranTextEmptyMessage =>
      'استخدم هذا التبويب للبحث في الكلمات العربية أو نص الترجمة. بحث السور يبقى في تبويب السور.';

  @override
  String get noQuranTextResults => 'لا توجد نتائج في نص القرآن';

  @override
  String noAyahSearchResults(Object query) {
    return 'لم تطابق أي آيات \"$query\". جرّب كلمة أو عبارة أخرى.';
  }

  @override
  String get optionalNote => 'ملاحظة اختيارية...';

  @override
  String ayahOfTotal(Object current, Object total) {
    return 'الآية $current من $total';
  }

  @override
  String get noMatchingSavedAyahs => 'لا توجد آيات محفوظة مطابقة.';

  @override
  String get saveAyahsNotesHere => 'احفظ الآيات والملاحظات والتأملات هنا.';

  @override
  String get savedAyahLibraryHint =>
      'احفظ الآيات بسرعة، أو أضف مجلدات ووسوماً وملاحظات خاصة من خيارات القراءة.';

  @override
  String get privateNote => 'ملاحظة خاصة';

  @override
  String get writeReflectionHint => 'اكتب تأملاً...';

  @override
  String get createFolder => 'إنشاء مجلد';

  @override
  String get tagsHint => 'شكر، دعاء';

  @override
  String get unsorted => 'غير مصنفة';

  @override
  String get removeSavedAyahDetailsBody =>
      'سيؤدي ذلك إلى إزالة الملاحظة والوسوم والمجلد وحالة المفضلة لهذه الآية.';

  @override
  String get folderName => 'اسم المجلد';

  @override
  String get folderNameHint => 'تأملات';

  @override
  String get libraryFolders => 'مجلدات المكتبة';

  @override
  String get defaultSavedAyahDestination => 'الوجهة الافتراضية للآيات المحفوظة';

  @override
  String get savedAyahCollection => 'مجموعة آيات محفوظة';

  @override
  String get renameFolder => 'إعادة تسمية المجلد';

  @override
  String get rename => 'إعادة تسمية';

  @override
  String deleteFolderQuestion(Object folder) {
    return 'حذف $folder؟';
  }

  @override
  String get deleteFolderBody =>
      'ستنقل الآيات المحفوظة في هذا المجلد إلى غير مصنفة.';

  @override
  String get quranRecitation => 'تلاوة القرآن';

  @override
  String get openPlayer => 'فتح المشغل';

  @override
  String resumeRecitation(Object progress) {
    return 'استئناف التلاوة$progress';
  }

  @override
  String get ayahsToday => 'آية اليوم';

  @override
  String lettersCount(Object count) {
    return '$count حرف';
  }

  @override
  String dayStreakCount(num count) {
    return '$count يوم متتالية';
  }

  @override
  String ayahsCount(num count) {
    return '$count آية';
  }

  @override
  String daysCount(num count) {
    return '$count يوم';
  }

  @override
  String get todaysPortionComplete => 'اكتمل ورد اليوم';

  @override
  String catchUpAyahsIncluded(Object count) {
    return 'يتضمن $count آية للتعويض';
  }

  @override
  String ayahsRemainingToday(Object count) {
    return 'بقي $count آية اليوم';
  }

  @override
  String todaysPortion(Object count) {
    return 'ورد اليوم: $count آية';
  }

  @override
  String surahIntroMeta(Object juz, Object revelation, Object verseCount) {
    return '$revelation · $verseCount آية · الجزء $juz';
  }

  @override
  String get makkah => 'مكية';

  @override
  String get madinah => 'مدنية';

  @override
  String get currentAyahOnly => 'الآية الحالية فقط';

  @override
  String surahAyahRange(Object endAyah, Object startAyah, Object surahName) {
    return '$surahName $startAyah ← $endAyah';
  }

  @override
  String get intervalEndBeforeStartError =>
      'اختر آية نهاية مساوية لآية البداية أو بعدها.';

  @override
  String get intervalRange => 'نطاق الفاصل';

  @override
  String get intervalRangeHint =>
      'اختر آية البداية والنهاية. يمكن أن يمتد النطاق بين السور.';

  @override
  String get end => 'النهاية';

  @override
  String get apply => 'تطبيق';

  @override
  String get customizeRecitationBehavior => 'خصّص سلوك التلاوة';

  @override
  String get recitation => 'التلاوة';

  @override
  String get timing => 'التوقيت';

  @override
  String get ayahDelay => 'تأخير الآية';

  @override
  String get audioDownloads => 'تنزيلات الصوت';

  @override
  String get surahAudioDownloaded => 'صوت السورة منزّل';

  @override
  String get allAyahsAvailableOffline => 'كل الآيات متاحة دون اتصال';

  @override
  String get downloadEveryAyahInSurah => 'تنزيل كل آية في هذه السورة';

  @override
  String get downloadingCurrentAyah => 'جارٍ تنزيل الآية الحالية';

  @override
  String get deleteCurrentAyahAudio => 'حذف صوت الآية الحالية';

  @override
  String get downloadCurrentAyah => 'تنزيل الآية الحالية';

  @override
  String intervalPickerTitle(Object kind, Object position) {
    return '$position $kind';
  }

  @override
  String get noDelay => 'بدون تأخير';

  @override
  String secondsCount(num count) {
    return '$count ثانية';
  }

  @override
  String tafsirNeedsDownload(Object size) {
    return 'يجب تنزيل هذا التفسير أولاً. $size';
  }

  @override
  String get downloading => 'جارٍ التنزيل';

  @override
  String get noTafsirTextForAyah => 'لا يوجد نص تفسير لهذه الآية.';

  @override
  String get noTafsirResourcesAvailable => 'لا توجد موارد تفسير متاحة';

  @override
  String enterAyahRange(Object total) {
    return 'أدخل رقم آية من 1 إلى $total';
  }

  @override
  String get ayahNumberHint => 'رقم الآية';

  @override
  String downloadingSurahAyahs(Object surahName) {
    return 'جارٍ تنزيل آيات $surahName';
  }

  @override
  String downloadedSurahAyahs(Object surahName) {
    return 'تم تنزيل آيات $surahName';
  }

  @override
  String downloadedAllAyahsFor(Object surahName) {
    return 'تم تنزيل كل آيات $surahName';
  }

  @override
  String failedDownloadSurahAyahs(Object surahName) {
    return 'فشل تنزيل آيات $surahName.';
  }

  @override
  String downloadAllAyahsForSurah(Object surahName) {
    return 'تنزيل صوت كل آيات $surahName للاستماع دون اتصال؟';
  }

  @override
  String get removedFromFavourites => 'تمت الإزالة من المفضلة.';

  @override
  String get savedAyahsOrganizedHint =>
      'يمكن تنظيم الآيات المحفوظة في مجلدات ووسوم.';

  @override
  String get playerOptions => 'خيارات المشغل';

  @override
  String get chooseSurah => 'اختيار السورة';

  @override
  String get offline => 'دون اتصال';

  @override
  String get downloadMp3 => 'تنزيل MP3';

  @override
  String get availableOffline => 'متاح دون اتصال';

  @override
  String get notSaved => 'غير محفوظ';

  @override
  String get playback => 'التشغيل';

  @override
  String get sleepTimerOptions => 'خيارات مؤقت النوم';

  @override
  String get endOfSurah => 'نهاية السورة';

  @override
  String get enabled => 'مفعّل';

  @override
  String get disabled => 'معطّل';

  @override
  String get off => 'متوقف';

  @override
  String get sleepingSoon => 'سيتوقف قريباً';

  @override
  String sleepingInMinutes(num minutes) {
    return 'يتوقف خلال $minutes دقيقة';
  }

  @override
  String pendingLabel(Object label) {
    return '$label قيد الانتظار';
  }

  @override
  String get loadingSyncedAyah => 'جارٍ تحميل الآية المتزامنة';

  @override
  String get syncedAyahUnavailableReciter =>
      'عرض الآية المتزامنة غير متاح لهذا القارئ';

  @override
  String get syncedAyahUnavailableSurah =>
      'عرض الآية المتزامنة غير متاح لهذه السورة';

  @override
  String get downloadTimingsToSyncAyahs =>
      'نزّل التوقيتات لمزامنة الآيات لهذا القارئ';

  @override
  String get unableToPlaySurahAudio => 'تعذّر تشغيل صوت السورة.';

  @override
  String downloadingName(Object name) {
    return 'جارٍ تنزيل $name';
  }

  @override
  String downloadedName(Object name) {
    return 'تم تنزيل $name';
  }

  @override
  String failedDownloadName(Object name) {
    return 'فشل تنزيل $name';
  }

  @override
  String get failedDownloadSurahAudio => 'فشل تنزيل صوت السورة.';

  @override
  String deletedMp3Name(Object name) {
    return 'تم حذف MP3 لسورة $name';
  }

  @override
  String get failedDeleteDownloadedSurah => 'فشل حذف السورة المنزّلة.';

  @override
  String get deleteDownloadedMp3Question => 'حذف MP3 المنزّل؟';

  @override
  String removeSurahFromOffline(Object name) {
    return 'سيؤدي ذلك إلى إزالة $name من التخزين دون اتصال.';
  }

  @override
  String get offlineReady => 'جاهز دون اتصال';

  @override
  String get streaming => 'بث مباشر';

  @override
  String get showAyahText => 'إظهار نص الآية';

  @override
  String get hideAyahText => 'إخفاء نص الآية';

  @override
  String get themeSchemeEmeraldGreen => 'أخضر زمردي';

  @override
  String get themeSchemeEmeraldGreenSubtitle => 'لوحة إي قرآن الهادئة الأصلية.';

  @override
  String get themeSchemeSapphireBlue => 'أزرق ياقوتي';

  @override
  String get themeSchemeSapphireBlueSubtitle =>
      'كحلي عميق مع لمسات ياقوتية وسماوية هادئة.';

  @override
  String get themeSchemeRoyalPurple => 'بنفسجي ملكي';

  @override
  String get themeSchemeRoyalPurpleSubtitle => 'بنفسجي ليلي مع إبرازات ملكية.';

  @override
  String get themeSchemeSepia => 'بني دافئ';

  @override
  String get themeSchemeSepiaSubtitle => 'درجات ورق دافئة وبنية وذهبية ناعمة.';

  @override
  String get themeSchemeBlack => 'أسود';

  @override
  String get themeSchemeBlackSubtitle => 'أسود AMOLED مع لمسات فيروزية هادئة.';

  @override
  String get themeSchemeRubyRed => 'أحمر ياقوتي';

  @override
  String get themeSchemeRubyRedSubtitle =>
      'أسطح عنابية عميقة مع لمسات ياقوتية أنيقة.';

  @override
  String get enterLatitudeLongitude => 'أدخل خط العرض وخط الطول.';

  @override
  String get chooseLocationBeforeCalculating => 'اختر موقعاً قبل الحساب';

  @override
  String get usingDeviceTimezone => 'يُستخدم توقيت هذا الجهاز.';

  @override
  String get usingDeviceTimezoneUntilLocationAvailable =>
      'يُستخدم توقيت الجهاز حتى تتوفر المنطقة الزمنية للموقع.';

  @override
  String displayPrayerTimesUsingTimezone(Object timezone) {
    return 'عرض أوقات الصلاة باستخدام $timezone.';
  }

  @override
  String get remindersOff => 'التذكيرات متوقفة';

  @override
  String get remindersOnWaitingLocation => 'مفعّلة، بانتظار الموقع';

  @override
  String get allPrayerRemindersOn => 'كل تذكيرات الصلاة مفعّلة';

  @override
  String remindersEnabledCount(Object count) {
    return '$count تذكيرات مفعّلة';
  }

  @override
  String get checkingNotificationPermission =>
      'جارٍ التحقق من إذن الإشعارات...';

  @override
  String get permissionStatusNeedsRetry =>
      'تحتاج حالة الإذن إلى إعادة المحاولة.';

  @override
  String get localNotificationsScheduled =>
      'تمت جدولة الإشعارات المحلية على هذا الجهاز.';

  @override
  String get notificationPermissionGranted => 'تم منح إذن الإشعارات.';

  @override
  String get notificationPermissionOffEnable =>
      'إذن الإشعارات متوقف. فعّله لاستقبال تذكيرات الصلاة.';

  @override
  String get prayerRemindersUnsupported =>
      'تذكيرات الصلاة غير مدعومة على هذه المنصة.';

  @override
  String get checkingExactAlarmPermission =>
      'جارٍ التحقق من إذن المنبه الدقيق...';

  @override
  String get exactAlarmStatusNeedsRetry =>
      'تحتاج حالة المنبه الدقيق إلى إعادة المحاولة.';

  @override
  String get alarmPermissionGranted => 'تم منح إذن المنبهات والتذكيرات.';

  @override
  String get exactAlarmPermissionNotRequired =>
      'إذن المنبه الدقيق غير مطلوب على هذه المنصة.';

  @override
  String get hisnCategoryCouldNotLoad =>
      'لم يمكن تحميل هذا التصنيف من حصن المسلم.';

  @override
  String get categoryContainsNoDuas => 'لا يحتوي هذا التصنيف على أي أدعية.';

  @override
  String get couldNotUpdateDua => 'تعذّر تحديث مفضلة الدعاء.';

  @override
  String get moreActions => 'إجراءات إضافية';

  @override
  String get duaCopied => 'تم نسخ الدعاء.';

  @override
  String get hisnAlMuslimDua => 'دعاء من حصن المسلم';

  @override
  String get copyText => 'نسخ النص';

  @override
  String get shareText => 'مشاركة النص';

  @override
  String get prayerStats => 'إحصاءات الصلاة';

  @override
  String get quranStats => 'إحصاءات القرآن';

  @override
  String get tasbihStats => 'إحصاءات التسبيح';

  @override
  String get duaStats => 'إحصاءات الأدعية';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get thisYear => 'هذه السنة';

  @override
  String get allTime => 'كل الوقت';

  @override
  String get onTime => 'في الوقت';

  @override
  String get late => 'متأخر';

  @override
  String get missed => 'فائت';

  @override
  String get log => 'تسجيل';

  @override
  String get fajr => 'الفجر';

  @override
  String get dhuhr => 'الظهر';

  @override
  String get asr => 'العصر';

  @override
  String get maghrib => 'المغرب';

  @override
  String get isha => 'العشاء';

  @override
  String get notYet => 'لم يحن بعد';

  @override
  String get onTimeThisWeek => 'في الوقت هذا الأسبوع';

  @override
  String get lateThisWeek => 'متأخر هذا الأسبوع';

  @override
  String get bestPrayer => 'أفضل صلاة';

  @override
  String get currentFajrStreak => 'سلسلة الفجر الحالية';

  @override
  String get startLoggingFajr => 'ابدأ بتسجيل الفجر لتتبع تقدمك.';

  @override
  String get fajrVeryConsistent => 'ما شاء الله، الفجر لديك منتظم جداً.';

  @override
  String get fajrGettingStronger => 'جهد طيب، الفجر يتحسن.';

  @override
  String get fajrEveryAttemptCounts => 'الفجر تحدّ، وكل محاولة تُحتسب.';

  @override
  String get fajrConsistency => 'انتظام الفجر';

  @override
  String get todaysPrayers => 'صلوات اليوم';

  @override
  String get saving => 'جارٍ الحفظ';

  @override
  String availableAfter(Object time) {
    return 'متاح بعد $time';
  }

  @override
  String get quranActivity => 'نشاط القرآن';

  @override
  String get ayahsRead => 'الآيات المقروءة';

  @override
  String get lettersRead => 'الحروف المقروءة';

  @override
  String get activeDays => 'الأيام النشطة';

  @override
  String get mostActiveDay => 'أكثر يوم نشاطاً';

  @override
  String ayahsReadCount(Object count) {
    return '$count آية مقروءة';
  }

  @override
  String recitationsCount(Object count) {
    return '$count تلاوة';
  }

  @override
  String get surahProgress => 'تقدم السور';

  @override
  String surahsComplete(Object completed, Object total) {
    return '$completed / $total سورة مكتملة';
  }

  @override
  String get showLess => 'عرض أقل';

  @override
  String showAllSurahs(Object count) {
    return 'عرض كل السور ($count)';
  }

  @override
  String get quranCompletions => 'ختمات القرآن';

  @override
  String get fullCompletions => 'الختمات الكاملة';

  @override
  String completeAllSurahsForFirstKhatm(Object count) {
    return 'أكمل كل السور ($count) لتسجيل أول ختمة';
  }

  @override
  String khatmDateLabel(Object date, Object number) {
    return 'الختمة $number · $date';
  }

  @override
  String get startFirstTasbihSession => 'ابدأ أول جلسة تسبيح';

  @override
  String get totalDhikr => 'إجمالي الذكر';

  @override
  String get dailyAverage => 'المتوسط اليومي';

  @override
  String get openDuaToBeginHistory => 'افتح دعاءً لبدء سجل الأدعية';

  @override
  String get duasViewed => 'الأدعية المعروضة';

  @override
  String viewsCount(Object count) {
    return '$count مشاهدة';
  }

  @override
  String get previousMonth => 'الشهر السابق';

  @override
  String get nextMonth => 'الشهر التالي';

  @override
  String activeDaysCount(num count) {
    return '$count يوم نشط';
  }

  @override
  String monthlyActivitySummary(
    Object activeDays,
    Object bestDay,
    Object totalActions,
  ) {
    return '$activeDays · أفضل يوم: $bestDay · $totalActions إجراء إجمالي';
  }

  @override
  String dhikrCount(Object count) {
    return '$count ذكر';
  }

  @override
  String duasCount(Object count) {
    return '$count دعاء';
  }

  @override
  String get quranStreak => 'سلسلة القرآن';

  @override
  String get tasbihStreak => 'سلسلة التسبيح';

  @override
  String get overallStreak => 'السلسلة العامة';

  @override
  String dayWorshipStreak(Object count) {
    return 'سلسلة عبادة $count يوم';
  }

  @override
  String weekShortLabel(Object week) {
    return 'أ$week';
  }

  @override
  String youReadMostOn(Object day) {
    return 'تقرأ غالباً في $day';
  }

  @override
  String get startReadingToUnlockInsights => 'ابدأ القراءة لعرض الرؤى';

  @override
  String readingUpFromLastWeek(Object percent) {
    return 'القراءة أعلى $percent% من الأسبوع الماضي';
  }

  @override
  String readingDownFromLastWeek(Object percent) {
    return 'القراءة أقل $percent% من الأسبوع الماضي';
  }

  @override
  String youVisitSurahMostOften(Object surahName) {
    return 'تزور $surahName غالباً';
  }

  @override
  String get monday => 'الاثنين';

  @override
  String get tuesday => 'الثلاثاء';

  @override
  String get wednesday => 'الأربعاء';

  @override
  String get thursday => 'الخميس';

  @override
  String get friday => 'الجمعة';

  @override
  String get saturday => 'السبت';

  @override
  String get sunday => 'الأحد';

  @override
  String get mondayShort => 'الاثنين';

  @override
  String get tuesdayShort => 'الثلاثاء';

  @override
  String get wednesdayShort => 'الأربعاء';

  @override
  String get thursdayShort => 'الخميس';

  @override
  String get fridayShort => 'الجمعة';

  @override
  String get saturdayShort => 'السبت';

  @override
  String get sundayShort => 'الأحد';

  @override
  String get mondayInitial => 'ن';

  @override
  String get tuesdayInitial => 'ث';

  @override
  String get wednesdayInitial => 'ر';

  @override
  String get thursdayInitial => 'خ';

  @override
  String get fridayInitial => 'ج';

  @override
  String get saturdayInitial => 'س';

  @override
  String get sundayInitial => 'ح';

  @override
  String get mondays => 'أيام الاثنين';

  @override
  String get tuesdays => 'أيام الثلاثاء';

  @override
  String get wednesdays => 'أيام الأربعاء';

  @override
  String get thursdays => 'أيام الخميس';

  @override
  String get fridays => 'أيام الجمعة';

  @override
  String get saturdays => 'أيام السبت';

  @override
  String get sundays => 'أيام الأحد';

  @override
  String get january => 'يناير';

  @override
  String get february => 'فبراير';

  @override
  String get march => 'مارس';

  @override
  String get april => 'أبريل';

  @override
  String get may => 'مايو';

  @override
  String get june => 'يونيو';

  @override
  String get july => 'يوليو';

  @override
  String get august => 'أغسطس';

  @override
  String get september => 'سبتمبر';

  @override
  String get october => 'أكتوبر';

  @override
  String get november => 'نوفمبر';

  @override
  String get december => 'ديسمبر';

  @override
  String get januaryShort => 'يناير';

  @override
  String get februaryShort => 'فبراير';

  @override
  String get marchShort => 'مارس';

  @override
  String get aprilShort => 'أبريل';

  @override
  String get mayShort => 'مايو';

  @override
  String get juneShort => 'يونيو';

  @override
  String get julyShort => 'يوليو';

  @override
  String get augustShort => 'أغسطس';

  @override
  String get septemberShort => 'سبتمبر';

  @override
  String get octoberShort => 'أكتوبر';

  @override
  String get novemberShort => 'نوفمبر';

  @override
  String get decemberShort => 'ديسمبر';

  @override
  String get dailyQuoteSmallDeeds => 'الأعمال الصغيرة إذا صدقت نمت بجمال.';

  @override
  String get dailyQuoteBeginAgain => 'ابدأ من جديد بالذكر والامتنان.';

  @override
  String get dailyQuoteSteadyHeart => 'القلب الثابت يعود إلى الله كل يوم.';

  @override
  String get dailyQuoteGentleConsistent => 'لتكن عبادة اليوم لطيفة وثابتة.';

  @override
  String get dailyQuoteEveryAyah => 'كل آية تُقرأ نور في الطريق.';

  @override
  String get dailyWorshipComplete => 'ما شاء الله! اكتملت عبادة اليوم';

  @override
  String get greatProgressKeepGoing => 'تقدم رائع، واصل';

  @override
  String get everyDeedCountsKeepGoing => 'كل عمل يُحتسب، واصل';

  @override
  String get startYourWorshipForToday => 'ابدأ عبادتك لليوم';

  @override
  String get totalRead => 'إجمالي المقروء';

  @override
  String get estimatedLettersRead => 'الحروف المقدرة المقروءة';

  @override
  String get rewardIsWithAllah => 'الأجر عند الله.';

  @override
  String get totalZakahWealth =>
      'يجب أن يكون إجمالي الثروة 200 على الأقل لحساب الزكاة.';
}
