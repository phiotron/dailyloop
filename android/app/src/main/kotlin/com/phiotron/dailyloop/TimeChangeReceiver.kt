package com.phiotron.dailyloop

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * Đặt lại giờ nhắc khi máy đổi giờ, đổi múi giờ, khởi động lại hoặc app được cập nhật
 * lúc app đang tắt (AC-21, D-007). Giờ nhắc lưu theo giờ địa phương nên phải tính lại
 * thời điểm tuyệt đối: bộ nhận chạy một FlutterEngine không giao diện, gọi hàm Dart
 * `timeChangedMain` (lib/src/reminders/time_change_entry.dart) rồi giải phóng engine.
 * Dart báo xong qua kênh `dailyloop/background`; có hẹn giờ dự phòng vì bộ nhận chỉ được
 * chạy vài giây.
 */
class TimeChangeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val app = context.applicationContext
        val pending = goAsync()
        val handler = Handler(Looper.getMainLooper())
        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(app)
        loader.ensureInitializationCompleteAsync(app, null, handler) {
            var engine: FlutterEngine? = null
            var finished = false
            fun finish() {
                if (finished) return
                finished = true
                engine?.destroy()
                pending.finish()
            }
            try {
                val e = FlutterEngine(app)
                engine = e
                MethodChannel(e.dartExecutor.binaryMessenger, "dailyloop/background")
                    .setMethodCallHandler { call, result ->
                        if (call.method == "done") {
                            result.success(null)
                            finish()
                        } else {
                            result.notImplemented()
                        }
                    }
                e.dartExecutor.executeDartEntrypoint(
                    DartExecutor.DartEntrypoint(
                        loader.findAppBundlePath(),
                        "package:dailyloop/src/reminders/time_change_entry.dart",
                        "timeChangedMain"
                    )
                )
                handler.postDelayed({ finish() }, 9000)
            } catch (t: Throwable) {
                finish()
            }
        }
    }
}
