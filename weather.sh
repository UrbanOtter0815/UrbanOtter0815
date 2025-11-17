#!/bin/bash

###############################################################################
# Script Name: weather.sh
# Description: This script fetches and displays the current weather, including
#              sunrise and sunset times, for a specified city using the 
#              OpenWeatherMap API. It also downloads and displays the relevant 
#              weather icon.
#              Prerequirements: jq and gdate (brew install jq; brew install coreutils)
#                               GeekTool may require full access to the hdd
#
# Author:      sstumpf
# Date:        23.09.2024
# Modified:    15.04.2025
###############################################################################

PATH=$PATH:/usr/local/bin:/opt/homebrew/bin
CITY_ID="2948652"                                                         # City ID for Birkenau, DE
API_KEY="ebe27016fad92614ff7dedeb3e7de78f"                                # Example API key
UNITS="metric"                                                            # Use "imperial" for Fahrenheit
LANG="de"                                                                 # Language code for German
PUBLIC_IP=$(curl -s https://api.ipify.org)                                # Public IP to retrieve geo location
GEO_DATA=$(curl -s "http://ip-api.com/json/$PUBLIC_IP")                   # prepare search criteria
LATITUDE=$(echo "$GEO_DATA" | grep -o '"lat":[^,]*' | cut -d':' -f2)      # retrieve latitude
LONGITUDE=$(echo "$GEO_DATA" | grep -o '"lon":[^,]*' | cut -d':' -f2)     # retrieve longitude

# Temporary file paths
TEMP_FILE="/tmp/current_weather.json"
ICON_FILE="/tmp/weather_icon.png"

# Check if internet connection is available
if ! ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
  echo "Keine Internetverbindung verfügbar - Exit!"
  exit 1
fi

# Function to handle API errors
function handle_error() {
  local status_code=$1
  case $status_code in
    400) echo "Bad Request: The request was unacceptable, often due to a missing or misconfigured parameter." ;;
    401) echo "Unauthorized: Your API key is invalid or was not provided." ;;
    404) echo "Not Found: The requested resource could not be found." ;;
    429) echo "Too Many Requests: You have exceeded your API request limit." ;;
    500) echo "Server Error: An error occurred on the server side." ;;
    *) echo "An unexpected error occurred. Status code: $status_code" ;;
  esac
}

# Function to download the weather icon and check its freshness
function download_and_check_icon() {
    local icon_code="$1"
    local icon_url="http://openweathermap.org/img/wn/${icon_code}@4x.png"
    local icon_file="$ICON_FILE"

    # Download the icon
    curl -L --fail --silent --show-error -o "$icon_file" "$icon_url"

    # Extract the last modification date and time
    MOD_TIME=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$icon_file")     # Format: YYYY-MM-DD HH:MM:SS

    # Get current time in the same format
    CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")

    # Calculate the difference in seconds between CURRENT_TIME and MOD_TIME
    MOD_TIMESTAMP=$(date -j -f "%Y-%m-%d %H:%M:%S" "$MOD_TIME" "+%s") # Convert MOD_TIME to Unix timestamp
    CURRENT_TIMESTAMP=$(date "+%s")                                   # Convert CURRENT_TIME to Unix timestamp

    DIFF=$((CURRENT_TIMESTAMP - MOD_TIMESTAMP)) # Difference in seconds

    # Check if the difference is less than or equal to 600 seconds (10 minutes)
    if [ "$DIFF" -le 600 ]; then
        echo "✔"
    else
        echo "×"
    fi
}

# Fetch current weather data using my public ip and geo-location
response=$(curl --silent --show-error --fail -w "%{http_code}" -o "$TEMP_FILE" "http://api.openweathermap.org/data/2.5/weather?lat=${LATITUDE}&lon=${LONGITUDE}&units=${UNITS}&lang=${LANG}&appid=${API_KEY}")

# Extract HTTP status code from the response
http_status="${response: -3}"

# Check if the request was successful (HTTP status code 200)
if [ "$http_status" -eq 200 ]; then
  # Parse and display current weather information
  cityName=$(jq -r '.name' "$TEMP_FILE")
  country=$(jq -r '.sys.country' "$TEMP_FILE")
  temp=$(jq -r '.main.temp' "$TEMP_FILE")
  weather=$(jq -r '.weather[0].description' "$TEMP_FILE")
  icon=$(jq -r '.weather[0].icon' "$TEMP_FILE") # Get the icon code
  
  # Parse sunrise and sunset times and convert them to human-readable format using gdate
  sunrise=$(jq -r '.sys.sunrise' "$TEMP_FILE")
  sunset=$(jq -r '.sys.sunset' "$TEMP_FILE")

  # Download the weather icon and check freshness BEFORE printing the header
  if [ "$icon" != "null" ]; then
      current=$(download_and_check_icon "$icon")
  else
      current="(kein Symbol)"
  fi

  echo "Aktuelles Wetter in ${cityName}, ${country} $current"
  echo 
  echo "Temperatur: ${temp}°C"
  echo "Bedingung: ${weather}"

  if [ "$sunrise" != "null" ] && [ "$sunset" != "null" ]; then
    sunrise_formatted=$(gdate -d @"$sunrise" '+%H:%M')
    sunset_formatted=$(gdate -d @"$sunset" '+%H:%M')
    echo "Sonnenaufgang: ${sunrise_formatted}"
    echo "Sonnenuntergang: ${sunset_formatted}"
  else
    echo "Sonnenauf- und Untergang nicht verfügbar."
  fi

else
  # Handle errors based on HTTP status code
  handle_error "$http_status"
fi

# Clean up temporary file
#if [ -f "$ICON_FILE" ]; then
#     rm "$ICON_FILE"
#fi
