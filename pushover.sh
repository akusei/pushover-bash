#!/bin/bash

HEADER_CONTENT_TYPE="Content-Type: application/x-www-form-urlencoded"
API_URL="https://api.pushover.net/1/messages.json"
CONFIG_FILE="pushover-config"
DEFAULT_CONFIG="/etc/pushover/${CONFIG_FILE}"
USER_OVERRIDE="${HOME}/.pushover/${CONFIG_FILE}"

showHelp()
{
	script=`basename "$0"`
	echo "Send Pushover v1.0 scripted by Nathan Martini 20150925"
	echo "Push notifications to your Android, iOS, or desktop devices"
	echo
	echo "NOTE: This script requires an account at http://www.pushover.net"
	echo
	echo "usage: ${script} <apikey> <userkey> <message> [options]"
	echo
	echo "  -t,  --token APIKEY        The pushover.net API Key for your application"
	echo "  -u,  --user USERKEY        Your pushover.net user key"
	echo "  -m,  --message MESSAGE     The message to send; supports HTML formatting"
	echo "  -T,  --title TITLE         Title of the message"
	echo "  -d,  --device NAME         Comma seperated list of devices to receive message"
	echo "  -U,  --url URL             URL to send with message"
	echo "       --url-title URLTITLE  Title of the URL"
	echo "  -p,  --priority PRIORITY   Priority of the message"
	echo "                               -2 - no notification/alert"
	echo "                               -1 - quiet notification"
	echo "                                0 - normal priority"
	echo "                                1 - bypass the user's quiet hours"
	echo "                                2 - require confirmation from the user"
	echo "  -s,  --sound SOUND         Notification sound to play with message"
	echo "                               pushover - Pushover (default)"
	echo "                               bike - Bike"
	echo "                               bugle - Bugle"
	echo "                               cashregister - Cash Register"
	echo "                               classical - Classical"
	echo "                               cosmic - Cosmic"
	echo "                               falling - Falling"
	echo "                               gamelan - Gamelan"
	echo "                               incoming - Incoming"
	echo "                               intermission - Intermission"
	echo "                               magic - Magic"
	echo "                               mechanical - Mechanical"
	echo "                               pianobar - Piano Bar"
	echo "                               siren - Siren"
	echo "                               spacealarm - Space Alarm"
	echo "                               tugboat - Tug Boat"
	echo "                               alien - Alien Alarm (long)"
	echo "                               climb - Climb (long)"
	echo "                               persistent - Persistent (long)"
	echo "                               echo - Pushover Echo (long)"
	echo "                               updown - Up Down (long)"
	echo "                               none - None (silent)"
	echo
	echo "EXAMPLES:"
	echo
	echo "  ${script} -t xxxxxxxxxx -u yyyyyyyyyy -m \"This is a test\""
	echo "  Sends a simple \"This is a test\" message to all devices."
	echo
	echo "  ${script} -t xxxxxxxxxx -u yyyyyyyyyy -m \"This is a test\" -T \"Test Title\""
	echo "  Sends a simple \"This is a test\" message with the title \"Test Title\" to all devices."
	echo
	echo "  ${script} -t xxxxxxxxxx -u yyyyyyyyyy -m \"This is a test\" -d \"Phone,Home Desktop\""
	echo "  Sends a simple \"This is a test\" message to the devices named \"Phone\" and \"Home Desktop\"."
	echo
	echo "  ${script} -t xxxxxxxxxx -u yyyyyyyyyy -m \"This is a test\" -U \"http://www.google.com\" --url-title Google"
	echo "  Sends a simple \"This is a test\" message to all devices that contains a link to www.google.com titled \"Google\"."
	echo
	echo "  ${script} -t xxxxxxxxxx -u yyyyyyyyyy -m \"This is a test\" -p 1"
	echo "  Sends a simple \"This is a test\" high priority message to all devices."
	echo
	echo "  ${script} -t xxxxxxxxxx -u yyyyyyyyyy -m \"This is a test\" -s bike"
	echo "  Sends a simple \"This is a test\" message to all devices that uses the sound of a bike bell as the notification sound."
	echo
}

curl --version > /dev/null 2>&1 || { echo "This script requires curl; aborting."; echo; exit 1; }

if [ -f ${DEFAULT_CONFIG} ]; then
	. ${DEFAULT_CONFIG}
fi
if [ -f ${USER_OVERRIDE} ]; then
	. ${USER_OVERRIDE}
fi

while [ $# -gt 0 ]
do

	case "$1" in
	-t|--token)
		api_token="$2"
		shift
		;;
	-u|--user)
		user_key="$2"
		shift
		;;
	-m|--message)
		message="$2"
		shift
		;;
	-T|--title)
		title="$2"
		shift
		;;
	-d|--device)
		device="$2"
		shift
		;;
	-U|--url)
		url="$2"
		shift
		;;
	--url-title)
		url_title="$2"
		shift
		;;
	-p|--priority)
		priority="$2"
		shift
		;;
	-s|--sound)
		sound="$2"
		shift
		;;
	-h|--help)
		showHelp
		exit
		;;
	*)
		;;
	esac

	shift

done

if [ -z "${api_token}" ]; then
	echo "-t|--token must be set"
	exit
fi

if [ -z "${user_key}" ]; then
	echo "-u|--user must be set"
	exit
fi

if [ -z "${message}" ]; then
	echo "-m|--message must be set"
	exit
fi

#json is currently disabled on the server

#json='{"token":"'"$api_token"'","user":"'"$user_key"'","message":"'"$message"'"'
#if [ "$device" ]; then json=${json}',"device":"'"$device"'"'; fi
#if [ "$title" ]; then json=${json}',"title":"'"$title"'"'; fi
#if [ "$url" ]; then json=${json}',"url":"'"$url"'"'; fi
#if [ "$urlTitle" ]; then json=${json}',"url_title":"'"$url_title"'"'; fi
#if [ "$priority" ]; then json=${json}',"priority":'$priority''; fi
#if [ "$sound" ]; then json=${json}',"sound":"'"$sound"'"'; fi
#json="${json}}"

#echo "${json}"
#curl -s -o /dev/null -X POST -H "${HEADER_CONTENT_TYPE}" -d "${json}" "${API_URL}" &> /dev/null

curl -s -o /dev/null -X POST -H "${HEADER_CONTENT_TYPE}" "${API_URL}" \
		--data-urlencode "token=${api_token}" \
		--data-urlencode "user=${user_key}" \
		--data-urlencode "message=${message}" \
		${device:+ --data-urlencode "device=${device}"} \
		${title:+ --data-urlencode "title=${title}"} \
		${url:+ --data-urlencode "url=${url}"} \
		${urlTitle:+ --data-urlencode "url_title=${url_title}"} \
		${priority:+ --data-urlencode "priority=${priority}"} \
		${sound:+ --data-urlencode "sound=${sound}"} > /dev/null 2>&1
