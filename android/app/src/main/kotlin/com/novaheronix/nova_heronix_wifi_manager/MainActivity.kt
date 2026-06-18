package com.novaheronix.nova_heronix_wifi_manager

import android.content.Intent
import android.nfc.NdefMessage
import android.nfc.NdefRecord
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.nio.charset.Charset

class MainActivity : FlutterActivity() {
    private companion object {
        const val TAG = "NovaNfc"
    }

    private val channelName = "com.novaheronix.wifimanager/nfc"
    private var pendingNovaJson: String? = null
    private var channel: MethodChannel? = null

    // True while a Flutter NFC session (read/write/lock/wipe via nfc_manager)
    // owns reader mode. While set, the Activity must NOT run its own reader
    // mode or it would steal tags from the plugin.
    private var appNfcExclusive = false
    private var isResumed = false
    private var nfcAdapter: NfcAdapter? = null

    // True when OUR foreground reader mode is the one currently active. Lets us
    // hand off to the plugin exactly once (disable ours so it can't intercept
    // a write tap) without clobbering the plugin's reader mode on every resume.
    private var activityOwnsReader = false

    // Suppress all common tag technologies + the platform "tag found" sound.
    // SKIP_NDEF_CHECK is critical: this reader mode exists ONLY to swallow taps
    // so the system "new tag" screen never shows (onReaderTag does nothing with
    // the tag). If we let Android run its NDEF check here, it connects/reads the
    // tag's NDEF, leaving a stale NDEF handle; when the Flutter plugin then takes
    // over to WRITE, Android reports "Tag is not ndef" and the write fails. By
    // skipping the check we only detect presence and never touch NDEF, so the
    // plugin gets a clean handle for its write/wipe.
    private val readerFlags =
        NfcAdapter.FLAG_READER_NFC_A or
            NfcAdapter.FLAG_READER_NFC_B or
            NfcAdapter.FLAG_READER_NFC_F or
            NfcAdapter.FLAG_READER_NFC_V or
            NfcAdapter.FLAG_READER_SKIP_NDEF_CHECK or
            NfcAdapter.FLAG_READER_NO_PLATFORM_SOUNDS

    private val readerCallback = NfcAdapter.ReaderCallback { tag -> onReaderTag(tag) }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getPendingNovaJson" -> {
                    val json = pendingNovaJson
                    pendingNovaJson = null
                    result.success(json)
                }
                "setAppNfcExclusive" -> {
                    appNfcExclusive = call.argument<Boolean>("active") ?: false
                    // Hand reader mode to / take it back from the plugin.
                    updateReaderMode()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        nfcAdapter = NfcAdapter.getDefaultAdapter(this)
        Log.d(TAG, "onCreate: nfcAdapter=${nfcAdapter}, enabled=${nfcAdapter?.isEnabled}")
        captureNfcIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        isResumed = true
        Log.d(TAG, "onResume: arming foreground suppression")
        updateReaderMode()
    }

    override fun onPause() {
        super.onPause()
        isResumed = false
        // Tags should reach the system again once Nova is backgrounded.
        Log.d(TAG, "onPause: releasing reader mode")
        try {
            nfcAdapter?.disableReaderMode(this)
        } catch (e: Exception) {
            Log.e(TAG, "onPause: disableReaderMode failed", e)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureNfcIntent(intent)
    }

    /// Runs a foreground reader session whenever Nova is in the foreground and
    /// the plugin isn't already driving NFC. This is what stops Android's
    /// "New tag scanned" system screen from appearing while the app is open.
    private fun updateReaderMode() {
        val adapter = nfcAdapter
        if (adapter == null) {
            Log.w(TAG, "updateReaderMode: no NFC adapter on this device")
            return
        }
        if (appNfcExclusive) {
            // The Flutter plugin is taking over for a read/write/lock/wipe.
            // Do NOT disable our reader mode here: that would leave the NFC
            // field with no owner until the plugin arms its own reader mode,
            // and Android's system "new tag" screen would grab any tap in that
            // gap. Instead we keep our suppression reader mode running; the
            // plugin's enableReaderMode atomically replaces it (one reader mode
            // per Activity), so the field is never unguarded. We only mark that
            // the plugin now owns it, so a later resume won't clobber it.
            activityOwnsReader = false
            Log.d(TAG, "updateReaderMode: yielding to plugin (suppression held until replaced)")
            return
        }
        if (isResumed) {
            try {
                adapter.enableReaderMode(this, readerCallback, readerFlags, null)
                activityOwnsReader = true
                Log.d(TAG, "updateReaderMode: foreground reader mode ENABLED")
            } catch (e: Exception) {
                Log.e(TAG, "updateReaderMode: enableReaderMode failed", e)
            }
        } else {
            try {
                adapter.disableReaderMode(this)
                activityOwnsReader = false
                Log.d(TAG, "updateReaderMode: reader mode DISABLED (backgrounded)")
            } catch (e: Exception) {
                Log.e(TAG, "updateReaderMode: disableReaderMode failed", e)
            }
        }
    }

    /// A tag entered the field while OUR foreground reader mode owned it.
    /// This reader mode exists purely to SUPPRESS Android's "New tag scanned"
    /// system screen on non-scanning screens. We deliberately do nothing with
    /// the tag — swallowing it. Active tag handling only happens through an
    /// explicit Flutter session (Home scan, or a write/wipe), never here, so a
    /// stray tap on the Wipe/Setup/Detail screens can't hijack the flow.
    private fun onReaderTag(tag: Tag) {
        Log.d(TAG, "onReaderTag: tag swallowed for suppression (no action)")
    }

    private fun captureNfcIntent(intent: Intent?) {
        if (intent == null) return
        // Reader mode owns the tag while Nova has an active NFC session.
        if (appNfcExclusive) return
        val action = intent.action ?: return
        if (
            action != NfcAdapter.ACTION_NDEF_DISCOVERED &&
            action != NfcAdapter.ACTION_TAG_DISCOVERED
        ) {
            return
        }

        val rawMessages = intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES)
            ?: return

        for (parcelable in rawMessages) {
            val message = parcelable as? NdefMessage ?: continue
            val merged = mergeTagPayload(message) ?: continue
            pendingNovaJson = merged
            channel?.invokeMethod("onNfcTag", merged)
            return
        }
    }

    private fun mergeTagPayload(message: NdefMessage): String? {
        var novaJson: JSONObject? = null
        var wscSsid: String? = null
        var wscPassword: String? = null

        for (record in message.records) {
            val type = String(record.type, Charset.forName("US-ASCII"))
            val payload = record.payload ?: continue

            when {
                type == "novaheronix.com:wifi" -> {
                    val text = payload.toString(Charset.forName("UTF-8"))
                    if (text.startsWith("{")) {
                        novaJson = JSONObject(text)
                    }
                }
                type == "application/vnd.novaheronix.wifi" || type == "application/x.nova" -> {
                    val text = payload.toString(Charset.forName("UTF-8"))
                    if (text.startsWith("{")) {
                        novaJson = JSONObject(text)
                    }
                }
                type == "application/vnd.wfa.wsc" -> {
                    val creds = parseWsc(payload)
                    wscSsid = creds?.first
                    wscPassword = creds?.second
                }
                type == "T" -> {
                    if (payload.isEmpty()) continue
                    val langLen = payload[0].toInt() and 0x3F
                    if (payload.size <= 1 + langLen) continue
                    val text = payload.copyOfRange(1 + langLen, payload.size)
                        .toString(Charset.forName("UTF-8"))
                    if (text.trim().startsWith("{")) {
                        novaJson = JSONObject(text)
                    }
                }
            }
        }

        if (novaJson == null) return null

        if (!novaJson!!.has("ssid") && wscSsid != null) {
            novaJson!!.put("ssid", wscSsid)
        }
        if (!novaJson!!.has("password") && wscPassword != null) {
            novaJson!!.put("password", wscPassword)
        }

        return novaJson!!.toString()
    }

    private fun parseWsc(payload: ByteArray): Pair<String, String>? {
        var offset = 0
        if (payload.size >= 2 && payload[0] == 0x10.toByte() && payload[1] == 0x6e.toByte()) {
            offset = 2
        }

        val tlvs = readTlvs(payload, offset, payload.size)
        for (tlv in tlvs) {
            if (tlv.first == 0x100E) {
                return parseCredential(tlv.second)
            }
        }
        return null
    }

    private fun parseCredential(data: ByteArray): Pair<String, String>? {
        var ssid: String? = null
        var password: String? = null
        for (tlv in readTlvs(data, 0, data.size)) {
            when (tlv.first) {
                0x1045 -> ssid = tlv.second.toString(Charset.forName("UTF-8"))
                0x1027 -> password = tlv.second.toString(Charset.forName("UTF-8"))
            }
        }
        if (ssid == null || password == null) return null
        return Pair(ssid, password)
    }

    private fun readTlvs(data: ByteArray, start: Int, end: Int): List<Pair<Int, ByteArray>> {
        val result = mutableListOf<Pair<Int, ByteArray>>()
        var offset = start
        while (offset + 4 <= end) {
            val type = ((data[offset].toInt() and 0xFF) shl 8) or (data[offset + 1].toInt() and 0xFF)
            val length =
                ((data[offset + 2].toInt() and 0xFF) shl 8) or (data[offset + 3].toInt() and 0xFF)
            offset += 4
            if (offset + length > end) break
            result.add(Pair(type, data.copyOfRange(offset, offset + length)))
            offset += length
        }
        return result
    }
}
