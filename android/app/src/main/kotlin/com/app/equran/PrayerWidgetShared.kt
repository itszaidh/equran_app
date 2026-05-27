package com.app.equran

import android.content.Context
import androidx.compose.ui.graphics.Color
import es.antonborri.home_widget.HomeWidgetPlugin

internal data class PrayerWidgetPalette(
  val bgColor: Color,
  val surfaceColor: Color,
  val primaryColor: Color,
  val primaryStrongColor: Color,
  val textColor: Color,
  val textSecondaryColor: Color,
  val textMutedColor: Color,
  val goldColor: Color,
  val borderColor: Color,
  val onPrimaryColor: Color,
)

internal data class PrayerWidgetLabels(
  val headerLabel: String,
  val fajrLabel: String,
  val sunriseLabel: String,
  val dhuhrLabel: String,
  val asrLabel: String,
  val maghribLabel: String,
  val ishaLabel: String,
  val updatedLabel: String,
  val placeholderLabel: String,
)

internal data class PrayerWidgetState(
  val fajr: String?,
  val sunrise: String,
  val dhuhr: String,
  val asr: String,
  val maghrib: String,
  val isha: String,
  val next: String,
  val nextTime: String,
  val loc: String,
  val updated: String,
  val palette: PrayerWidgetPalette,
  val labels: PrayerWidgetLabels,
)

internal fun loadPrayerWidgetState(context: Context): PrayerWidgetState {
  val prefs = HomeWidgetPlugin.getData(context)

  val palette = PrayerWidgetPalette(
    bgColor = hexToColor(prefs.getString("w_bg", "FF07110E") ?: "FF07110E"),
    surfaceColor = hexToColor(prefs.getString("w_surface", "FF111A17") ?: "FF111A17"),
    primaryColor = hexToColor(prefs.getString("w_primary", "FF1E7A61") ?: "FF1E7A61"),
    primaryStrongColor = hexToColor(
      prefs.getString("w_primary_strong", "FF125B49") ?: "FF125B49"
    ),
    textColor = hexToColor(prefs.getString("w_text", "FFF3F7F4") ?: "FFF3F7F4"),
    textSecondaryColor = hexToColor(
      prefs.getString("w_text_sec", "FFB8C2BC") ?: "FFB8C2BC"
    ),
    textMutedColor = hexToColor(
      prefs.getString("w_text_muted", "FF83908A") ?: "FF83908A"
    ),
    goldColor = hexToColor(prefs.getString("w_gold", "FFD6A84F") ?: "FFD6A84F"),
    borderColor = hexToColor(prefs.getString("w_border", "FF26332E") ?: "FF26332E"),
    onPrimaryColor = hexToColor(
      prefs.getString("w_on_primary", "FFFFFFFF") ?: "FFFFFFFF"
    ),
  )

  val labels = PrayerWidgetLabels(
    headerLabel = prefs.getString("label_header", "Prayer Times") ?: "Prayer Times",
    fajrLabel = prefs.getString("label_fajr", "Fajr") ?: "Fajr",
    sunriseLabel = prefs.getString("label_sunrise", "Sunrise") ?: "Sunrise",
    dhuhrLabel = prefs.getString("label_dhuhr", "Dhuhr") ?: "Dhuhr",
    asrLabel = prefs.getString("label_asr", "Asr") ?: "Asr",
    maghribLabel = prefs.getString("label_maghrib", "Maghrib") ?: "Maghrib",
    ishaLabel = prefs.getString("label_isha", "Isha") ?: "Isha",
    updatedLabel = prefs.getString("label_updated", "Updated") ?: "Updated",
    placeholderLabel = prefs.getString(
      "label_placeholder",
      "Tap to load prayer times"
    ) ?: "Tap to load prayer times",
  )

  return PrayerWidgetState(
    fajr = prefs.getString("fajr_time", null),
    sunrise = prefs.getString("sunrise_time", "---") ?: "---",
    dhuhr = prefs.getString("dhuhr_time", "---") ?: "---",
    asr = prefs.getString("asr_time", "---") ?: "---",
    maghrib = prefs.getString("maghrib_time", "---") ?: "---",
    isha = prefs.getString("isha_time", "---") ?: "---",
    next = prefs.getString("next_prayer", "") ?: "",
    nextTime = prefs.getString("next_prayer_time", "") ?: "",
    loc = prefs.getString("location_name", "") ?: "",
    updated = prefs.getString("last_updated", "") ?: "",
    palette = palette,
    labels = labels,
  )
}

internal fun hexToColor(hex: String): Color {
  val normalized = hex.removePrefix("#")
  return Color(android.graphics.Color.parseColor("#$normalized"))
}

internal fun prayerLabelForId(id: String, labels: PrayerWidgetLabels): String {
  return when (id) {
    "fajr" -> labels.fajrLabel
    "sunrise" -> labels.sunriseLabel
    "dhuhr" -> labels.dhuhrLabel
    "asr" -> labels.asrLabel
    "maghrib" -> labels.maghribLabel
    "isha" -> labels.ishaLabel
    else -> ""
  }
}

internal fun prayerTimeForId(state: PrayerWidgetState, prayerId: String): String {
  return when (prayerId) {
    "fajr" -> state.fajr ?: "---"
    "sunrise" -> state.sunrise
    "dhuhr" -> state.dhuhr
    "asr" -> state.asr
    "maghrib" -> state.maghrib
    "isha" -> state.isha
    else -> "---"
  }
}

internal fun headerSupportingLine(loc: String, updatedLabel: String, updated: String): String {
  val trimmedLoc = loc.trim()
  if (trimmedLoc.length in 1..22) {
    return trimmedLoc
  }
  if (updated.isNotEmpty()) {
    return "$updatedLabel $updated"
  }
  return ""
}

internal fun compactSupportingLine(loc: String, updated: String): String {
  val trimmedLoc = loc.trim()
  if (trimmedLoc.length in 1..18) {
    return trimmedLoc
  }
  if (updated.length in 1..10) {
    return updated
  }
  return ""
}