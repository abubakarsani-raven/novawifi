import 'dart:async';

import 'package:app_links/app_links.dart';

/// Receives incoming Universal Links (iOS) / App Links (Android) so a tapped
/// provisioned tag opens the app straight on its setup form.
///
/// On iOS, background NFC tag reading opens the app via the tag's `https://`
/// URI record (an associated `applinks:` domain). The link carries the tag id
/// in the `t` query parameter.
class DeepLinkBridge {
  DeepLinkBridge._();

  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _sub;

  static Future<void> init(void Function(Uri uri) onLink) async {
    // Cold-start: a link that launched the app.
    final initial = await _appLinks.getInitialLink();
    if (initial != null) onLink(initial);
    // Warm links while the app is running.
    _sub = _appLinks.uriLinkStream.listen(onLink);
  }

  static void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
