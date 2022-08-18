package com.kitepay.kitepay

import android.content.Intent
import android.os.Bundle
import android.content.pm.PackageManager
import android.util.Log
import android.app.PendingIntent
import android.content.Context
import android.nfc.NdefMessage
import android.nfc.NfcAdapter
import android.nfc.NfcManager
import androidx.appcompat.app.AppCompatActivity
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterView
import com.kitepay.kitepay.nfc.NdefParser

class MainActivity : FlutterActivity() {

    private var nfcAdapter: NfcAdapter? = null
    private val TAG = "NfcEmulator-MainActivity"
    private val NFC_NDEF_KEY = "ndefMessage"
    private val CHANNEL = "org.kitepay.app.emulator"
    private lateinit var methodChannel: MethodChannel

//    private val channel: MethodChannel by lazy { MethodChannel(flutterView, "hce") }
//
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        GeneratedPluginRegister.registerGeneratedPlugins(FlutterEngine(this));
//        flutterView.addFirstFrameListener {
//            if (intent.hasExtra("success")) {
//                onHCEResult(intent)
//            }
//        }
//    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        methodChannel.setMethodCallHandler { call, result ->
            if (call.method == "startNfcEmulator") {
                val text: String? = call.argument<String?>("text")

                if (text != null || text?.length != 0) {
                    Log.d("TEXT", text!!)
                    initNfcEmulatorFunction(text)
                    result.success(null)
                } else {
                    Log.d(TAG, "NFC text is null")
                }
            } else if (call.method == "stopNfcEmulator") {
                stopNfcEmulatorService()
                result.success(null);
            } else if (call.method == "enableNfc") {
                enableNfc()
                result.success(null);
            } else if (call.method == "disableNfc") {
                disableNfc()
                result.success(null);
            } else {
                result.notImplemented()
            }
        }
    }

    private fun initNfcEmulatorFunction(text: String) {
        nfcAdapter = NfcAdapter.getDefaultAdapter(this)

//        if (this.packageManager.hasSystemFeature(PackageManager.FEATURE_NFC_HOST_CARD_EMULATION)) {
//            Log.d(TAG, "NFC Unavailable")
//            return
//        }

        if (nfcAdapter?.isEnabled == true) {
            initNfcEmulatorService(text)
        } else {
            Log.d(TAG, "NFC Unenabled")
        }
    }

    private fun initNfcEmulatorService(text: String) {
        val intent = Intent(this, HceCardEmulationApduService::class.java)
        intent.putExtra(NFC_NDEF_KEY, text)
        this.startService(intent)
        Log.d(TAG, "NFC Emulation Started")

    }

    private fun stopNfcEmulatorService() {
        nfcAdapter = NfcAdapter.getDefaultAdapter(this)
        if (nfcAdapter?.isEnabled == true) {
            this.stopService(Intent(this, HceCardEmulationApduService::class.java))
        }
        Log.d(TAG, "NFC Emulation stopped")
    }

    private fun enableNfc() {
        nfcAdapter = NfcAdapter.getDefaultAdapter(this)
        try {
            val intent =
                Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            val nfcPendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE)
            nfcAdapter?.enableForegroundDispatch(this, nfcPendingIntent, null, null)
            Log.d(TAG, "NFC enabled")

        } catch (ex: IllegalStateException) {
            Log.d(TAG, "Error enabling NFC foreground dispatch")
        }
    }

    private fun disableNfc() {
        nfcAdapter = NfcAdapter.getDefaultAdapter(this)

        try {
            nfcAdapter?.disableForegroundDispatch(this)
            Log.d(TAG, "NFC disabled")

        } catch (ex: IllegalStateException) {
            Log.e("Error disabling NFC foreground dispatch", ex.message!!)
        }
    }

    private fun handleIntent(intent: Intent) {
        if (intent.action == NfcAdapter.ACTION_NDEF_DISCOVERED) {
            checkNdefMessage(intent)
        }
    }

    private fun checkNdefMessage(intent: Intent) {
        intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES)?.also { rawMessages ->
            val messages = rawMessages.map { it as NdefMessage }
            parseNdefMessages(messages)
            intent.removeExtra(NfcAdapter.EXTRA_NDEF_MESSAGES)
        }
    }

    private fun parseNdefMessages(messages: List<NdefMessage>) {
        if (messages.isEmpty()) {
            return
        }

        val builder = StringBuilder()
        val records = NdefParser.parse(messages[0])
        val size = records.size

        for (i in 0 until size) {
            val record = records[i]
            val str = record.str()
            builder.append(str)
        }

        val message = builder.toString()
        if (message.isNotEmpty()) {
            methodChannel.invokeMethod("onNfcRead", message)
        } else {
            Log.d(TAG, "Received empty NDEFMessage")
        }
    }

//    override fun onNewIntent(intent: Intent) {
//        super.onNewIntent(intent)
//        if (intent?.hasExtra("success") == true) {
//            onHCEResult(intent)
//        }
//    }

//    private fun onHCEResult(intent: Intent) = intent.getBooleanExtra("success", false).let { success ->
//        channel.invokeMethod("onHCEResult", success)
//    }
}
