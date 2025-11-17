#!/bin/bash

###############################################################################
# Script Name: weather_forecast.sh
# Description: This script fetches and displays the current weather, including
#              sunrise and sunset times, and a 2-day weather forecast for a 
#              specified city using the OpenWeatherMap API. It also downloads 
#              and displays the relevant weather icon.
#              Prerequirements: jq and gdate (brew install jq; brew install coreutils)
#
# Author: sstumpf
# Date: September 23, 2024
###############################################################################

PATH=$PATH:/usr/local/bin:/opt/homebrew/bin
CITY_ID="2948652" # City ID for Birkenau, DE
API_KEY="ebe27016fad92614ff7dedeb3e7de78f" # API key - current weather
API_KEY_FC="d9ec593d5da467695e486b40a3905acb" # API key - forecast weather

UNITS="metric" # Use "imperial" for Fahrenheit
LANG="de" # Language code for German

# Temporary file paths
CURRENT_WEATHER_FILE="/tmp/current_weather.json"
FORECAST_FILE="/tmp/weather_forecast.json"
ICON_FILE="/tmp/weather_icon.png"

# Function to handle API errors
handle_error() {
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

# Fetch current weather data using city ID
current_response=$(curl --silent --show-error --fail -w "%{http_code}" -o "$CURRENT_WEATHER_FILE" "http://api.openweathermap.org/data/2.5/weather?id=${CITY_ID}&units=${UNITS}&lang=${LANG}&appid=${API_KEY}")
http_status_current="${current_response: -3}"

# Fetch 3-day weather forecast (daily data)
forecast_response=$(curl --silent --show-error --fail -w "%{http_code}" -o "$FORECAST_FILE" "https://api.openweathermap.org/data/2.5/forecast/daily?id=${CITY_ID}&cnt=3&units=${UNITS}&lang=${LANG}&appid=${API_KEY_FC}")
http_status_forecast="${forecast_response: -3}"

# Check if the current weather request was successful (HTTP status code 200)
if [ "$http_status_current" -eq 200 ] && [ "$http_status_forecast" -eq 200 ]; then
  # Parse and display current weather information
  cityName=$(jq -r '.name' "$CURRENT_WEATHER_FILE")
  country=$(jq -r '.sys.country' "$CURRENT_WEATHER_FILE")
  temp=$(jq -r '.main.temp' "$CURRENT_WEATHER_FILE")
  weather=$(jq -r '.weather[0].description' "$CURRENT_WEATHER_FILE")
  icon=$(jq -r '.weather[0].icon' "$CURRENT_WEATHER_FILE") # Get the icon code
  
  # Parse sunrise and sunset times and convert them to human-readable format using gdate
  sunrise=$(jq -r '.sys.sunrise' "$CURRENT_WEATHER_FILE")
  sunset=$(jq -r '.sys.sunset' "$CURRENT_WEATHER_FILE")
  
  echo "Aktuelles Wetter in ${cityName}, ${country}"
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

  # Download the weather icon
  if [ "$icon" != "null" ]; then
    icon_url="http://openweathermap.org/img/wn/${icon}@4x.png" #download 100x100 sized image
    curl -L --fail --silent --show-error -o "$ICON_FILE" "$icon_url"
  else
    echo "Kein Symbol für Wetter verfügbar."
  fi

  # Parse 2-day weather forecast and display it
  echo "Vorhersage für die nächsten 2 Tage:"
  for i in {1..2}; do
    day_of_week=$(jq -r ".list[$i].dt" "$FORECAST_FILE" | gdate -d @"$(jq -r ".list[$i].dt" "$FORECAST_FILE")" '+%A')
    forecast_weather=$(jq -r ".list[$i].weather[0].description" "$FORECAST_FILE")
    temp_max=$(jq -r ".list[$i].temp.max" "$FORECAST_FILE")
    temp_min=$(jq -r ".list[$i].temp.min" "$FORECAST_FILE")
    echo "${day_of_week} - ${forecast_weather} - Max: ${temp_max}°C, Min: ${temp_min}°C"
  done

else
  # Handle errors based on HTTP status code for either current weather or forecast request
  if [ "$http_status_current" -ne 200 ]; then
    handle_error "$http_status_current"
  fi

  if [ "$http_status_forecast" -ne 200 ]; then
    handle_error "$http_status_forecast"
  fi
fi

# Clean up temporary file
if [ -f "$ICON_FILE" ]; then
    rm "$ICON_FILE"
fi
