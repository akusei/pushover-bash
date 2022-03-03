#!/usr/bin/env bash

set -o errexit
set -o nounset

readonly API_URL="https://api.pushover.net/1/messages.json"
readonly CONFIG_FILE="pushover-config"
readonly DEFAULT_CONFIG="/etc/pushover/${CONFIG_FILE}"
readonly USER_OVERRIDE=~/.pushover/${CONFIG_FILE}
readonly EXPIRE_DEFAULT=180
readonly RETRY_DEFAULT=30
HIDE_REPLY=true

showHelp()
{
        local script=`basename "$0"`
        echo "Send Pushover v1.2 scripted by Nathan Martini"
        echo "Push notifications to your Android, iOS, or desktop devices"
        echo
        echo "NOTE: This script requires an account at http://www.pushover.net"
        echo
        echo "usage: ${script} <-t|--token apikey> <-u|--user userkey> <-m|--message message> [options]"
        echo
        echo "  -t,  --token APIKEY        The pushover.net API Key for your application"
        echo "  -u,  --user USERKEY        Your pushover.net user key"
        echo "  -m,  --message MESSAGE     The message to send; supports HTML formatting"
        echo "  -a,  --attachment filename The Picture you want to send"
        echo "  -T,  --title TITLE         Title of the message"
        echo "  -d,  --device NAME         Comma seperated list of devices to receive message"
        echo "  -U,  --url URL             URL to send with message"
        echo "       --url-title URLTITLE  Title of the URL"
        echo "  -H,  --html                Enable HTML formatting, cannot be used with the --monospace flag"
        echo "  -M,  --monospace           Enable monospace messages, cannot be used with the --html flag"
        echo "  -p,  --priority PRIORITY   Priority of the message"
        echo "                               -2 - no notification/alert"
        echo "                               -1 - quiet notification"
        echo "                                0 - normal priority"
        echo "                                1 - bypass the user's quiet hours"
        echo "                                2 - require confirmation from the user"
        echo "  -e,  --expire SECONDS      Set expiration time for notifications with priority 2 (default ${EXPIRE_DEFAULT})"
        echo "  -r,  --retry COUNT         Set retry period for notifications with priority 2 (default ${RETRY_DEFAULT})"
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
        echo "  -v,  --verbose             Return API execution reply to stdout"
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
        echo "  ${script} -t xxxxxxxxxx -u yyyyyyyyyy -m \"This is a test Pic\" -a /path/to/pic.jpg"
        echo "  Sends a simple \"This is a test Pic\" message to all devices and send the Picture with the message."
        echo
}

curl --version > /dev/null 2>&1 || { echo "This script requires curl; aborting."; echo; exit 1; }

if [ -f ${DEFAULT_CONFIG} ]; then
  source ${DEFAULT_CONFIG}
fi
if [ -f ${USER_OVERRIDE} ]; then
  source ${USER_OVERRIDE}
fi

while [ $# -gt 0 ]
do
  case "${1:-}" in
    -t|--token)
      api_token="${2:-}"
      shift
      ;;

    -u|--user)
      user_key="${2:-}"
      shift
      ;;

    -m|--message)
      message="${2:-}"
      shift
      ;;

    -a|--attachment)
      attachment="${2:-}"
      shift
      ;;

    -T|--title)
      title="${2:-}"
      shift
      ;;

    -d|--device)
      device="${2:-}"
      shift
      ;;

    -U|--url)
      url="${2:-}"
      shift
      ;;

    --url-title)
      url_title="${2:-}"
      shift
      ;;

    -H|--html)
      html=1
      ;;

    -M|--monospace)
      monospace=1
      ;;

    -p|--priority)
      priority="${2:-}"
      shift
      ;;

    -s|--sound)
      sound="${2:-}"
      shift
      ;;

    -e|--expire)
      expire="${2:-}"
      shift
      ;;

    -r|--retry)
      retry="${2:-}"
      shift
      ;;

    -v|--verbose)
      unset HIDE_REPLY
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

if [ ${priority:-0} -eq 2 ]; then
  if [ -z "${expire:-}" ]; then
    expire=${EXPIRE_DEFAULT}
  fi
  if [ -z "${retry:-}" ]; then
    retry=${RETRY_DEFAULT}
  fi
fi

if [ -z "${api_token:-}" ]; then
  echo "-t|--token must be set"
  exit 1
fi

if [ -z "${user_key:-}" ]; then
  echo "-u|--user must be set"
  exit 1
fi

if [ -z "${message:-}" ]; then
  echo "-m|--message must be set"
  exit 1
fi

if [ ! -z "${html:-}" ] && [ ! -z "${monospace:-}" ]; then
  echo "--html and --monospace are mutually exclusive"
  exit 1
fi

if [ ! -z "${attachment:-}" ] && [ ! -f "${attachment}" ]; then
  echo "${attachment} not found"
  exit 1
fi

if [ -z "${attachment:-}" ]; then
  json="{\"token\":\"${api_token}\",\"user\":\"${user_key}\",\"message\":\"${message}\""
  if [ "${device:-}" ]; then json="${json},\"device\":\"${device}\""; fi
  if [ "${title:-}" ]; then json="${json},\"title\":\"${title}\""; fi
  if [ "${url:-}" ]; then json="${json},\"url\":\"${url}\""; fi
  if [ "${url_title:-}" ]; then json="${json},\"url_title\":\"${url_title}\""; fi
  if [ "${html:-}" ]; then json="${json},\"html\":1"; fi
  if [ "${monospace:-}" ]; then json="${json},\"monospace\":1"; fi
  if [ "${priority:-}" ]; then json="${json},\"priority\":${priority}"; fi
  if [ "${expire:-}" ]; then json="${json},\"expire\":${expire}"; fi
  if [ "${retry:-}" ]; then json="${json},\"retry\":${retry}"; fi
  if [ "${sound:-}" ]; then json="${json},\"sound\":\"${sound}\""; fi
  json="${json}}"

  curl -s ${HIDE_REPLY:+ -o /dev/null} \
    -H "Content-Type: application/json" \
    -d "${json}" \
    "${API_URL}" 2>&1
else
  curl -s ${HIDE_REPLY:+ -o /dev/null} \
    --form-string "token=${api_token}" \
    --form-string "user=${user_key}" \
    --form-string "message=${message}" \
    --form "attachment=@${attachment}" \
    ${html:+ --form-string "html=1"} \
    ${monospace:+ --form-string "monospace=1"} \
    ${priority:+ --form-string "priority=${priority}"} \
    ${sound:+ --form-string "sound=${sound}"} \
    ${device:+ --form-string "device=${device}"} \
    ${title:+ --form-string "title=${title}"} \
    "${API_URL}" 2>&1
fi
