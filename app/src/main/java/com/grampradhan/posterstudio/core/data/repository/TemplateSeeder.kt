package com.grampradhan.posterstudio.core.data.repository

import com.grampradhan.posterstudio.core.data.model.AspectRatio
import com.grampradhan.posterstudio.core.data.model.ImageSlotConfig
import com.grampradhan.posterstudio.core.data.model.PosterTemplate
import com.grampradhan.posterstudio.core.data.model.SlotType
import com.grampradhan.posterstudio.core.data.model.TemplateCategory
import com.grampradhan.posterstudio.core.data.model.TextLayerConfig

object TemplateSeeder {

    val BUNDLED_TEMPLATES = listOf(
        // 1. Gram Pradhan Election Announcement (Square 1:1)
        PosterTemplate(
            id = "tpl_election_pradhan_01",
            category = TemplateCategory.ELECTION_CAMPAIGN,
            aspectRatio = AspectRatio.SQUARE_1_1,
            backgroundUrl = "gradient:#FF6A1B:#FFFFFF:#138808", // Tricolor saffron gradient
            thumbUrl = "",
            predefinedTextLayers = listOf(
                TextLayerConfig(
                    layerId = "slogan",
                    text = "गाँव का सर्वांगीण विकास ही हमारा मुख्य संकल्प है",
                    fontName = "Rozha One",
                    colorHex = "#FFD700",
                    strokeColorHex = "#000000",
                    strokeWidthDp = 2f,
                    fontSizeSp = 24f,
                    xRatio = 0.5f,
                    yRatio = 0.15f
                ),
                TextLayerConfig(
                    layerId = "appeal",
                    text = "ग्राम पंचायत के सम्मानित मतदाताओं से करबद्ध प्रार्थना",
                    fontName = "Noto Sans Devanagari",
                    colorHex = "#FFFFFF",
                    fontSizeSp = 18f,
                    xRatio = 0.5f,
                    yRatio = 0.25f
                ),
                TextLayerConfig(
                    layerId = "vote_call",
                    text = "अपना बहुमूल्य वोट एवं आशीर्वाद देकर भारी मतों से विजयी बनाएं",
                    fontName = "Baloo Bhai 2",
                    colorHex = "#FFFF00",
                    strokeColorHex = "#B71C1C",
                    strokeWidthDp = 1.5f,
                    fontSizeSp = 20f,
                    xRatio = 0.5f,
                    yRatio = 0.78f
                )
            ),
            slotConfigs = listOf(
                ImageSlotConfig("slot_candidate", SlotType.CANDIDATE_PHOTO, 0.22f, 0.65f, 0.38f, 0.55f, 2),
                ImageSlotConfig("slot_symbol", SlotType.PARTY_SYMBOL, 0.82f, 0.20f, 0.22f, 0.22f, 3),
                ImageSlotConfig("slot_village", SlotType.VILLAGE_TEXT, 0.50f, 0.92f, 0.90f, 0.12f, 4)
            ),
            isPro = false
        ),

        // 2. WhatsApp Status Election Appeal (Portrait 9:16)
        PosterTemplate(
            id = "tpl_election_status_02",
            category = TemplateCategory.ELECTION_CAMPAIGN,
            aspectRatio = AspectRatio.PORTRAIT_9_16,
            backgroundUrl = "gradient:#0D47A1:#1976D2:#000000",
            thumbUrl = "",
            predefinedTextLayers = listOf(
                TextLayerConfig(
                    layerId = "slogan",
                    text = "विश्वास आपका, विकास हमारा",
                    fontName = "Rozha One",
                    colorHex = "#FFEB3B",
                    strokeColorHex = "#000000",
                    strokeWidthDp = 2.5f,
                    fontSizeSp = 28f,
                    xRatio = 0.5f,
                    yRatio = 0.12f
                ),
                TextLayerConfig(
                    layerId = "title",
                    text = "त्रिस्तरीय पंचायत सामान्य निर्वाचन 2026",
                    fontName = "Mukta",
                    colorHex = "#FFFFFF",
                    fontSizeSp = 18f,
                    xRatio = 0.5f,
                    yRatio = 0.18f
                ),
                TextLayerConfig(
                    layerId = "pledge",
                    text = "ईमानदार, कर्मठ एवं जुझारू व्यक्तित्व",
                    fontName = "Kalam",
                    colorHex = "#00E676",
                    fontSizeSp = 22f,
                    xRatio = 0.5f,
                    yRatio = 0.72f
                )
            ),
            slotConfigs = listOf(
                ImageSlotConfig("slot_candidate", SlotType.CANDIDATE_PHOTO, 0.50f, 0.46f, 0.65f, 0.45f, 2),
                ImageSlotConfig("slot_symbol", SlotType.PARTY_SYMBOL, 0.85f, 0.22f, 0.20f, 0.20f, 3),
                ImageSlotConfig("slot_village", SlotType.VILLAGE_TEXT, 0.50f, 0.90f, 0.92f, 0.14f, 4)
            ),
            isPro = false
        ),

        // 3. Diwali & Chhath Puja Greetings (Square 1:1)
        PosterTemplate(
            id = "tpl_festival_diwali_01",
            category = TemplateCategory.FESTIVAL_GREETINGS,
            aspectRatio = AspectRatio.SQUARE_1_1,
            backgroundUrl = "gradient:#4A0E17:#B71C1C:#FF8F00", // Deep festive maroon
            thumbUrl = "",
            predefinedTextLayers = listOf(
                TextLayerConfig(
                    layerId = "greeting_heading",
                    text = "शुभ दीपावली एवं छठ महापर्व",
                    fontName = "Yatra One",
                    colorHex = "#FFD700",
                    strokeColorHex = "#3E2723",
                    strokeWidthDp = 2.5f,
                    fontSizeSp = 30f,
                    xRatio = 0.5f,
                    yRatio = 0.18f
                ),
                TextLayerConfig(
                    layerId = "greeting_body",
                    text = "समस्त क्षेत्रवासियों एवं ग्रामवासियों को सुख, शांति व समृद्धि के पावन पर्व की हार्दिक शुभकामनाएँ",
                    fontName = "Noto Sans Devanagari",
                    colorHex = "#FFFFFF",
                    fontSizeSp = 17f,
                    xRatio = 0.5f,
                    yRatio = 0.30f
                )
            ),
            slotConfigs = listOf(
                ImageSlotConfig("slot_candidate", SlotType.CANDIDATE_PHOTO, 0.22f, 0.72f, 0.38f, 0.50f, 2),
                ImageSlotConfig("slot_symbol", SlotType.PARTY_SYMBOL, 0.85f, 0.18f, 0.20f, 0.20f, 3),
                ImageSlotConfig("slot_village", SlotType.VILLAGE_TEXT, 0.58f, 0.88f, 0.75f, 0.14f, 4)
            ),
            isPro = false
        ),

        // 4. Holi Festival Greetings (Square 1:1)
        PosterTemplate(
            id = "tpl_festival_holi_02",
            category = TemplateCategory.FESTIVAL_GREETINGS,
            aspectRatio = AspectRatio.SQUARE_1_1,
            backgroundUrl = "gradient:#880E4F:#E91E63:#FF9800", // Vibrant Gulal Pink & Saffron
            thumbUrl = "",
            predefinedTextLayers = listOf(
                TextLayerConfig(
                    layerId = "greeting_heading",
                    text = "रंगों के पावन पर्व होली की हार्दिक बधाई",
                    fontName = "Rozha One",
                    colorHex = "#FFFFFF",
                    strokeColorHex = "#880E4F",
                    strokeWidthDp = 2.5f,
                    fontSizeSp = 28f,
                    xRatio = 0.5f,
                    yRatio = 0.16f
                ),
                TextLayerConfig(
                    layerId = "greeting_body",
                    text = "आपसी प्रेम, सद्भाव और उल्लास का यह पर्व आपके जीवन में खुशहाली लाए",
                    fontName = "Mukta",
                    colorHex = "#FFF9C4",
                    fontSizeSp = 18f,
                    xRatio = 0.5f,
                    yRatio = 0.28f
                )
            ),
            slotConfigs = listOf(
                ImageSlotConfig("slot_candidate", SlotType.CANDIDATE_PHOTO, 0.24f, 0.70f, 0.36f, 0.50f, 2),
                ImageSlotConfig("slot_symbol", SlotType.PARTY_SYMBOL, 0.82f, 0.18f, 0.18f, 0.18f, 3),
                ImageSlotConfig("slot_village", SlotType.VILLAGE_TEXT, 0.58f, 0.88f, 0.75f, 0.14f, 4)
            ),
            isPro = false
        ),

        // 5. Village Development / Vikas Karya Shilanayas (Banner 2:1 Flex)
        PosterTemplate(
            id = "tpl_vikas_road_01",
            category = TemplateCategory.VIKAS_KARYA,
            aspectRatio = AspectRatio.BANNER_2_1,
            backgroundUrl = "gradient:#1B5E20:#2E7D32:#F5F5F5",
            thumbUrl = "",
            predefinedTextLayers = listOf(
                TextLayerConfig(
                    layerId = "work_headline",
                    text = "ग्राम पंचायत में विकास कार्यों का लोकार्पण एवं शिलान्यास",
                    fontName = "Baloo Bhai 2",
                    colorHex = "#FFEB3B",
                    strokeColorHex = "#1B5E20",
                    strokeWidthDp = 2f,
                    fontSizeSp = 26f,
                    xRatio = 0.55f,
                    yRatio = 0.22f
                ),
                TextLayerConfig(
                    layerId = "work_desc",
                    text = "पक्की इंटरलॉकिंग सड़क, जल निकासी नाली एवं सौर ऊर्जा लाइट व्यवस्था",
                    fontName = "Noto Sans Devanagari",
                    colorHex = "#FFFFFF",
                    fontSizeSp = 18f,
                    xRatio = 0.55f,
                    yRatio = 0.45f
                ),
                TextLayerConfig(
                    layerId = "work_motto",
                    text = "कहा जो, किया वो — विकसित गाँव, खुशहाल गाँव",
                    fontName = "Kalam",
                    colorHex = "#FFCC80",
                    fontSizeSp = 20f,
                    xRatio = 0.55f,
                    yRatio = 0.68f
                )
            ),
            slotConfigs = listOf(
                ImageSlotConfig("slot_candidate", SlotType.CANDIDATE_PHOTO, 0.16f, 0.52f, 0.28f, 0.85f, 2),
                ImageSlotConfig("slot_symbol", SlotType.PARTY_SYMBOL, 0.90f, 0.22f, 0.16f, 0.32f, 3),
                ImageSlotConfig("slot_village", SlotType.VILLAGE_TEXT, 0.55f, 0.88f, 0.65f, 0.18f, 4)
            ),
            isPro = false
        ),

        // 6. Birthday / Congratulations Greetings (Square 1:1)
        PosterTemplate(
            id = "tpl_birthday_leader_01",
            category = TemplateCategory.BIRTHDAY_CONGRATULATIONS,
            aspectRatio = AspectRatio.SQUARE_1_1,
            backgroundUrl = "gradient:#311B92:#512DA8:#FFD700",
            thumbUrl = "",
            predefinedTextLayers = listOf(
                TextLayerConfig(
                    layerId = "bd_title",
                    text = "जन्मदिन की अनंत हार्दिक शुभकामनाएँ",
                    fontName = "Rozha One",
                    colorHex = "#FFD700",
                    strokeColorHex = "#1A237E",
                    strokeWidthDp = 2.5f,
                    fontSizeSp = 28f,
                    xRatio = 0.5f,
                    yRatio = 0.18f
                ),
                TextLayerConfig(
                    layerId = "bd_prayer",
                    text = "परमपिता परमेश्वर से आपके उत्तम स्वास्थ्य, सुदीर्घ जीवन एवं निरंतर जनसेवा की कामना करते हैं",
                    fontName = "Mukta",
                    colorHex = "#FFFFFF",
                    fontSizeSp = 17f,
                    xRatio = 0.5f,
                    yRatio = 0.72f
                )
            ),
            slotConfigs = listOf(
                ImageSlotConfig("slot_candidate", SlotType.CANDIDATE_PHOTO, 0.50f, 0.45f, 0.55f, 0.50f, 2),
                ImageSlotConfig("slot_symbol", SlotType.PARTY_SYMBOL, 0.88f, 0.18f, 0.18f, 0.18f, 3),
                ImageSlotConfig("slot_village", SlotType.VILLAGE_TEXT, 0.50f, 0.90f, 0.85f, 0.12f, 4)
            ),
            isPro = false
        )
    )
}
