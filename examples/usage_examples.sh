#!/bin/zsh

# Example usage scripts for Azure Speech API

echo "🎤 Azure Speech API Examples"
echo "=============================="

SCRIPT_PATH="../azure_speech_v1.sh"

# Check if the main script exists
if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo "❌ Error: azure_speech_v1.sh not found at $SCRIPT_PATH"
    exit 1
fi

echo ""
echo "1. 📝 Text-to-Speech Examples"
echo "----------------------------"

echo "• Basic TTS:"
echo "  $SCRIPT_PATH tts \"Hello, this is a test of Azure Speech Services!\""

echo ""
echo "• Custom voice and output:"
echo "  $SCRIPT_PATH tts -t \"Welcome to our application\" -v \"en-US-AriaNeural\" -o welcome.wav"

echo ""
echo "• Adjust speech rate and pitch:"
echo "  $SCRIPT_PATH tts -t \"This is fast speech\" -r \"+50%\" -p \"+10%\" -o fast_speech.wav"

echo ""
echo "• Different languages:"
echo "  $SCRIPT_PATH tts -t \"Bonjour le monde\" -v \"fr-FR-DeniseNeural\" -o french.wav"
echo "  $SCRIPT_PATH tts -t \"Hola mundo\" -v \"es-ES-ElviraNeural\" -o spanish.wav"

echo ""
echo "2. 🎙️  Speech-to-Text Examples (with Auto-Optimization)"
echo "-------------------------------------------------------"

echo "• Basic STT with automatic conversion:"
echo "  $SCRIPT_PATH stt audio_file.wav"

echo ""
echo "• Interactive mode (prompts for file):"
echo "  $SCRIPT_PATH stt"

echo ""
echo "• Multi-format support with automatic optimization:"
echo "  $SCRIPT_PATH stt -f recording.mp3      # MP3 → optimized WAV"
echo "  $SCRIPT_PATH stt -f podcast.flac       # FLAC → optimized WAV"
echo "  $SCRIPT_PATH stt -f voice_memo.m4a     # M4A → optimized WAV"
echo "  $SCRIPT_PATH stt -f interview.ogg      # OGG → optimized WAV"
echo "  $SCRIPT_PATH stt -f voice_memo.m4a"

echo ""
echo "• With language specification:"
echo "  $SCRIPT_PATH stt -f audio_file.wav -l en-US"

echo ""
echo ""
echo "• Different languages with auto-optimization:"
echo "  $SCRIPT_PATH stt -f spanish_audio.mp3 -l es-ES"
echo "  $SCRIPT_PATH stt -f french_audio.flac -l fr-FR"

echo ""
echo "• JSON output for processing:"
echo "  $SCRIPT_PATH stt -f audio_file.wav -j > transcript.json"

echo ""
echo "📄 Audio Format Support with Auto-Optimization:"
echo "  • WAV - ✅ Optimized if needed (16kHz, mono, PCM)"
echo "  • MP3 - ✅ Always converted to optimal WAV"
echo "  • FLAC - ✅ Always converted to optimal WAV"
echo "  • OGG - ✅ Always converted to optimal WAV"
echo "  • M4A - ✅ Always converted to optimal WAV"
echo "  • OPUS - ✅ Always converted to optimal WAV"
echo "  • WEBM - ✅ Always converted to optimal WAV"
echo ""
echo "🎯 Optimization Benefits:"
echo "  • Improved recognition accuracy"
echo "  • Higher confidence scores"
echo "  • Consistent quality across all formats"
echo "  • Optimal bandwidth usage"
echo ""
echo "📏 Audio Requirements:"
echo "  • Max file size: 25MB (after conversion if applicable)"
echo "  • Max duration: 10 minutes"
echo "  • Auto-converted to: 16kHz, 16-bit, mono WAV"
echo "  • FFmpeg recommended: brew install ffmpeg"

echo ""
echo "3. 🗣️  Voice Management"
echo "----------------------"

echo "• List all available voices (400+):"
echo "  $SCRIPT_PATH voices"

echo ""
echo "4. ⚙️  Configuration & Debug"
echo "---------------------------"

echo "• Set up Azure credentials:"
echo "  $SCRIPT_PATH config"

echo ""
echo "• Debug system information:"
echo "  $SCRIPT_PATH debug"

echo ""
echo "5. 🔄 Batch Processing Examples"
echo "------------------------------"
echo "• Process multiple audio files:"
echo "  for file in *.mp3; do $SCRIPT_PATH stt \"\$file\"; done"

echo ""
echo "• Convert and transcribe with specific language:"
echo "  for file in spanish_recordings/*.m4a; do"
echo "    $SCRIPT_PATH stt \"\$file\" -l es-ES"
echo "  done"

echo ""
echo "6. 📚 Common Voice Options"
echo "-------------------------"
echo "English (US) - Neural Voices:"
echo "  - en-US-JennyNeural (Female, friendly)"
echo "  - en-US-GuyNeural (Male, warm)"
echo "  - en-US-AriaNeural (Female, cheerful)"
echo "  - en-US-DavisNeural (Male, professional)"

echo ""
echo "English (UK) - Neural Voices:"
echo "  - en-GB-SoniaNeural (Female, British)"
echo "  - en-GB-RyanNeural (Male, British)"

echo ""
echo "Other Languages - Neural Voices:"
echo "  - fr-FR-DeniseNeural (French Female)"
echo "  - es-ES-ElviraNeural (Spanish Female)"
echo "  - de-DE-KatjaNeural (German Female)"
echo "  - it-IT-ElsaNeural (Italian Female)"

echo ""
echo "💡 Pro Tips:"
echo "  • Install FFmpeg for best STT results: brew install ffmpeg"
echo "  • Use debug mode to check system status: $SCRIPT_PATH debug"
echo "  • All audio formats automatically optimized for best accuracy"
echo "  • Files organized in output/ directory with collision prevention"

echo ""
echo "Run any of the above commands to test the functionality!"
echo "Make sure to configure your Azure credentials first with: $SCRIPT_PATH config"
