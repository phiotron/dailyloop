package com.phiotron.dailyloop

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray

class TodayWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory = Factory(applicationContext)

    private class Factory(private val context: Context) : RemoteViewsFactory {
        private var items = JSONArray()

        override fun onCreate() {}

        override fun onDataSetChanged() {
            items = WidgetStore.today(context)?.optJSONArray("items") ?: JSONArray()
        }

        override fun onDestroy() {}
        override fun getCount() = items.length()
        override fun getViewTypeCount() = 1
        override fun getItemId(position: Int) = position.toLong()
        override fun hasStableIds() = false
        override fun getLoadingView(): RemoteViews? = null

        override fun getViewAt(position: Int): RemoteViews {
            val v = RemoteViews(context.packageName, R.layout.widget_item)
            val item = items.getJSONObject(position)
            val done = item.getBoolean("done")
            v.setTextViewText(R.id.name, item.getString("name"))
            v.setImageViewResource(
                R.id.check,
                if (done) R.drawable.ic_widget_check_on else R.drawable.ic_widget_check_off
            )
            val toggle = Intent()
                .putExtra(WidgetActionActivity.EXTRA_ACTION, if (item.getBoolean("tap")) "toggle" else "open")
                .putExtra("id", item.getLong("id"))
                .putExtra("date", item.getString("date"))
                .putExtra("task", item.getBoolean("task"))
            val open = Intent(toggle).putExtra(WidgetActionActivity.EXTRA_ACTION, "open")
            v.setOnClickFillInIntent(R.id.check, toggle)
            v.setOnClickFillInIntent(R.id.name, open)
            return v
        }
    }
}
