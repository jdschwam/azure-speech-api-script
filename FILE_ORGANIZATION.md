# File Organization and Collision Prevention

## Overview
The Azure Speech API script now implements a comprehensive file organization system to prevent input/output file collisions and maintain clean workspace structure.

## Directory Structure

```
./output/
├── tts/           # Text-to-Speech audio outputs
├── stt/           # Speech-to-Text transcription outputs  
└── debug/         # Debug files and raw API responses
```

## File Naming Conventions

### TTS (Text-to-Speech)
- **Location**: `./output/tts/`
- **Default filename**: `speech.wav`
- **Custom filename**: User-specified via `-o` parameter
- **Format**: Any valid filename ending in `.wav`

### STT (Speech-to-Text)
- **Location**: `./output/stt/`
- **Naming pattern**: `transcription_YYYYMMDD_HHMMSS_<audio_basename>.*`
- **Files created**:
  - `.txt` - Plain text transcription
  - `.json` - Full JSON response with confidence scores
- **Examples**:
  - `transcription_20250719_162029_collision_test.txt`
  - `transcription_20250719_162029_collision_test.json`

### Debug Files
- **Location**: `./output/debug/`
- **Naming pattern**: `stt_response_YYYYMMDD_HHMMSS_<audio_basename>.json`
- **Content**: Raw API responses for troubleshooting
- **Example**: `stt_response_20250719_162029_collision_test.json`

## Collision Prevention Features

### 1. Unique Timestamps
- All STT outputs include timestamp: `YYYYMMDD_HHMMSS`
- Ensures files from different sessions don't overwrite each other

### 2. Session Identification
- Session ID format: `{timestamp}_{audio_basename}`
- Links all files from the same STT operation
- Example: `20250719_162029_collision_test`

### 3. Separate Directories
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
