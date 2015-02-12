require 'spec_helper'

MS_CLIENT_ID = 'tt-v2-d'
MS_CLIENT_SECRET = 'nByOzOS8kXvM8HB5AtDDsHRQwaDXGayOyPCzTbD44VQ='

describe Microsoft::Translator::Client do
	describe "#access_token" do
		context "when status is not 200" do
			it "returns false" do
        VCR.use_cassette("access_token/error") do
				  expect(Microsoft::Translator::Client.new('not-an-id', MS_CLIENT_SECRET).access_token).to be false
        end
			end
		end

		context "when access token accessed first time" do
			before(:each) {
        @ms = Microsoft::Translator::Client.new(MS_CLIENT_ID, MS_CLIENT_SECRET)
        VCR.use_cassette("access_token/success") { @ms.access_token }
        @ms
      }
			it "sets the expiration time" do
				expect(@ms.instance_variable_get(:@expires_in)).not_to eq nil
			end
			it "sets the access token" do
				expect(@ms.instance_variable_get(:@access_token)).not_to eq nil
			end
		end

    context "when access token is not expired" do
      it "returns the same access token" do
        ms = Microsoft::Translator::Client.new(MS_CLIENT_ID, MS_CLIENT_SECRET)
        VCR.use_cassette("access_token/success") { ms.access_token }
        expect(ms.access_token).to eq ms.instance_variable_get(:@access_token)
      end
    end
		context "when access token is expired" do
			before {
        @ms = Microsoft::Translator::Client.new(MS_CLIENT_ID, MS_CLIENT_SECRET)
        VCR.use_cassette("access_token/success") { @ms.access_token }
      }
			it "updates expiration time" do
				expires_in = @ms.instance_variable_get :@expires_in
				expires_in -= 600
				expiration_time = @ms.instance_variable_set(:@expires_in, expires_in)
				VCR.use_cassette("access_token/success") { @ms.access_token }
				expect(expiration_time).not_to eq @ms.instance_variable_get(:@expires_in)
			end
		end

		it "returns access token" do
      ms = Microsoft::Translator::Client.new(MS_CLIENT_ID, MS_CLIENT_SECRET)
      token = VCR.use_cassette("access_token/success") { ms.access_token }
      expect(token).to eq ms.instance_variable_get(:@access_token)
    end
  end

  describe "#detect_language" do
    before(:each) do 
      @ms = Microsoft::Translator::Client.new(MS_CLIENT_ID, MS_CLIENT_SECRET) 
      VCR.use_cassette("access_token/success") { @ms.access_token }
    end
    context "when string given" do
      context "and status is 200" do
        it "returns the language code" do
          VCR.use_cassette("detect/success") do
            expect(@ms.detect_language('This is a test.')).to eq 'en'
          end
        end
      end
    end
    context "when string not given" do
      it "raises argument error" do
        lambda { expect(@ms.detect_language(3)).to raise_error ArgumentError }
      end
    end
  end

  describe "#translate" do
    let(:test_text) { "This is a small test string" }
    before(:each) do 
      @ms = Microsoft::Translator::Client.new(MS_CLIENT_ID, MS_CLIENT_SECRET) 
      VCR.use_cassette("access_token/success") { @ms.access_token }
      VCR.use_cassette("supported_languages") { @ms.supported_languages }
    end
    context "when lang_to or lang_fromis not valid" do
      it "lang_to wrong raises an error" do
        lambda { expect(@ms.translate(test_text, 'not_a_code')).to raise_error }
      end
      it "lang_from wrong raises an error" do
        lambda { expect(@ms.translate(test_text, 'fr', 'not_a_code')).to raise_error }
      end
    end
    context "when string is given" do
      it "returns a translated text" do
        VCR.use_cassette("translate/success") do
          expect(@ms.translate(test_text, 'fr')).to eq "Il s'agit d'une petite chaîne"
        end
      end
    end
    context "when string is not given" do
      context "when lang_from is invalid" do
        it "raises an error" do
          lambda { expect(@ms.translate(3, 'en')).to raise_error ArgumentError }
        end
      end
      context "when lang_from is valid" do
        it "returns translated text"do
          VCR.use_cassette("translate/success") do
            expect(@ms.translate(test_text, 'fr')).to eq "Il s'agit d'une petite chaîne"
          end
        end
      end
    end
  end

  describe "#supported_languages" do
    before(:each) do
      @ms = Microsoft::Translator::Client.new(MS_CLIENT_ID, MS_CLIENT_SECRET)
      VCR.use_cassette("access_token/success") { @ms.access_token }
      VCR.use_cassette("supported_languages") { @ms.supported_languages }
    end
    it "sets @supported languages" do
      expect(@ms.instance_variable_get(:@supported_languages)).not_to be nil
    end
    it "returns an array of languages" do
      expect(@ms.instance_variable_get(:@supported_languages).class).to eq Array
    end
  end
end