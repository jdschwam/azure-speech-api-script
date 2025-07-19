#!/bin/zsh

# Azure Speech API Script
# This script provides text-to-speech and speech-to-text functionality using Azure Cognitive Services
# 
# Prerequisites:
# - Azure Speech Services subscription
# - curl command line tool
# - jq for JSON parsing (install with: brew install jq)

# TEST COMMANDS
# ./azure_speech_v1.sh voices
# ./azure_speech_v1.sh tts -t "This is a test with a different voice" -v "en-US-AriaNeural" -o aria_test.wav
# ./azure_speech_v1.sh tts -t "Testing with custom settings" -v "en-US-GuyNeural" -r "+25%" -p "+5%" -o custom_test.wav
# ./azure_speech_v1.sh stt output/tts/speech.wav
# ./azure_speech_v1.sh stt -f output/tts/speech.wav -j


# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
AZURE_REGION=""
AZURE_SPEECH_KEY=""
CONFIG_FILE="$HOME/.azure_speech_config"

# Default values
DEFAULT_VOICE="en-US-JennyNeural"
DEFAULT_LANGUAGE="en-US"
OUTPUT_DIR="./output"
TTS_DIR="$OUTPUT_DIR/tts"
STT_DIR="$OUTPUT_DIR/stt"
DEBUG_DIR="$OUTPUT_DIR/debug"

# Help function
show_help() {
    echo -e "${BLUE}Azure Speech API Script${NC}"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  config                Set up Azure credentials"
    echo "  tts [text]           Text-to-speech conversion"
    echo "  stt [audio_file]     Speech-to-text conversion"
    echo "  voices               List available voices"
    echo "  debug                Show debug information"
    echo "  help                 Show this help message"
    echo ""
    echo "Text-to-Speech Options:"
    echo "  -t, --text TEXT      Text to convert to speech"
    echo "  -v, --voice VOICE    Voice to use (default: $DEFAULT_VOICE)"
    echo "  -o, --output FILE    Output audio file (default: speech.wav)"
    echo "  -r, --rate RATE      Speech rate (-50% to +200%, default: +0%)"
    echo "  -p, --pitch PITCH    Speech pitch (-50% to +50%, default: +0%)"
    echo ""
    echo "Speech-to-Text Options:"
    echo "  -f, --file FILE      Audio file to transcribe"
    echo "  -l, --language LANG  Language code (default: $DEFAULT_LANGUAGE)"
    echo "  -j, --json           Output result as JSON"
    echo ""
    echo "Examples:"
    echo "  $0 config"
    echo "  $0 tts -t \"Hello, world!\" -v \"en-US-AriaNeural\" -o hello.wav"
    echo "  $0 stt -f audio.wav -l en-US"
    echo "  $0 voices"
    echo ""
    echo "File Organization:"
    echo "  TTS outputs:    $TTS_DIR/"
    echo "  STT outputs:    $STT_DIR/"
    echo "  Debug files:    $DEBUG_DIR/"
}

# Logging function
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "INFO")
            echo -e "${timestamp} ${GREEN}[INFO]${NC} $message"
            ;;
        "WARN")
            echo -e "${timestamp} ${YELLOW}[WARN]${NC} $message"
            ;;
        "ERROR")
            echo -e "${timestamp} ${RED}[ERROR]${NC} $message"
            ;;
        *)
            echo -e "${timestamp} [DEBUG] $message"
            ;;
    esac
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log "ERROR" "Missing dependencies: ${missing_deps[*]}"
        log "INFO" "Install missing dependencies:"
        for dep in "${missing_deps[@]}"; do
            case $dep in
                "jq")
                    echo "  brew install jq"
                    ;;
                "curl")
                    echo "  curl is usually pre-installed on macOS"
                    ;;
            esac
        done
        exit 1
    fi
}

# Load configuration
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        if [[ -n "$AZURE_REGION" && -n "$AZURE_SPEECH_KEY" ]]; then
            return 0
        fi
    fi
    return 1
}

# Save configuration
save_config() {
    cat > "$CONFIG_FILE" << EOF
# Azure Speech API Configuration
AZURE_REGION="$AZURE_REGION"
AZURE_SPEECH_KEY="$AZURE_SPEECH_KEY"
EOF
    chmod 600 "$CONFIG_FILE"
    log "INFO" "Configuration saved to $CONFIG_FILE"
}

# Setup configuration
setup_config() {
    echo -e "${BLUE}Azure Speech API Configuration${NC}"
    echo ""
    
    if [[ -t 0 ]]; then
        echo -n "Enter your Azure region (e.g., eastus, westus2): "
        read AZURE_REGION
        echo -n "Enter your Azure Speech API key: "
        read -s AZURE_SPEECH_KEY
        echo ""
    else
        log "ERROR" "Interactive configuration requires a terminal"
        exit 1
    fi
    
    if [[ -z "$AZURE_REGION" || -z "$AZURE_SPEECH_KEY" ]]; then
        log "ERROR" "Region and API key are required"
        exit 1
    fi
    
    # Test the configuration
    local test_url="https://${AZURE_REGION}.api.cognitive.microsoft.com/sts/v1.0/issuetoken"
    local response=$(curl -s -w "%{http_code}" -X POST \
        -H "Ocp-Apim-Subscription-Key: $AZURE_SPEECH_KEY" \
        -H "Content-Length: 0" \
        "$test_url")
    
    local http_code="${response: -3}"
    
    if [[ "$http_code" == "200" ]]; then
        save_config
        log "INFO" "Configuration test successful!"
    else
        log "ERROR" "Configuration test failed. HTTP code: $http_code"
        log "ERROR" "Please check your region and API key"
        exit 1
    fi
}

# Get access token
get_access_token() {
    local token_url="https://${AZURE_REGION}.api.cognitive.microsoft.com/sts/v1.0/issuetoken"
    
    local token=$(curl -s -X POST \
        -H "Ocp-Apim-Subscription-Key: $AZURE_SPEECH_KEY" \
        -H "Content-Length: 0" \
        "$token_url")
    
    if [[ -n "$token" ]]; then
        echo "$token"
        return 0
    else
        log "ERROR" "Failed to get access token"
        return 1
    fi
}

# Text-to-Speech function
text_to_speech() {
    local text=""
    local voice="$DEFAULT_VOICE"
    local output_file="speech.wav"
    local rate="+0%"
    local pitch="+0%"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--text)
                text="$2"
                shift 2
                ;;
            -v|--voice)
                voice="$2"
                shift 2
                ;;
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            -r|--rate)
                rate="$2"
                shift 2
                ;;
            -p|--pitch)
                pitch="$2"
                shift 2
                ;;
            *)
                if [[ -z "$text" ]]; then
                    text="$1"
                fi
                shift
                ;;
        esac
    done
    
    if [[ -z "$text" ]]; then
        if [[ -t 0 ]]; then
            echo -n "Enter text to convert to speech: "
            read text
        else
            log "ERROR" "No text provided and not running interactively"
            return 1
        fi
    fi
    
    if [[ -z "$text" ]]; then
        log "ERROR" "No text provided"
        return 1
    fi
    
    # Create output directories
    mkdir -p "$TTS_DIR"
    local full_output_path="$TTS_DIR/$output_file"
    
    log "INFO" "Converting text to speech..."
    log "INFO" "Text: $text"
    log "INFO" "Voice: $voice"
    log "INFO" "Output: $full_output_path"
    
    # Get access token
    local token=$(get_access_token)
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Create SSML
    local ssml="<speak version='1.0' xml:lang='en-US'>
        <voice xml:lang='en-US' name='$voice'>
            <prosody rate='$rate' pitch='$pitch'>
                $text
            </prosody>
        </voice>
    </speak>"
    
    # Make TTS request
    local tts_url="https://${AZURE_REGION}.tts.speech.microsoft.com/cognitiveservices/v1"
    
    local response=$(curl -s -w "%{http_code}" -X POST \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/ssml+xml" \
        -H "X-Microsoft-OutputFormat: riff-24khz-16bit-mono-pcm" \
        -H "User-Agent: AzureSpeechScript" \
        --data "$ssml" \
        -o "$full_output_path" \
        "$tts_url")
    
    local http_code="${response: -3}"
    
    if [[ "$http_code" == "200" ]]; then
        log "INFO" "Speech synthesis completed successfully!"
        log "INFO" "Audio saved to: $full_output_path"
        
        # Check if afplay is available (macOS audio player)
        if command -v afplay &> /dev/null; then
            if [[ -t 0 ]]; then
                echo -n "Play the audio now? (y/n): "
                read play_audio
                if [[ "$play_audio" =~ ^[Yy]$ ]]; then
                    afplay "$full_output_path"
                fi
            else
                log "INFO" "Audio file created. Use 'afplay $full_output_path' to play it."
            fi
        fi
    else
        log "ERROR" "Speech synthesis failed. HTTP code: $http_code"
        rm -f "$full_output_path"
        return 1
    fi
}

# Speech-to-Text function
speech_to_text() {
    local audio_file=""
    local language="$DEFAULT_LANGUAGE"
    local json_output=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--file)
                audio_file="$2"
                shift 2
                ;;
            -l|--language)
                language="$2"
                shift 2
                ;;
            -j|--json)
                json_output=true
                shift
                ;;
            *)
                if [[ -z "$audio_file" ]]; then
                    audio_file="$1"
                fi
                shift
                ;;
        esac
    done
    
    if [[ -z "$audio_file" ]]; then
        log "ERROR" "No audio file provided"
        return 1
    fi
    
    if [[ ! -f "$audio_file" ]]; then
        log "ERROR" "Audio file not found: $audio_file"
        return 1
    fi
    
    log "INFO" "Transcribing audio file: $audio_file"
    log "INFO" "Language: $language"
    
    # Check audio file size and format
    local file_size=$(stat -f%z "$audio_file" 2>/dev/null || echo "unknown")
    log "INFO" "Audio file size: $file_size bytes"
    
    # Get access token
    local token=$(get_access_token)
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    log "INFO" "Access token obtained successfully"
    
    # Make STT request
    local stt_url="https://${AZURE_REGION}.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1"
    stt_url="${stt_url}?language=${language}&format=detailed"
    
    log "INFO" "STT URL: $stt_url"
    log "INFO" "Making STT request..."
    
    # Create directories for outputs
    mkdir -p "$STT_DIR" "$DEBUG_DIR"
    
    # Generate timestamp for unique filenames
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local session_id="${timestamp}_$(basename "$audio_file" .wav)"
    
    # Add timeout and verbose error handling
    local response=$(curl -m 30 -w "HTTPCODE:%{http_code}" -X POST \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: audio/wav" \
        -H "Accept: application/json" \
        --data-binary "@$audio_file" \
        "$stt_url" 2>/dev/null)
    
    local curl_exit_code=$?
    log "INFO" "Curl exit code: $curl_exit_code"
    
    # Extract HTTP code and response body
    local http_code=$(echo "$response" | grep -o "HTTPCODE:[0-9]*" | cut -d: -f2)
    local response_body=$(echo "$response" | sed 's/HTTPCODE:[0-9]*$//')
    
    log "INFO" "HTTP response code: $http_code"
    
    # Save raw response for debugging with unique filename
    local debug_file="$DEBUG_DIR/stt_response_${session_id}.json"
    echo "$response_body" > "$debug_file"
    log "INFO" "Raw response saved to: $debug_file"
    
    if [[ $curl_exit_code -eq 0 && "$http_code" == "200" ]]; then
        local recognition_status=$(echo "$response_body" | jq -r '.RecognitionStatus // empty')
        
        if [[ "$recognition_status" == "Success" ]]; then
            log "INFO" "Speech recognition completed successfully!"
            
            # Save transcription to file with unique naming
            local output_file="$STT_DIR/transcription_${session_id}.txt"
            local json_file="$STT_DIR/transcription_${session_id}.json"
            
            if [[ "$json_output" == true ]]; then
                echo "$response_body" | jq . | tee "$json_file"
                log "INFO" "JSON response saved to: $json_file"
            else
                local display_text=$(echo "$response_body" | jq -r '.DisplayText // empty')
                echo -e "${GREEN}Transcription:${NC} $display_text"
                echo "$display_text" > "$output_file"
                # Also save JSON version for reference
                echo "$response_body" | jq . > "$json_file"
                log "INFO" "Transcription saved to: $output_file"
                log "INFO" "JSON version saved to: $json_file"
                
                # Show confidence scores if available
                local best_result=$(echo "$response_body" | jq -r '.NBest[0] // empty')
                if [[ "$best_result" != "empty" && "$best_result" != "null" ]]; then
                    local confidence=$(echo "$best_result" | jq -r '.Confidence // empty')
                    if [[ "$confidence" != "empty" && "$confidence" != "null" ]]; then
                        echo -e "${BLUE}Confidence:${NC} $(echo "$confidence * 100" | bc -l | cut -d. -f1)%"
                    fi
                fi
            fi
        else
            log "ERROR" "Speech recognition failed. Status: $recognition_status"
            log "ERROR" "Full response saved to $debug_file"
            if [[ "$json_output" == true ]]; then
                echo "$response_body" | jq .
            fi
            return 1
        fi
    else
        if [[ $curl_exit_code -eq 28 ]]; then
            log "ERROR" "Request timed out after 30 seconds"
        elif [[ $curl_exit_code -ne 0 ]]; then
            log "ERROR" "Curl failed with exit code: $curl_exit_code"
        else
            log "ERROR" "HTTP error. Status code: $http_code"
        fi
        log "ERROR" "Response saved to $debug_file"
        return 1
    fi
}

# List available voices
list_voices() {
    log "INFO" "Fetching available voices..."
    
    local voices_url="https://${AZURE_REGION}.tts.speech.microsoft.com/cognitiveservices/voices/list"
    
    local response=$(curl -s -H "Ocp-Apim-Subscription-Key: $AZURE_SPEECH_KEY" "$voices_url")
    
    if [[ $? -eq 0 ]]; then
        echo -e "${BLUE}Available Voices:${NC}"
        echo ""
        echo "$response" | jq -r '.[] | "\(.Name) - \(.DisplayName) (\(.Locale)) - \(.Gender)"' | sort
    else
        log "ERROR" "Failed to fetch voices"
        return 1
    fi
}

# Debug function
show_debug() {
    echo -e "${BLUE}Azure Speech API Debug Information${NC}"
    echo ""
    
    # Check configuration
    if load_config; then
        echo -e "${GREEN}✅ Configuration loaded successfully${NC}"
        echo "Region: $AZURE_REGION"
        echo "API Key: ${AZURE_SPEECH_KEY:0:8}...${AZURE_SPEECH_KEY: -8}"
    else
        echo -e "${RED}❌ Configuration not found${NC}"
        echo "Run: $0 config"
        return 1
    fi
    
    echo ""
    echo -e "${BLUE}Dependencies:${NC}"
    
    # Check curl
    if command -v curl &> /dev/null; then
        local curl_version=$(curl --version | head -1)
        echo -e "${GREEN}✅ curl: $curl_version${NC}"
    else
        echo -e "${RED}❌ curl: Not found${NC}"
    fi
    
    # Check jq
    if command -v jq &> /dev/null; then
        local jq_version=$(jq --version)
        echo -e "${GREEN}✅ jq: $jq_version${NC}"
    else
        echo -e "${RED}❌ jq: Not found${NC}"
    fi
    
    # Check bc
    if command -v bc &> /dev/null; then
        echo -e "${GREEN}✅ bc: Available${NC}"
    else
        echo -e "${RED}❌ bc: Not found${NC}"
    fi
    
    # Check afplay
    if command -v afplay &> /dev/null; then
        echo -e "${GREEN}✅ afplay: Available${NC}"
    else
        echo -e "${YELLOW}⚠️ afplay: Not found (audio playback unavailable)${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}Test Connectivity:${NC}"
    
    # Test token endpoint
    local token_url="https://${AZURE_REGION}.api.cognitive.microsoft.com/sts/v1.0/issuetoken"
    local token_test=$(curl -s -w "%{http_code}" -X POST \
        -H "Ocp-Apim-Subscription-Key: $AZURE_SPEECH_KEY" \
        -H "Content-Length: 0" \
        "$token_url")
    
    local token_http_code="${token_test: -3}"
    if [[ "$token_http_code" == "200" ]]; then
        echo -e "${GREEN}✅ Token endpoint: Accessible${NC}"
    else
        echo -e "${RED}❌ Token endpoint: HTTP $token_http_code${NC}"
    fi
    
    # Test TTS endpoint
    local tts_url="https://${AZURE_REGION}.tts.speech.microsoft.com/cognitiveservices/v1"
    echo "TTS endpoint: $tts_url"
    
    # Test STT endpoint  
    local stt_url="https://${AZURE_REGION}.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1"
    echo "STT endpoint: $stt_url"
    
    # Check output directories
    echo ""
    echo -e "${BLUE}Output Directories:${NC}"
    
    if [[ -d "$OUTPUT_DIR" ]]; then
        echo -e "${GREEN}✅ Main output directory exists: $OUTPUT_DIR${NC}"
        
        # Check TTS directory
        if [[ -d "$TTS_DIR" ]]; then
            local tts_count=$(ls "$TTS_DIR"/*.wav 2>/dev/null | wc -l | tr -d ' ')
            echo -e "${GREEN}✅ TTS directory: $TTS_DIR (${tts_count} files)${NC}"
        else
            echo -e "${YELLOW}⚠️ TTS directory does not exist: $TTS_DIR${NC}"
        fi
        
        # Check STT directory
        if [[ -d "$STT_DIR" ]]; then
            local stt_txt_count=$(ls "$STT_DIR"/*.txt 2>/dev/null | wc -l | tr -d ' ')
            local stt_json_count=$(ls "$STT_DIR"/*.json 2>/dev/null | wc -l | tr -d ' ')
            echo -e "${GREEN}✅ STT directory: $STT_DIR (${stt_txt_count} txt, ${stt_json_count} json files)${NC}"
        else
            echo -e "${YELLOW}⚠️ STT directory does not exist: $STT_DIR${NC}"
        fi
        
        # Check debug directory
        if [[ -d "$DEBUG_DIR" ]]; then
            local debug_count=$(ls "$DEBUG_DIR"/*.json 2>/dev/null | wc -l | tr -d ' ')
            echo -e "${GREEN}✅ Debug directory: $DEBUG_DIR (${debug_count} files)${NC}"
        else
            echo -e "${YELLOW}⚠️ Debug directory does not exist: $DEBUG_DIR${NC}"
        fi
        
        # Show recent files if any exist
        local recent_files=$(find "$OUTPUT_DIR" -type f -name "*.wav" -o -name "*.txt" -o -name "*.json" | head -5)
        if [[ -n "$recent_files" ]]; then
            echo ""
            echo -e "${BLUE}Recent output files:${NC}"
            echo "$recent_files" | while read -r file; do
                echo "  $(ls -lh "$file")"
            done
        fi
    else
        echo -e "${YELLOW}⚠️ Main output directory does not exist: $OUTPUT_DIR${NC}"
    fi
}

# Main function
main() {
    check_dependencies
    
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi
    
    local command="$1"
    shift
    
    case "$command" in
        "config")
            setup_config
            ;;
        "debug")
            show_debug
            ;;
        "tts")
            if ! load_config; then
                log "ERROR" "Azure configuration not found. Run: $0 config"
                exit 1
            fi
            text_to_speech "$@"
            ;;
        "stt")
            if ! load_config; then
                log "ERROR" "Azure configuration not found. Run: $0 config"
                exit 1
            fi
            speech_to_text "$@"
            ;;
        "voices")
            if ! load_config; then
                log "ERROR" "Azure configuration not found. Run: $0 config"
                exit 1
            fi
            list_voices
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            log "ERROR" "Unknown command: $command"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
