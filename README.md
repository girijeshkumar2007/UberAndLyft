# UberAndLyft

Go to your project path and run the following comand on your terminal

pod install

	for Uber
Add UberClientID and  UberServerToken in info plist. You can these info when you register your app in uber developer website
	<key>UberClientID</key>
	<string></string>
	<key>UberServerToken</key>
	<string></string>
	<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>uber</string>
		<string>uberauth</string>
	</array>
	
	For Lyft
private  let kLyftClientId          =  "" // Only This value will be changes

private  let kLyftClientSecret      =  "" // Only This value will be changes

Add kLyftClientId and  kLyftClientSecret in TALyftServiceClass.swift class. You can these info when you register your app in lyft developer website

