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
 * Screenshots arrive from MainActivity's Android 14 capture callback. This
 * class watches the other half: a second display appearing, which is what
 * casting, mirroring, an HDMI cable and most MediaProjection recorders all
 * attach. Both are reported rather than blocked, so the server can count them.
 *
 * Not every recorder is caught. A MediaProjection virtual display created
 * without VIRTUAL_DISPLAY_FLAG_PUBLIC stays invisible to other processes, and
 * nothing short of a privileged app can see it.
 */
class ScreenCaptureDetector(context: Context) :
    EventChannel.StreamHandler, DisplayManager.DisplayListener {

    companion object {
        const val CHANNEL = "bilhikma/screen_capture"

        private const val TYPE_SCREENSHOT = "screenshot"
        private const val TYPE_SCREEN_RECORD = "screen_record"
        private const val TYPE_EXTERNAL_DISPLAY = "external_display"
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
            events?.success(mapOf("type" to TYPE_SCREENSHOT, "active" to true))
        }
    }

    private val displayManager =
        context.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager

    private val handler = Handler(Looper.getMainLooper())

    
    private val reported = mutableMapOf<Int, String>()

    private var events: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
        events = sink
        displayManager.registerDisplayListener(this, handler)



        displayManager.displays.forEach { report(it) }
    }

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
                "display_id" to display.displayId,
                "display_name" to display.name,
                "secure" to (display.flags and Display.FLAG_SECURE != 0),
            )
        )
    }
}
