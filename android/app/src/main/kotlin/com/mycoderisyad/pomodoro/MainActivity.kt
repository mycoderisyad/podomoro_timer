package com.mycoderisyad.pomodoro

import android.content.ContentUris
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSdkInt" -> result.success(Build.VERSION.SDK_INT)
                "getDeviceAudioTracks" -> result.success(loadDeviceAudioTracks())
                else -> result.notImplemented()
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun loadDeviceAudioTracks(): List<Map<String, Any?>> {
        val tracks = mutableListOf<Map<String, Any?>>()
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.DISPLAY_NAME,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.DATA,
        )
        val selection = "${MediaStore.Audio.Media.IS_MUSIC} != 0"
        val sortOrder = "${MediaStore.Audio.Media.TITLE} COLLATE NOCASE ASC"

        contentResolver.query(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            projection,
            selection,
            null,
            sortOrder,
        )?.use { cursor ->
            val idIndex = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val titleIndex = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
            val displayNameIndex = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DISPLAY_NAME)
            val artistIndex = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
            val albumIndex = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
            val durationIndex = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
            val dataIndex = cursor.getColumnIndex(MediaStore.Audio.Media.DATA)

            while (cursor.moveToNext()) {
                val id = cursor.getLong(idIndex)
                val displayName = cursor.getString(displayNameIndex).orEmpty()
                val titleValue = cursor.getString(titleIndex).orEmpty().ifBlank {
                    displayName.substringBeforeLast('.').ifBlank { displayName }
                }
                val artistValue = cursor.getString(artistIndex).orEmpty()
                val albumValue = cursor.getString(albumIndex).orEmpty()
                val durationMs = cursor.getLong(durationIndex).toInt()
                val filePath = if (dataIndex >= 0) cursor.getString(dataIndex) else null
                val contentUri = ContentUris.withAppendedId(
                    MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                    id,
                ).toString()

                tracks.add(
                    mapOf(
                        "id" to id.toString(),
                        "title" to titleValue,
                        "artist" to artistValue,
                        "album" to albumValue,
                        "durationMs" to durationMs,
                        "filePath" to filePath,
                        "contentUri" to contentUri,
                    ),
                )
            }
        }

        return tracks
    }

    companion object {
        private const val CHANNEL_NAME = "pomodoro_timer/device_audio"
    }
}
