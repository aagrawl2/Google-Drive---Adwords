require_relative './Google_Oauth.rb'

require 'rubygems'
require 'rest_client'
require 'json'
require 'csv'
require 'pp'

class GDrive

	def initialize (params)
		#Generate new access token from Google_Oauth library
		@new_token     = Google_Oauth.new(params['client_id'],params['client_secret'],params['refresh_token'])
		#Store the fresh access token as an instance variable
		@access_token = @new_token.get_access_token
		#Create an instance variable that is a timer. It checks before each API call that it has exceeded 1hr , if it is then generate a new access token and reset the timer
		@start_time = Time.now
	end

	# This function is used to generate new access token and reset the timer
	def refresh_access_token()

		if(Time.now - @start_time) >=3000
			puts "Access Token Expired .......Creating a new one"
			@access_token = @new_token.get_access_token
			@start_time   = Time.now
		end
	end

	# This will give list of folders in authenticated Google Drive
	def get_list_folders()
		refresh_access_token()
		request_url = "https://www.googleapis.com/drive/v2/files?q=mimeType='application/vnd.google-apps.folder'&access_token=#{@access_token}"

		response = RestClient.get request_url
		response_body = JSON.parse(response.body)
		folders = Hash.new

		response_body['items'].each do |item|
			folders[item['title']] = item['id']
		end

		return folders
	end

	#Get list of all files from authenticated Google Drive
	def list_all_files()
		files = Hash.new
		refresh_access_token()
		request_url = "https://www.googleapis.com/drive/v2/files?access_token=#{@access_token}"
		response = RestClient.get request_url
		response_body = JSON.parse(response.body)
		response_body['items'].each do |item|
				files[item['id']] = item['title']
		end
		return files
	end

	# List all the files in your folder. If no folder name is passed, it will assume Adwords as the default folder
	def get_list_files_folder(*folder_name)

		files = Array.new
		if (folder_name.length==0)
			folders = get_list_folders()
			#Give the folder you want to use otherwise we'll have to loop through
			folder_id = folders['Adwords']
			refresh_access_token()

			request_url = "https://www.googleapis.com/drive/v2/files/#{folder_id}/children?access_token=#{@access_token}"
			response = RestClient.get request_url
			response_body = JSON.parse(response.body)
			#puts pp(response_body)

			response_body['items'].each do |item|
				files.push(item['id'])
			end

			return files
		end
	end

	def fetch_file_download_url(*file_id)

		files= Hash.new { |l, k| l[k] = Hash.new(&l.default_proc) }
		if(file_id.length==0)
			list = get_list_files_folder()
			list.each do |item|
				refresh_access_token()
				request_url = "https://www.googleapis.com/drive/v2/files/#{item}?access_token=#{@access_token}"
				response = RestClient.get request_url
				response_body = JSON.parse(response.body)
				#puts response_body
				files[response_body['title']][item] = response_body['downloadUrl']
			end
			return files
		end
	end


	def download_file(*download_url)

		files = fetch_file_download_url()
		file_names = Array.new
		file_ids = Array.new

		puts "#{files.length} files will be exported to S3"
		puts "#{files.keys}"
		files.each do |file_name,file_url|
			puts "Downloading file #{file_name}"
			file_url.each do |file_id,download_url|
				file_ids.push(file_id)
				refresh_access_token()
				request_url = download_url + "&access_token=#{@access_token}"
				response = RestClient.get request_url
				#Write it to a file
				output_csv = file_name + ".csv" # This is done because we are not able to identify extension of file from the file information
				file_names.push(output_csv)
				open(output_csv,'wb') do |file|
					file.write(response.body)
				end
			end
		end
		return file_names,file_ids
	end

	def move_to_trash(file_id)

		refresh_access_token()
		request_url = "https://www.googleapis.com/drive/v2/files/#{file_id}/trash?access_token=#{@access_token}"
		response = RestClient.post request_url, {:content_type => 'application/x-www-form-urlencoded'}
		puts "Move #{file_id} to trash"
	end
end
