package com.amitsharma.flutercv1

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.view.KeyEvent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class FlutePlayerWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val title = widgetData.getString(
                "flute_widget_title",
                "Nothing playing",
            ) ?: "Nothing playing"
            val artist = widgetData.getString(
                "flute_widget_artist",
                "Open flute to play music",
            ) ?: "Open flute to play music"
            val playing = widgetData.getBoolean("flute_widget_playing", false)

            val views = RemoteViews(context.packageName, R.layout.flute_player_widget)
            views.setTextViewText(R.id.flute_widget_title, title)
            views.setTextViewText(R.id.flute_widget_artist, artist)
            views.setImageViewResource(
                R.id.flute_widget_play_pause,
                if (playing) R.drawable.ic_widget_pause else R.drawable.ic_widget_play,
            )

            views.setOnClickPendingIntent(
                R.id.flute_widget_root,
                openAppIntent(context),
            )
            views.setOnClickPendingIntent(
                R.id.flute_widget_previous,
                mediaButtonIntent(context, KeyEvent.KEYCODE_MEDIA_PREVIOUS, 1),
            )
            views.setOnClickPendingIntent(
                R.id.flute_widget_play_pause,
                mediaButtonIntent(context, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE, 2),
            )
            views.setOnClickPendingIntent(
                R.id.flute_widget_next,
                mediaButtonIntent(context, KeyEvent.KEYCODE_MEDIA_NEXT, 3),
            )

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun openAppIntent(context: Context): PendingIntent {
        val intent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
            ?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            } ?: Intent(context, MainActivity::class.java)

        return PendingIntent.getActivity(
            context,
            100,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun mediaButtonIntent(
        context: Context,
        keyCode: Int,
        requestCode: Int,
    ): PendingIntent {
        val intent = Intent(Intent.ACTION_MEDIA_BUTTON).apply {
            component = ComponentName(
                context,
                "com.ryanheise.audioservice.MediaButtonReceiver",
            )
            putExtra(
                Intent.EXTRA_KEY_EVENT,
                KeyEvent(KeyEvent.ACTION_DOWN, keyCode),
            )
        }

        return PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}
