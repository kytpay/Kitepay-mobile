package com.kitepay.kitepay.nfc

class TextRecord(
    private val text: String
) : ParsedNdefRecord {

    override fun str(): String = text
}
