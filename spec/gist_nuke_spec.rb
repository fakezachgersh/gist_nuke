require './lib/gist_nuke'
require 'vcr_setup'

describe GistNuke do
  describe "get_github_token" do
    it "returns a valid GitHub auth token" do
      VCR.use_cassette('github') do
        credentials = {username: "test", password: "test"}

        token = GistNuke.get_github_token(credentials)
        token.should == "fe71e9391a26d6280ac377081d7ba3bfe2364993"
      end
    end
  end
end
