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

  override suspend fun provideGlance(
    context: Context,
    id: GlanceId
  ) {
    val prefs = HomeWidgetPlugin.getData(context)
    val fajr = prefs.getString("fajr_time", null)
    val dhuhr = prefs.getString("dhuhr_time", "---") ?: "---"
    val asr = prefs.getString("asr_time", "---") ?: "---"
    val maghrib = prefs.getString("maghrib_time", "---") ?: "---"
    val isha = prefs.getString("isha_time", "---") ?: "---"
    val sunrise = prefs.getString("sunrise_time", "---") ?: "---"
    val next = prefs.getString("next_prayer", "") ?: ""
    val loc = prefs.getString("location_name", "") ?: ""
    val updated = prefs.getString("last_updated", "") ?: ""

    val bgHex = prefs.getString("w_bg", "FF0D1F1A") ?: "FF0D1F1A"
    val surfaceHex = prefs.getString("w_surface", "FF122920") ?: "FF122920"
    val primaryHex = prefs.getString("w_primary", "FF1E735D") ?: "FF1E735D"
    val textHex = prefs.getString("w_text", "FFFFFFFF") ?: "FFFFFFFF"
    val textMutedHex = prefs.getString("w_text_muted", "FF8A918B") ?: "FF8A918B"
    val goldHex = prefs.getString("w_gold", "FFD6A84F") ?: "FFD6A84F"
    val borderHex = prefs.getString("w_border", "FF1E3A2E") ?: "FF1E3A2E"

    val bgColor = hexToColor(bgHex)
    val surfaceColor = hexToColor(surfaceHex)
    val primaryColor = hexToColor(primaryHex)
    val textColor = hexToColor(textHex)
    val textMuted = hexToColor(textMutedHex)
    val goldColor = hexToColor(goldHex)
    val borderColor = hexToColor(borderHex)

    val headerLabel = prefs.getString("label_header", "Prayer Times") ?: "Prayer Times"
    val fajrLabel = prefs.getString("label_fajr", "Fajr") ?: "Fajr"
    val sunriseLabel = prefs.getString("label_sunrise", "Sunrise") ?: "Sunrise"
    val dhuhrLabel = prefs.getString("label_dhuhr", "Dhuhr") ?: "Dhuhr"
    val asrLabel = prefs.getString("label_asr", "Asr") ?: "Asr"
    val maghribLabel = prefs.getString("label_maghrib", "Maghrib") ?: "Maghrib"
    val ishaLabel = prefs.getString("label_isha", "Isha") ?: "Isha"
    val updatedLabel = prefs.getString("label_updated", "Updated") ?: "Updated"
    val placeholderLabel = prefs.getString("label_placeholder", "Tap to load prayer times") ?: "Tap to load prayer times"

    provideContent {
      GlanceTheme {
        if (fajr == null) {
          WidgetPlaceholder(
            bgColor = bgColor,
            primaryColor = primaryColor,
            mutedColor = textMuted,
            label = placeholderLabel,
          )
        } else {
          WidgetContent(
            fajr = fajr,
            sunrise = sunrise,
            dhuhr = dhuhr,
            asr = asr,
            maghrib = maghrib,
            isha = isha,
            next = next,
            loc = loc,
            updated = updated,
            bgColor = bgColor,
            surfaceColor = surfaceColor,
            primaryColor = primaryColor,
            textColor = textColor,
            textMuted = textMuted,
            goldColor = goldColor,
            borderColor = borderColor,
            headerLabel = headerLabel,
            fajrLabel = fajrLabel,
            sunriseLabel = sunriseLabel,
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

private fun hexToColor(hex: String): Color {
  val normalized = hex.removePrefix("#")
  return Color(android.graphics.Color.parseColor("#$normalized"))
}

@Composable
private fun WidgetPlaceholder(
  bgColor: Color,
  primaryColor: Color,
  mutedColor: Color,
  label: String,
) {
  Box(
    modifier = GlanceModifier
      .fillMaxSize()
      .background(bgColor)
      .padding(12.dp)
      .clickable(actionStartActivity<MainActivity>()),
    contentAlignment = Alignment.Center,
  ) {
    Column(
      horizontalAlignment = Alignment.CenterHorizontally,
    ) {
      Text(
        text = "eQuran",
        style = TextStyle(
          color = ColorProvider(primaryColor),
          fontSize = 14.sp,
          fontWeight = FontWeight.Bold
        )
      )
      Spacer(GlanceModifier.height(6.dp))
      Text(
        text = label,
        style = TextStyle(
          color = ColorProvider(mutedColor),
          fontSize = 10.sp,
          textAlign = TextAlign.Center
        )
      )
    }
  }
}

@Composable
private fun WidgetContent(
  fajr: String,
  sunrise: String,
  dhuhr: String,
  asr: String,
  maghrib: String,
  isha: String,
  next: String,
  loc: String,
  updated: String,
  bgColor: Color,
  surfaceColor: Color,
  primaryColor: Color,
  textColor: Color,
  textMuted: Color,
  goldColor: Color,
  borderColor: Color,
  headerLabel: String,
  fajrLabel: String,
  sunriseLabel: String,
  dhuhrLabel: String,
  asrLabel: String,
  maghribLabel: String,
  ishaLabel: String,
  updatedLabel: String,
) {
  Box(
    modifier = GlanceModifier
      .fillMaxSize()
      .background(bgColor)
      .padding(16.dp)
      .clickable(actionStartActivity<MainActivity>()),
    contentAlignment = Alignment.TopStart,
  ) {
    Column(
      modifier = GlanceModifier.fillMaxSize(),
    ) {
      // HEADER
      Row(
        modifier = GlanceModifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
      ) {
        Column(
          modifier = GlanceModifier.defaultWeight(),
        ) {
          Text(
            text = headerLabel,
            style = TextStyle(
              color = ColorProvider(textColor),
              fontSize = 15.sp,
              fontWeight = FontWeight.Bold
            )
          )
          if (loc.isNotEmpty()) {
            Text(
              text = loc,
              style = TextStyle(
                color = ColorProvider(textMuted),
                fontSize = 10.sp
              )
            )
          }
        }
        if (next.isNotEmpty()) {
          Box(
            modifier = GlanceModifier
              .background(primaryColor)
              .padding(horizontal = 8.dp, vertical = 4.dp),
            contentAlignment = Alignment.Center,
          ) {
            Text(
              text = _nextPrayerLabel(next),
              style = TextStyle(
                color = ColorProvider(textColor),
                fontSize = 9.sp,
                fontWeight = FontWeight.Bold
              )
            )
          }
        }
      }

      Spacer(GlanceModifier.height(8.dp))
      Spacer(
        GlanceModifier
          .fillMaxWidth()
          .height(1.dp)
          .background(borderColor)
      )
      Spacer(GlanceModifier.height(8.dp))

      // ROW 1: Fajr | Sunrise | Dhuhr
      Row(
        modifier = GlanceModifier
          .fillMaxWidth()
          .padding(bottom = 6.dp),
      ) {
        PrayerCell(
          name = fajrLabel,
          time = fajr,
          isNext = next == "fajr",
          surfaceColor = surfaceColor,
          goldColor = goldColor,
          textColor = textColor,
          textMuted = textMuted,
          modifier = GlanceModifier.defaultWeight()
        )
        Spacer(GlanceModifier.width(6.dp))
        PrayerCell(
          name = sunriseLabel,
          time = sunrise,
          isNext = next == "sunrise",
          surfaceColor = surfaceColor,
          goldColor = goldColor,
          textColor = textColor,
          textMuted = textMuted,
          modifier = GlanceModifier.defaultWeight()
        )
        Spacer(GlanceModifier.width(6.dp))
        PrayerCell(
          name = dhuhrLabel,
          time = dhuhr,
          isNext = next == "dhuhr",
          surfaceColor = surfaceColor,
          goldColor = goldColor,
          textColor = textColor,
          textMuted = textMuted,
          modifier = GlanceModifier.defaultWeight()
        )
      }

      // ROW 2: Asr | Maghrib | Isha
      Row(
        modifier = GlanceModifier.fillMaxWidth(),
      ) {
        PrayerCell(
          name = asrLabel,
          time = asr,
          isNext = next == "asr",
          surfaceColor = surfaceColor,
          goldColor = goldColor,
          textColor = textColor,
          textMuted = textMuted,
          modifier = GlanceModifier.defaultWeight()
        )
        Spacer(GlanceModifier.width(6.dp))
        PrayerCell(
          name = maghribLabel,
          time = maghrib,
          isNext = next == "maghrib",
          surfaceColor = surfaceColor,
          goldColor = goldColor,
          textColor = textColor,
          textMuted = textMuted,
          modifier = GlanceModifier.defaultWeight()
        )
        Spacer(GlanceModifier.width(6.dp))
        PrayerCell(
          name = ishaLabel,
          time = isha,
          isNext = next == "isha",
          surfaceColor = surfaceColor,
          goldColor = goldColor,
          textColor = textColor,
          textMuted = textMuted,
          modifier = GlanceModifier.defaultWeight()
        )
      }

      // LAST UPDATED
      if (updated.isNotEmpty()) {
        Text(
          text = "$updatedLabel: $updated",
          style = TextStyle(
            color = ColorProvider(textMuted),
            fontSize = 9.sp,
            textAlign = TextAlign.Center
          ),
          modifier = GlanceModifier
            .fillMaxWidth()
            .padding(top = 8.dp)
        )
      }
    }
  }
}

@Composable
private fun PrayerCell(
  name: String,
  time: String,
  isNext: Boolean,
  surfaceColor: Color,
  goldColor: Color,
  textColor: Color,
  textMuted: Color,
  modifier: GlanceModifier = GlanceModifier,
) {
  val finalBg = if (isNext)
    Color(0xFF1E3A2EL)
  else
    surfaceColor

  val nameColor = if (isNext) goldColor else textMuted

  Box(
    modifier = modifier
      .fillMaxWidth()
      .height(58.dp)
      .background(finalBg)
      .padding(horizontal = 6.dp, vertical = 8.dp),
    contentAlignment = Alignment.Center,
  ) {
    Column(
      horizontalAlignment = Alignment.CenterHorizontally,
      verticalAlignment = Alignment.CenterVertically,
    ) {
      Text(
        text = name,
        style = TextStyle(
          color = ColorProvider(nameColor),
          fontSize = 9.sp,
          fontWeight = if (isNext)
            FontWeight.Bold
          else
            FontWeight.Normal
        )
      )
      Spacer(GlanceModifier.height(3.dp))
      Text(
        text = time,
        style = TextStyle(
          color = ColorProvider(textColor),
          fontSize = 14.sp,
          fontWeight = FontWeight.Bold
        )
      )
    }
  }
}

private fun _nextPrayerLabel(next: String): String {
  return when (next) {
    "fajr" -> "Fajr next"
    "dhuhr" -> "Dhuhr next"
    "asr" -> "Asr next"
    "maghrib" -> "Maghrib next"
    "isha" -> "Isha next"
    "sunrise" -> "Sunrise next"
    else -> ""
  }
}
