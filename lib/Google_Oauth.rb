require 'rubygems'
require 'rest_client'
require 'json'

class Google_Oauth

	def initialize (client_id,client_secret,refresh_token)
		@client_id     	    = client_id
		@client_secret      = client_secret
		@refresh_token 		= refresh_token
		@token_refresh_url  = 'https://accounts.google.com/o/oauth2/token'
	end

	def get_access_token

		#Create request body
		request_body_map = {
			:client_id => client_id,
			:client_secret => client_secret,
			:refresh_token => refresh_token,
			:grant_type => 'refresh_token'
		}

		#Create a new request
		request = RestClient.post token_refresh_url, request_body_map, {:content_type => 'application/x-www-form-urlencoded'}

		response = request

		#Parse the JSON body for access token
		response_body = JSON.parse(response.body)
		access_token = response_body['access_token']
		return access_token
	end

	def client_id
		@client_id
	end

	def client_secret
		@client_secret
	end

	def refresh_token
		@refresh_token
	end

	def token_refresh_url
		@token_refresh_url
	end

end

	

