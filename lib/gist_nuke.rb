require 'net/http'
require 'json'
require 'uri'

module GistNuke
  extend self

  BASE_URL = "https://api.github.com/"
  AUTH_EXT = "/authorizations"

  def hi
    puts "hey"
  end

  def login
    credentials = {}
    puts "Let's get an Oauth Token from GitHub"
    print "Enter your username: "
    credentials[:username] = $stdin.gets.chomp
    print "Enter your password: "
    credentials[:password] = begin `stty -echo` rescue nil
                 $stdin.gets.chomp
               ensure
                 `stty -echo` rescue nil
               end

    phone_github(credentials)
  end

  def phone_github(credentials = {})
    uri = URI(BASE_URL + AUTH_EXT)
    p uri
  end
end
