import os
import requests
from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route('/')
def home():
    """Health check and welcome route."""
    return jsonify({
        "status": "Healthy",
        "message": "Welcome to the Weather API Tracker! Use the /weather endpoint.",
        "usage": "/weather?city=YOUR_CITY_NAME"
    })

@app.route('/weather', methods=['GET'])
def get_weather():
    """Fetches weather data for a specified city using OpenWeatherMap."""
    city = request.args.get('city')
    
    # Check if user provided a city
    if not city:
        return jsonify({"error": "Please provide a city name. Example: /weather?city=Chennai"}), 400

    # Retrieve the API key from environment variables (Crucial for DevOps security)
    api_key = os.getenv('WEATHER_API_KEY')
    if not api_key:
        return jsonify({"error": "WEATHER_API_KEY environment variable is not set."}), 500

    # OpenWeatherMap API Endpoint (using metric units for Celsius)
    url = f"http://api.openweathermap.org/data/2.5/weather?q={city}&appid={api_key}&units=metric"
    
    try:
        response = requests.get(url)
        data = response.json()
        
        # If the API call is successful
        if response.status_code == 200:
            weather_info = {
                "city": data["name"],
                "country": data["sys"]["country"],
                "temperature_celsius": data["main"]["temp"],
                "feels_like_celsius": data["main"]["feels_like"],
                "description": data["weather"][0]["description"].title(),
                "humidity_percent": data["main"]["humidity"]
            }
            return jsonify(weather_info)
        else:
            # Handle API errors (e.g., city not found, invalid API key)
            return jsonify({"error": data.get("message", "Failed to fetch weather data")}), response.status_code
            
    except Exception as e:
        # Catch any server-side exceptions (e.g., network failure)
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # host='0.0.0.0' is required for Docker port mapping to work correctly
    app.run(host='0.0.0.0', port=5000, debug=True)