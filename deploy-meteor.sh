#!/bin/bash


echo "What is the git tag?" 
read var1 

# Get to know your exports
export METEOR_SETTINGS=$(cat /var/www/sites/meteor-app-src/settings.prod.json)  # this can be commented out if you are not using a settings file
export MONGO_URL='mongodb://localhost:27017/meteor-app'                     # Localhost mongodb server 
export ROOT_URL='http://meteor-app.hifighetto.com'                          # the url, it can also be http://localhost/
export PORT=8118                                                            # The port number that the app will run on 

# Start doing things, rest of the comments will be echo'ed to the command line
echo "Need to do the git steps manually at the moment"
echo "if you havent done the git steps stop here"

# does the git updates into the raw code page 
cd /var/www/html/sites/meteor-app-src
git fetch --tags 
git checkout $var1
git fetch origin 

# Creates the package for the meteor-app in /var/www/sites/meteor-app/meteor-app-src.tar.gz 
echo " "
echo "Creating Bundle for deployment"
meteor build --mobile-settings settings.prod.json ../meteor-app

# The first run this will give an error but it will stop the existing running meteor-app being run by forever 
echo " "
echo "stopping the server"
cd /var/www/html/sites/meteor-app/bundle
/usr/local/bin/forever stop main.js

# Removes the old app by deleting the bundle directory 
echo " "
echo "Removing old code"
cd /var/www/html/sites/meteor-app
/bin/rm -rf bundle 
tar -zxf meteor-app-src.tar.gz

# Installs the required NPM modules as per the meteor-app/bundle/README 
echo " "
echo "Installing site modules"
cd bundle/programs/server
/usr/bin/npm install

# Starts forever node.js so that it can run as a service and the user can logout 
echo " "
echo "Restarting the server"
cd /var/www/html/sites/meteor-app/bundle
forever start main.js


# Last step, check it make sure it works, just like you should after a deploy 
echo " "
echo "Completed, please check for errors on the site"
