package com.kitepay.kitepay.nfc

import android.nfc.NdefMessage
import android.nfc.NdefRecord
import android.util.Log
import java.io.UnsupportedEncodingException
import java.util.*
import kotlin.experimental.and

object NdefParser {

    fun parse(message: NdefMessage): List<ParsedNdefRecord> = getRecords(message.records)

    private fun getRecords(records: Array<NdefRecord>): List<ParsedNdefRecord> =
        records.map {
            it.parse() ?: object : ParsedNdefRecord {
                override fun str(): String = String(it.payload)
            }
        }
}

fun NdefRecord.parse(): ParsedNdefRecord? =
    if (tnf == NdefRecord.TNF_WELL_KNOWN && Arrays.equals(type, NdefRecord.RTD_TEXT)) {
        try {
            val recordPayload = payload

            /*
             * payload[0] contains the "Status Byte Encodings" field, per the
             * NFC Forum "Text Record Type Definition" section 3.2.1.
             *
             * bit7 is the Text Encoding Field.
             *
             * if (Bit_7 == 0): The text is encoded in UTF-8 if (Bit_7 == 1):
             * The text is encoded in UTF16
             *
             * Bit_6 is reserved for future use and must be set to zero.
             */
            val textEncoding = if (recordPayload[0] and 128.toByte() == 0.toByte()) {
                Charsets.UTF_8
            } else {
                Charsets.UTF_16
            }

            val langCodeLen = (recordPayload[0] and 63.toByte()).toInt()
            val text = String(recordPayload, textEncoding).substring(1 + langCodeLen)

            TextRecord(text)
        } catch (e: UnsupportedEncodingException) {
            Log.d("TAG","We got a malformed tag.")
            null
        }
    } else {
        null
    }
