# Secret_Cloud
[![Dependency Status](https://gemnasium.com/badges/github.com/Tai-Chi/Secret_Cloud.svg)](https://gemnasium.com/github.com/Tai-Chi/Secret_Cloud)
* Main idea: A project to periodically backup some files/folders on our local computer to Google Drive.
* Features:
  * To ensure that our data cannot be read by the service provider, we may encrypt our files/folders before uploading them to Google Drive.
  * For some files larger than 15GB, we can split the files first and then upload those portions to Google Drive. Of course, the relation between those portions should be maintained.

## To run the server:

1. $ bundle install
2. $ rackup
3. Browser URL: 'localhost:9292/'
4. Use the following routes

## Routes

- get `users/`: returns a json of all usernames
- get `[username]/`: returns the whole selected file system of a user specified by its ID
- post `[username]/create/folder/[absolute path]`: tells the server to create an empty folder
- post `[username]/create/file/[absolute path]/[portion number]`: tells the server to create a file. If the file is too large, the portion number tells the server the correct order to combine this file.
- post `[username]/delete/folder/[absolute path]`: tells the server to delete a folder
- post `[username]/delete/file/[absolute path]`: tells the server to delete a file. All portions of this file must be deleted.
- post `[username]/rename/folder/[absolute path]`: tells the server to rename a folder
- post `[username]/rename/file/[absolute path]`: tells the server to rename a file. All portions of this file must be renamed.
- post `[username]/giveid/[new id]/[absolute path]/[portion number]`: tells the server to add the file id given by Google Drive. Although a folder also has id in Google Drive, we don't have to do this for folders because we never uploads a folder.
- post `[username]/update/[absolute path]/[portion number]`: tells the server to update the file content. Updating a folder means updating files inside. Therefore we can do this only for files many times and ignore folders.

#### Notes
* To ensure the safety of our URL commands, the /[absolute path]/[portion number] part should be passed with the HTTP request body.
* All post methods will return a list of parameters, in json format, required to call Google APIs.
