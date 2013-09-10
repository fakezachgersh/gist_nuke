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
    token = get_github_token(credentials)
    save_auth_token(token)
  end

  def get_github_token(credentials = {})
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

    JSON.parse(res.body)['token']
  end

  def token_from_file
    if File.exists?('.gist_nuke')
      File.read('.gist_nuke')
    else
      false
    end
  end

  def save_auth_token(token)
    File.open(".gist_nuke", "w+") do |file|
      file.write(token)
    end
  end

  def load_gists(page_number = 1)
    token = token_from_file
    uri = URI("#{BASE_URL}gists?access_token=#{token}&page=#{page_number}")
    Net::HTTP.start(uri.host, uri.port,
                    :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri.request_uri

      response = http.request(request)

      JSON.parse(response.body)
    end
  end

  def just_keys(gists = [])
    gists.map { |g| g['id'] }
  end

  def gather_pages(range)
    keys = []
    page_number = 1
    last_page = false

    until keys.length >= range.last || last_page
      to_append = just_keys(load_gists(page_number))
      last_page = to_append.empty?
      keys += to_append
      page_number += 1
    end
    keys
  end

  def delete_range(numbers = [])
    numbers = numbers.map { |num| num.to_i }
    range = (numbers[0]..numbers[-1])
    list = gather_pages(range)
    list[range]
    construct_hydra(list[range])
    @batch.run
  end

  def construct_hydra(range)
    t = token_from_file
    @batch = Typhoeus::Hydra.new
    range.map { |gist_id| @batch.queue(Typhoeus::Request.new("#{BASE_URL}gists/#{gist_id}?access_token=#{t}",
                                                           method: :delete))}
  end
end
