require 'google/apis/youtube_v3'
require 'fileutils'
require 'json'
require './crawler'

crawler = Crawler.new ENV['YOUTUBE_API_KEY']
likedFirst = crawler.getTopVideosRunningThroughFavorites("kJQP7kiw5Fk", 60)

deeper = likedFirst.map { |k,v| crawler.getTopVideosRunningThroughFavorites(k, 10)}
puts deeper

summary = likedFirst
deeper.each do |k,v|
  if summary.has_key? k
    summary[k] += 1
  else
    summary[k] = 1
  end
end

put summary





