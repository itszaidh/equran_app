package com.app.equran

import android.content.Context
import android.content.SharedPreferences
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.*
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
import androidx.glance.appwidget.*
import androidx.glance.appwidget.lazy.LazyColumn
import androidx.glance.appwidget.provideContent
import androidx.glance.layout.*
import androidx.glance.text.*
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetPlugin

class PrayerTimesWidget : GlanceAppWidget() {

  override suspend fun provideGlance(
    context: Context, id: GlanceId) {
    try {
      val prefs = HomeWidgetPlugin.getData(context)
      val fajrTime = prefs.getString("fajr_time", null)

      provideContent {
        if (fajrTime == null) {
          // Data not yet pushed from app
          // Show a loading/placeholder state
          PrayerWidgetPlaceholder(context)
        } else {
          PrayerTimesWidgetContent(
            fajr    = prefs.getString("fajr_time",    "---") ?: "---",
            dhuhr   = prefs.getString("dhuhr_time",   "---") ?: "---",
            asr     = prefs.getString("asr_time",     "---") ?: "---",
            maghrib = prefs.getString("maghrib_time", "---") ?: "---",
            isha    = prefs.getString("isha_time",    "---") ?: "---",
            nextPrayer   = prefs.getString("next_prayer",   "") ?: "",
            locationName = prefs.getString("location_name", "") ?: "",
            lastUpdated  = prefs.getString("last_updated",  "") ?: "",
            context      = context,
          )
        }
      }
    } catch (e: Exception) {
      provideContent {
        PrayerWidgetPlaceholder(context)
      }
    }
  }
}

@Composable
fun PrayerWidgetPlaceholder(context: Context) {
  val bgColor = Color(0xFF0D1F1A)
  val textMuted = Color(0xFF8A918B)
  Box(
    modifier = GlanceModifier
      .fillMaxSize()
      .background(bgColor)
      .padding(16.dp)
      .clickable(actionStartActivity<MainActivity>()),
    contentAlignment = Alignment.Center,
  ) {
    Column(
      horizontalAlignment = Alignment.CenterHorizontally,
      verticalAlignment = Alignment.CenterVertically,
    ) {
      Text(
        text = "eQuran",
        style = TextStyle(
          color = ColorProvider(Color(0xFF1E735D)),
          fontSize = 14.sp,
          fontWeight = FontWeight.Bold))
      Spacer(GlanceModifier.height(4.dp))
      Text(
        text = "Open app to load prayer times",
        style = TextStyle(
          color = ColorProvider(textMuted),
          fontSize = 10.sp,
          textAlign = TextAlign.Center))
    }
  }
}

@Composable
fun PrayerTimesWidgetContent(
  fajr: String,
  dhuhr: String,
  asr: String,
  maghrib: String,
  isha: String,
  nextPrayer: String,
  locationName: String,
  lastUpdated: String,
  context: Context,
) {
  // Dark teal background matching app theme
  val bgColor    = Color(0xFF0D1F1A)
  val cardColor  = Color(0xFF122920)
  val primary    = Color(0xFF1E735D)
  val textPrimary  = Color(0xFFFFFFFF)
  val textMuted    = Color(0xFF8A918B)
  val accentGold   = Color(0xFFD6A84F)

  GlanceTheme {
    Box(
      modifier = GlanceModifier
        .fillMaxSize()
        .background(bgColor)
        .padding(12.dp)
        .clickable(
          actionStartActivity<MainActivity>()),
      contentAlignment = Alignment.TopStart,
    ) {
      Column(
        modifier = GlanceModifier.fillMaxSize(),
        verticalAlignment = Alignment.Top,
      ) {

        // HEADER ROW
        Row(
          modifier = GlanceModifier
            .fillMaxWidth()
            .padding(bottom = 8.dp),
          verticalAlignment = Alignment.CenterVertically,
        ) {
          Text(
            text = "Prayer Times",
            style = TextStyle(
              color  = ColorProvider(textPrimary),
              fontSize = 13.sp,
              fontWeight = FontWeight.Bold),
            modifier = GlanceModifier.defaultWeight())

          if (locationName.isNotEmpty()) {
            Text(
              text = locationName,
              style = TextStyle(
                color    = ColorProvider(textMuted),
                fontSize = 10.sp),
            )
          }
        }

        // PRAYER TIMES GRID
        // Two rows of prayers:
        // Row 1: Fajr | Dhuhr | Asr
        // Row 2: Maghrib | Isha | (next indicator)

        Row(
          modifier = GlanceModifier
            .fillMaxWidth()
            .padding(bottom = 6.dp),
          horizontalAlignment = Alignment.CenterHorizontally,
        ) {
          PrayerCell(
            name  = "Fajr",
            time  = fajr,
            isNext = nextPrayer == "fajr",
            primary = primary,
            textPrimary = textPrimary,
            textMuted = textMuted,
            accentGold = accentGold,
            cardColor = cardColor,
            modifier = GlanceModifier.defaultWeight())
          Spacer(GlanceModifier.width(6.dp))
          PrayerCell(
            name  = "Dhuhr",
            time  = dhuhr,
            isNext = nextPrayer == "dhuhr",
            primary = primary,
            textPrimary = textPrimary,
            textMuted = textMuted,
            accentGold = accentGold,
            cardColor = cardColor,
            modifier = GlanceModifier.defaultWeight())
          Spacer(GlanceModifier.width(6.dp))
          PrayerCell(
            name  = "Asr",
            time  = asr,
            isNext = nextPrayer == "asr",
            primary = primary,
            textPrimary = textPrimary,
            textMuted = textMuted,
            accentGold = accentGold,
            cardColor = cardColor,
            modifier = GlanceModifier.defaultWeight())
        }

        Row(
          modifier = GlanceModifier.fillMaxWidth(),
          horizontalAlignment = Alignment.CenterHorizontally,
        ) {
          PrayerCell(
            name  = "Maghrib",
            time  = maghrib,
            isNext = nextPrayer == "maghrib",
            primary = primary,
            textPrimary = textPrimary,
            textMuted = textMuted,
            accentGold = accentGold,
            cardColor = cardColor,
            modifier = GlanceModifier.defaultWeight())
          Spacer(GlanceModifier.width(6.dp))
          PrayerCell(
            name  = "Isha",
            time  = isha,
            isNext = nextPrayer == "isha",
            primary = primary,
            textPrimary = textPrimary,
            textMuted = textMuted,
            accentGold = accentGold,
            cardColor = cardColor,
            modifier = GlanceModifier.defaultWeight())
          Spacer(GlanceModifier.width(6.dp))
          // Last updated cell
          Box(
            modifier = GlanceModifier
              .defaultWeight()
              .height(52.dp)
              .background(cardColor)
              .cornerRadius(10.dp)
              .padding(6.dp),
            contentAlignment = Alignment.Center,
          ) {
            Text(
              text = if (lastUpdated.isNotEmpty())
                "Updated\n$lastUpdated"
              else "eQuran",
              style = TextStyle(
                color    = ColorProvider(textMuted),
                fontSize = 9.sp,
                textAlign = TextAlign.Center),
            )
          }
        }
      }
    }
  }
}

@Composable
fun PrayerCell(
  name: String,
  time: String,
  isNext: Boolean,
  primary: Color,
  textPrimary: Color,
  textMuted: Color,
  accentGold: Color,
  cardColor: Color,
  modifier: GlanceModifier = GlanceModifier,
) {
  val bg = if (isNext)
    Color(0xFF1E3A2E)   // highlighted cell for next prayer
  else cardColor

  val nameColor  = if (isNext) accentGold else textMuted
  val timeColor  = if (isNext) textPrimary else textPrimary

  Box(
    modifier = modifier
      .height(52.dp)
      .background(bg)
      .cornerRadius(10.dp)
      .padding(6.dp),
    contentAlignment = Alignment.Center,
  ) {
    Column(
      horizontalAlignment = Alignment.CenterHorizontally,
      verticalAlignment   = Alignment.CenterVertically,
    ) {
      Text(
        text  = name,
        style = TextStyle(
          color    = ColorProvider(nameColor),
          fontSize = 9.sp,
          fontWeight = if (isNext) FontWeight.Bold
                       else FontWeight.Normal),
      )
      Spacer(GlanceModifier.height(2.dp))
      Text(
        text  = time,
        style = TextStyle(
          color    = ColorProvider(timeColor),
          fontSize = 13.sp,
          fontWeight = FontWeight.Bold),
      )
    }
  }
}
