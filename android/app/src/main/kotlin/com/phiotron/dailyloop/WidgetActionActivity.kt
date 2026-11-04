package com.phiotron.dailyloop

import android.app.Activity
import android.content.Intent
import android.os.Bundle

/**
 * Hoạt động trong suốt nhận cú chạm trên widget: đánh dấu xong thì ghi thẳng
 * vào cơ sở dữ liệu rồi đóng; mở app thì chuyển tới màn hình của mục (AC-39).
 */
class WidgetActionActivity : Activity() {
    companion object {
        const val EXTRA_ACTION = "widget_action"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val action = intent.getStringExtra(EXTRA_ACTION)
        val id = intent.getLongExtra("id", -1)
        val date = intent.getStringExtra("date")
        try {
            if (action == "toggle" && id >= 0 && date != null) {
                WidgetStore.toggle(applicationContext, id, date)
                TodayWidgetProvider.refresh(applicationContext)
            } else {
                val open = Intent(this, MainActivity::class.java)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                if (id >= 0) {
                    val base = if (intent.getBooleanExtra("task", false)) "/tasks/" else "/habits/"
                    open.putExtra("route", base + id)
                }
                startActivity(open)
            }
        } catch (e: Exception) {
            // Cơ sở dữ liệu đang bận: không làm sập, lần chạm sau sẽ thử lại.
        }
        finish()
        overridePendingTransition(0, 0)
    }
}
