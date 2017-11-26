# Sample Ruby code for user authorization
require 'google/apis/youtube_v3'
require 'fileutils'
require 'json'

# Initialize the API
service = Google::Apis::YoutubeV3::YouTubeService.new
service.client_options.application_name = "youtube-similarity-finder"
service.key = ENV['YOUTUBE_API_KEY']

# Sample ruby code for channels.list

def channels_list_by_username(service, part, **params)
  response = service.list_channels(part, params).to_json
  item = JSON.parse(response).fetch("items")[0]

  puts ("This channel's ID is #{item.fetch("id")}. " +
      "Its title is '#{item.fetch("snippet").fetch("title")}', and it has " +
      "#{item.fetch("statistics").fetch("viewCount")} views.")
end

channels_list_by_username(service, 'snippet,contentDetails,statistics', for_username: 'GoogleDevelopers')