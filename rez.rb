require 'open-uri'
require 'json'
require 'net/http'
require 'nokogiri'
require 'rubygems'
require 'rufus/scheduler'
require 'twitter'
require 'sinatra'
require 'pry'

#if Sinatra::Base.development?
#  require 'pry'
#end

class RezUsage

	def initialize(appartement)
    url = "http://reznetusage.azurewebsites.net/?phase=#{appartement[:phase]}&appart=#{appartement[:appartement]}"
    @page = Nokogiri::HTML(open(url))
  end

  def parse_usage
		
    gb_restant = @page.css('span#ContentPlaceHolder1_lblRestant').text.delete('GB').to_i
    borne_atteinte = (0..100).step(5).find { |b| b >= gb_restant }
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
    config.consumer_key        = '*****'
    config.consumer_secret     = '****'
    config.access_token        = '******'
    config.access_token_secret = '****'
  end

  def send_tweet(msg, handle)
   # if Sinatra::Base.production?
      @client.update("[#{Date.today.strftime("%Y %m")}] #{msg} @#{handle}")
    #else
     # puts "[#{Time.now()}] #{msg}"
    #end
  end

end
end

get '/' do
  {goku417: {phase: 2, chambre: 626}, maxstonge: {phase: 2, chambre: 627}}.each do |handle, appartement|
  message =RezUsage.new(appartement).parse_usage
  TweetBot.new.send_tweet(message, handle) if message 
  p 'test'
end

end