package com.phiotron.dailyloop

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import java.util.Calendar

/** Widget danh sách "Hôm nay" (F-10). */
class TodayWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        for (id in ids) manager.updateAppWidget(id, build(context, id))
        manager.notifyAppWidgetViewDataChanged(ids, R.id.list)
        armMidnight(context)
    }

    override fun onEnabled(context: Context) = armMidnight(context)

    companion object {
        fun refresh(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, TodayWidgetProvider::class.java))
            if (ids.isEmpty()) return
            for (id in ids) manager.updateAppWidget(id, build(context, id))
            manager.notifyAppWidgetViewDataChanged(ids, R.id.list)
        }

        private fun actionIntent(context: Context, action: String?, id: Int): PendingIntent {
            val i = Intent(context, WidgetActionActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_NO_ANIMATION)
            if (action != null) i.putExtra(WidgetActionActivity.EXTRA_ACTION, action)
            val mutable = if (action == null) PendingIntent.FLAG_IMMUTABLE else PendingIntent.FLAG_MUTABLE
            return PendingIntent.getActivity(context, id, i, PendingIntent.FLAG_UPDATE_CURRENT or mutable)
        }

        private fun build(context: Context, widgetId: Int): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.widget_today)
            val root = WidgetStore.load(context)
            val day = WidgetStore.today(context)
            views.setTextViewText(R.id.title, root?.optString("title", "DailyLoop") ?: "DailyLoop")
            views.setTextViewText(R.id.summary, day?.optString("summary") ?: "")
            val service = Intent(context, TodayWidgetService::class.java)
            service.data = Uri.parse(service.toUri(Intent.URI_INTENT_SCHEME))
            views.setRemoteAdapter(R.id.list, service)
            views.setPendingIntentTemplate(R.id.list, actionIntent(context, "item", widgetId))
            views.setOnClickPendingIntent(R.id.header, actionIntent(context, null, widgetId))
            return views
        }

        /** Hẹn cập nhật ngay sau 00:00 để widget sang ngày mới (AC-40). */
        fun armMidnight(context: Context) {
            val c = Calendar.getInstance().apply {
                add(Calendar.DAY_OF_YEAR, 1)
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 1)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, TodayWidgetProvider::class.java))
            val i = Intent(context, TodayWidgetProvider::class.java)
                .setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE)
                .putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            val pi = PendingIntent.getBroadcast(
                context, 7, i, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val alarms = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarms.setAndAllowWhileIdle(AlarmManager.RTC, c.timeInMillis, pi)
        }
    }
}
