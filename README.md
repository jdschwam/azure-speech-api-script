# Azure Speech API Script

A comprehensive zsh script for working with Azure Cognitive Services Speech API, providing both Text-to-Speech (TTS) and Speech-to-Text (STT) functionality.

## Features

- **Text-to-Speech**: Convert text to natural-sounding speech
- **Speech-to-Text**: Transcribe audio files to text
- **Voice Management**: List and select from available voices
- **Configuration Management**: Secure storage of Azure credentials
- **Customization**: Adjust speech rate, pitch, and voice selection
- **Multiple Output Formats**: Support for various audio formats
- **Error Handling**: Comprehensive error checking and logging

## Prerequisites

1. **Azure Speech Services Subscription**
   - Create an Azure account at [portal.azure.com](https://portal.azure.com)
   - Create a Speech Services resource
   - Note your subscription key and region

2. **Required Tools**
   ```bash
   # Install jq for JSON parsing (if not already installed)
   brew install jq
   
   # curl is usually pre-installed on macOS
   ```

## Setup

1. **Make the script executable** (if not already done):
   ```bash
   chmod +x azure_speech.sh
   ```

2. **Configure Azure credentials**:
   ```bash
   ./azure_speech.sh config
   ```
   
   You'll be prompted to enter:
   - Azure region (e.g., `eastus`, `westus2`)
   - Azure Speech API key

   The configuration is securely stored in `~/.azure_speech_config`.

## Usage

### Basic Commands

```bash
# Show help
./azure_speech.sh help

# Configure Azure credentials
./azure_speech.sh config

# Convert text to speech
./azure_speech.sh tts "Hello, world!"

# Transcribe audio file
./azure_speech.sh stt audio_file.wav

# List available voices
./azure_speech.sh voices
```

### Text-to-Speech Examples

```bash
# Basic text-to-speech
./azure_speech.sh tts "Welcome to Azure Speech Services!"

# Specify voice and output file
./azure_speech.sh tts -t "Hello there!" -v "en-US-AriaNeural" -o greeting.wav

# Adjust speech rate and pitch
./azure_speech.sh tts -t "Fast speech" -r "+50%" -p "+10%" -o fast_speech.wav

# Using different voices
./azure_speech.sh tts -t "This is a male voice" -v "en-US-DavisNeural"
./azure_speech.sh tts -t "This is a female voice" -v "en-US-JennyNeural"
```

### Speech-to-Text Examples

```bash
# Basic speech-to-text
./azure_speech.sh stt audio.wav

# Specify language
./azure_speech.sh stt -f audio.wav -l es-ES

# Get JSON output
./azure_speech.sh stt -f audio.wav -j

# Transcribe with different language
./azure_speech.sh stt -f french_audio.wav -l fr-FR
```

### Voice Management

```bash
# List all available voices
./azure_speech.sh voices

# Common voice options:
# - en-US-JennyNeural (Female, US English)
# - en-US-GuyNeural (Male, US English)
# - en-US-AriaNeural (Female, US English)
# - en-US-DavisNeural (Male, US English)
# - en-GB-SoniaNeural (Female, British English)
# - en-GB-RyanNeural (Male, British English)
```

## Command Line Options

### Text-to-Speech Options

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--text` | `-t` | Text to convert to speech | (prompted) |
| `--voice` | `-v` | Voice to use | `en-US-JennyNeural` |
| `--output` | `-o` | Output audio file | `speech.wav` |
| `--rate` | `-r` | Speech rate (-50% to +200%) | `+0%` |
| `--pitch` | `-p` | Speech pitch (-50% to +50%) | `+0%` |

### Speech-to-Text Options

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--file` | `-f` | Audio file to transcribe | (required) |
| `--language` | `-l` | Language code | `en-US` |
| `--json` | `-j` | Output result as JSON | false |

## Supported Languages

The script supports all languages available in Azure Speech Services, including:

- `en-US` - English (United States)
- `en-GB` - English (United Kingdom)
- `es-ES` - Spanish (Spain)
- `fr-FR` - French (France)
- `de-DE` - German (Germany)
- `it-IT` - Italian (Italy)
- `pt-BR` - Portuguese (Brazil)
- `ja-JP` - Japanese (Japan)
- `ko-KR` - Korean (South Korea)
- `zh-CN` - Chinese (Mandarin, Simplified)

## Output

- **Audio files** are saved to the `./output/` directory
- **Transcription results** are displayed in the terminal
- **Logs** include timestamps and colored output for better readability

## Error Handling

The script includes comprehensive error handling for:

- Missing dependencies
- Invalid Azure credentials
- Network connectivity issues
- Invalid audio files
- Unsupported languages or voices

## Security

- Azure credentials are stored securely in `~/.azure_speech_config`
- File permissions are set to 600 (owner read/write only)
- API keys are never logged or displayed

## Troubleshooting

### Common Issues

1. **"Missing dependencies" error**
   ```bash
   brew install jq
   ```

2. **"Configuration test failed" error**
   - Verify your Azure region and API key
   - Check your internet connection
   - Ensure your Azure Speech Services resource is active

3. **"Speech synthesis failed" error**
   - Check if the voice name is correct
   - Verify the text content is valid
   - Ensure output directory is writable

4. **"Audio file not found" error**
   - Verify the audio file path
   - Ensure the file format is supported (WAV recommended)

### Getting Help

```bash
# Show detailed help
./azure_speech.sh help

# Test configuration
./azure_speech.sh config
```

## Examples Directory

Here are some practical examples:

```bash
# Create a welcome message
./azure_speech.sh tts -t "Welcome to our application!" -v "en-US-AriaNeural" -o welcome.wav

# Transcribe a meeting recording
./azure_speech.sh stt -f meeting_recording.wav -l en-US -j > meeting_transcript.json

# Generate speech with custom prosody
./azure_speech.sh tts -t "This is an important announcement" -r "+25%" -p "+5%" -o announcement.wav

# Multi-language example
./azure_speech.sh tts -t "Bonjour le monde" -v "fr-FR-DeniseNeural" -o french_greeting.wav
```

## License

This script is provided as-is for educational and development purposes. Please ensure compliance with Azure's terms of service when using their APIs.

## Support

For Azure Speech Services documentation and support:
- [Azure Speech Services Documentation](https://docs.microsoft.com/en-us/azure/cognitive-services/speech-service/)
- [Azure Speech Services Pricing](https://azure.microsoft.com/en-us/pricing/details/cognitive-services/speech-services/)
