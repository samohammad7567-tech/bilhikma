package tech.bilhikma.app

import android.app.Activity
import android.os.Build
import android.util.Log
import android.view.WindowManager
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import java.util.function.Consumer

/**
 * The window is never protected. FLAG_SECURE would block the screenshot, and a
 * blocked screenshot raises no callback and can never be reported — so the app
 * lets every capture happen and reports the ones it is told about.
 *
 * Whether a capture is reported is decided entirely in Dart from the account's
 * `can_capture_screen`, which arrives with the login response. Nothing on this
 * side needs to know about it, so there is no policy channel here.
 *
 * Two platform callbacks are registered here, both only while the activity is
 * started, and both ending up in [ScreenCaptureDetector]:
 *  - Android 14's screenshot callback, and
 *  - Android 15's screen-recording callback, which is the only signal that
 *    reports a recording of this window regardless of how the recorder set its
 *    virtual display up. Below API 35 the app is left with the DisplayManager
 *    inference in [ScreenCaptureDetector], which misses most recorders.
 *
 * The superclass is [AudioServiceActivity], not `FlutterActivity`: both
 * audio_service and just_audio_background require it, because tapping the
 * media notification has to re-attach this activity to the engine the
 * background service is already driving. With a plain `FlutterActivity` that
 * hand-off has no route back into the running isolate.
 */
class MainActivity : AudioServiceActivity() {

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

    /**
     * Android 15 added [WindowManager.addScreenRecordingCallback]. It is the
     * platform telling the app that *this window's* content is being recorded,
     * so unlike the DisplayManager inference it does not care whether the
     * recorder's virtual display is public, and it covers the built-in
     * recorder.
     *
     * It fires on every transition while registered, and the add call also
     * answers with the state in force at that moment — which is what catches a
     * recording that was already running before the app was opened.
     */
    private val screenRecordingCallback =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM) {
            Consumer<Int> { state -> onScreenRecordingState(state) }
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

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM) {
            screenRecordingCallback?.let {
                try {
                    // The return value is the current state, not an
                    // acknowledgement: a recording already in progress is only
                    // ever reported here, never by a later callback.
                    onScreenRecordingState(
                        windowManager.addScreenRecordingCallback(mainExecutor, it)
                    )
                } catch (error: RuntimeException) {
                    // SecurityException for a missing permission, but also
                    // whatever an OEM throws from a window this call does not
                    // like. Losing the detection is a bad outcome; taking the
                    // activity down on every start is a far worse one.
                    Log.w(TAG, "Screen recording detection unavailable", error)
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

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM) {
            screenRecordingCallback?.let {
                try {
                    windowManager.removeScreenRecordingCallback(it)
                } catch (error: RuntimeException) {
                    Log.w(TAG, "Screen recording detection was not registered", error)
                }
            }
        }

        super.onStop()
    }

    /**
     * Deliberately does not report "not recording" when the callback is torn
     * down in [onStop]: the recording is still running, the app has only
     * stopped watching it. [ScreenCaptureDetector.reportRecording] holds the
     * state, so returning to a still-recording screen reports nothing new and
     * the event is not sent twice.
     */
    private fun onScreenRecordingState(state: Int) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.VANILLA_ICE_CREAM) return

        detector?.reportRecording(
            state == WindowManager.SCREEN_RECORDING_STATE_VISIBLE
        )
    }
}
