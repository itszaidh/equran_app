// ignore_for_file: constant_identifier_names
class ReciterProfile {
  final String
  id; // Existing lookup ID matching the current settings database key
  final String englishName; // High-fidelity English UI name mapping
  final String arabicName; // High-fidelity Arabic UI name mapping
  final String
  everyAyahFolder; // Exact target folder string matching EveryAyah CDN asset trees
  final String fallbackSurahUrl; // Full-chapter URL (if available)

  const ReciterProfile({
    required this.id,
    required this.englishName,
    required this.arabicName,
    required this.everyAyahFolder,
    required this.fallbackSurahUrl,
  });
}

class QuranAudioCatalog {
  static const List<ReciterProfile> reciters = [
    ReciterProfile(
      id: 'abdul_samad',
      englishName: 'Abdul Samad',
      arabicName: 'عبد الصمد',
      everyAyahFolder: 'AbdulSamad_64kbps_QuranExplorer.Com',
      fallbackSurahUrl: '',
    ),
    ReciterProfile(
      id: 'abdul_basit_mujawwad',
      englishName: 'Abdul Basit (Mujawwad)',
      arabicName: 'عبد الباسط (مجوّد)',
      everyAyahFolder: 'Abdul_Basit_Mujawwad_128kbps',
      fallbackSurahUrl:
          'https://everyayah.com/data/Abdul_Basit_Mujawwad_128kbps',
    ),
    ReciterProfile(
      id: 'abdul_basit_murattal',
      englishName: 'Abdul Basit (Murattal)',
      arabicName: 'عبد الباسط (مرتل)',
      everyAyahFolder: 'Abdul_Basit_Murattal_64kbps',
      fallbackSurahUrl:
          'https://everyayah.com/data/Abdul_Basit_Murattal_64kbps',
    ),
    ReciterProfile(
      id: 'abdul_basit_murattal_192',
      englishName: 'Abdul Basit (Murattal 192kbps)',
      arabicName: 'عبد الباسط (مرتل 192)',
      everyAyahFolder: 'Abdul_Basit_Murattal_192kbps',
      fallbackSurahUrl:
          'https://everyayah.com/data/Abdul_Basit_Murattal_192kbps',
    ),
    ReciterProfile(
      id: 'abdullaah_3awwaad_al_juhaynee',
      englishName: 'Abdullaah Awaad Al-Juhaynee',
      arabicName: 'عبدالله عواد الجهني',
      everyAyahFolder: 'Abdullaah_3awwaad_Al-Juhaynee_128kbps',
      fallbackSurahUrl:
          'https://everyayah.com/data/Abdullaah_3awwaad_Al-Juhaynee_128kbps',
    ),
    ReciterProfile(
      id: 'abdullah_basfar',
      englishName: 'Abdullah Basfar',
      arabicName: 'عبدالله بخاري',
      everyAyahFolder: 'Abdullah_Basfar_32kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Abdullah_Basfar_32kbps',
    ),
    ReciterProfile(
      id: 'abdullah_basfar_64',
      englishName: 'Abdullah Basfar (64kbps)',
      arabicName: 'عبدالله بخاري (64)',
      everyAyahFolder: 'Abdullah_Basfar_64kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Abdullah_Basfar_64kbps',
    ),
    ReciterProfile(
      id: 'abdullah_basfar_192',
      englishName: 'Abdullah Basfar (192kbps)',
      arabicName: 'عبدالله بخاري (192)',
      everyAyahFolder: 'Abdullah_Basfar_192kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Abdullah_Basfar_192kbps',
    ),
    ReciterProfile(
      id: 'abdullah_matroud',
      englishName: 'Abdullah Matroud',
      arabicName: 'عبدالله مطرود',
      everyAyahFolder: 'Abdullah_Matroud_128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Abdullah_Matroud_128kbps',
    ),
    ReciterProfile(
      id: 'abdurrahmaan_as_sudais',
      englishName: 'Abdul Rahman Al-Sudais',
      arabicName: 'عبد الرحمن السديس',
      everyAyahFolder: 'Abdurrahmaan_As-Sudais_64kbps',
      fallbackSurahUrl:
          'https://everyayah.com/data/Abdurrahmaan_As-Sudais_64kbps',
    ),
    ReciterProfile(
      id: 'abdurrahmaan_as_sudais_192',
      englishName: 'Abdul Rahman Al-Sudais (192kbps)',
      arabicName: 'عبد الرحمن السديس (192)',
      everyAyahFolder: 'Abdurrahmaan_As-Sudais_192kbps',
      fallbackSurahUrl:
          'https://everyayah.com/data/Abdurrahmaan_As-Sudais_192kbps',
    ),
    ReciterProfile(
      id: 'abu_bakr_ash_shaatree',
      englishName: 'Abu Bakr Ash-Shaatree',
      arabicName: 'أبو بكر الشاطري',
      everyAyahFolder: 'Abu_Bakr_Ash-Shaatree_64kbps',
      fallbackSurahUrl:
          'https://everyayah.com/data/Abu_Bakr_Ash-Shaatree_64kbps',
    ),
    ReciterProfile(
      id: 'ahmed_neana',
      englishName: 'Ahmed Neana',
      arabicName: 'أحمد نفاع',
      everyAyahFolder: 'Ahmed_Neana_128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Ahmed_Neana_128kbps',
    ),
    ReciterProfile(
      id: 'ahmed_ibn_ali_al_ajamy',
      englishName: 'Ahmed ibn Ali al-Ajamy',
      arabicName: 'أحمد بن علي العجمي',
      everyAyahFolder: 'Ahmed_ibn_Ali_al-Ajamy_64kbps_QuranExplorer.Com',
      fallbackSurahUrl:
          'https://everyayah.com/data/Ahmed_ibn_Ali_al-Ajamy_64kbps_QuranExplorer.Com',
    ),
    ReciterProfile(
      id: 'akram_alalaqimy',
      englishName: 'Akram AlAlaqimy',
      arabicName: 'أكرم العلاقيمي',
      everyAyahFolder: 'Akram_AlAlaqimy_128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Akram_AlAlaqimy_128kbps',
    ),
    ReciterProfile(
      id: 'alafasy',
      englishName: 'Mishary Rashid Alafasy',
      arabicName: 'مشاري راشد العفاسي',
      everyAyahFolder: 'Alafasy_128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Alafasy_128kbps',
    ),
    ReciterProfile(
      id: 'alafasy_64',
      englishName: 'Mishary Rashid Alafasy (64kbps)',
      arabicName: 'مشاري راشد العفاسي (64)',
      everyAyahFolder: 'Alafasy_64kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Alafasy_64kbps',
    ),
    ReciterProfile(
      id: 'ali_hajjaj_alsuesy',
      englishName: 'Ali Hajjaj Al-Suesy',
      arabicName: 'علي حجاج السكري',
      everyAyahFolder: 'Ali_Hajjaj_AlSuesy_128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Ali_Hajjaj_AlSuesy_128kbps',
    ),
    ReciterProfile(
      id: 'ali_jaber',
      englishName: 'Ali Jaber',
      arabicName: 'علي جابر',
      everyAyahFolder: 'Ali_Jaber_64kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Ali_Jaber_64kbps',
    ),
    ReciterProfile(
      id: 'ayman_sowaid',
      englishName: 'Ayman Sowaid',
      arabicName: 'أيمن سويد',
      everyAyahFolder: 'Ayman_Sowaid_64kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Ayman_Sowaid_64kbps',
    ),
    ReciterProfile(
      id: 'fares_abbad',
      englishName: 'Fares Abbad',
      arabicName: 'فارس عباد',
      everyAyahFolder: 'Fares_Abbad_64kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Fares_Abbad_64kbps',
    ),
    ReciterProfile(
      id: 'ghamadi',
      englishName: 'Saad Al-Ghamdi',
      arabicName: 'سعد الغامدي',
      everyAyahFolder: 'Ghamadi_40kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Ghamadi_40kbps',
    ),
    ReciterProfile(
      id: 'hani_rifai',
      englishName: 'Hani Ar-Rifai',
      arabicName: 'هاني الرفاعي',
      everyAyahFolder: 'Hani_Rifai_64kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Hani_Rifai_64kbps',
    ),
    ReciterProfile(
      id: 'hani_rifai_192',
      englishName: 'Hani Ar-Rifai (192kbps)',
      arabicName: 'هاني الرفاعي (192)',
      everyAyahFolder: 'Hani_Rifai_192kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Hani_Rifai_192kbps',
    ),
    ReciterProfile(
      id: 'hudhaify',
      englishName: 'Yassin Al-Hudhaify',
      arabicName: 'ياسين الحذيفي',
      everyAyahFolder: 'Hudhaify_128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Hudhaify_128kbps',
    ),
    ReciterProfile(
      id: 'hudhaify_64',
      englishName: 'Yassin Al-Hudhaify (64kbps)',
      arabicName: 'ياسين الحذيفي (64)',
      everyAyahFolder: 'Hudhaify_64kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Hudhaify_64kbps',
    ),
    ReciterProfile(
      id: 'hudhaify_32',
      englishName: 'Yassin Al-Hudhaify (32kbps)',
      arabicName: 'ياسين الحذيفي (32)',
      everyAyahFolder: 'Hudhaify_32kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Hudhaify_32kbps',
    ),
    ReciterProfile(
      id: 'husary',
      englishName: 'Mahmoud Khalil Al-Husary',
      arabicName: 'محمود خليل الحصري',
      everyAyahFolder: 'Husary_128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Husary_128kbps',
    ),
    ReciterProfile(
      id: 'husary_64',
      englishName: 'Mahmoud Khalil Al-Husary (64kbps)',
      arabicName: 'محمود خليل الحصري (64)',
      everyAyahFolder: 'Husary_64kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Husary_64kbps',
    ),
    ReciterProfile(
      id: 'husary_mujawwad',
      englishName: 'Mahmoud Khalil Al-Husary (Mujawwad)',
      arabicName: 'محمود خليل الحصري (مجوّد)',
      everyAyahFolder: 'Husary_128kbps_Mujawwad',
      fallbackSurahUrl: 'https://everyayah.com/data/Husary_128kbps_Mujawwad',
    ),
    ReciterProfile(
      id: 'husary_mujawwad_64',
      englishName: 'Mahmoud Khalil Al-Husary (Mujawwad 64kbps)',
      arabicName: 'محمود خليل الحصري (مجوّد 64)',
      everyAyahFolder: 'Husary_Mujawwad_64kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Husary_Mujawwad_64kbps',
    ),
    ReciterProfile(
      id: 'husary_muallim',
      englishName: 'Mahmoud Khalil Al-Husary (Muallim)',
      arabicName: 'محمود خليل الحصري (معلّم)',
      everyAyahFolder: 'Husary_Muallim_128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Husary_Muallim_128kbps',
    ),
    ReciterProfile(
      id: 'ibrahim_akhdar',
      englishName: 'Ibrahim Akhdar',
      arabicName: 'إبراهيم أخضر',
      everyAyahFolder: 'Ibrahim_Akhdar_32kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Ibrahim_Akhdar_32kbps',
    ),
    ReciterProfile(
      id: 'ibrahim_akhdar_64',
      englishName: 'Ibrahim Akhdar (64kbps)',
      arabicName: 'إبراهيم أخضر (64)',
      everyAyahFolder: 'Ibrahim_Akhdar_64kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Ibrahim_Akhdar_64kbps',
    ),
    ReciterProfile(
      id: 'karim_mansoori',
      englishName: 'Karim Mansoori',
      arabicName: 'كريم منصوري',
      everyAyahFolder: 'Karim_Mansoori_40kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Karim_Mansoori_40kbps',
    ),
    ReciterProfile(
      id: 'khalid_abdul_qahtaanee',
      englishName: "Khalid Abdul Qahtaanee",
      arabicName: 'خالد عبدالقهوائي',
      everyAyahFolder: "Khaalid_Abdullaah_al-Qahtaanee_192kbps",
      fallbackSurahUrl:
          "https://everyayah.com/data/Khaalid_Abdullaah_al-Qahtaanee_192kbps",
    ),
    ReciterProfile(
      id: 'maher_al_muaiqly',
      englishName: 'Maher Al-Muaiqly',
      arabicName: 'ماهر المعيقلي',
      everyAyahFolder: 'Maher_AlMuaiqly_64kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Maher_AlMuaiqly_64kbps',
    ),
    ReciterProfile(
      id: 'maher_al_muaiqly_128',
      englishName: 'Maher Al-Muaiqly (128kbps)',
      arabicName: 'ماهر المعيقلي (128)',
      everyAyahFolder: 'MaherAlMuaiqly128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/MaherAlMuaiqly128kbps',
    ),
    ReciterProfile(
      id: 'menshawy',
      englishName: 'Mohammed Siddiq Al-Minshawy',
      arabicName: 'محمد صديق المنشاوي',
      everyAyahFolder: 'Menshawi_32kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Menshawi_32kbps',
    ),
    ReciterProfile(
      id: 'minshawi_murattal',
      englishName: 'Siddiq Al-Minshawi (Murattal)',
      arabicName: 'محمد صديق المنشاوي (مرتل)',
      everyAyahFolder: 'Minshawy_Murattal_128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Minshawy_Murattal_128kbps',
    ),
    ReciterProfile(
      id: 'minshawi_mujawwad',
      englishName: 'Siddiq Al-Minshawi (Mujawwad)',
      arabicName: 'محمد صديق المنشاوي (مجوّد)',
      everyAyahFolder: 'Minshawy_Mujawwad_128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Minshawy_Mujawwad_128kbps',
    ),
    ReciterProfile(
      id: 'minshawi_mujawwad_192',
      englishName: 'Siddiq Al-Minshawi (Mujawwad 192kbps)',
      arabicName: 'محمد صديق المنشاوي (مجوّد 192)',
      everyAyahFolder: 'Minshawy_Mujawwad_192kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Minshawy_Mujawwad_192kbps',
    ),
    ReciterProfile(
      id: 'minshawi_teacher',
      englishName: 'Siddiq Al-Minshawi (Teacher)',
      arabicName: 'محمد صديق المنشاوي (معلّم)',
      everyAyahFolder: 'Minshawy_Teacher_128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Minshawy_Teacher_128kbps',
    ),
    ReciterProfile(
      id: 'mohammad_al_tablaway',
      englishName: 'Mohammad al-Tablaway',
      arabicName: 'محمد الطبلاوي',
      everyAyahFolder: 'Mohammad_al_Tablaway_128kbps',
      fallbackSurahUrl:
          'https://everyayah.com/data/Mohammad_al_Tablaway_128kbps',
    ),
    ReciterProfile(
      id: 'mohammad_al_tablaway_64',
      englishName: 'Mohammad al-Tablaway (64kbps)',
      arabicName: 'محمد الطبلاوي (64)',
      everyAyahFolder: 'Mohammad_al_Tablaway_64kbps',
      fallbackSurahUrl:
          'https://everyayah.com/data/Mohammad_al_Tablaway_64kbps',
    ),
    ReciterProfile(
      id: 'muhammad_abdul_kareem',
      englishName: 'Muhammad AbdulKareem',
      arabicName: 'محمد عبد الكريم',
      everyAyahFolder: 'Muhammad_AbdulKareem_128kbps',
      fallbackSurahUrl:
          'https://everyayah.com/data/Muhammad_AbdulKareem_128kbps',
    ),
    ReciterProfile(
      id: 'muhammad_ayyoub',
      englishName: 'Muhammad Ayyoub',
      arabicName: 'محمد أيوب',
      everyAyahFolder: 'Muhammad_Ayyoub_128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Muhammad_Ayyoub_128kbps',
    ),
    ReciterProfile(
      id: 'muhammad_ayyoub_64',
      englishName: 'Muhammad Ayyoub (64kbps)',
      arabicName: 'محمد أيوب (64)',
      everyAyahFolder: 'Muhammad_Ayyoub_64kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Muhammad_Ayyoub_64kbps',
    ),
    ReciterProfile(
      id: 'muhammad_jibreel',
      englishName: 'Muhammad Jibreel',
      arabicName: 'محمد جبريل',
      everyAyahFolder: 'Muhammad_Jibreel_128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Muhammad_Jibreel_128kbps',
    ),
    ReciterProfile(
      id: 'muhammad_jibreel_64',
      englishName: 'Muhammad Jibreel (64kbps)',
      arabicName: 'محمد جبريل (64)',
      everyAyahFolder: 'Muhammad_Jibreel_64kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Muhammad_Jibreel_64kbps',
    ),
    ReciterProfile(
      id: 'muhsin_al_qasim',
      englishName: 'Muhsin Al-Qasim',
      arabicName: 'محسن القصام',
      everyAyahFolder: 'Muhsin_Al_Qasim_192kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Muhsin_Al_Qasim_192kbps',
    ),
    ReciterProfile(
      id: 'mustafa_ismail',
      englishName: 'Mustafa Ismail',
      arabicName: 'مصطفى إسماعيل',
      everyAyahFolder: 'Mustafa_Ismail_48kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Mustafa_Ismail_48kbps',
    ),
    ReciterProfile(
      id: 'nabil_rifa3i',
      englishName: 'Nabil Rifa3i',
      arabicName: 'نبيل رفيعي',
      everyAyahFolder: 'Nabil_Rifa3i_48kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Nabil_Rifa3i_48kbps',
    ),
    ReciterProfile(
      id: 'nasser_al_qatami',
      englishName: 'Nasser Al-Qatami',
      arabicName: 'ناصر القطامي',
      everyAyahFolder: 'Nasser_Alqatami_128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Nasser_Alqatami_128kbps',
    ),
    ReciterProfile(
      id: 'parhizgar',
      englishName: 'Parhizgar',
      arabicName: 'پرهيزگار',
      everyAyahFolder: 'Parhizgar_48kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Parhizgar_48kbps',
    ),
    ReciterProfile(
      id: 'sahl_yassin',
      englishName: 'Sahl Yassin',
      arabicName: 'سهل يسين',
      everyAyahFolder: 'Sahl_Yassin_128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Sahl_Yassin_128kbps',
    ),
    ReciterProfile(
      id: 'salaah_abdulrahman_bukhatir',
      englishName: 'Salaah AbdulRahman Bukhatir',
      arabicName: 'صلاحbukhatir',
      everyAyahFolder: 'Salaah_AbdulRahman_Bukhatir_128kbps',
      fallbackSurahUrl:
          'https://everyayah.com/data/Salaah_AbdulRahman_Bukhatir_128kbps',
    ),
    ReciterProfile(
      id: 'salah_al_budair',
      englishName: 'Salah Al-Budair',
      arabicName: 'صلاحbudair',
      everyAyahFolder: 'Salah_Al_Budair_128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Salah_Al_Budair_128kbps',
    ),
    ReciterProfile(
      id: 'saood_ash_shuraym',
      englishName: 'Saud Al-Shuraim',
      arabicName: 'سعود الشريم',
      everyAyahFolder: 'Saood_ash-Shuraym_64kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Saood_ash-Shuraym_64kbps',
    ),
    ReciterProfile(
      id: 'saood_ash_shuraym_128',
      englishName: 'Saud Al-Shuraim (128kbps)',
      arabicName: 'سعود الشريم (128)',
      everyAyahFolder: 'Saood_ash-Shuraym_128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Saood_ash-Shuraym_128kbps',
    ),
    ReciterProfile(
      id: 'yasser_salamah',
      englishName: 'Yaser Salamah',
      arabicName: 'ياسرسلامة',
      everyAyahFolder: 'Yaser_Salamah_128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Yaser_Salamah_128kbps',
    ),
    ReciterProfile(
      id: 'yasser_ad_dussary',
      englishName: 'Yasser Ad-Dussary',
      arabicName: 'ياسرالدوسري',
      everyAyahFolder: 'Yasser_Ad-Dussary_128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/Yasser_Ad-Dussary_128kbps',
    ),
    ReciterProfile(
      id: 'aziz_alili',
      englishName: 'Aziz Alili',
      arabicName: 'عزيز عليلي',
      everyAyahFolder: 'aziz_alili_128kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/aziz_alili_128kbps',
    ),
    ReciterProfile(
      id: 'khalefa_al_tunaiji',
      englishName: 'Khalefa Al-Tunaiji',
      arabicName: 'خليفة التناوي',
      everyAyahFolder: 'khalefa_al_tunaiji_64kbps',
      fallbackSurahUrl: 'https://everyayah.com/data/khalefa_al_tunaiji_64kbps',
    ),
    ReciterProfile(
      id: 'mahmoud_ali_al_banna',
      englishName: 'Mahmoud Ali Al-Banna',
      arabicName: 'محمود علي البنا',
      everyAyahFolder: 'mahmoud_ali_al_banna_32kbps',
      fallbackSurahUrl:
          'https://everyayah.com/data/mahmoud_ali_al_banna_32kbps',
    ),
  ];

  /// Defensive fallback method to resolve safe defaults if an upgrade path passes a malformed ID key
  static ReciterProfile findById(String id) {
    return reciters.firstWhere(
      (profile) => profile.id == id,
      orElse: () =>
          reciters.first, // Fallback to safe zero-bloat standard profile
    );
  }
}

enum AppReciter {
  abdul_samad(
    code: 'abdul_samad',
    englishName: 'Abdul Samad',
    arabicName: 'عبد الصمد',
  ),
  abdul_basit_mujawwad(
    code: 'abdul_basit_mujawwad',
    englishName: 'Abdul Basit (Mujawwad)',
    arabicName: 'عبد الباسط (مجوّد)',
  ),
  abdul_basit_murattal(
    code: 'abdul_basit_murattal',
    englishName: 'Abdul Basit (Murattal)',
    arabicName: 'عبد الباسط (مرتل)',
  ),
  abdul_basit_murattal_192(
    code: 'abdul_basit_murattal_192',
    englishName: 'Abdul Basit (Murattal 192kbps)',
    arabicName: 'عبد الباسط (مرتل 192)',
  ),
  abdullaah_3awwaad_al_juhaynee(
    code: 'abdullaah_3awwaad_al_juhaynee',
    englishName: 'Abdullaah Awaad Al-Juhaynee',
    arabicName: 'عبدالله عواد الجهني',
  ),
  abdullah_basfar(
    code: 'abdullah_basfar',
    englishName: 'Abdullah Basfar',
    arabicName: 'عبدالله بخاري',
  ),
  abdullah_basfar_64(
    code: 'abdullah_basfar_64',
    englishName: 'Abdullah Basfar (64kbps)',
    arabicName: 'عبدالله بخاري (64)',
  ),
  abdullah_basfar_192(
    code: 'abdullah_basfar_192',
    englishName: 'Abdullah Basfar (192kbps)',
    arabicName: 'عبدالله بخاري (192)',
  ),
  abdullah_matroud(
    code: 'abdullah_matroud',
    englishName: 'Abdullah Matroud',
    arabicName: 'عبدالله مطرود',
  ),
  abdurrahmaan_as_sudais(
    code: 'abdurrahmaan_as_sudais',
    englishName: 'Abdul Rahman Al-Sudais',
    arabicName: 'عبد الرحمن السديس',
  ),
  abdurrahmaan_as_sudais_192(
    code: 'abdurrahmaan_as_sudais_192',
    englishName: 'Abdul Rahman Al-Sudais (192kbps)',
    arabicName: 'عبد الرحمن السديس (192)',
  ),
  abu_bakr_ash_shaatree(
    code: 'abu_bakr_ash_shaatree',
    englishName: 'Abu Bakr Ash-Shaatree',
    arabicName: 'أبو بكر الشاطري',
  ),
  ahmed_neana(
    code: 'ahmed_neana',
    englishName: 'Ahmed Neana',
    arabicName: 'أحمد نفاع',
  ),
  ahmed_ibn_ali_al_ajamy(
    code: 'ahmed_ibn_ali_al_ajamy',
    englishName: 'Ahmed ibn Ali al-Ajamy',
    arabicName: 'أحمد بن علي العجمي',
  ),
  akram_alalaqimy(
    code: 'akram_alalaqimy',
    englishName: 'Akram AlAlaqimy',
    arabicName: 'أكرم العلاقيمي',
  ),
  alafasy(
    code: 'alafasy',
    englishName: 'Mishary Rashid Alafasy',
    arabicName: 'مشاري راشد العفاسي',
  ),
  alafasy_64(
    code: 'alafasy_64',
    englishName: 'Mishary Rashid Alafasy (64kbps)',
    arabicName: 'مشاري راشد العفاسي (64)',
  ),
  ali_hajjaj_alsuesy(
    code: 'ali_hajjaj_alsuesy',
    englishName: 'Ali Hajjaj Al-Suesy',
    arabicName: 'علي حجاج السكري',
  ),
  ali_jaber(
    code: 'ali_jaber',
    englishName: 'Ali Jaber',
    arabicName: 'علي جابر',
  ),
  ayman_sowaid(
    code: 'ayman_sowaid',
    englishName: 'Ayman Sowaid',
    arabicName: 'أيمن سويد',
  ),
  fares_abbad(
    code: 'fares_abbad',
    englishName: 'Fares Abbad',
    arabicName: 'فارس عباد',
  ),
  ghamadi(
    code: 'ghamadi',
    englishName: 'Saad Al-Ghamdi',
    arabicName: 'سعد الغامدي',
  ),
  hani_rifai(
    code: 'hani_rifai',
    englishName: 'Hani Ar-Rifai',
    arabicName: 'هاني الرفاعي',
  ),
  hani_rifai_192(
    code: 'hani_rifai_192',
    englishName: 'Hani Ar-Rifai (192kbps)',
    arabicName: 'هاني الرفاعي (192)',
  ),
  hudhaify(
    code: 'hudhaify',
    englishName: 'Yassin Al-Hudhaify',
    arabicName: 'ياسين الحذيفي',
  ),
  hudhaify_64(
    code: 'hudhaify_64',
    englishName: 'Yassin Al-Hudhaify (64kbps)',
    arabicName: 'ياسين الحذيفي (64)',
  ),
  hudhaify_32(
    code: 'hudhaify_32',
    englishName: 'Yassin Al-Hudhaify (32kbps)',
    arabicName: 'ياسين الحذيفي (32)',
  ),
  husary(
    code: 'husary',
    englishName: 'Mahmoud Khalil Al-Husary',
    arabicName: 'محمود خليل الحصري',
  ),
  husary_64(
    code: 'husary_64',
    englishName: 'Mahmoud Khalil Al-Husary (64kbps)',
    arabicName: 'محمود خليل الحصري (64)',
  ),
  husary_mujawwad(
    code: 'husary_mujawwad',
    englishName: 'Mahmoud Khalil Al-Husary (Mujawwad)',
    arabicName: 'محمود خليل الحصري (مجوّد)',
  ),
  husary_mujawwad_64(
    code: 'husary_mujawwad_64',
    englishName: 'Mahmoud Khalil Al-Husary (Mujawwad 64kbps)',
    arabicName: 'محمود خليل الحصري (مجوّد 64)',
  ),
  husary_muallim(
    code: 'husary_muallim',
    englishName: 'Mahmoud Khalil Al-Husary (Muallim)',
    arabicName: 'محمود خليل الحصري (معلّم)',
  ),
  ibrahim_akhdar(
    code: 'ibrahim_akhdar',
    englishName: 'Ibrahim Akhdar',
    arabicName: 'إبراهيم أخضر',
  ),
  ibrahim_akhdar_64(
    code: 'ibrahim_akhdar_64',
    englishName: 'Ibrahim Akhdar (64kbps)',
    arabicName: 'إبراهيم أخضر (64)',
  ),
  karim_mansoori(
    code: 'karim_mansoori',
    englishName: 'Karim Mansoori',
    arabicName: 'كريم منصوري',
  ),
  khalid_abdul_qahtaanee(
    code: 'khalid_abdul_qahtaanee',
    englishName: "Khalid Abdul Qahtaanee",
    arabicName: 'خالد عبدالقهوائي',
  ),
  maher_al_muaiqly(
    code: 'maher_al_muaiqly',
    englishName: 'Maher Al-Muaiqly',
    arabicName: 'ماهر المعيقلي',
  ),
  maher_al_muaiqly_128(
    code: 'maher_al_muaiqly_128',
    englishName: 'Maher Al-Muaiqly (128kbps)',
    arabicName: 'ماهر المعيقلي (128)',
  ),
  menshawy(
    code: 'menshawy',
    englishName: 'Mohammed Siddiq Al-Minshawy',
    arabicName: 'محمد صديق المنشاوي',
  ),
  minshawi_murattal(
    code: 'minshawi_murattal',
    englishName: 'Siddiq Al-Minshawi (Murattal)',
    arabicName: 'محمد صديق المنشاوي (مرتل)',
  ),
  minshawi_mujawwad(
    code: 'minshawi_mujawwad',
    englishName: 'Siddiq Al-Minshawi (Mujawwad)',
    arabicName: 'محمد صديق المنشاوي (مجوّد)',
  ),
  minshawi_mujawwad_192(
    code: 'minshawi_mujawwad_192',
    englishName: 'Siddiq Al-Minshawi (Mujawwad 192kbps)',
    arabicName: 'محمد صديق المنشاوي (مجوّد 192)',
  ),
  minshawi_teacher(
    code: 'minshawi_teacher',
    englishName: 'Siddiq Al-Minshawi (Teacher)',
    arabicName: 'محمد صديق المنشاوي (معلّم)',
  ),
  mohammad_al_tablaway(
    code: 'mohammad_al_tablaway',
    englishName: 'Mohammad al-Tablaway',
    arabicName: 'محمد الطبلاوي',
  ),
  mohammad_al_tablaway_64(
    code: 'mohammad_al_tablaway_64',
    englishName: 'Mohammad al-Tablaway (64kbps)',
    arabicName: 'محمد الطبلاوي (64)',
  ),
  muhammad_abdul_kareem(
    code: 'muhammad_abdul_kareem',
    englishName: 'Muhammad AbdulKareem',
    arabicName: 'محمد عبد الكريم',
  ),
  muhammad_ayyoub(
    code: 'muhammad_ayyoub',
    englishName: 'Muhammad Ayyoub',
    arabicName: 'محمد أيوب',
  ),
  muhammad_ayyoub_64(
    code: 'muhammad_ayyoub_64',
    englishName: 'Muhammad Ayyoub (64kbps)',
    arabicName: 'محمد أيوب (64)',
  ),
  muhammad_jibreel(
    code: 'muhammad_jibreel',
    englishName: 'Muhammad Jibreel',
    arabicName: 'محمد جبريل',
  ),
  muhammad_jibreel_64(
    code: 'muhammad_jibreel_64',
    englishName: 'Muhammad Jibreel (64kbps)',
    arabicName: 'محمد جبريل (64)',
  ),
  muhsin_al_qasim(
    code: 'muhsin_al_qasim',
    englishName: 'Muhsin Al-Qasim',
    arabicName: 'محسن القصام',
  ),
  mustafa_ismail(
    code: 'mustafa_ismail',
    englishName: 'Mustafa Ismail',
    arabicName: 'مصطفى إسماعيل',
  ),
  nabil_rifa3i(
    code: 'nabil_rifa3i',
    englishName: 'Nabil Rifa3i',
    arabicName: 'نبيل رفيعي',
  ),
  nasser_al_qatami(
    code: 'nasser_al_qatami',
    englishName: 'Nasser Al-Qatami',
    arabicName: 'ناصر القطامي',
  ),
  parhizgar(
    code: 'parhizgar',
    englishName: 'Parhizgar',
    arabicName: 'پرهيزگار',
  ),
  sahl_yassin(
    code: 'sahl_yassin',
    englishName: 'Sahl Yassin',
    arabicName: 'سهل يسين',
  ),
  salaah_abdulrahman_bukhatir(
    code: 'salaah_abdulrahman_bukhatir',
    englishName: 'Salaah AbdulRahman Bukhatir',
    arabicName: 'صلاحbukhatir',
  ),
  salah_al_budair(
    code: 'salah_al_budair',
    englishName: 'Salah Al-Budair',
    arabicName: 'صلاحbudair',
  ),
  saood_ash_shuraym(
    code: 'saood_ash_shuraym',
    englishName: 'Saud Al-Shuraim',
    arabicName: 'سعود الشريم',
  ),
  saood_ash_shuraym_128(
    code: 'saood_ash_shuraym_128',
    englishName: 'Saud Al-Shuraim (128kbps)',
    arabicName: 'سعود الشريم (128)',
  ),
  yasser_salamah(
    code: 'yasser_salamah',
    englishName: 'Yaser Salamah',
    arabicName: 'ياسرسلامة',
  ),
  yasser_ad_dussary(
    code: 'yasser_ad_dussary',
    englishName: 'Yasser Ad-Dussary',
    arabicName: 'ياسرالدوسري',
  ),
  aziz_alili(
    code: 'aziz_alili',
    englishName: 'Aziz Alili',
    arabicName: 'عزيز عليلي',
  ),
  khalefa_al_tunaiji(
    code: 'khalefa_al_tunaiji',
    englishName: 'Khalefa Al-Tunaiji',
    arabicName: 'خليفة التناوي',
  ),
  mahmoud_ali_al_banna(
    code: 'mahmoud_ali_al_banna',
    englishName: 'Mahmoud Ali Al-Banna',
    arabicName: 'محمود علي البنا',
  );

  final String code;
  final String englishName;
  final String arabicName;

  const AppReciter({
    required this.code,
    required this.englishName,
    required this.arabicName,
  });

  String displayName({required bool arabic}) =>
      arabic ? arabicName : englishName;

  static const Map<String, String> _legacyCodeMap = <String, String>{
    // Legacy reciter codes from previous API
    '1': 'alafasy',
    '2': 'alafasy',
    '3': 'alafasy',
    '4': 'alafasy',
    '5': 'alafasy',
    'ar.alafasy': 'alafasy',
    'ar.alafasi': 'alafasy',
    // Old snake_case IDs from previous enum
    'sudais': 'abdurrahmaan_as_sudais',
    'shuraym': 'saood_ash_shuraym',
    'ajamy': 'ahmed_ibn_ali_al_ajamy',
    'minshawi_mujawwad': 'minshawi_mujawwad',
    'minshawi_murattal': 'minshawi_murattal',
    'abdul_basit_mujawwad': 'abdul_basit_mujawwad',
    'abdul_basit_murattal': 'abdul_basit_murattal',
    'husary': 'husary',
    'ghamdi': 'ghamadi',
    'alafasy': 'alafasy',
  };

  static String normalizeCode(String? code) {
    if (code == null || code.isEmpty) {
      return AppReciter.alafasy.code;
    }
    return _legacyCodeMap[code] ?? code;
  }

  static AppReciter fromCode(String? code) {
    final String normalizedCode = normalizeCode(code);
    return AppReciter.values.firstWhere(
      (r) => r.code == normalizedCode,
      orElse: () => AppReciter.alafasy,
    );
  }
}

