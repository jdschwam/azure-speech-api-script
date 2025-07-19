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
# ./azure_speech_v1.sh stt output/speech.wav
# ./azure_speech_v1.sh stt -f output/speech.wav -j


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
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    local full_output_path="$OUTPUT_DIR/$output_file"
    
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
    
    # Get access token
    local token=$(get_access_token)
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Make STT request
    local stt_url="https://${AZURE_REGION}.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1"
    stt_url="${stt_url}?language=${language}&format=detailed"
    
    local response=$(curl -s -X POST \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: audio/wav" \
        -H "Accept: application/json" \
        --data-binary "@$audio_file" \
        "$stt_url")
    
    if [[ $? -eq 0 ]]; then
        local recognition_status=$(echo "$response" | jq -r '.RecognitionStatus // empty')
        
        if [[ "$recognition_status" == "Success" ]]; then
            log "INFO" "Speech recognition completed successfully!"
            
            if [[ "$json_output" == true ]]; then
                echo "$response" | jq .
            else
                local display_text=$(echo "$response" | jq -r '.DisplayText // empty')
                echo -e "${GREEN}Transcription:${NC} $display_text"
                
                # Show confidence scores if available
                local best_result=$(echo "$response" | jq -r '.NBest[0] // empty')
                if [[ "$best_result" != "empty" && "$best_result" != "null" ]]; then
                    local confidence=$(echo "$best_result" | jq -r '.Confidence // empty')
                    if [[ "$confidence" != "empty" && "$confidence" != "null" ]]; then
                        echo -e "${BLUE}Confidence:${NC} $(echo "$confidence * 100" | bc -l | cut -d. -f1)%"
                    fi
                fi
            fi
        else
            log "ERROR" "Speech recognition failed. Status: $recognition_status"
            if [[ "$json_output" == true ]]; then
                echo "$response" | jq .
            fi
            return 1
        fi
    else
        log "ERROR" "Failed to make speech recognition request"
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
