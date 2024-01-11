#!/bin/bash
#
###############################################################################################################################################
#
# ABOUT THIS PROGRAM
#
#	JAMF-Bulk-Wipe.sh
#	https://github.com/Headbolt/JAMF-Bulk-Wipe
#
#   This Script is designed for use in JAMF
#
#   - This script will ...
#			Use the Provided list ( Seperated by Spaces ) and connect to the JAMF API to send a remote Wipe to them all
#			If they are found
#
#			The Following Variables should be defined
#
#			Variable 4 - Named "API URL - eg. https://mycompany.jamfcloud.com"
#			Variable 5 - Named "API User - eg. API-User"
#			Variable 6 - Named "API User Password - eg. YetAnotherPasswordyThing"
#			Variable 7 - Named "Serial Number List - eg. abcdef poiuyt cdfghbre"
#			Variable 8 - Named "Code For Wipe - eg. 123456"
#			Variable 9 - Named "WIPE/TEST - eg. WIPE"
#
#			The API User set in Variable 5 will need the following permisions ONLY
#			Jamf Pro Server Objects > Read perms for Computers
#			Jamf Pro Server Actions > Send Computer Remote Wipe Command
#
###############################################################################################################################################
#
# HISTORY
#
#	Version: 1.0 - 11/01/2024
#
#	- 11/01/2024 - V1.0 - Created by Headbolt
#
###############################################################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
###############################################################################################################################################
#
apiURL=${4} # Grab the url for API Login from JAMF variable #4 eg. https://company.jamfcloud.com
apiUser=${5} # Grab the username for API Login from JAMF variable #5 eg. username
apiPass=${6} # Grab the password for API Login from JAMF variable #6 eg. password
DeviceList=${7} # Grab the list of serial number to wipe from JAMF variable #6 eg. abcdef poiuyt cdfghbre
WipeCode=${8} # Grab the wipe code to set from JAMF variable #8 eg. 123456
WIPE_TEST=${9} # Grab decision to Wipe or Test from JAMF variable #9 eg. WIPE
#
ScriptName="MacOS | Bulk Wipe" # Set the name of the script for later logging
ExitCode=0 # Set Initial ExitCode
#
###############################################################################################################################################
#
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
###############################################################################################################################################
#
# Defining Functions
#
###############################################################################################################################################
#
# Auth Token Function
#
AuthToken (){
#
/bin/echo 'Getting Athentication Token from JAMF'
rawtoken=$(curl -s -u ${apiUser}:${apiPass} -X POST "${apiURL}/uapi/auth/tokens" | grep token) # This Authenticates against the JAMF API with the Provided details and obtains an Authentication Token
rawtoken=${rawtoken%?};
token=$(echo $rawtoken | awk '{print$3}' | cut -d \" -f2)
#
}
#
###############################################################################################################################################
#
# Get Management Account Password Function
#
GetDeviceID (){
#
/bin/echo 'Grabbing Device Serial Number : "'$sernum'"'
jamfdeviceId=$(curl -s -X GET "${apiURL}/JSSResource/computers/serialnumber/$sernum/subset/general" -H 'Authorization: Bearer '$token'' | xpath -e '/computer/general/id/text()' 2>/dev/null )
#
if [ "$jamfdeviceId" == "" ]
	then
		/bin/echo 'Device ID in JAMF for Serial Number: "'$sernum'" Not Found.'
	else
		/bin/echo 'Device ID in JAMF : "'$jamfdeviceId'"'
fi
#
}
#
###############################################################################################################################################
#
# Get Management Account Password Function
#
WipeDevice (){
#
if [ "$WIPE_TEST" == "WIPE" ]
	then
		/bin/echo 'Sending Wipe to Serial Number : "'$sernum'" using JAMF Device ID "'$jamfdeviceId'" wipe code will be "'$WipeCode'"'
		#
response=$( /usr/bin/curl \
--header "Authorization: Bearer $token" \
--header "Content-Type: text/xml" \
--request POST \
--silent \
--url "${apiURL}/JSSResource/computercommands/command/EraseDevice/passcode/$WipeCode/id/${jamfdeviceId}" > /dev/null )
		#
	else
		/bin/echo 'NOT sending Wipe to Serial Number : "'$sernum'" using JAMF Device ID "'$jamfdeviceId'" wipe code would have been "'$WipeCode'"'
fi
#
}
#
###############################################################################################################################################
#
# Section End Function
#
SectionEnd(){
#
/bin/echo # Outputting a Blank Line for Reporting Purposes
/bin/echo  ----------------------------------------------- # Outputting a Dotted Line for Reporting Purposes
/bin/echo # Outputting a Blank Line for Reporting Purposes
#
}
#
###############################################################################################################################################
#
# Script End Function
#
ScriptEnd(){
#
/bin/echo Ending Script '"'$ScriptName'"'
/bin/echo # Outputting a Blank Line for Reporting Purposes
/bin/echo  ----------------------------------------------- # Outputting a Dotted Line for Reporting Purposes
/bin/echo # Outputting a Blank Line for Reporting Purposes
exit $ExitCode
#
}
#
###############################################################################################################################################
#
# End Of Function Definition
#
###############################################################################################################################################
#
# Beginning Processing
#
###############################################################################################################################################
#
/bin/echo # Outputting a Blank Line for Reporting Purposes
SectionEnd
#
/bin/echo 'Processing devices in Tennant "'$apiURL'"'
/bin/echo 'Unsing User name "'$apiUser'"'
SectionEnd
#
AuthToken
SectionEnd
#
for sernum in $DeviceList    
do
	GetDeviceID
	#
	if [ "$jamfdeviceId" != "" ]
		then
			/bin/echo # Outputting a Blank Line for Reporting Purposes
			WipeDevice
			SectionEnd
		else
			SectionEnd
	fi
done
#
#SectionEnd
ScriptEnd
