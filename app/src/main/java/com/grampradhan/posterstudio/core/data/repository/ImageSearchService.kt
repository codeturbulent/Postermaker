package com.grampradhan.posterstudio.core.data.repository

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder
import javax.inject.Inject
import javax.inject.Singleton

data class ImageSearchResult(
    val id: String,
    val title: String,
    val thumbnailUrl: String,
    val fullUrl: String,
    val source: String,
    val category: String,
    val isTransparentSticker: Boolean = false
)

@Singleton
class ImageSearchService @Inject constructor() {

    companion object {
        val POPULAR_SUGGESTIONS = listOf(
            "Diwali 🪔",
            "Holi 🎨",
            "Tiranga 🇮🇳",
            "Banner Background 🖼️",
            "Golden Frame ✨",
            "Elections 🗳️",
            "Birthday 🎂",
            "Mandala 🕉️",
            "Flowers 🌺",
            "Glow Effect 🌟"
        )

        val CURATED_REGIONAL_ASSETS = listOf(
            ImageSearchResult(
                id = "curated_diwali_1",
                title = "दीपावली दीया एवं स्वर्ण रोशनी (Diwali Golden Lights)",
                thumbnailUrl = "https://images.unsplash.com/photo-1514565131-fce0801e5785?auto=format&fit=crop&w=400&q=80",
                fullUrl = "https://images.unsplash.com/photo-1514565131-fce0801e5785?auto=format&fit=crop&w=1200&q=85",
                source = "Curated",
                category = "त्यौहार"
            ),
            ImageSearchResult(
                id = "curated_diwali_2",
                title = "पारंपरिक दीया थाली (Traditional Diya Plate)",
                thumbnailUrl = "https://images.unsplash.com/photo-1605629921711-2f6b00c6bbf4?auto=format&fit=crop&w=400&q=80",
                fullUrl = "https://images.unsplash.com/photo-1605629921711-2f6b00c6bbf4?auto=format&fit=crop&w=1200&q=85",
                source = "Curated",
                category = "त्यौहार"
            ),
            ImageSearchResult(
                id = "curated_patriotic_1",
                title = "तिरंगा देशभक्ति पृष्ठभूमि (Tiranga Tri-color Backdrop)",
                thumbnailUrl = "https://images.unsplash.com/photo-1532375810709-75b1da00537c?auto=format&fit=crop&w=400&q=80",
                fullUrl = "https://images.unsplash.com/photo-1532375810709-75b1da00537c?auto=format&fit=crop&w=1200&q=85",
                source = "Curated",
                category = "राष्ट्रीय"
            ),
            ImageSearchResult(
                id = "curated_mandala_1",
                title = "स्वर्ण मंडला कला (Golden Mandala Frame)",
                thumbnailUrl = "https://images.unsplash.com/photo-1579783902614-a3fb3927b675?auto=format&fit=crop&w=400&q=80",
                fullUrl = "https://images.unsplash.com/photo-1579783902614-a3fb3927b675?auto=format&fit=crop&w=1200&q=85",
                source = "Curated",
                category = "डिज़ाइन"
            ),
            ImageSearchResult(
                id = "curated_holi_1",
                title = "गुलाल एवं रंग उत्सव (Vibrant Gulal Colors)",
                thumbnailUrl = "https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=400&q=80",
                fullUrl = "https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=1200&q=85",
                source = "Curated",
                category = "त्यौहार"
            )
        )
    }

    suspend fun searchImages(query: String): List<ImageSearchResult> = withContext(Dispatchers.IO) {
        val cleanQuery = query.trim()
        if (cleanQuery.isBlank()) {
            return@withContext CURATED_REGIONAL_ASSETS
        }

        val filteredCurated = CURATED_REGIONAL_ASSETS.filter {
            it.title.contains(cleanQuery, ignoreCase = true) || it.category.contains(cleanQuery, ignoreCase = true)
        }

        val remoteResults = runCatching { fetchFromWikimedia(cleanQuery) }.getOrDefault(emptyList())

        (filteredCurated + remoteResults).distinctBy { it.fullUrl }
    }

    private fun fetchFromWikimedia(query: String): List<ImageSearchResult> {
        val encoded = URLEncoder.encode(query, "UTF-8")
        val endpoint = "https://commons.wikimedia.org/w/api.php?action=query&generator=search&gsrsearch=$encoded&gsrnamespace=6&gsrlimit=16&prop=imageinfo&iiprop=url|mime|size&iiurlwidth=500&format=json"

        val connection = (URL(endpoint).openConnection() as HttpURLConnection).apply {
            requestMethod = "GET"
            connectTimeout = 8000
            readTimeout = 8000
            setRequestProperty("User-Agent", "GramPradhanPosterStudio/1.0 (Android Native)")
        }

        if (connection.responseCode != HttpURLConnection.HTTP_OK) {
            return emptyList()
        }

        val responseBody = connection.inputStream.bufferedReader().use { it.readText() }
        val root = JSONObject(responseBody)
        val pages = root.optJSONObject("query")?.optJSONObject("pages") ?: return emptyList()

        val results = mutableListOf<ImageSearchResult>()
        val keys = pages.keys()

        while (keys.hasNext()) {
            val key = keys.next()
            val page = pages.getJSONObject(key)
            val title = page.optString("title", "Image").removePrefix("File:").removePrefix("चित्र:")
            val imageInfoArray = page.optJSONArray("imageinfo")
            if (imageInfoArray != null && imageInfoArray.length() > 0) {
                val info = imageInfoArray.getJSONObject(0)
                val thumbUrl = info.optString("thumburl", info.optString("url"))
                val fullUrl = info.optString("url")
                val mime = info.optString("mime", "")

                if (fullUrl.isNotBlank() && (mime.contains("jpeg") || mime.contains("png") || mime.contains("webp"))) {
                    results.add(
                        ImageSearchResult(
                            id = "wiki_${page.optInt("pageid", results.size)}",
                            title = title,
                            thumbnailUrl = thumbUrl,
                            fullUrl = fullUrl,
                            source = "Wikimedia Commons",
                            category = "पब्लिक डोमेन",
                            isTransparentSticker = mime.contains("png")
                        )
                    )
                }
            }
        }
        return results
    }
}
