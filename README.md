# Pushover Bash Script
A Bash shell script to send pushover notifications. A [Pushover account](https://pushover.net/) is required to use this script.

## Usage

```
usage: pushover.sh <apikey> <userkey> <message> [options]

  -t,  --token APIKEY        The pushover.net API Key for your application
  -u,  --user USERKEY        Your pushover.net user key
  -m,  --message MESSAGE     The message to send; supports HTML formatting
  -a,  --attachment filename The Picture you want to send
  -T,  --title TITLE         Title of the message
  -d,  --device NAME         Comma seperated list of devices to receive message
  -U,  --url URL             URL to send with message
       --url-title URLTITLE  Title of the URL
  -p,  --priority PRIORITY   Priority of the message
                               -2 - no notification/alert
                               -1 - quiet notification
                                0 - normal priority
                                1 - bypass the user's quiet hours
                                2 - require confirmation from the user
  -e,  --expire SECONDS      Set expiration time for for notifications with priority 2 (default 180)
  -r,  --retry COUNT         Set retry period for notifications with priority 2 (default 30)
  -s,  --sound SOUND         Notification sound to play with message
                               pushover - Pushover (default)
                               bike - Bike
                               bugle - Bugle
                               cashregister - Cash Register
                               classical - Classical
                               cosmic - Cosmic
                               falling - Falling
                               gamelan - Gamelan
                               incoming - Incoming
                               intermission - Intermission
                               magic - Magic
                               mechanical - Mechanical
                               pianobar - Piano Bar
                               siren - Siren
                               spacealarm - Space Alarm
                               tugboat - Tug Boat
                               alien - Alien Alarm (long)
                               climb - Climb (long)
                               persistent - Persistent (long)
                               echo - Pushover Echo (long)
                               updown - Up Down (long)
                               none - None (silent)
```

## Configuration
Configuration files can be placed in **/etc/pushover/pushover-config** or in the user's home directory at **$HOME/.pushover/pushover-config**. The options are processed in order of importance for location.

1) Options in /etc/pushover/pushover-config are processed first
2) Options in $HOME/.pushover/pushover-config are processed next
3) Command line arguments override all configuration values

The default configuration is empty and contains the following:

```
api_token=
user_key=
device=
url=
url_title=
priority=
title=
sound=
```

**NOTE:** If you have a value defined in /etc/default/ and also have overrides in $HOME/.pushover/ all empty options in $HOME/.pushover/ must not exist in the file. For example, I have the following configuration in /etc/default/

```
api_token=my-app-api-token
user_key=my-user-key
device=
url=
url_title="I want all URLs to have this title"
priority=
title="this is a generic title"
sound=
```

If I want to override only **title** for a specific user, the configuration in $HOME/.pushover/ will look like this

```
title="title for specific user"
```

## Support
For PHP Composer based projects, see [COMPOSER.md](COMPOSER.md)

## Examples
Send a simple "This is a test" message to all devices using the stored configuration in either **/etc/default/pushover-config** or **$HOME/.pushover/pushover-config**

```
pushover.sh -m "This is a test"
```

Send a simple "This is a test" message to all devices using the specified API token and user key

```
pushover.sh -t token -u key -m "This is a test"
```

Send a simple "This is a test" message with the title "Test Title" to all devices using the specified API token and user key

```
pushover.sh -t token -u key -m "This is a test" -T "Test Title"
```

Send a simple "This is a test" message to the devices named "Phone" and "Home Desktop" using the specified API token and user key

```
pushover.sh -t token -u key -m "This is a test" -d "Phone,Home Desktop"
```

Send a simple "This is a test" message to all devices that contains a link to www.google.com titled "Google" using the specified API token and user key

```
pushover.sh -t token -u key -m "This is a test" -U "http://www.google.com" --url-title Google
```

Send a simple "This is a test" high priority message to all devices using the specified API token and user key

```
pushover.sh -t token -u key -m "This is a test" -p 1
```

Send a simple "This is a test" message to all devices that uses the sound of a bike bell as the notification sound using the specified API token and user key

```
pushover.sh -t token -u key -m "This is a test" -s bike
```

Sends a simple "This is a test Pic" message to all devices and send the Picture with the message

```
pushover.sh -t token -u key -m "This is a test Pic" -a /path/to/pic.jpg
```
