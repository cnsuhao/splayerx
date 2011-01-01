#!/bin/sh

#########clear the current files#########
rm -Rf SPlayerX.app
rm -Rf SPlayerX.zip
rm -Rf ../../releases/SPlayerX.zip

#########copy the newly release app#########
cp -R ../MPlayerX/build/Release/SPlayerX.app ./SPlayerX.app

##########zip it#########
zip -ry SPlayerX.zip SPlayerX.app > /dev/null

##########get the create time#########
ruby GetTime.rb "./SPlayerX.zip"
echo

##########get the version#########
ruby GetBundleVersion.rb "./SPlayerX.app"
echo

##########get the size#########
ruby GetFileSize.rb "./SPlayerX.zip"
echo

##########get the signature#########
echo "Sign:"
security find-generic-password -g -s "SPlayerX Private Key" 1>/dev/null 2>key.txt
ruby parsePriKey.rb key.txt > key2.txt
openssl dgst -sha1 -binary "./SPlayerX.zip" | openssl dgst -dss1 -sign key2.txt | openssl enc -base64

#diff key2.txt ../Sparkle.framework/Extras/Signing\ Tools/dsa_priv.pem

mv SPlayerX.zip ../../releases/

rm -Rf SPlayerX.app
rm -Rf ../MPlayerX/build/Release/SPlayerX.app
rm -Rf key.txt
rm -Rf key2.txt