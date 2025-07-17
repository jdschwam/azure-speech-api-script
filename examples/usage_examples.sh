#!/bin/zsh

# Example usage scripts for Azure Speech API

echo "🎤 Azure Speech API Examples"
echo "=============================="

SCRIPT_PATH="../azure_speech.sh"

# Check if the main script exists
if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo "❌ Error: azure_speech.sh not found at $SCRIPT_PATH"
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
echo "2. 🎙️  Speech-to-Text Examples"
echo "-----------------------------"

echo "• Basic STT (you'll need an audio file):"
echo "  $SCRIPT_PATH stt audio_file.wav"

echo ""
echo "• With language specification:"
echo "  $SCRIPT_PATH stt -f audio_file.wav -l en-US"

echo ""
echo "• JSON output for processing:"
echo "  $SCRIPT_PATH stt -f audio_file.wav -j > transcript.json"

echo ""
echo "3. 🗣️  Voice Management"
echo "----------------------"

echo "• List all available voices:"
echo "  $SCRIPT_PATH voices"

echo ""
echo "4. ⚙️  Configuration"
echo "-------------------"

echo "• Set up Azure credentials:"
echo "  $SCRIPT_PATH config"

echo ""
echo "5. 📚 Common Voice Options"
echo "-------------------------"
echo "English (US):"
echo "  - en-US-JennyNeural (Female, friendly)"
echo "  - en-US-GuyNeural (Male, warm)"
echo "  - en-US-AriaNeural (Female, cheerful)"
echo "  - en-US-DavisNeural (Male, professional)"

echo ""
echo "English (UK):"
echo "  - en-GB-SoniaNeural (Female, British)"
echo "  - en-GB-RyanNeural (Male, British)"

echo ""
echo "Other Languages:"
echo "  - fr-FR-DeniseNeural (French Female)"
echo "  - es-ES-ElviraNeural (Spanish Female)"
echo "  - de-DE-KatjaNeural (German Female)"
echo "  - it-IT-ElsaNeural (Italian Female)"

echo ""
echo "Run any of the above commands to test the functionality!"
echo "Make sure to configure your Azure credentials first with: $SCRIPT_PATH config"
