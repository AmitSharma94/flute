package com.amitsharma.flutercv1

import android.media.audiofx.Equalizer
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private val channelName = "com.amitsharma.flute/equalizer"
    private var equalizer: Equalizer? = null
    private var currentSessionId: Int? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "attach" -> attach(call, result)
                    "getState" -> result.success(stateMap())
                    "setEnabled" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        equalizer?.enabled = enabled
                        result.success(stateMap())
                    }
                    "setBandLevel" -> {
                        val band = call.argument<Int>("band") ?: 0
                        val level = call.argument<Int>("level") ?: 0
                        equalizer?.setBandLevel(band.toShort(), level.toShort())
                        result.success(stateMap())
                    }
                    "usePreset" -> {
                        val preset = call.argument<Int>("preset") ?: 0
                        equalizer?.usePreset(preset.toShort())
                        result.success(stateMap())
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
    }

    private fun attach(call: MethodCall, result: MethodChannel.Result) {
        val sessionId = call.argument<Int>("audioSessionId") ?: 0
        if (sessionId <= 0) {
            result.success(unsupportedState())
            return
        }
        if (currentSessionId != sessionId || equalizer == null) {
            releaseEqualizer()
            equalizer = Equalizer(0, sessionId).apply { enabled = false }
            currentSessionId = sessionId
        }
        result.success(stateMap())
    }

    private fun stateMap(): Map<String, Any> {
        val effect = equalizer ?: return unsupportedState()
        val range = effect.bandLevelRange
        val bands = (0 until effect.numberOfBands.toInt()).map { index ->
            mapOf(
                "index" to index,
                "centerFrequencyHz" to (effect.getCenterFreq(index.toShort()) / 1000),
                "level" to effect.getBandLevel(index.toShort()).toInt(),
            )
        }
        val presets = (0 until effect.numberOfPresets.toInt()).map { index ->
            effect.getPresetName(index.toShort())
        }
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

    private fun unsupportedState(): Map<String, Any> = mapOf(
        "supported" to false,
        "enabled" to false,
        "minLevel" to -1500,
        "maxLevel" to 1500,
        "bands" to emptyList<Map<String, Any>>(),
        "presets" to emptyList<String>(),
        "currentPreset" to -1,
    )

    private fun releaseEqualizer() {
        equalizer?.release()
        equalizer = null
        currentSessionId = null
    }

    override fun onDestroy() {
        releaseEqualizer()
        super.onDestroy()
    }
}
