require "sinatra"
require "sinatra/reloader"
require "http"
require "json"

get("/") do
  erb(:main)
end

get("/umbrella") do
  erb(:umbrella)
end

get("/message") do
  erb(:message)
end

get("/chat") do
  erb(:chat)
end

get("/process_umbrella") do
  gmaps_key = "AIzaSyDKz4Y3bvrTsWpPRNn9ab55OkmcwZxLOHI"
  pweather_key = "kgcx5l5n4bxXRWQA3XmXjjSjybwUhK5K"
  @location = params.fetch("location")

  # GMAPS: Fetch data and parse to get lat/long
  gmaps = "https://maps.googleapis.com/maps/api/geocode/json?address=#{@location}&key=#{gmaps_key}"
  gmaps_data = HTTP.get(gmaps).to_s
  gmaps_parse = JSON.parse(gmaps_data)

  location_data = gmaps_parse["results"][0]["geometry"]["location"]
  @lat = location_data["lat"]
  @long = location_data["lng"]

  # PIRATE_WEATHER: Fetch data and parse to get weather
  pweather = "https://api.pirateweather.net/forecast/#{pweather_key}/41.8887,-87.6355"
  pweather_data = HTTP.get(pweather).to_s
  pweather_parse = JSON.parse(pweather_data)
  @current_temp = pweather_parse["currently"]["temperature"]
  @current_sum = pweather_parse["currently"]["summary"]
  

  # Store Hours and precipitation prob in a 2d array
  hourly = pweather_parse["hourly"]["data"]
  hour_arr = Array.new
  need_umbrella = false
  rain_hour = 0


  (1..12).each do |hour|
    prob = hourly[hour]["precipProbability"]*100
    new_prob = prob.to_i
    pair = [hour, new_prob]
    hour_arr.append(pair)

    # Check if precipitation prob is above 10%
    if (new_prob > 10) && (!need_umbrella)
      need_umbrella = true
      rain_hour = hour
    end
  end

  if need_umbrella
    @outcome = "You might want to carry an umbrella!"
  else
    @outcome = "You probably won`t need an umbrella."
  end

  erb(:process_umbrella)
end

get("/process_single_message") do
  @message = params.fetch("message")
  
  erb(:process_message)
end
