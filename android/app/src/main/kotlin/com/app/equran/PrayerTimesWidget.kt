package com.app.equran

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetPlugin
import androidx.compose.ui.graphics.Color

class PrayerTimesWidget : GlanceAppWidget() {

  // Glance 1.1.0 correct pattern:
  // Read data in provideGlance BEFORE
  // calling provideContent, pass as
  // plain values into the composable.

  override suspend fun provideGlance(
      context: Context,
      id: GlanceId) {

    // Read ALL data here synchronously
    // before entering composition
    val prefs = HomeWidgetPlugin.getData(context)
    val fajr    = prefs.getString("fajr_time",    null)
    val dhuhr   = prefs.getString("dhuhr_time",   "---") ?: "---"
    val asr     = prefs.getString("asr_time",     "---") ?: "---"
    val maghrib = prefs.getString("maghrib_time", "---") ?: "---"
    val isha    = prefs.getString("isha_time",    "---") ?: "---"
    val next    = prefs.getString("next_prayer",  "")   ?: ""
    val loc     = prefs.getString("location_name","")   ?: ""
    val updated = prefs.getString("last_updated", "")   ?: ""

    // Read localized labels
    val headerLabel = prefs.getString("label_header", "Prayer Times") ?: "Prayer Times"
    val fajrLabel   = prefs.getString("label_fajr",   "Fajr") ?: "Fajr"
    val dhuhrLabel  = prefs.getString("label_dhuhr",  "Dhuhr") ?: "Dhuhr"
    val asrLabel    = prefs.getString("label_asr",    "Asr") ?: "Asr"
    val maghribLabel= prefs.getString("label_maghrib","Maghrib") ?: "Maghrib"
    val ishaLabel   = prefs.getString("label_isha",   "Isha") ?: "Isha"
    val updatedLabel= prefs.getString("label_updated","Updated") ?: "Updated"
    val placeholderLabel = prefs.getString("label_placeholder", "Tap to load prayer times") ?: "Tap to load prayer times"

    // provideContent in Glance 1.1.0
    // is called as a member function
    // (not a top-level extension)
    provideContent {
      GlanceTheme {
        if (fajr == null) {
          WidgetPlaceholder(placeholderLabel)
        } else {
          WidgetContent(
            fajr    = fajr,
            dhuhr   = dhuhr,
            asr     = asr,
            maghrib = maghrib,
            isha    = isha,
            next    = next,
            loc     = loc,
            updated = updated,
            headerLabel = headerLabel,
            fajrLabel = fajrLabel,
            dhuhrLabel = dhuhrLabel,
            asrLabel = asrLabel,
            maghribLabel = maghribLabel,
            ishaLabel = ishaLabel,
            updatedLabel = updatedLabel,
          )
        }
      }
    }
  }
}

// All Color values MUST use Long literals
// (suffix L) to avoid signed Int overflow
private val BgColor     = Color(0xFF0D1F1AL)
private val CardColor   = Color(0xFF122920L)
private val PrimaryColor = Color(0xFF1E735DL)
private val TextColor   = Color(0xFFFFFFFFL)
private val MutedColor  = Color(0xFF8A918BL)
private val GoldColor   = Color(0xFFD6A84FL)
private val NextBgColor = Color(0xFF1E3A2EL)

@Composable
private fun WidgetPlaceholder(label: String) {
  Box(
    modifier = GlanceModifier
      .fillMaxSize()
      .background(BgColor)
      .padding(12.dp)
      .clickable(
        actionStartActivity<MainActivity>()),
    contentAlignment = Alignment.Center,
  ) {
    Column(
      horizontalAlignment =
        Alignment.CenterHorizontally,
    ) {
      Text(
        text = "eQuran",
        style = TextStyle(
          color = ColorProvider(PrimaryColor),
          fontSize = 14.sp,
          fontWeight = FontWeight.Bold))
      Spacer(GlanceModifier.height(6.dp))
      Text(
        text = label,
        style = TextStyle(
          color = ColorProvider(MutedColor),
          fontSize = 10.sp,
          textAlign = TextAlign.Center))
    }
  }
}

@Composable
private fun WidgetContent(
  fajr: String,
  dhuhr: String,
  asr: String,
  maghrib: String,
  isha: String,
  next: String,
  loc: String,
  updated: String,
  headerLabel: String,
  fajrLabel: String,
  dhuhrLabel: String,
  asrLabel: String,
  maghribLabel: String,
  ishaLabel: String,
  updatedLabel: String,
) {
  Box(
    modifier = GlanceModifier
      .fillMaxSize()
      .background(BgColor)
      .padding(12.dp)
      .clickable(
        actionStartActivity<MainActivity>()),
    contentAlignment = Alignment.TopStart,
  ) {
    Column(
      modifier = GlanceModifier.fillMaxSize(),
    ) {

      // HEADER
      Row(
        modifier = GlanceModifier
          .fillMaxWidth()
          .padding(bottom = 8.dp),
        verticalAlignment =
          Alignment.CenterVertically,
      ) {
        Text(
          text = headerLabel,
          style = TextStyle(
            color = ColorProvider(TextColor),
            fontSize = 13.sp,
            fontWeight = FontWeight.Bold),
          modifier = GlanceModifier
            .defaultWeight())
        if (loc.isNotEmpty()) {
          Text(
            text = loc,
            style = TextStyle(
              color = ColorProvider(MutedColor),
              fontSize = 10.sp))
        }
      }

      // ROW 1: Fajr | Dhuhr | Asr
      Row(
        modifier = GlanceModifier
          .fillMaxWidth()
          .padding(bottom = 6.dp),
      ) {
        PrayerCell(
          name = fajrLabel,
          time = fajr,
          isNext = next == "fajr",
          modifier = GlanceModifier
            .defaultWeight())
        Spacer(GlanceModifier.width(6.dp))
        PrayerCell(
          name = dhuhrLabel,
          time = dhuhr,
          isNext = next == "dhuhr",
          modifier = GlanceModifier
            .defaultWeight())
        Spacer(GlanceModifier.width(6.dp))
        PrayerCell(
          name = asrLabel,
          time = asr,
          isNext = next == "asr",
          modifier = GlanceModifier
            .defaultWeight())
      }

      // ROW 2: Maghrib | Isha | Updated
      Row(
        modifier = GlanceModifier.fillMaxWidth(),
      ) {
        PrayerCell(
          name = maghribLabel,
          time = maghrib,
          isNext = next == "maghrib",
          modifier = GlanceModifier
            .defaultWeight())
        Spacer(GlanceModifier.width(6.dp))
        PrayerCell(
          name = ishaLabel,
          time = isha,
          isNext = next == "isha",
          modifier = GlanceModifier
            .defaultWeight())
        Spacer(GlanceModifier.width(6.dp))
        // Redesigned Updated cell matching standard PrayerCell
        PrayerCell(
          name = updatedLabel,
          time = if (updated.isNotEmpty()) updated else "--:--",
          isNext = false,
          modifier = GlanceModifier
            .defaultWeight())
      }
    }
  }
}

@Composable
private fun PrayerCell(
  name: String,
  time: String,
  isNext: Boolean,
  modifier: GlanceModifier = GlanceModifier,
) {
  val bg = if (isNext) NextBgColor else CardColor
  val nameColor = if (isNext) GoldColor else MutedColor

  Box(
    modifier = modifier
      .height(60.dp)
      .background(bg)
      .padding(4.dp),
    contentAlignment = Alignment.Center,
  ) {
    Column(
      horizontalAlignment =
        Alignment.CenterHorizontally,
    ) {
      Text(
        text = name,
        style = TextStyle(
          color = ColorProvider(nameColor),
          fontSize = 9.sp,
          fontWeight = if (isNext)
            FontWeight.Bold
          else FontWeight.Normal))
      Spacer(GlanceModifier.height(2.dp))
      Text(
        text = time,
        style = TextStyle(
          color = ColorProvider(TextColor),
          fontSize = 13.sp,
          fontWeight = FontWeight.Bold))
    }
  }
}
