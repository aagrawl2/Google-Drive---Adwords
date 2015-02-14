# Google Drive API Ruby Code
A simple Googel Drive API client for Ruby which downloads files from your defined folder in Google Drive and can push them to S3

####Notes
1) Oauth2 credentials (client id, client secret, refresh token) are needed before running the script. 
2) Steps for creating Oauth credentials are :
https://confluence.intgdc.com/display/PS/Oauth+2+Authentication+Steps

3) Scopes needed for current ruby script are :
      a) https://www.googleapis.com/auth/drive
      b) https://www.googleapis.com/auth/drive.readonly
If you have not generated refresh token take reference : https://github.com/aagrawl2/Ruby/blob/master/generate_refresh_token.rb

4) Amazon S3 credentials are required if backing up to S3 else remove that piece of code

####Steps
1) Initialize S3 bucket

2) Initialize new Google Drive object
  
      a) Create Google_Oaut2 class object that generates fresh access token
      b) Automatic Token refreshing is handled as it expires in 3600 sec 
      
3) Get a list of folders from Google Drive. If folder name is no gven, then default "Adwords" is used.

4) Scan through the folder to get list of all files and their file ids

5) For each file id , get the download url associated with it 

5) Download all files locally

6) Backup all downloaded files to S3

7) Move the files that are backd up to Trash in Google Drive


