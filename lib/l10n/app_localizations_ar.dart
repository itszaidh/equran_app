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
}
