package io.github.marco_zanella.sentinel

import com.pravera.flutter_foreground_task.FlutterForegroundTaskLifecycleListener
import com.pravera.flutter_foreground_task.FlutterForegroundTaskPlugin
import com.pravera.flutter_foreground_task.FlutterForegroundTaskStarter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register SMS plugin in the main (UI) engine.
        flutterEngine.plugins.add(SmsSenderPlugin())

        // Also register it in the background (foreground service) engine so
        // SMS can be sent from the timer handler when the UI is not running.
        FlutterForegroundTaskPlugin.addTaskLifecycleListener(
            object : FlutterForegroundTaskLifecycleListener {
                override fun onEngineCreate(engine: FlutterEngine?) {
                    engine?.plugins?.add(SmsSenderPlugin())
                }
                override fun onTaskStart(starter: FlutterForegroundTaskStarter) {}
                override fun onTaskRepeatEvent() {}
                override fun onTaskDestroy() {}
                override fun onEngineWillDestroy() {}
            }
        )
    }
}
