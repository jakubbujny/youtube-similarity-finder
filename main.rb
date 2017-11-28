require 'google/apis/youtube_v3'
require 'fileutils'
require 'json'
require './crawler'

crawler = Crawler.new ENV['YOUTUBE_API_KEY']
likedFirst = crawler.getTopVideosRunningThroughFavorites("kJQP7kiw5Fk", 60)

puts likedFirst.map { |k,v| crawler.getTopVideosRunningThroughFavorites(k, 5)}



