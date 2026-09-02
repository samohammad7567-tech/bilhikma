package tech.bilhikma.app

import android.app.Activity
import android.os.Build
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

/**
 * The window is never protected. FLAG_SECURE would block the screenshot, and a
 * blocked screenshot raises no callback and can never be reported — so the app
 * lets every capture happen and reports the ones it is told about.
 *
 * Whether a capture is reported is decided entirely in Dart from the account's
 * `can_capture_screen`, which arrives with the login response. Nothing on this
 * side needs to know about it, so there is no policy channel here.
 */
class MainActivity : FlutterActivity() {

    private companion object {
        const val TAG = "MainActivity"
    }

    private var detector: ScreenCaptureDetector? = null

    /**
     * Android 14 added [Activity.registerScreenCaptureCallback]. Below API 34
     * the platform reports nothing at all, so a screenshot there is neither
     * blocked nor observable and simply goes unreported.
     */
    private val screenCaptureCallback =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            Activity.ScreenCaptureCallback { detector?.reportScreenshot() }
        } else {
            null
        }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val handler = ScreenCaptureDetector(applicationContext)
        detector = handler

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ScreenCaptureDetector.CHANNEL,
        ).setStreamHandler(handler)
    }

    override fun onStart() {
        super.onStart()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            screenCaptureCallback?.let {
                try {
                    registerScreenCaptureCallback(mainExecutor, it)
                } catch (error: SecurityException) {
                    Log.w(TAG, "Screenshot detection unavailable", error)
                }
            }
        }
    }

    override fun onStop() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            screenCaptureCallback?.let {
                try {
                    unregisterScreenCaptureCallback(it)
                } catch (error: RuntimeException) {
                    Log.w(TAG, "Screenshot detection was not registered", error)
                }
            }
        }

        super.onStop()
    }
}
