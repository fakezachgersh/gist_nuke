require './lib/gist_nuke'
require 'vcr_setup'

describe GistNuke do
  around(:each) do |example|
    VCR.use_cassette('github', :record => :once) do
      example.run
    end
  end

  describe ".get_github_token" do
    it "should return a valid GitHub auth token" do
      credentials = {username: "test", password: "test"}

      token = GistNuke.get_github_token(credentials)
      token.should == "5611d1d57d6837dedf584f0b9418da7cc8d7f976"
    end
  end

  describe ".load_gists" do
    it "should return the GitHub gist JSON with expected keys" do
      GistNuke.stub(:token_from_file).and_return "fe71e9391a26d6280ac377081d7ba3bfe2364993"
      gist_hash = GistNuke.load_gists
      gist_hash[0].has_key?("url").should == true
      gist_hash[0].has_key?("id").should == true
      gist_hash[0].has_key?("public").should == true
    end
  end

  describe ".just_keys" do
    it "should return an array of only gist keys" do
      gists = [{'id' => "kjashdfkljhaskjdfhasdf", 'junk' => "asdkfjalshdfkjhasfkhjasf"}]
      GistNuke.just_keys(gists).should == ["kjashdfkljhaskjdfhasdf"]
    end
  end

  describe ".gather_pages" do
    it "should return an array of gists that is 34 keys long" do
      GistNuke.stub(:token_from_file).and_return "fe71e9391a26d6280ac377081d7ba3bfe2364993"
      GistNuke.gather_pages(32..34).length == 34
    end

    it "should return an array of gists that is 30 keys long" do
      GistNuke.stub(:token_from_file).and_return "fe71e9391a26d6280ac377081d7ba3bfe2364993"
      GistNuke.gather_pages(0..3).length == 30
    end
  end
end
