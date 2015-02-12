module Microsoft
  module Translator
    class Client

      MS_PARAMETERS = {
        'scope' => 'http://api.microsofttranslator.com',
        'grant_type' => 'client_credentials'
      }

      MS_ACCESS_TOKEN_URI = "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13"
      MS_TRANSLATOR_URI = "http://api.microsofttranslator.com/v2/Http.svc/"

      def initialize(client_id, client_secret)
        if client_id.class != String || client_secret.class != String
          raise ArgumentError, "You must provide Strings"
        else
          @credentials = MS_PARAMETERS.clone
          @credentials['client_id'] = client_id
          @credentials['client_secret'] = client_secret
          @expires_in = @access_token = @supported_languages = nil
        end
      end

      # Returns access token to Microsoft Translator Service
      def access_token
        if @expires_in && Time.now < @expires_in
          @access_token
        else
          response = HTTParty.post(MS_ACCESS_TOKEN_URI, body: @credentials)
          if response.code == 200
            @expires_in = Time.now + ( response['expires_in'].to_i )
            @access_token = response['access_token']
          else
            false
          end
        end
      end

      #
      # Returns language code of text, false if there is an error
      # @param [Sting] text to detect language from
      #
      def detect_language(text)
        if text.class == String
          encoded_text = CGI::escape(text).slice(0..500)
          response = get('Detect', "text=#{encoded_text}")
          if response.code == 200
            response.parsed_response.to_hash['string']['__content__']
          else
            false
          end
        else
          raise ArgumentError, "You must provide a String"
        end
      end

      #
      # Returns translated text, false if there is an error
      # @param [String] text The text to be translated
      # @param [String] lang_to A two character code that represents language
      # @param [String] lang_from A two character code that represents language to translate from
      #
      def translate(text, lang_to, lang_from=nil)
        if text.class == String
          raise "Language code is not supported" and return unless supported_languages.include?(lang_to)
          raise "" and return if !lang_from.nil? && !supported_languages.include?(lang_from)

          encoded_text = CGI::escape(text)
          response = get('Translate', "text=#{encoded_text}&to=#{lang_to}")
          if response.code == 200
            response.parsed_response.to_hash['string']['__content__']
          else
            false
          end
        else
          raise ArgumentError, "You must provide a String"
        end
      end

      # Returns an array pf supported language codes, false if error
      def supported_languages
        unless @supported_languages
          response = get('GetLanguagesForTranslate')
          if response.code == 200
            @supported_languages = response.parsed_response['ArrayOfstring']['string']
          else
            @supported_languages = false
          end
        end
        @supported_languages
      end

      private

        def get(api_call, query_string=nil)
          HTTParty.get("#{MS_TRANSLATOR_URI}#{api_call}?#{query_string}", headers: { 'Authorization' => "Bearer #{access_token}"})
        end
    end
  end
end
