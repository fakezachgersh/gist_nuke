require 'net/http'
require 'json'
require 'uri'
require 'typhoeus'

module GistNuke
  extend self

  BASE_URL = "https://api.github.com/"
  AUTH_EXT = "authorizations"

  def login
    credentials = {}
    puts "Let's get an Oauth Token from GitHub"
    print "Enter your username: "
    credentials[:username] = $stdin.gets.chomp
    print "Enter your password: "
    credentials[:password] = begin `stty -echo` rescue nil
                 $stdin.gets.chomp
               ensure
                 `stty echo` rescue nil
               end

    puts ""
    phone_github(credentials)
  end

  def phone_github(credentials = {})
    uri = URI(BASE_URL + AUTH_EXT)
    req = Net::HTTP::Post.new(uri.path)
    req.content_type = "application/json"
    req.body = JSON.dump({
      scopes: [:gist],
      note: "Batch delete your gists, you know you want to."
    })

    req.basic_auth(credentials[:username], credentials[:password])

    res = Net::HTTP.start(uri.hostname, uri.port,
                         :use_ssl => uri.scheme == 'https') do |http|
      http.request(req)
    end

    save_auth_token(res.body)
  end

  def save_auth_token(res)
    token = JSON.parse(res)['token']
    File.open(".gist_nuke", "w+") do |file|
      file.write(token)
    end
  end

  def load_gists(page_number = 0)
    token = File.read(".gist_nuke")
    uri = URI("#{BASE_URL}gists?access_token=#{token}&page=#{page_number}")
    Net::HTTP.start(uri.host, uri.port,
                    :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri.request_uri

      response = http.request(request)

      gist_hash = JSON.parse(response.body)

      just_keys(gist_hash)
    end
  end

  def just_keys(gist_hash = {})
    just_keys = []

    gist_hash.each do |hash|
      just_keys << hash['id']
    end

    just_keys
  end

  def delete_range(numbers = [])
    numbers= numbers.map { |num| num.to_i }
    range = (numbers[0]..numbers[-1])
    delete_list = load_gists[range]
    p queue = construct_hydra(delete_list)
    #queue.run
  end

  def construct_hydra(range)
    p range
    t = File.read(".gist_nuke")
    batch = Typhoeus::Hydra.new
    range.map { |gist_id| batch.queue(Typhoeus::Request.new("#{BASE_URL}gists/#{gist_id}?access_token=#{t}",
                                                           method: :delete))}
  end
end
