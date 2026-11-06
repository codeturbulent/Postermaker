package com.grampradhan.posterstudio.core.formatter

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test

class DevanagariTextFormatterTest {

    @Test
    @DisplayName("formatHonorific: Prevents duplicate prefixing when prefix is already present")
    fun testHonorificNoDuplicatePrefix() {
        // Case 1: Name already prefixed with "श्री"
        val result1 = DevanagariTextFormatter.formatHonorific(
            name = "श्री राम सिंह यादव",
            prefix = DevanagariTextFormatter.HonorificPrefix.SHRI
        )
        assertEquals("श्री राम सिंह यादव", result1)

        // Case 2: Name without prefix
        val result2 = DevanagariTextFormatter.formatHonorific(
            name = "राम सिंह यादव",
            prefix = DevanagariTextFormatter.HonorificPrefix.SHRI
        )
        assertEquals("श्री राम सिंह यादव", result2)

        // Case 3: Female candidate with "श्रीमती"
        val result3 = DevanagariTextFormatter.formatHonorific(
            name = "सरिता देवी",
            prefix = DevanagariTextFormatter.HonorificPrefix.SHRIMATI
        )
        assertEquals("श्रीमती सरिता देवी", result3)
    }

    @Test
    @DisplayName("formatDesignation: Preserves hierarchy and omits blank administrative tiers")
    fun testFormatDesignationHierarchy() {
        val lines = DevanagariTextFormatter.formatDesignation(
            designation = "भावी ग्राम प्रधान प्रत्याशी",
            panchayat = "रामपुर",
            block = "बक्शा",
            district = "जौनपुर"
        )

        assertEquals(4, lines.size)
        assertEquals("भावी ग्राम प्रधान प्रत्याशी", lines[0])
        assertEquals("ग्राम पंचायत: रामपुर", lines[1])
        assertEquals("विकास खंड: बक्शा", lines[2])
        assertEquals("जनपद: जौनपुर", lines[3])

        // When block is omitted
        val partialLines = DevanagariTextFormatter.formatDesignation(
            designation = "ग्राम प्रधान",
            panchayat = "रामपुर",
            block = "",
            district = "जौनपुर"
        )
        assertEquals(3, partialLines.size)
        assertEquals("ग्राम प्रधान", partialLines[0])
        assertEquals("ग्राम पंचायत: रामपुर", partialLines[1])
        assertEquals("जनपद: जौनपुर", partialLines[2])
    }

    @Test
    @DisplayName("smartWrapHindi: Does not break Devanagari conjuncts or matras across lines")
    fun testSmartWrapHindiMatraPreservation() {
        val hindiText = "सबका साथ सबका विकास और गाँव का संपूर्ण उत्थान"
        val wrapped = DevanagariTextFormatter.smartWrapHindi(hindiText, maxCharsPerLine = 15)

        assertTrue(wrapped.isNotEmpty())
        for (line in wrapped) {
            // Assert that line does not begin with an isolated combining matra or halant
            val firstChar = line.first()
            val isCombiningVowelSign = firstChar in '\u093E'..'\u094F'
            val isVirama = firstChar == '\u094D'
            assertTrue(!isCombiningVowelSign && !isVirama, "Line must not start with broken matra or halant: $line")
        }
    }

    @Test
    @DisplayName("toDevanagariNumerals: Maps Western digits 0-9 to Devanagari numerals ०-९")
    fun testToDevanagariNumerals() {
        val phone = "9876543210"
        val converted = DevanagariTextFormatter.toDevanagariNumerals(phone)
        assertEquals("९८७६५४३२१०", converted)

        val yearText = "वर्ष 2026"
        val convertedYear = DevanagariTextFormatter.toDevanagariNumerals(yearText)
        assertEquals("वर्ष २०२६", convertedYear)
    }
}
