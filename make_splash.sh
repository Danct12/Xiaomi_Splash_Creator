#!/usr/bin/env bash

: '
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
'

## Config
VERSION=0.1
RESOLUTION=720x1280 # redmi 4x display resolution
SPLASH_SCREEN_HEADER=/tmp/splash_screen_header
SPLASH_HEADER="U1BMQVNIISHQAgAAAAUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

## Don't touch these
FASTBOOT_IMAGE=
BOOT_IMAGE=
UNLOCKED_IMAGE=
OUTPUT_FILE=

function version_message() {
	echo "Xiaomi Splash Creator - Version $VERSION"
	echo "Copyright (C) 2019 - Danct12"
	echo 
	echo "This software is licensed under:"
	echo "GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>"
	echo
	echo "This is free software; you are free to change and redistribute it."
	echo "There is NO WARRANTY, to the extent permitted by law."
}

function short_message() {
	echo "Xiaomi Splash Creator - Version $VERSION"
	echo "Copyright (C) 2019 - Danct12"
	echo
}

function help_usage() {
	echo "USAGE: $0 -b boot_image.png -u unlocked_bl.png -f fastboot.png -o splash.img"
	echo
	echo "-b : Boot splash image, the splash that shows the MI logo."
	echo "-f : Fastboot splash image"
	echo "-u : Unlocked bootloader image, which shows if you got the bootloader unlocked."
	echo "-o : Output of the splash image."
}

function extract_splash_header() {
	echo "INFO: Extracting the splash header..."
	echo $SPLASH_HEADER | base64 -d > $SPLASH_SCREEN_HEADER
	if [ ! -f "$SPLASH_SCREEN_HEADER" ]; then
		echo -e "\e[41m\e[5mERROR:\e[25m\e[49m $SPLASH_SCREEN_HEADER doesn't exist\!"
		echo "Is access to the directory read/write to the user you're running this script on? Exiting..."
		exit 1
	fi
}

function convert_to_raw() {
	echo "INFO: Converting images to RAW format."
	if [ -x "$(command -v ffmpeg)" ]; then
		mkdir .splash_output
		# We'll hide all those log messages, and only show if the thing panic'd.
		ffmpeg -hide_banner -loglevel panic -i $BOOT_IMAGE -f rawvideo -vcodec rawvideo -pix_fmt bgr24 -s $RESOLUTION -y ".splash_output/bootsplash.raw"
		ffmpeg -hide_banner -loglevel panic -i $FASTBOOT_IMAGE -f rawvideo -vcodec rawvideo -pix_fmt bgr24 -s $RESOLUTION -y ".splash_output/fastbootsplash.raw"
		ffmpeg -hide_banner -loglevel panic -i $UNLOCKED_IMAGE -f rawvideo -vcodec rawvideo -pix_fmt bgr24 -s $RESOLUTION -y ".splash_output/unlockedsplash.raw"
	else
		echo -e "\e[41m\e[5mERROR:\e[25m\e[49m FFmpeg is not installed or errored!"
		echo "Make sure you have FFmpeg installed, or path to FFmpeg added to envpath."
		exit 1
	fi
}

function create_splash() {
	echo "INFO: Joining splashes to a fastboot flashable image..."
	if cat $SPLASH_SCREEN_HEADER .splash_output/bootsplash.raw \
		$SPLASH_SCREEN_HEADER .splash_output/fastbootsplash.raw \
		$SPLASH_SCREEN_HEADER .splash_output/unlockedsplash.raw > $OUTPUT_FILE ; then
		echo -e "\e[1m\e[32mDone!\e[39m\e[0m You're ready to flash your newly created splash image!"
		echo "Your splash image is in $OUTPUT_FILE"
		echo
		echo -e "To flash the image, boot your device to fastboot and run \e[92m'fastboot flash splash $OUTPUT_FILE'\e[39m\e[0m"
	else
		echo -e "\e[41m\e[5mERROR:\e[25m\e[49m Joining splashes failed!"
		echo "Is the directory the output file be created is writable?"
		echo
		housekeeping && rm $OUTPUT_FILE
		exit 1
	fi
}

function housekeeping() {
	echo "INFO: Cleaning up temporary files..."
	rm -rf .splash_output
}

for ((i = 1; i < ($#+1); i++)); do
    case "${!i}" in
	-f|--fastboot)
		((++i))
		FASTBOOT_IMAGE="${!i}"
        ;;
	-b|--boot)
		((++i))
		BOOT_IMAGE="${!i}"
        ;;
	-u|--unlocked)
		((++i))
		UNLOCKED_IMAGE="${!i}"
        ;;
	-o|--output)
		((++i))
		OUTPUT_FILE="${!i}"
        ;;
	-v|--version)
		version_message
		exit 0
		;;
	-h|--help)
		help_usage
		exit 0
		;;
    esac
done

if [[ $FASTBOOT_IMAGE && $BOOT_IMAGE && $UNLOCKED_IMAGE && $OUTPUT_FILE ]]; then
	short_message
	echo "DEBUG: Chosen fastboot splash image: $FASTBOOT_IMAGE"
	echo "DEBUG: Chosen boot splash image: $BOOT_IMAGE"
	echo "DEBUG: Chosen bootloader unlocked splash image: $UNLOCKED_IMAGE"
	echo
	extract_splash_header
	convert_to_raw
	create_splash
	housekeeping
	exit 0
else
	short_message
	help_usage
fi
