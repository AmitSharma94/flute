package com.amitsharma.flutercv1

import android.content.ContentValues
import android.content.Intent
import android.media.RingtoneManager
import android.media.audiofx.Equalizer
import android.media.audiofx.LoudnessEnhancer
import android.media.audiofx.Virtualizer
import android.media.audiofx.Visualizer
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.provider.Settings
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : AudioServiceActivity() {
    private val equalizerChannelName = "com.amitsharma.flute/equalizer"
    private val effectsChannelName = "com.amitsharma.flute/audio_effects"
    private val ringtoneChannelName = "com.amitsharma.flute/ringtone"

    private var equalizer: Equalizer? = null
    private var loudnessEnhancer: LoudnessEnhancer? = null
    private var virtualizer: Virtualizer? = null
    private var visualizer: Visualizer? = null
    private var currentSessionId: Int? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        MethodChannel(messenger, equalizerChannelName).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "attach" -> attachEqualizer(call, result)
                    "getState" -> result.success(equalizerStateMap())
                    "setEnabled" -> {
                        equalizer?.enabled = call.argument<Boolean>("enabled") ?: false
                        result.success(equalizerStateMap())
                    }
                    "setBandLevel" -> {
                        val band = call.argument<Int>("band") ?: 0
                        val level = call.argument<Int>("level") ?: 0
                        equalizer?.setBandLevel(band.toShort(), level.toShort())
                        result.success(equalizerStateMap())
                    }
                    "usePreset" -> {
                        equalizer?.usePreset((call.argument<Int>("preset") ?: 0).toShort())
                        result.success(equalizerStateMap())
                    }
                    "release" -> {
                        releaseEqualizer()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (error: Throwable) {
                result.error("equalizer_error", error.message, null)
            }
        }

        MethodChannel(messenger, effectsChannelName).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "attach" -> {
                        val sessionId = call.argument<Int>("audioSessionId") ?: 0
                        result.success(attachEffects(sessionId))
                    }
                    "getState" -> result.success(effectsStateMap())
                    "setLoudness" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        val gainMb = (call.argument<Int>("gainMb") ?: 0).coerceIn(0, 600)
                        loudnessEnhancer?.setTargetGain(gainMb)
                        loudnessEnhancer?.enabled = enabled
                        result.success(effectsStateMap())
                    }
                    "setSpatial" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        val strength = (call.argument<Int>("strength") ?: 0).coerceIn(0, 1000)
                        virtualizer?.setStrength(strength.toShort())
                        virtualizer?.enabled = enabled
                        result.success(effectsStateMap())
                    }
                    "startVisualizer" -> {
                        result.success(startVisualizer())
                    }
                    "getVisualizerFrame" -> result.success(getVisualizerFrame())
                    "stopVisualizer" -> {
                        releaseVisualizer()
                        result.success(null)
                    }
                    "release" -> {
                        releaseExtraEffects()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (error: Throwable) {
                result.error("audio_effect_error", error.message, null)
            }
        }

        MethodChannel(messenger, ringtoneChannelName).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "canWriteSettings" -> result.success(Settings.System.canWrite(this))
                    "requestWriteSettings" -> {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_WRITE_SETTINGS,
                            Uri.parse("package:$packageName"),
                        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(null)
                    }
                    "setRingtone" -> setRingtone(call, result)
                    else -> result.notImplemented()
                }
            } catch (error: Throwable) {
                result.error("ringtone_error", error.message, null)
            }
        }
    }

    private fun attachEqualizer(call: MethodCall, result: MethodChannel.Result) {
        val sessionId = call.argument<Int>("audioSessionId") ?: 0
        if (sessionId <= 0) {
            result.success(unsupportedEqualizerState())
            return
        }
        ensureSession(sessionId)
        if (equalizer == null) equalizer = Equalizer(0, sessionId).apply { enabled = false }
        result.success(equalizerStateMap())
    }

    private fun ensureSession(sessionId: Int) {
        if (currentSessionId == sessionId) return
        releaseAllEffects()
        currentSessionId = sessionId
    }

    private fun attachEffects(sessionId: Int): Map<String, Any> {
        if (sessionId <= 0) return unsupportedEffectsState()
        ensureSession(sessionId)
        if (loudnessEnhancer == null) {
            loudnessEnhancer = runCatching { LoudnessEnhancer(sessionId).apply { enabled = false } }.getOrNull()
        }
        if (virtualizer == null) {
            @Suppress("DEPRECATION")
            virtualizer = runCatching { Virtualizer(0, sessionId).apply { enabled = false } }.getOrNull()
        }
        return effectsStateMap()
    }

    private fun startVisualizer(): Boolean {
        val sessionId = currentSessionId ?: return false
        if (visualizer != null) return true
        return runCatching {
            val effect = Visualizer(sessionId)
            val range = Visualizer.getCaptureSizeRange()
            effect.captureSize = minOf(512, range[1]).coerceAtLeast(range[0])
            effect.scalingMode = Visualizer.SCALING_MODE_NORMALIZED
            effect.enabled = true
            visualizer = effect
            true
        }.getOrDefault(false)
    }

    private fun getVisualizerFrame(): Map<String, Any> {
        val effect = visualizer ?: return mapOf("available" to false, "waveform" to emptyList<Int>())
        val waveform = ByteArray(effect.captureSize)
        val status = effect.getWaveForm(waveform)
        if (status != Visualizer.SUCCESS) {
            return mapOf("available" to false, "waveform" to emptyList<Int>())
        }
        return mapOf(
            "available" to true,
            "waveform" to waveform.map { it.toInt() and 0xFF },
        )
    }

    private fun effectsStateMap(): Map<String, Any> = mapOf(
        "supported" to (loudnessEnhancer != null || virtualizer != null),
        "loudnessSupported" to (loudnessEnhancer != null),
        "loudnessEnabled" to (loudnessEnhancer?.enabled ?: false),
        "loudnessGainMb" to (loudnessEnhancer?.targetGain ?: 0),
        "spatialSupported" to (virtualizer != null && (virtualizer?.strengthSupported ?: false)),
        "spatialEnabled" to (virtualizer?.enabled ?: false),
        "spatialStrength" to (virtualizer?.roundedStrength?.toInt() ?: 0),
    )

    private fun unsupportedEffectsState(): Map<String, Any> = mapOf(
        "supported" to false,
        "loudnessSupported" to false,
        "loudnessEnabled" to false,
        "loudnessGainMb" to 0,
        "spatialSupported" to false,
        "spatialEnabled" to false,
        "spatialStrength" to 0,
    )

    private fun equalizerStateMap(): Map<String, Any> {
        val effect = equalizer ?: return unsupportedEqualizerState()
        val range = effect.bandLevelRange
        val bands = (0 until effect.numberOfBands.toInt()).map { index ->
            mapOf(
                "index" to index,
                "centerFrequencyHz" to (effect.getCenterFreq(index.toShort()) / 1000),
                "level" to effect.getBandLevel(index.toShort()).toInt(),
            )
        }
        val presets = (0 until effect.numberOfPresets.toInt()).map { index -> effect.getPresetName(index.toShort()) }
        return mapOf(
            "supported" to true,
            "enabled" to effect.enabled,
            "minLevel" to range[0].toInt(),
            "maxLevel" to range[1].toInt(),
            "bands" to bands,
            "presets" to presets,
            "currentPreset" to effect.currentPreset.toInt(),
        )
    }

    private fun unsupportedEqualizerState(): Map<String, Any> = mapOf(
        "supported" to false,
        "enabled" to false,
        "minLevel" to -1500,
        "maxLevel" to 1500,
        "bands" to emptyList<Map<String, Any>>(),
        "presets" to emptyList<String>(),
        "currentPreset" to -1,
    )

    private fun setRingtone(call: MethodCall, result: MethodChannel.Result) {
        if (!Settings.System.canWrite(this)) {
            result.success(mapOf("success" to false, "needsPermission" to true))
            return
        }
        val path = call.argument<String>("path")?.trim().orEmpty()
        val title = call.argument<String>("title")?.trim().orEmpty().ifEmpty { "Flute ringtone" }
        val typeName = call.argument<String>("type") ?: "ringtone"
        val source = File(path)
        if (!source.exists()) {
            result.error("missing_file", "The selected audio file no longer exists.", null)
            return
        }

        val ringtoneType = when (typeName) {
            "notification" -> RingtoneManager.TYPE_NOTIFICATION
            "alarm" -> RingtoneManager.TYPE_ALARM
            else -> RingtoneManager.TYPE_RINGTONE
        }
        val values = ContentValues().apply {
            put(MediaStore.Audio.Media.DISPLAY_NAME, source.name)
            put(MediaStore.Audio.Media.TITLE, title)
            put(MediaStore.Audio.Media.MIME_TYPE, guessMimeType(source.extension))
            put(MediaStore.Audio.Media.IS_MUSIC, false)
            put(MediaStore.Audio.Media.IS_RINGTONE, ringtoneType == RingtoneManager.TYPE_RINGTONE)
            put(MediaStore.Audio.Media.IS_NOTIFICATION, ringtoneType == RingtoneManager.TYPE_NOTIFICATION)
            put(MediaStore.Audio.Media.IS_ALARM, ringtoneType == RingtoneManager.TYPE_ALARM)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.Audio.Media.RELATIVE_PATH, "Ringtones/Flute")
                put(MediaStore.Audio.Media.IS_PENDING, 1)
            }
        }
        val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        } else {
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        }
        val uri = contentResolver.insert(collection, values)
            ?: throw IllegalStateException("Could not create ringtone entry.")
        contentResolver.openOutputStream(uri)?.use { output -> source.inputStream().use { it.copyTo(output) } }
            ?: throw IllegalStateException("Could not write ringtone file.")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            values.clear()
            values.put(MediaStore.Audio.Media.IS_PENDING, 0)
            contentResolver.update(uri, values, null, null)
        }
        RingtoneManager.setActualDefaultRingtoneUri(this, ringtoneType, uri)
        result.success(mapOf("success" to true, "needsPermission" to false, "uri" to uri.toString()))
    }

    private fun guessMimeType(extension: String): String = when (extension.lowercase()) {
        "flac" -> "audio/flac"
        "wav" -> "audio/wav"
        "ogg", "oga" -> "audio/ogg"
        "m4a", "mp4" -> "audio/mp4"
        else -> "audio/mpeg"
    }

    private fun releaseEqualizer() {
        equalizer?.release()
        equalizer = null
    }

    private fun releaseVisualizer() {
        visualizer?.runCatching { enabled = false }
        visualizer?.release()
        visualizer = null
    }

    private fun releaseExtraEffects() {
        releaseVisualizer()
        loudnessEnhancer?.release()
        loudnessEnhancer = null
        virtualizer?.release()
        virtualizer = null
    }

    private fun releaseAllEffects() {
        releaseEqualizer()
        releaseExtraEffects()
        currentSessionId = null
    }

    override fun onDestroy() {
        releaseAllEffects()
        super.onDestroy()
    }
}
