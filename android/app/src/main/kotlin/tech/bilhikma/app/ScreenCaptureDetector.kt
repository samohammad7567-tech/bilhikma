package tech.bilhikma.app

import android.content.Context
import android.hardware.display.DisplayManager
import android.os.Handler
import android.os.Looper
import android.view.Display
import io.flutter.plugin.common.EventChannel

/**
 * Streams screen-capture attempts to Dart over [CHANNEL].
 *
 * Screenshots arrive from MainActivity's Android 14 capture callback, and
 * recordings from its Android 15 screen-recording callback. This class watches
 * the remaining half itself: a second display appearing, which is what
 * casting, mirroring and an HDMI cable attach. Everything is reported rather
 * than blocked, so the server can count it.
 *
 * The display inference is the weak one, and on its own it misses most
 * recorders: a MediaProjection virtual display created without
 * VIRTUAL_DISPLAY_FLAG_PUBLIC — the default — stays invisible to other
 * processes, and nothing short of a privileged app can see it. It is kept
 * because it is all there is below API 35, and because above it, it still
 * covers a mirroring route that never goes through MediaProjection.
 *
 * Each event carries the `source` that produced it, so the two can be told
 * apart in the backend without guessing from the API level.
 */
class ScreenCaptureDetector(context: Context) :
    EventChannel.StreamHandler, DisplayManager.DisplayListener {

    companion object {
        const val CHANNEL = "bilhikma/screen_capture"

        private const val TYPE_SCREENSHOT = "screenshot"
        private const val TYPE_SCREEN_RECORD = "screen_record"
        private const val TYPE_EXTERNAL_DISPLAY = "external_display"

        /** Reported by the platform itself — authoritative. */
        private const val SOURCE_PLATFORM = "platform"

        /** Inferred from a second display appearing — best effort. */
        private const val SOURCE_DISPLAY = "display"
    }

    /**
     * Emits a screenshot event. Called by MainActivity's
     * Activity.ScreenCaptureCallback on Android 14+; older versions give no
     * equivalent signal.
     *
     * A screenshot is instantaneous, so unlike a recording or an external
     * display it has no "active: false" counterpart to send afterwards.
     */
    fun reportScreenshot() {
        handler.post {
            events?.success(
                mapOf(
                    "type" to TYPE_SCREENSHOT,
                    "active" to true,
                    "source" to SOURCE_PLATFORM,
                )
            )
        }
    }

    /**
     * Emits a recording event. Called by MainActivity's Android 15
     * screen-recording callback with the state the platform reports for this
     * window.
     *
     * Only a change is emitted, because the callback is re-registered on every
     * [onListen] and on every return to the foreground: without this guard,
     * backgrounding the app during a recording and coming back would report the
     * same recording again.
     *
     * The state is kept so that a recording already in progress can be handed
     * to Dart the moment it starts listening, which is the common case on a
     * cold start — the platform callback fires long before the Flutter engine
     * is up.
     */
    fun reportRecording(isActive: Boolean) {
        if (isActive == isPlatformRecording) return

        isPlatformRecording = isActive

        handler.post { emitPlatformRecording() }
    }

    private val displayManager =
        context.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager

    private val handler = Handler(Looper.getMainLooper())

    
    private val reported = mutableMapOf<Int, String>()

    /**
     * Last recording state the platform reported, which outranks anything the
     * display inference concludes.
     */
    private var isPlatformRecording = false

    private var events: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
        events = sink
        displayManager.registerDisplayListener(this, handler)

        // A recording and an external display can both predate the engine, so
        // the current state is replayed rather than waited for. Dart is the
        // side that de-duplicates, and it has nothing to de-duplicate yet.
        if (isPlatformRecording) emitPlatformRecording()

        displayManager.displays.forEach { report(it) }
    }

    /**
     * [isPlatformRecording] is deliberately left alone: the subscription is
     * dropped whenever the policy exempts the account, while the recording
     * itself carries on, and clearing it would report that same recording
     * again on the next [onListen].
     */
    override fun onCancel(arguments: Any?) {
        displayManager.unregisterDisplayListener(this)
        reported.clear()
        events = null
    }

    override fun onDisplayAdded(displayId: Int) {
        displayManager.getDisplay(displayId)?.let { report(it) }
    }

    override fun onDisplayRemoved(displayId: Int) {
        val type = reported.remove(displayId) ?: return

        // A recorder can drop its virtual display and keep recording through
        // another surface. Where the platform is still reporting a recording it
        // is right and this inference is not, and sending "stopped" here would
        // re-arm Dart and have the next event reported as a second recording.
        if (type == TYPE_SCREEN_RECORD && isPlatformRecording) return

        events?.success(
            mapOf(
                "type" to type,
                "active" to false,
                "display_id" to displayId,
            )
        )
    }

    /**
     * A virtual display can be added while still STATE_OFF, which [report]
     * skips because an off display is capturing nothing yet. It is this
     * callback that fires when the recorder powers it on, so without handling
     * it that recording would never be reported at all.
     */
    override fun onDisplayChanged(displayId: Int) {
        displayManager.getDisplay(displayId)?.let { report(it) }
    }

    private fun report(display: Display) {
        if (display.displayId == Display.DEFAULT_DISPLAY) return
        if (display.state == Display.STATE_OFF) return
        if (reported.containsKey(display.displayId)) return

        val isPresentation = display.flags and Display.FLAG_PRESENTATION != 0
        val type = if (isPresentation) TYPE_EXTERNAL_DISPLAY else TYPE_SCREEN_RECORD

        reported[display.displayId] = type

        events?.success(
            mapOf(
                "type" to type,
                "active" to true,
                "source" to SOURCE_DISPLAY,
                "display_id" to display.displayId,
                "display_name" to display.name,
                "secure" to (display.flags and Display.FLAG_SECURE != 0),
            )
        )
    }

    private fun emitPlatformRecording() {
        events?.success(
            mapOf(
                "type" to TYPE_SCREEN_RECORD,
                "active" to isPlatformRecording,
                "source" to SOURCE_PLATFORM,
            )
        )
    }
}
