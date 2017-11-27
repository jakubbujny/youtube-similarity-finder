require 'google/apis/youtube_v3'
require 'fileutils'
require 'json'

service = Google::Apis::YoutubeV3::YouTubeService.new
service.client_options.application_name = "youtube-similarity-finder"
service.key = ENV['YOUTUBE_API_KEY']


sourceVideoId = "m9UB9B0CSok"
channelsIdsFromMovieComments =  JSON.parse(service.list_comment_threads("snippet", video_id: sourceVideoId,max_results: 100).to_json)["items"].map{|response| response["snippet"]["topLevelComment"]["snippet"]["authorChannelId"]["value"]}
favorites = channelsIdsFromMovieComments.map{|channelId| JSON.parse(service.list_channels("contentDetails", id:channelId).to_json)["items"].first["contentDetails"]["relatedPlaylists"]["favorites"]}.select{|value| !value.nil?}
videosList = favorites.map {|favoritePlaylistId| JSON.parse(service.list_playlist_items("contentDetails", playlist_id: favoritePlaylistId).to_json)["items"]}.flatten.map{|video| video["contentDetails"]["videoId"]}
puts videosList.reduce(Hash.new(0)) {|acc,el|
  if acc.has_key? el
    acc[el] += 1
  else
    acc[el] = 1
  end
  acc
}.select{|k,v| v > 1}.sort_by {|k,v| v}.reverse
