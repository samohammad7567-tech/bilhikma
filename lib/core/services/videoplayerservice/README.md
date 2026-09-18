
A portable floating video player: full-screen playback with custom gesture
controls, shrinking into a draggable / pinch-to-resize picture-in-picture
square, plus Android system Picture-in-Picture when the user leaves the app.
**No dependency on the rest of this app** (no `Lesson`, no app theme). Drop the
whole `videoplayerservice/` folder into another Flutter project's
`lib/core/services/`.

Plays **every kind of video behind one API**:

| Source | Engine | Notes |
|--------|--------|-------|
| YouTube watch / live / shorts / embed / `youtu.be` links, or a raw video id | `youtube_player_flutter` (IFrame) | Live broadcasts supported |
| `.mp4`, `.webm`, HLS `.m3u8`, DASH `.mpd`, any direct URL | `video_player` (ExoPlayer / AVPlayer) | Live HLS supported, custom HTTP headers supported |

Live streams are detected automatically (no fixed duration): the progress bar
and seek gestures are replaced by a **LIVE** badge.

Gesture controls (expanded): tap = show/hide controls · center button =
play/pause · double-tap left/right = seek ±10s · long-press right = 2x while
held · swipe down = minimize · rotate button · speed picker · draggable
progress bar. PiP square: drag to move, pinch to resize, tap center =
play/pause, tap elsewhere = expand, ✕ = close.

| File | Purpose |
|------|---------|
| `video_item.dart` | Portable `VideoItem` model + `VideoSourceKind` + YouTube-id / live-URL detection. |
| `video_playback.dart` | `VideoPlayback` — the engine-agnostic playback interface the UI talks to, plus `VideoPlayback.forItem` which picks the engine. |
| `youtube_video_playback.dart` | `VideoPlayback` over the YouTube IFrame player. |
| `network_video_playback.dart` | `VideoPlayback` over `video_player` (mp4 / HLS / DASH, live or VOD). |
| `floating_video_controller.dart` | `FloatingVideoController` (a `ChangeNotifier`, no `flutter_bloc`): open / minimize / expand / close / retry + PiP geometry. |
| `floating_video_overlay.dart` | `FloatingVideoOverlay` widget: full-screen + PiP UI with all gestures, loading and error states. |
| `video_player_options.dart` | `FloatingVideoOptions`: colors, speed list, labels, share hook, custom details builder. |
| `videoplayerservice.dart` | Barrel export. |

```yaml
dependencies:
  youtube_player_flutter: ^10.0.1
  video_player: ^2.13.0
  floating: ^6.0.0        # Android system Picture-in-Picture
  share_plus: ^13.3.0     # only used if you rely on VideoItem.shareText
```

For Android system PiP, follow the `floating` package's setup (declare
`android:supportsPictureInPicture="true"` on your Activity). To skip system PiP
entirely, construct the controller with `enablePictureInPicture: false`.

Network playback needs the usual platform bits: `android:usesCleartextTraffic`
(only for plain-http streams) and `NSAppTransportSecurity` on iOS.

```dart
final videoController = FloatingVideoController();
```

Provide it however you like (a singleton, `Provider`, `InheritedWidget`, passed
down, …).

Put `FloatingVideoOverlay` in a `Stack` above your main content (e.g. wrapping
your shell / `MainScreen`) so it floats over everything:

```dart
Stack(
  children: [
    yourAppContent,
    FloatingVideoOverlay(
      controller: videoController,
      options: const FloatingVideoOptions(),
    ),
  ],
);
```

Let the URL decide the engine — this is the call you normally want:

```dart
final item = VideoItem.fromUrl(
  lesson.videoUrl,           
  id: lesson.id,
  title: lesson.title,
  date: lesson.date,
  description: lesson.description,
  shareText: 'Watch: ${lesson.videoUrl}',
);
if (item != null) videoController.open(item);
```

Or be explicit:

```dart

videoController.open(VideoItem.youtube(
  id: lesson.id,
  youtubeVideoId: 'dQw4w9WgXcQ',
));


videoController.open(VideoItem.network(
  id: session.id,
  url: 'https:
  isLive: true,
  httpHeaders: {'Authorization': 'Bearer $token'},
));
```

`isLive` is only a hint — if you get it wrong it self-corrects once the stream
reports (or fails to report) a duration.

```dart
FloatingVideoOptions(
  backgroundColor: const Color(0xFF101820),
  accentColor: Colors.tealAccent,
  speedSheetTitle: 'Playback speed',
  descriptionLabel: 'Description',
  liveLabel: 'LIVE',
  retryLabel: 'Retry',
  enablePictureInPicture: true,
  onShare: (item) => Share.share(item.shareText ?? ''),
  detailsBuilder: (context, item) => MyCustomDetails(item: item),
);
```

- `onShare` overrides the default share behavior. If both `onShare` and
  `VideoItem.shareText` are null, the share button is hidden.
- `detailsBuilder` replaces the default title/date/description block under the
  expanded video.

- The options class is called `FloatingVideoOptions`, not `VideoPlayerOptions`,
  so it never collides with `video_player`'s own `VideoPlayerOptions`.
- Controls are handed *into* the player surface (`VideoPlayback.buildSurface`)
  rather than stacked around it, because the YouTube engine renders through a
  platform view whose overlay must live inside the player to compose correctly.
- A shared `GlobalKey` reparents the same player across expanded ⇄ PiP and
  portrait ⇄ landscape, so playback never restarts when the layout changes.
- Playback ticks are not forwarded through `FloatingVideoController`; the
  overlay's leaf widgets listen to `VideoPlayback` directly, so a position
  update never rebuilds the video surface.
- The overlay locks orientation back to portrait when it goes away.
- YouTube quality selection is gone: the IFrame API's `setPlaybackQuality` is a
  no-op on modern YouTube, so the picker now sets **playback speed**, which
  works on both engines.
- Call `videoController.dispose()` when you tear the controller down.
