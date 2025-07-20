# Audio Format Support for Azure Speech-to-Text

## Overview
The Azure Speech API script supports multiple audio formats for Speech-to-Text (STT) operations with **automatic conversion to optimal settings** for improved transcription accuracy. The script uses FFmpeg to convert all audio formats to the best possible quality for Azure Speech recognition.

## Automatic Audio Optimization

### Key Features
- **Intelligent Conversion**: Automatically converts audio to optimal settings (16kHz, mono, 16-bit PCM)
- **Format Detection**: Analyzes file extensions and audio properties
- **Quality Enhancement**: Improves recognition accuracy through standardized audio processing
- **Fallback Support**: Uses original files if FFmpeg is unavailable or conversion fails
- **Transparent Logging**: Reports all conversion activities and results

### Conversion Process
1. **File Analysis**: Detects audio format and checks if optimization is needed
2. **FFmpeg Conversion**: Converts to 16kHz, mono, 16-bit PCM WAV if needed
3. **Quality Verification**: Ensures converted audio meets optimal specifications
4. **API Processing**: Uses optimized audio for Azure Speech recognition
5. **Result Enhancement**: Delivers improved transcription accuracy

## Supported Formats (All with Auto-Optimization)

### 1. **WAV** ⭐⭐⭐⭐⭐
- **Extension**: `.wav`
- **Content-Type**: `audio/wav`
- **Description**: Waveform Audio File Format
- **Conversion**: ✅ Only if not already optimal (16kHz, mono, PCM)
- **Recognition Quality**: **Excellent** (native format for Azure Speech)
- **Best for**: Studio recordings, high-quality transcription

### 2. **MP3** ⭐⭐⭐⭐⭐
- **Extension**: `.mp3`
- **Content-Type**: `audio/mpeg`
- **Description**: MPEG Audio Layer 3 compressed audio
- **Conversion**: ✅ Always converted to optimal WAV
- **Recognition Quality**: **Excellent** (after conversion)
- **Best for**: General use, web downloads, music files, podcasts

### 3. **FLAC** ⭐⭐⭐⭐⭐
- **Extension**: `.flac`
- **Content-Type**: `audio/flac`
- **Description**: Free Lossless Audio Codec
- **Conversion**: ✅ Always converted to optimal WAV
- **Recognition Quality**: **Excellent** (after conversion)
- **Best for**: High-quality recordings, audiophile content

### 4. **OGG**
- **Extension**: `.ogg`
### 4. **OGG** ⭐⭐⭐⭐⭐
- **Extension**: `.ogg`
- **Content-Type**: `audio/ogg`
- **Description**: OGG Vorbis compressed audio
- **Conversion**: ✅ Always converted to optimal WAV
- **Recognition Quality**: **Excellent** (after conversion)
- **Best for**: Open-source projects, Linux recordings

### 5. **M4A** ⭐⭐⭐⭐⭐
- **Extension**: `.m4a`
- **Content-Type**: `audio/m4a`
- **Description**: MPEG-4 Audio, commonly from Apple devices
- **Conversion**: ✅ Always converted to optimal WAV
- **Recognition Quality**: **Excellent** (after conversion)
- **Best for**: iPhone recordings, iTunes files, Apple ecosystem

### 6. **OPUS** ⭐⭐⭐⭐⭐
- **Extension**: `.opus`
- **Content-Type**: `audio/opus`
- **Description**: Modern audio codec designed for internet transmission
- **Conversion**: ✅ Always converted to optimal WAV
- **Recognition Quality**: **Excellent** (after conversion)
- **Best for**: Voice calls, web applications, Discord recordings

### 7. **WEBM** ⭐⭐⭐⭐⭐
- **Extension**: `.webm`
- **Content-Type**: `audio/webm`
- **Description**: WebM audio format
- **Conversion**: ✅ Always converted to optimal WAV
- **Recognition Quality**: **Excellent** (after conversion)
- **Best for**: Web recordings, browser-based audio, YouTube audio

## Optimal Audio Settings

### Target Conversion Specifications
All audio formats are automatically converted to these optimal settings:

| Parameter | Value | Reason |
|-----------|-------|--------|
| **Sample Rate** | 16,000 Hz (16 kHz) | Optimal for speech recognition accuracy |
| **Channels** | 1 (Mono) | Human speech is mono; improves processing |
| **Bit Depth** | 16-bit | Perfect balance of quality and efficiency |
| **Encoding** | PCM | Uncompressed for maximum quality |
| **Container** | WAV | Native format for Azure Speech API |

### Benefits of Auto-Conversion
- **🎯 Improved Accuracy**: Consistent optimal format for all audio
- **⚡ Better Performance**: Reduced processing time on Azure servers  
- **🔧 Standardization**: All files processed with same high-quality settings
- **📊 Higher Confidence**: Better confidence scores in transcription results
- **🔄 Format Freedom**: Use any supported format with optimal results

## Technical Requirements

### File Size Limits
- **Maximum file size**: 25 MB (after conversion if applicable)
- **Automatic checking**: Script validates file size before upload
- **Conversion impact**: Most conversions reduce file size due to optimization

### Duration Limits
- **Maximum duration**: 10 minutes for REST API
- **Recommendation**: Break longer recordings into segments
- **Conversion time**: Additional 1-3 seconds for format conversion

### FFmpeg Dependency
- **Installation**: `brew install ffmpeg` (macOS)
- **Purpose**: Enables automatic audio conversion and optimization
- **Fallback**: Uses original files if FFmpeg is not available
- **Version**: Any recent version (tested with FFmpeg 4.0+)

## Conversion Examples

### Automatic Format Detection
```bash
# Script automatically detects format from file extension
./azure_speech_v1.sh stt recording.mp3    # Detected as MP3
./azure_speech_v1.sh stt podcast.flac     # Detected as FLAC
./azure_speech_v1.sh stt voice.m4a        # Detected as M4A
```

```bash
# Example: Converting MP3 to optimal format
./azure_speech_v1.sh stt recording.mp3
# Output: "Converting audio to optimal format for speech recognition..."
# Output: "Audio converted to: recording_converted.wav (16kHz, mono, 16-bit PCM)"

# Example: WAV file already optimal
./azure_speech_v1.sh stt optimal_recording.wav  
# Output: "Audio already in optimal format (16kHz, mono, PCM)"

# Example: Converting FLAC with large file
./azure_speech_v1.sh stt podcast_episode.flac
# Output: "Converting audio to optimal format for speech recognition..."
# Output: "Audio converted to: podcast_episode_converted.wav (16kHz, mono, 16-bit PCM)"
```

## Advanced Features

### Intelligent Format Detection
The script uses multiple methods to determine optimal processing:
1. **File Extension Analysis**: Primary format detection
2. **FFprobe Integration**: Detailed audio stream analysis for WAV files
3. **Quality Assessment**: Determines if conversion will improve recognition
4. **Automatic Optimization**: Converts only when beneficial

### Content-Type Headers
The script automatically sets correct `Content-Type` headers for Azure API:
- `.wav` → `audio/wav`
- `.mp3` → `audio/mpeg` 
- `.flac` → `audio/flac`
- `.ogg` → `audio/ogg`
- `.opus` → `audio/opus`
- `.webm` → `audio/webm`
- `.m4a` → `audio/m4a`

### Error Handling & Fallbacks
- **Unknown formats**: Falls back to `audio/wav` with warning
- **Conversion failures**: Uses original file with notification
- **Missing FFmpeg**: Continues with original format and helpful installation tip
- **File size validation**: Checks 25MB limit before and after conversion
- **Quality verification**: Ensures converted audio meets specifications

## Best Practices for Optimal Results

### Recording Guidelines
1. **Environment**: Record in quiet spaces with minimal echo
2. **Microphone**: Use good quality microphone positioned 6-12 inches from speaker
3. **Speaking**: Clear pronunciation, moderate pace, avoid overlapping speech
4. **Format**: Any supported format (script will optimize automatically)

### File Preparation
- **No preprocessing needed**: Script handles all optimization automatically
- **Any sample rate**: Will be converted to optimal 16kHz
- **Stereo or mono**: Script converts stereo to mono for better accuracy
- **Any bitrate**: Optimized to 16-bit during conversion

### Performance Tips
- **Install FFmpeg**: Essential for automatic optimization (`brew install ffmpeg`)
- **File size**: Keep under 25MB (most conversions reduce size)
- **Duration**: Break files longer than 10 minutes into segments
- **Batch processing**: Use shell loops for multiple files

## Common Use Cases

### 1. **Voice Memos** (iPhone/Android)
- **Typical formats**: M4A, MP3, AAC
- **Auto-conversion**: ✅ Always optimized
- **Quality**: Excellent after conversion

### 2. **Meeting Recordings**
- **Typical formats**: WAV, MP3, M4A
- May need to split if >10 minutes
- Mono recording preferred

### 3. **Podcast Files**
- Usually MP3 or FLAC
- Good compression-to-quality ratio
- Works well with script

### 4. **Phone Call Recordings**
- Often low sample rate (8kHz)
- May be compressed formats
- Script adapts automatically

## Troubleshooting

### Unsupported Format Error
```bash
# If you get format errors, try converting:
ffmpeg -i unsupported.avi -vn -ar 16000 -ac 1 converted.wav
./azure_speech_v1.sh stt converted.wav
```

### File Too Large
```bash
# Split large files:
ffmpeg -i large_file.wav -t 600 -c copy part1.wav
ffmpeg -i large_file.wav -ss 600 -c copy part2.wav
```

### Poor Transcription Quality
1. Check if file is mono (single channel)
2. Verify sample rate is appropriate (16kHz recommended)
3. Reduce background noise if possible
4. Consider converting to WAV format

## Examples

### Multiple Format Test
```bash
# Test different formats
./azure_speech_v1.sh stt recording.wav    # Best quality
./azure_speech_v1.sh stt recording.mp3    # Good compression
./azure_speech_v1.sh stt recording.flac   # Lossless compression
./azure_speech_v1.sh stt recording.m4a    # iPhone format
```

### Batch Processing Different Formats
```bash
# Process multiple format types
for file in *.{wav,mp3,flac,m4a}; do
    if [[ -f "$file" ]]; then
        echo "Processing: $file"
        ./azure_speech_v1.sh stt "$file"
    fi
done
```

The script's automatic format detection and appropriate header setting ensures optimal compatibility with Azure Speech Services across all supported audio formats.
