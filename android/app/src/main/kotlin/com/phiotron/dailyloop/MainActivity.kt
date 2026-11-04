package com.phiotron.dailyloop

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null

    // Chạm tên một mục trên widget mở app tại màn hình của mục (AC-39).
    override fun getInitialRoute(): String? = intent?.getStringExtra("route") ?: super.getInitialRoute()

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val route = intent.getStringExtra("route")
        if (route != null) channel?.invokeMethod("openRoute", route)
    }

    // Kiểm quyền thông báo toàn màn hình, mở cài đặt thông báo của app (D-007)
    // và nhận dữ liệu cho widget (D-009).
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dailyloop/system")
        channel = ch
        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                "canUseFullScreenIntent" -> {
                    val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    result.success(
                        Build.VERSION.SDK_INT < 34 || nm.canUseFullScreenIntent()
                    )
                }
                "openNotificationSettings" -> {
                    val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                        .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(null)
                }
                "updateWidget" -> {
                    val json = call.arguments as? String
                    if (json != null) {
                        WidgetStore.save(applicationContext, json)
                        TodayWidgetProvider.refresh(applicationContext)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
