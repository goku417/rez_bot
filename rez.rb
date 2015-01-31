require 'open-uri'
require 'json'
require 'net/http'
require 'nokogiri'
require 'rubygems'
require 'rufus/scheduler'
require 'twitter'
require 'sinatra'

if Sinatra::Base.development?
  require 'pry'
end

class RezUsage

	def initialize
    url = "http://reznetusage.azurewebsites.net/?phase=2&appart=627"
    @page = Nokogiri::HTML(open(url))
    #configure_twitter
  end

  def parse_usage
		
    gb_restant = @page.css('span#ContentPlaceHolder1_lblRestant').text.delete('GB').to_i
    borne_atteinte = (0..20).step(5).find { |b| b >= gb_restant }
    if borne_atteinte
      "Vous avez atteint la borne de #{borne_atteinte} GB, il ne vous reste que #{gb_restant} GB"
    end
	end
end

class TweetBot
  def initialize
    configure_twitter
  end


  def configure_twitter
    @client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['buI6wS66tpW8lTpHusKpHGYFB']
    config.consumer_secret     = ENV['xC4aOaxPmn0dsOfQ0D8c5cN91mspISSNGEIHZsANtQ6Cg5XOvB']
    config.access_token        = ENV['72032743-VZomJ6YSF4rYKUJBU8xmOQncyjBvasEXH0fY1eqHs']
    config.access_token_secret = ENV['GpYqcaHmHUETFJBbIcxzrOQpRgiSjh1iKMTDuzxfow8yy']
  end

  def send_tweet(msg)
    if Sinatra::Base.production?
      @client.update(msg)
    else
      puts "[#{Time.now()}] #{msg}"
    end
  end

end

message =RezUsage.new().parse_usage
TweetBot.new.send_tweet(message) if message end