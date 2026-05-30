package io.github.marco_zanella.sentinel

import android.content.Context
import android.os.Build
import android.telephony.SmsManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Non-ActivityAware plugin so it registers correctly in both the main Flutter
 * engine and the flutter_foreground_task background engine.
 */
class SmsSenderPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "io.github.marco_zanella.sentinel/sms")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "sendSms" -> {
                val phone = call.argument<String>("phone") ?: ""
                val message = call.argument<String>("message") ?: ""
                try {
                    @Suppress("DEPRECATION")
                    val smsManager: SmsManager =
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            context.getSystemService(SmsManager::class.java)
                        } else {
                            SmsManager.getDefault()
                        }
                    val parts = smsManager.divideMessage(message)
                    if (parts.size == 1) {
                        smsManager.sendTextMessage(phone, null, message, null, null)
                    } else {
                        smsManager.sendMultipartTextMessage(phone, null, parts, null, null)
                    }
                    result.success(true)
                } catch (e: Exception) {
                    result.error("SMS_SEND_FAILED", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }
}
