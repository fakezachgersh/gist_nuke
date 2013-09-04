require './lib/gist_nuke'
require 'vcr_setup'

describe GistNuke do
  describe ".get_github_token" do
    it "should return a valid GitHub auth token" do
      VCR.use_cassette('github') do
        credentials = {username: "test", password: "test"}

        token = GistNuke.get_github_token(credentials)
        token.should == "fe71e9391a26d6280ac377081d7ba3bfe2364993"
      end
    end
  end

  describe ".load_gists" do
    it "should return the GitHub gist JSON with expected keys" do
      GistNuke.stub(:token_from_file).and_return "fe71e9391a26d6280ac377081d7ba3bfe2364993"
      VCR.use_cassette('github') do
        gist_hash = GistNuke.load_gists
        gist_hash[0].has_key?("url").should == true
        gist_hash[0].has_key?("id").should == true
        gist_hash[0].has_key?("public").should == true
      end
    end
  end

  describe ".just_keys" do
    it "should return an array of only gist keys" do
      gists = [{'id' => "kjashdfkljhaskjdfhasdf", 'junk' => "asdkfjalshdfkjhasfkhjasf"}]
      GistNuke.just_keys(gists).should == ["kjashdfkljhaskjdfhasdf"]
    end
  end
end
