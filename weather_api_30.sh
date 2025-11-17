#!/bin/bash

###############################################################################
# Script Name: weather_forecast.sh
# Description: This script fetches and displays the current weather using
#              OpenWeatherMap's One Call API 3.0.
# Author: sstumpf
# Date: September 23, 2024
###############################################################################

LAT="32.0853" # Latitude for Tel Aviv
LON="34.7818" # Longitude for Tel Aviv
API_KEY="ebe27016fad92614ff7dedeb3e7de78f" # Replace with your OpenWeatherMap API key
UNITS="metric" # Use "imperial" for Fahrenheit
LANG="de" # Language code for German

# Fetch current weather data using One Call API 3.0
weather_data=$(curl -s "https://api.openweathermap.org/data/3.0/onecall?lat=${LAT}&lon=${LON}&units=${UNITS}&lang=${LANG}&appid=${API_KEY}")

# Parse and display current weather information
if [ "$(echo "$weather_data" | jq -r '.current')" != "null" ]; then
  temp=$(echo "$weather_data" | jq -r '.current.temp')
  weather=$(echo "$weather_data" | jq -r '.current.weather[0].description')
  
  echo "Aktuelles Wetter in Tel Aviv:"
  echo "Temperatur: ${temp}°C"
  echo "Bedingung: ${weather}"
else
  message=$(echo "$weather_data" | jq -r '.message')
  echo "Fehler beim Abrufen der Wetterdaten: ${message}"
fi

# Commented out forecast part (if needed)
: '
# Example of fetching additional forecast data if needed
daily_forecast=$(echo "$weather_data" | jq -r '.daily')
'