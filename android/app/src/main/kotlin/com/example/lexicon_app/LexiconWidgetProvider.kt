package com.example.lexicon_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews

open class LexiconWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    protected open fun getLayoutId(): Int = R.layout.lexicon_widget_dark

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val views = RemoteViews(context.packageName, getLayoutId())

        // Create an intent to launch the app and focus search
        val intent = Intent(context, MainActivity::class.java)
        intent.action = "com.example.lexicon.ACTION_SEARCH"
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        
        val pendingIntent = PendingIntent.getActivity(
            context, appWidgetId, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}

class LexiconWidgetDark : LexiconWidgetProvider() {
    override fun getLayoutId(): Int = R.layout.lexicon_widget_dark
}

class LexiconWidgetLight : LexiconWidgetProvider() {
    override fun getLayoutId(): Int = R.layout.lexicon_widget_light
}
