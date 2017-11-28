class Crawler
  @youtubeApiService

  def initialize(apiKey)
    @youtubeApiService = Google::Apis::YoutubeV3::YouTubeService.new
    @youtubeApiService.client_options.application_name = "youtube-similarity-finder"
    @youtubeApiService.key = apiKey
  end

  private
  def gatherPlaylistsFromUsersCommetingVideo(videoId, maxPlaylistsCount, nextPageToken = nil)


    commentsWithMetadata = JSON.parse(@youtubeApiService.list_comment_threads("snippet", video_id: videoId, max_results: 100, page_token: nextPageToken).to_json)
    nextPageToken = commentsWithMetadata["nextPageToken"]
    channelsIdsFromMovieComments = commentsWithMetadata["items"].map {|response| response["snippet"]["topLevelComment"]["snippet"]["authorChannelId"]["value"]}
    playLists = getPlaylistsFromChannels(channelsIdsFromMovieComments)
    return playLists, nextPageToken
  end

  private
  def getPlaylistsFromChannels(channelsIdsList)
    channelsIdsList
        .map {|channelId|
          playlists = JSON.parse(@youtubeApiService.list_channels("contentDetails", id: channelId).to_json)["items"].first["contentDetails"]["relatedPlaylists"]
          Array(playlists["favorites"]) + Array(playlists["likes"])}
        .select {|list| list.size > 0}
  end

  public
  def getTopVideosRunningThroughFavorites(startingVideoId, desiredPlaylists)
    favoritesMerge = []
    currentNextPageToken = nil

    minPlaylistsCounter = desiredPlaylists
    while minPlaylistsCounter > 0
      favorites, nextPageToken = gatherPlaylistsFromUsersCommetingVideo(startingVideoId, 100, currentNextPageToken)
      favoritesMerge += favorites
      minPlaylistsCounter -= favorites.size
      if nextPageToken.nil?
        break
      else
        currentNextPageToken = nextPageToken
      end
    end


    videosList = favoritesMerge.map {|favoritePlaylistId|
      begin
        JSON.parse(@youtubeApiService.list_playlist_items("contentDetails", playlist_id: favoritePlaylistId).to_json)["items"]
      rescue Google::Apis::ClientError => err
        puts err
        []
      end
    }.flatten.map {|video| video["contentDetails"]["videoId"]}
    return  videosList.reduce(Hash.new(0)) {|acc, el|
      if acc.has_key? el
        acc[el] += 1
      else
        acc[el] = 1
      end
      acc
    }.select {|k, v| v > 1}.sort_by {|k, v| v}.reverse
  end

end