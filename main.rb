require_relative './lib/upload_s3'
require_relative './lib/google_drive'

require 'json'

#Use / at the end  when specifying folder name otherwise it would error out
#Example AIDRGFRTUCNGHGK_gdc-ms-cust_demo/backup_adwords/keywords/
PATH_TO_S3_FOLDER_DESTINATION_URL =  ''
PATH_TO_S3_FOLDER_KEYWORDS        =  ''

#Read file parameters
file = File.read ('./params.json')
params = JSON.parse(file)


#Create a new  object for Google Drive
drive_token = GDrive.new(params)



#This function will directly download all the files present in "Adwords" folder in the authenticated Google Drive
# If you wnat to list files or download files from root folder  please use functions explicitly
file_names,file_ids  = drive_token.download_file()

#Initializing new object for S3 class which implicitly create new s3 bucket and send credentails
#Please remove this part if you don't wanna upload files to S3
s3_object = UploadS3.new(params['S3_ACCESS_KEY'],params['S3_SECRET_KEY'],params['S3_BUCKET'])

#Upload files to S3
file_names.each  {|item|
	if /destinationUrl/.match(item)
		s3_object.upload(item,PATH_TO_S3_FOLDER_DESTINATION_URL)
	else
		s3_object.upload(item,PATH_TO_S3_FOLDER_KEYWORDS)
	end
} unless file_names.nil?

#Move Files to Trash
file_ids.each { |file_id| drive_token.move_to_trash(file_id) } unless file_ids.nil?