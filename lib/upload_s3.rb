require 'csv'
require 'aws-sdk'

class UploadS3

	def initialize (access_key_id, secret_access_key, bucket_name)
		@s3 = AWS::S3.new(:access_key_id => access_key_id, :secret_access_key => secret_access_key)
		@bucket_name = bucket_name
	end

	def upload(file_name , path_to_s3_folder)
		final_file_path = path_to_s3_folder + file_name
		@s3.buckets[@bucket_name].objects[final_file_path].write(:file => file_name)
		puts "#{file_name} successfully uploaded"
	end
end

