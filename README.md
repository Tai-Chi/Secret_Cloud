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
- get `[username]/`: returns the whole file system of a user specified by its ID, in the form of a special data structure
- post `create/folder` + [username] + [absolute path]: tells the server to create an empty folder
- post `create/file` + [username] + [absolute path] + [portion number]: tells the server to create a file. If the file is too large, the portion number tells the server the correct order to combine this file.
- post `delete/folder` + [username] + [absolute path]: tells the server to delete a folder
- post `delete/file` + [username] + [absolute path]: tells the server to delete a file. All portions of this file must be deleted.
- post `rename/folder` + [username] + [old absolute path] + [new folder name]: tells the server to rename a folder
- post `rename/file` + [username] + [old absolute path] + [new file name]: tells the server to rename a file. All portions of this file must be renamed.
- post `giveid` + [username] + [new id] + [absolute path] + [portion number]: tells the server to add the file id given by Google Drive. Although a folder also has id in Google Drive, we don't have to do this for folders because we never uploads a folder.

#### Notes
* To ensure the safety of our URL commands, the data part enclosed with [] above should be passed with the HTTP request body.
* All post methods will return a list of parameters, in json format, required to call Google APIs.

### DONE

### TODO

