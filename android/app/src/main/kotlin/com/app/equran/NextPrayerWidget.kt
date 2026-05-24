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

class NextPrayerWidget : GlanceAppWidget() {

  override suspend fun provideGlance(
      context: Context,
      id: GlanceId) {

    val prefs = HomeWidgetPlugin.getData(context)
    val next = prefs.getString("next_prayer", "") ?: ""
    val nextTime = when (next.lowercase()) {
      "fajr" -> prefs.getString("fajr_time", "---")
      "dhuhr" -> prefs.getString("dhuhr_time", "---")
      "asr" -> prefs.getString("asr_time", "---")
      "maghrib" -> prefs.getString("maghrib_time", "---")
      "isha" -> prefs.getString("isha_time", "---")
      else -> null
    }

    provideContent {
      GlanceTheme {
        if (nextTime == null || nextTime == "---") {
          WidgetPlaceholder()
        } else {
          WidgetContent(
            name = next.replaceFirstChar { it.uppercase() },
            time = nextTime,
          )
        }
      }
    }
  }
}

private val BgColor      = Color(0xFF0D1F1AL)
private val CardColor    = Color(0xFF122920L)
private val TextColor    = Color(0xFFFFFFFFL)
private val MutedColor   = Color(0xFF8A918BL)
private val GoldColor    = Color(0xFFD6A84FL)
private val PrimaryColor = Color(0xFF1E735DL)

@Composable
private fun WidgetPlaceholder() {
  Box(
    modifier = GlanceModifier
      .fillMaxSize()
      .background(BgColor)
      .padding(8.dp)
      .clickable(
        actionStartActivity<MainActivity>()),
    contentAlignment = Alignment.Center,
  ) {
    Column(
      horizontalAlignment = Alignment.CenterHorizontally,
    ) {
      Text(
        text = "eQuran",
        style = TextStyle(
          color = ColorProvider(PrimaryColor),
          fontSize = 11.sp,
          fontWeight = FontWeight.Bold))
      Spacer(GlanceModifier.height(2.dp))
      Text(
        text = "Open app to load",
        style = TextStyle(
          color = ColorProvider(MutedColor),
          fontSize = 8.sp,
          textAlign = TextAlign.Center))
    }
  }
}

@Composable
private fun WidgetContent(
  name: String,
  time: String,
) {
  Box(
    modifier = GlanceModifier
      .fillMaxSize()
      .background(BgColor)
      .padding(horizontal = 12.dp, vertical = 6.dp)
      .clickable(
        actionStartActivity<MainActivity>()),
    contentAlignment = Alignment.CenterStart,
  ) {
    Row(
      modifier = GlanceModifier.fillMaxWidth(),
      verticalAlignment = Alignment.CenterVertically,
    ) {
      // Left side: Label + Name
      Column(
        verticalAlignment = Alignment.CenterVertically,
      ) {
        Text(
          text = "Next Prayer",
          style = TextStyle(
            color = ColorProvider(MutedColor),
            fontSize = 8.sp))
        Spacer(GlanceModifier.height(1.dp))
        Text(
          text = name,
          style = TextStyle(
            color = ColorProvider(GoldColor),
            fontSize = 13.sp,
            fontWeight = FontWeight.Bold))
      }

      Spacer(GlanceModifier.defaultWeight())

      // Right side: The time card
      Box(
        modifier = GlanceModifier
          .height(34.dp)
          .background(CardColor)
          .padding(horizontal = 8.dp, vertical = 4.dp),
        contentAlignment = Alignment.Center,
      ) {
        Text(
          text = time,
          style = TextStyle(
            color = ColorProvider(TextColor),
            fontSize = 13.sp,
            fontWeight = FontWeight.Bold))
      }
    }
  }
}
