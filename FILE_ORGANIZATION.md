# File Organization and Collision Prevention

## Overview
The Azure Speech API script implements a comprehensive file organization system with collision prevention, automatic audio conversion management, and clean workspace structure. All operations maintain traceability while preventing file overwrites.

## Directory Structure

```
./output/
├── tts/           # Text-to-Speech audio outputs (.wav files)
├── stt/           # Speech-to-Text transcription outputs (.txt and .json)
└── debug/         # Debug files and raw API responses (.json)
```

## File Management Features

### Collision Prevention
- **Timestamp-based naming**: Unique session IDs prevent overwrites
- **Separate directories**: Organized by operation type
- **Dual format outputs**: Both text and JSON for STT results
- **Debug preservation**: Raw API responses saved for troubleshooting

### Audio Conversion Handling
- **Temporary files**: Managed automatically during conversion
- **Original preservation**: Source files remain untouched
- **Conversion tracking**: Clear logging of optimization steps
- **Cleanup management**: Automatic temporary file removal

## File Naming Conventions

### TTS (Text-to-Speech)
- **Location**: `./output/tts/`
- **Default filename**: `speech.wav`
- **Custom filename**: User-specified via `-o` parameter
- **Format**: WAV files with 24kHz, 16-bit, mono PCM
- **Examples**:
  - `speech.wav` (default)
  - `welcome.wav` (custom)
  - `aria_test.wav` (custom with voice name)

### STT (Speech-to-Text)
- **Location**: `./output/stt/`
- **Naming pattern**: `transcription_YYYYMMDD_HHMMSS_<audio_basename>.*`
- **Files created**:
  - `.txt` - Plain text transcription
  - `.json` - Full JSON response with confidence scores and metadata
- **Examples**:
  - `transcription_20250719_162029_test.txt`
  - `transcription_20250719_162029_test.json`
  - `transcription_20250719_163045_meeting_recording.txt`

### Debug Files
- **Location**: `./output/debug/`
- **Naming pattern**: `stt_response_YYYYMMDD_HHMMSS_<audio_basename>.json`
- **Content**: Raw API responses for troubleshooting and analysis
- **Examples**:
  - `stt_response_20250719_162029_test.json`
  - `stt_response_20250719_163045_meeting_recording.json`

### Audio Conversion Files
- **Temporary files**: Created during conversion, automatically cleaned up
- **Naming pattern**: `<original_name>_converted.wav`
- **Location**: Same directory as source file (temporary)
- **Management**: Automatically removed after successful processing
- **Examples**:
  - `recording.mp3` → `recording_converted.wav` (temporary)
  - `podcast.flac` → `podcast_converted.wav` (temporary)

## Collision Prevention Features

### 1. Unique Timestamps
- All STT outputs include precise timestamp: `YYYYMMDD_HHMMSS`
- Prevents overwrites from multiple sessions
- Enables chronological organization

### 2. Session Identification
- Session ID format: `{timestamp}_{audio_basename}`
- Links all related files from the same operation
- Enables easy file correlation and debugging

### 3. Organized Directory Structure
- TTS, STT, and debug files are completely isolated
- No risk of audio files overwriting transcription files
- Clear organization for file management

### 4. Audio File Basename Inclusion
- STT output files include source audio filename
- Easy to trace which audio file produced which transcription
- Prevents confusion when processing multiple audio files

## File Examples

### TTS Operation
```bash
./azure_speech_v1.sh tts -t "Hello world" -o greeting.wav
# Creates: ./output/tts/greeting.wav
```

### STT Operation
```bash
./azure_speech_v1.sh stt -f ./output/tts/greeting.wav
# Creates:
# - ./output/stt/transcription_20250719_162500_greeting.txt
# - ./output/stt/transcription_20250719_162500_greeting.json
# - ./output/debug/stt_response_20250719_162500_greeting.json
```

### Round-trip Test
```bash
# Step 1: Create audio
./azure_speech_v1.sh tts -t "Testing round trip functionality" -o roundtrip.wav
# Output: ./output/tts/roundtrip.wav

# Step 2: Transcribe audio  
./azure_speech_v1.sh stt -f ./output/tts/roundtrip.wav
# Outputs:
# - ./output/stt/transcription_20250719_162600_roundtrip.txt
# - ./output/stt/transcription_20250719_162600_roundtrip.json
# - ./output/debug/stt_response_20250719_162600_roundtrip.json
```

## Cleanup and Maintenance

### Current File Count Check
```bash
./azure_speech_v1.sh debug
# Shows file counts for each directory
```

### Manual Cleanup
```bash
# Clean TTS files older than 7 days
find ./output/tts -name "*.wav" -mtime +7 -delete

# Clean STT files older than 30 days
find ./output/stt -name "transcription_*" -mtime +30 -delete

# Clean debug files older than 7 days
find ./output/debug -name "stt_response_*" -mtime +7 -delete
```

## Migration from Old Structure

Existing files were automatically moved during the upgrade:
- `./output/*.wav` → `./output/tts/`
- `./transcription_*.txt` → `./output/stt/`
- `./stt_debug_response.json` → `./output/debug/`

## Benefits

1. **No Collisions**: Different file types can't overwrite each other
2. **Traceability**: Easy to connect audio files with their transcriptions
3. **Organization**: Clean separation of inputs, outputs, and debug data
4. **Scalability**: System handles multiple concurrent operations
5. **Debugging**: All API responses preserved for troubleshooting
6. **Maintenance**: Clear structure for cleanup and archiving

## Error Prevention

The system prevents these common issues:
- Transcription files overwriting audio files
- Debug files cluttering the main directory
- Lost connection between audio files and their transcriptions
- Accidental overwriting of previous transcriptions
- Confusion about which files belong together
