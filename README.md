# Azure Speech API Script

A comprehensive **zsh script** for working with Azure Cognitive Services Speech API, providing both Text-to-Speech (TTS) and Speech-to-Text (STT) functionality with automatic audio optimization.

## Features

- **Text-to-Speech**: Convert text to natural-sounding speech with customizable voices
- **Speech-to-Text**: Transcribe audio files to text with automatic format optimization
- **Audio Conversion**: Automatic conversion to optimal settings for better speech recognition
- **Multi-Format Support**: WAV, MP3, OGG, FLAC, OPUS, WEBM, M4A audio formats
- **Voice Management**: List and select from 400+ available Azure voices
- **File Organization**: Organized output structure with collision prevention
- **Configuration Management**: Secure storage of Azure credentials
- **Customization**: Adjust speech rate, pitch, and voice selection
- **Error Handling**: Comprehensive error checking and logging
- **Debug Tools**: Built-in diagnostic and troubleshooting capabilities

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

3. **Optional Tools (for audio conversion)**
   ```bash
   # Install FFmpeg for optimal audio conversion
   brew install ffmpeg
   ```

4. **Shell Compatibility**
   - This script is written for **zsh** (default shell on macOS since Catalina)
   - Works on macOS with zsh
   - Includes zsh-specific parameter handling and compatibility fixes

## Setup

1. **Make the script executable** (if not already done):
   ```bash
   chmod +x azure_speech_v1.sh
   ```

2. **Configure Azure credentials**:
   ```bash
   ./azure_speech_v1.sh config
   ```
   
   You'll be prompted to enter:
   - Azure region (e.g., `eastus`, `westus2`)
   - Azure Speech API key

   The configuration is securely stored in `~/.azure_speech_config`.

## Usage

### Basic Commands

```bash
# Show help
./azure_speech_v1.sh help

# Configure Azure credentials
./azure_speech_v1.sh config

# Convert text to speech
./azure_speech_v1.sh tts "Hello, world!"

# Transcribe audio file
./azure_speech_v1.sh stt audio_file.wav

# Transcribe with prompt (will ask for file path)
./azure_speech_v1.sh stt

# List available voices
./azure_speech_v1.sh voices

# Show debug information and file organization
./azure_speech_v1.sh debug
```

### Text-to-Speech Examples

```bash
# Basic text-to-speech
./azure_speech_v1.sh tts "Welcome to Azure Speech Services!"

# Specify voice and output file
./azure_speech_v1.sh tts -t "Hello there!" -v "en-US-AriaNeural" -o greeting.wav

# Adjust speech rate and pitch
./azure_speech_v1.sh tts -t "Fast speech" -r "+50%" -p "+10%" -o fast_speech.wav

# Using different voices
./azure_speech_v1.sh tts -t "This is a male voice" -v "en-US-DavisNeural"
./azure_speech_v1.sh tts -t "This is a female voice" -v "en-US-JennyNeural"
```

### Speech-to-Text Examples

```bash
# Basic speech-to-text (with automatic optimization)
./azure_speech_v1.sh stt audio.wav

# Interactive mode (prompts for file)
./azure_speech_v1.sh stt

# Different audio formats (automatically converted to optimal settings)
./azure_speech_v1.sh stt recording.mp3     # Converts MP3 to optimal WAV
./azure_speech_v1.sh stt podcast.flac      # Converts FLAC to optimal WAV
./azure_speech_v1.sh stt voice_memo.m4a    # Converts M4A to optimal WAV

# Specify language
./azure_speech_v1.sh stt -f audio.wav -l es-ES

# Get JSON output
./azure_speech_v1.sh stt -f audio.wav -j

# Transcribe with different language
./azure_speech_v1.sh stt -f french_audio.wav -l fr-FR
```

## Supported Audio Formats

The script supports all major audio formats with **automatic conversion** to optimal settings for better speech recognition:

| Format | Extension | Auto-Conversion | Original Use | Recognition Quality |
|--------|-----------|----------------|--------------|-------------------|
| **WAV** | `.wav` | ✅ If not optimal | Uncompressed PCM | **Excellent** |
| **MP3** | `.mp3` | ✅ Always | MPEG Audio Layer 3 | **Excellent** (after conversion) |
| **FLAC** | `.flac` | ✅ Always | Free Lossless Audio Codec | **Excellent** (after conversion) |
| **OGG** | `.ogg` | ✅ Always | OGG Vorbis | **Excellent** (after conversion) |
| **M4A** | `.m4a` | ✅ Always | MPEG-4 Audio | **Excellent** (after conversion) |
| **OPUS** | `.opus` | ✅ Always | Opus codec | **Excellent** (after conversion) |
| **WEBM** | `.webm` | ✅ Always | WebM audio | **Excellent** (after conversion) |

### Automatic Audio Optimization

The script automatically converts audio files to optimal settings for speech recognition:

- **Target format**: WAV with 16-bit PCM encoding
- **Sample rate**: 16 kHz (optimal for speech recognition)
- **Channels**: Mono (better accuracy than stereo)
- **Conversion tool**: FFmpeg (install with `brew install ffmpeg`)

**Benefits of automatic conversion:**
- ✅ Improved recognition accuracy
- ✅ Consistent quality across all formats
- ✅ Optimal bandwidth usage
- ✅ Better confidence scores

### Audio Requirements

- **Maximum file size**: 25 MB (after conversion if applicable)
- **Maximum duration**: 10 minutes
- **Automatic optimization**: Files converted to 16 kHz, 16-bit, mono WAV
- **FFmpeg dependency**: Optional but recommended for best results

### Voice Management

```bash
# List all available voices
./azure_speech_v1.sh voices

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

## Output Organization

The script uses an organized file structure with collision prevention:

```
./output/
├── tts/           # Text-to-Speech audio outputs (.wav files)
├── stt/           # Speech-to-Text transcription outputs (.txt and .json files)
└── debug/         # Debug files and raw API responses (.json files)
```

### File Management Features

- **Collision Prevention**: Timestamp-based unique naming prevents file overwrites
- **Session Tracking**: Each STT operation gets a unique session ID
- **Organized Structure**: Separate directories for different output types
- **Dual Formats**: STT outputs saved as both text and JSON
- **Debug Support**: Raw API responses saved for troubleshooting

### File Naming Conventions

- **TTS files**: User-specified names or `speech.wav` (default)
- **STT files**: `transcription_YYYYMMDD_HHMMSS_<audiofile>.{txt,json}`
- **Debug files**: `stt_response_YYYYMMDD_HHMMSS_<audiofile>.json`
- **Converted files**: `<original_name>_converted.wav` (temporary, for processing)

### Audio Conversion Output

When automatic conversion is performed:
- Original files are preserved
- Converted files use `_converted.wav` suffix during processing
- Conversion status is logged for transparency
- Failed conversions fall back to original files

## Error Handling

The script includes comprehensive error handling for:

- **Dependencies**: Missing curl, jq, bc, ffmpeg
- **Configuration**: Invalid Azure credentials or regions
- **Network**: Connectivity issues and API timeouts
- **Audio Files**: Invalid files, unsupported formats, size limits
- **Conversion**: FFmpeg errors and fallback handling
- **API Responses**: Error status codes and recognition failures

## Security

- Azure credentials are stored securely in `~/.azure_speech_config`
- File permissions are set to 600 (owner read/write only)
- API keys are never logged or displayed

## Troubleshooting

### Common Issues

## Troubleshooting

### Common Issues and Solutions

1. **"Missing dependencies" error**
   ```bash
   # Install required dependencies
   brew install jq
   brew install ffmpeg  # Optional but recommended for audio conversion
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
   - Use tab completion or drag & drop for accurate paths
   - Remove surrounding quotes if present

5. **"Audio conversion failed" error**
   - Install FFmpeg: `brew install ffmpeg`
   - Check if the audio file is corrupted
   - Verify sufficient disk space for conversion

6. **"File too large" error**
   - Azure limit is 25MB
   - Use audio compression or split large files
   - Consider using a different audio format

### Debug Mode

Use debug mode to diagnose issues:

```bash
# Show comprehensive system information
./azure_speech_v1.sh debug
```

This will show:
- ✅ Configuration status
- ✅ Dependency versions
- ✅ Azure connectivity tests
- ✅ Output directory status
- ✅ Recent files

### Getting Help

```bash
# Show detailed help
./azure_speech_v1.sh help

# Test and fix configuration
./azure_speech_v1.sh config
```

## Advanced Examples

Here are some practical use cases:

```bash
# Create a welcome message with high-quality voice
./azure_speech_v1.sh tts -t "Welcome to our application!" -v "en-US-AriaNeural" -o welcome.wav

# Transcribe a meeting recording with automatic optimization
./azure_speech_v1.sh stt -f meeting_recording.mp3 -l en-US -j > meeting_transcript.json

# Generate speech with custom prosody
./azure_speech_v1.sh tts -t "This is an important announcement" -r "+25%" -p "+5%" -o announcement.wav

# Multi-language transcription
./azure_speech_v1.sh stt -f french_interview.flac -l fr-FR

# Process multiple audio files
for file in *.mp3; do
    ./azure_speech_v1.sh stt "$file" -l en-US
done

# Interactive workflow
./azure_speech_v1.sh stt  # Will prompt for file selection
```

## Performance Optimization

- **Use 16kHz mono WAV files** for fastest processing
- **Install FFmpeg** for automatic optimization
- **Keep files under 10MB** for best performance
- **Use specific language codes** to improve accuracy

## License

This script is provided as-is for educational and development purposes. Please ensure compliance with Azure's terms of service when using their APIs.

## Support

For Azure Speech Services documentation and support:
- [Azure Speech Services Documentation](https://docs.microsoft.com/en-us/azure/cognitive-services/speech-service/)
- [Azure Speech Services Pricing](https://azure.microsoft.com/en-us/pricing/details/cognitive-services/speech-services/)
