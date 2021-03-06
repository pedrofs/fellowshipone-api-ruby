require 'oauth'
require 'yaml'

# This POC code will request a OAuth token,
# and save it for later use in the
# file "access_token_marshal.txt"

@consumer = OAuth::Consumer.new(F1Keys::CONSUMER_KEY,
                                F1Keys::CONSUMER_KEY,{
                                  :site => "https://#{F1Keys::CHURCH_CODE}.#{F1Keys::ENVIRONMENT}.fellowshiponeapi.com",
                                  :request_token_path => "/v1/Tokens/RequestToken",
                                  :authorize_path => "/v1/PortalUser/Login",
                                  :access_token_path => "/v1/Tokens/AccessToken",
                                  :http_method => :get
                                })

puts "Request Token:"
puts @consumer.inspect
puts "\nDone inspecting\n\n"

@request_token = @consumer.get_request_token

#debug
puts @request_token.token
puts @request_token.secret
#end debug

puts "\nPaste URL into your browser:\n\n"

puts @request_token.authorize_url

puts "\nPress Enter when Done\n\n"

gets

@access_token = @request_token.get_access_token

puts "Access Token:"
puts @access_token.inspect
puts "\nDone inspecting\n"

File.write("access_token_marshal.txt", Marshal.dump(@access_token))
File.write("access_token.yml", YAML.dump(@access_token))

puts "\nAccess Token is now saved for future use"
