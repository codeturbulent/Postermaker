package com.grampradhan.posterstudio.core.formatter

import java.text.BreakIterator
import java.util.Locale

/**
 * Dedicated typography utility for Hindi/Devanagari election posters,
 * handling honorific normalization, panchayat administrative hierarchy,
 * grapheme-cluster-safe line wrapping, and numeral conversion.
 */
object DevanagariTextFormatter {

    enum class HonorificPrefix(val displayPrefix: String) {
        SHRI("श्री"),
        SHRIMATI("श्रीमती"),
        SAU("सौ."),
        KU("कु."),
        DR("डॉ.")
    }

    private val ALL_PREFIX_STRINGS = listOf(
        "श्री", "श्रीमान", "श्रीमती", "सौ.", "सौ", "कु.", "कुमारी", "डॉ.", "डॉ"
    )

    /**
     * Appends an honorific prefix while preventing duplicate prefixes.
     * e.g., "श्री राम सिंह" with HonorificPrefix.SHRI returns "श्री राम सिंह" rather than "श्री श्री राम सिंह".
     */
    fun formatHonorific(name: String, prefix: HonorificPrefix): String {
        val trimmed = name.trim()
        if (trimmed.isEmpty()) return prefix.displayPrefix

        // Check if name already begins with any known honorific prefix
        for (p in ALL_PREFIX_STRINGS) {
            if (trimmed.startsWith(p)) {
                val afterPrefix = trimmed.removePrefix(p).trimStart()
                // If it was already prefixed with the exact same prefix, return as-is
                if (p == prefix.displayPrefix) {
                    return trimmed
                }
                // Otherwise replace with requested prefix
                return "${prefix.displayPrefix} $afterPrefix"
            }
        }
        return "${prefix.displayPrefix} $trimmed"
    }

    /**
     * Formats administrative hierarchy in the standard Devanagari poster layout:
     * 1. Designation
     * 2. Gram Panchayat
     * 3. Vikas Khand (Block)
     * 4. District (Janpad)
     */
    fun formatDesignation(
        designation: String,
        panchayat: String,
        block: String,
        district: String
    ): List<String> {
        val lines = mutableListOf<String>()

        val cleanDesignation = designation.trim()
        if (cleanDesignation.isNotEmpty()) {
            lines.add(cleanDesignation)
        }

        val cleanPanchayat = panchayat.trim()
        if (cleanPanchayat.isNotEmpty()) {
            val formattedPanchayat = if (cleanPanchayat.startsWith("ग्राम पंचायत")) {
                cleanPanchayat
            } else {
                "ग्राम पंचायत: $cleanPanchayat"
            }
            lines.add(formattedPanchayat)
        }

        val cleanBlock = block.trim()
        if (cleanBlock.isNotEmpty()) {
            val formattedBlock = if (cleanBlock.startsWith("विकास खंड") || cleanBlock.startsWith("ब्लॉक")) {
                cleanBlock
            } else {
                "विकास खंड: $cleanBlock"
            }
            lines.add(formattedBlock)
        }

        val cleanDistrict = district.trim()
        if (cleanDistrict.isNotEmpty()) {
            val formattedDistrict = if (cleanDistrict.startsWith("जनपद") || cleanDistrict.startsWith("ज़िला") || cleanDistrict.startsWith("जिला")) {
                cleanDistrict
            } else {
                "जनपद: $cleanDistrict"
            }
            lines.add(formattedDistrict)
        }

        return lines
    }

    /**
     * Wraps Hindi text cleanly without breaking matra clusters or halant conjuncts.
     * Uses BreakIterator configured for Locale("hi", "IN").
     */
    fun smartWrapHindi(text: String, maxCharsPerLine: Int): List<String> {
        val trimmed = text.trim()
        if (trimmed.isEmpty()) return emptyList()
        if (trimmed.length <= maxCharsPerLine) return listOf(trimmed)

        val iterator = BreakIterator.getLineInstance(Locale("hi", "IN"))
        iterator.setText(trimmed)

        val resultLines = mutableListOf<String>()
        var start = iterator.first()
        var end = iterator.next()
        val currentLine = StringBuilder()

        while (end != BreakIterator.DONE) {
            val wordOrCluster = trimmed.substring(start, end)

            if (currentLine.length + wordOrCluster.length <= maxCharsPerLine) {
                currentLine.append(wordOrCluster)
            } else {
                val candidateLine = currentLine.toString().trim()
                if (candidateLine.isNotEmpty()) {
                    resultLines.add(candidateLine)
                    currentLine.clear()
                }
                currentLine.append(wordOrCluster.trimStart())
            }

            start = end
            end = iterator.next()
        }

        val finalLine = currentLine.toString().trim()
        if (finalLine.isNotEmpty()) {
            resultLines.add(finalLine)
        }

        return resultLines
    }

    /**
     * Converts standard Western Arabic digits (0-9) to Devanagari numerals (०-९).
     */
    fun toDevanagariNumerals(input: String): String {
        val devanagariZero = 0x0966
        val sb = StringBuilder(input.length)
        for (ch in input) {
            if (ch in '0'..'9') {
                val digitValue = ch - '0'
                sb.append((devanagariZero + digitValue).toChar())
            } else {
                sb.append(ch)
            }
        }
        return sb.toString()
    }
}
