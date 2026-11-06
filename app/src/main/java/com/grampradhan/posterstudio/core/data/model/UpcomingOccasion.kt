package com.grampradhan.posterstudio.core.data.model

data class UpcomingOccasion(
    val title: String,
    val subtitle: String,
    val badgeText: String,
    val icon: String,
    val category: TemplateCategory,
    val dateText: String
) {
    companion object {
        val PRESET_OCCASIONS = listOf(
            UpcomingOccasion(
                title = "दीपावली महापर्व",
                subtitle = "समस्त क्षेत्रवासियों को प्रकाश पर्व की बधाई भेजें",
                badgeText = "🔥 आगामी पर्व",
                icon = "🪔",
                category = TemplateCategory.FESTIVAL_GREETINGS,
                dateText = "कार्तिक अमावस्या"
            ),
            UpcomingOccasion(
                title = "छठ पूजा महोत्सव",
                subtitle = "सूर्य उपासना के महापर्व का पोस्टर तैयार करें",
                badgeText = "✨ पावन पर्व",
                icon = "🌅",
                category = TemplateCategory.FESTIVAL_GREETINGS,
                dateText = "कार्तिक शुक्ल षष्ठी"
            ),
            UpcomingOccasion(
                title = "ग्राम पंचायत चुनाव 2026",
                subtitle = "विकास और सेवा के संकल्प के साथ अपना पोस्टर बनाएं",
                badgeText = "🗳️ चुनावी हलचल",
                icon = "🗳️",
                category = TemplateCategory.ELECTION_CAMPAIGN,
                dateText = "विशेष अभियान"
            ),
            UpcomingOccasion(
                title = "नव वर्ष 2026 मंगलमय हो",
                subtitle = "नए साल के संकल्प और मंगलकामनाएं साझा करें",
                badgeText = "🎉 नव वर्ष",
                icon = "✨",
                category = TemplateCategory.FESTIVAL_GREETINGS,
                dateText = "1 जनवरी"
            ),
            UpcomingOccasion(
                title = "गणतंत्र दिवस (26 जनवरी)",
                subtitle = "तिरंगे की शान और संविधान का सम्मान",
                badgeText = "🇮🇳 राष्ट्रीय पर्व",
                icon = "🇮🇳",
                category = TemplateCategory.ELECTION_CAMPAIGN,
                dateText = "26 जनवरी"
            )
        )
    }
}
