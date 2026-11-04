package com.phiotron.dailyloop

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import org.json.JSONObject
import java.io.File
import java.util.Calendar

/**
 * Dữ liệu widget: bản chụp 7 ngày do app Dart ghi vào SharedPreferences (D-009).
 * Widget tự chọn ngày theo giờ máy nên sang ngày mới được kể cả khi app đóng.
 */
object WidgetStore {
    private const val PREFS = "dailyloop_widget"
    private const val KEY = "payload"

    fun save(context: Context, json: String) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putString(KEY, json).apply()
    }

    fun load(context: Context): JSONObject? {
        val s = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY, null) ?: return null
        return try {
            JSONObject(s)
        } catch (e: Exception) {
            null
        }
    }

    fun todayKey(): String {
        val c = Calendar.getInstance()
        return String.format(
            "%04d-%02d-%02d",
            c.get(Calendar.YEAR),
            c.get(Calendar.MONTH) + 1,
            c.get(Calendar.DAY_OF_MONTH)
        )
    }

    /** Ngày hôm nay trong bản chụp, hoặc null nếu bản chụp đã cũ hơn 7 ngày. */
    fun today(context: Context): JSONObject? =
        load(context)?.optJSONObject("days")?.optJSONObject(todayKey())

    /**
     * Đánh dấu xong hoặc bỏ dấu một mục Có/Không ngay trong cơ sở dữ liệu của app,
     * không mở app (AC-39). Cơ sở dữ liệu do drift tạo ở thư mục app_flutter.
     */
    fun toggle(context: Context, activityId: Long, date: String): Boolean {
        val file = File(context.getDir("flutter", Context.MODE_PRIVATE), "dailyloop.sqlite")
        if (!file.exists()) return false
        val db = SQLiteDatabase.openDatabase(file.path, null, SQLiteDatabase.OPEN_READWRITE)
        var done = false
        try {
            db.beginTransaction()
            var current = 0.0
            db.rawQuery(
                "SELECT value FROM entries WHERE activity_id = ? AND date = ?",
                arrayOf(activityId.toString(), date)
            ).use { if (it.moveToFirst()) current = it.getDouble(0) }
            done = current < 1.0
            val cv = ContentValues().apply {
                put("value", if (done) 1.0 else 0.0)
                put("skipped", 0)
            }
            val rows = db.update(
                "entries", cv, "activity_id = ? AND date = ?",
                arrayOf(activityId.toString(), date)
            )
            if (rows == 0) {
                cv.put("activity_id", activityId)
                cv.put("date", date)
                db.insertOrThrow("entries", null, cv)
            }
            db.setTransactionSuccessful()
        } finally {
            if (db.inTransaction()) db.endTransaction()
            db.close()
        }
        patch(context, activityId, date, done)
        return true
    }

    /** Sửa bản chụp để widget vẽ lại ngay, không đợi app. */
    private fun patch(context: Context, activityId: Long, date: String, done: Boolean) {
        val root = load(context) ?: return
        val day = root.optJSONObject("days")?.optJSONObject(date) ?: return
        val items = day.optJSONArray("items") ?: return
        var left = 0
        for (i in 0 until items.length()) {
            val item = items.getJSONObject(i)
            if (item.getLong("id") == activityId && item.getString("date") == date) {
                item.put("done", done)
                item.put("skipped", false)
            }
            if (!item.getBoolean("done") && !item.getBoolean("skipped")) left++
        }
        val summary = if (items.length() == 0) root.optString("empty")
        else if (left == 0) root.optString("allDone")
        else root.optString("leftTpl").replace("-1", left.toString())
        day.put("summary", summary)
        save(context, root.toString())
    }
}
