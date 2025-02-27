# Raspberry Pi Kiosk configuration

# Install instructions for Pi OS "bookworm" (2023)

Correct the user 'ijl20' in `crontab`, `run.sh` and `.config/wayfire.sh` as needed.
```
mkdir src
cd src
git clone https://github.com/SmartCambridge/raspberry_pi_kiosk
cp raspberry_pi_kiosk/settime.sh ~
cp raspberry_pi_kiosk/run_firefox.sh ~/run.sh
cd ~
sudo apt install vim
```

See further notes on firefox at https://github.com/SmartCambridge/raspberry_pi_kiosk/firefox

Edit run.sh to fix the home directory names and the web address to be loaded.

Create crontab entries for SUDO user:
```
sudo crontab -e
```
To reboot early every morning (here 05:09) , and sync clock via http, add:
```
09 05 * * *  /usr/sbin/shutdown -r now

*/13 * * * * /home/ijl20/settime.sh
```

`settime.sh` is a simple script that 'get's a web page and syncs the clock to the time found in the response header. This is
accurate enough for the browser to function properly without needing the network to route anything other than http/https.

Have the browser launch your web page in 'kiosk' mode on startup (after GUI has loaded):
```
vim .config/wayfire.ini
```
Add:
```
[autostart]
test = touch /home/ijl20/boot_timestamp
smartpanel = /home/ijl20/run.sh
```

# General instructions

This development assumes the use of a Raspberry Pi, a superb platform that emerged from the University of Cambridge. This
guide is actually a side-effect of the Cambridge SmartPanel development, also from the University of Cambridge.

The Raspberry Pi makes an excellent (low cost & inconspicuous) controller for a public display screen, with the
screen often being an HDMI-connected 1920x1080 TV. In due course 4K will probably be the expected resolution and
these instructions will be broadly similar.

This README isn't about the basics of how to build/configure a Raspberry Pi from scratch, i.e. it assumes you
start with a working Pi with the Raspbian OS installed, you've worked out the magic key sequence of
Ctrl-Alt-T to open a 'command terminal' window and you know how to edit files (at least with 'nano'). If you really are
a Pi noob, see [here](https://www.raspberrypi.org/documentation/installation/noobs.md).

This guide, originally written for the
[Cambridge SmartPanel](https://smartcambridge.org/csn/forum/forum/smartpanel-3/topic/about-the-cambridge-smartpanel-34/),
assumes the ultimate objective is to 'boot' the Pi and launch chromium-browser to display a web page.
_All_ the smarts in the display are provided by the javascript over the web, so dependencies on the kiosk
implementation are absolutely at a minimum. Essentially we need the kiosk to:

* display on an HD TV without cropping, overscanning, underscanning or otherwise adjusting the display
* reboot periodically at some selected time (typically early in the morning)
* get a network connection
* initialize the Pi clock with a reasonably accurate time (the Pi forgets the time on each shutdown)
* reliably launch chromium-browser without the usual menus and 'human-centered' dialogs ('would you like to reload
your previous tabs')
* load a chosen web page into the browser on start up

Each of those things listed above is actually harder than it sounds (otherwise I wouldn't have bothered
mentioning them) and considerable detail is provided below to address each of those challenges.

For our purposes the Cambridge Smartpanel is a web page that has a supporting web-based configuration process and the
actual page loaded will periodically check back with the web server for new content or an updated configuration.

## Getting started

Perhaps using the [NOOBS reference](https://www.raspberrypi.org/documentation/installation/noobs.md), install the
Raspbian Operating System on your Pi. Follow the instructions to:

* download the 'NOOBS' software
* copy the software to an otherwise blank FAT32-formatted micro-SD card
* install the micro SD card in your Pi
* power it up
* follow the prompts, including to 'update the software'.

The above can take half-an-hour, mainly downloading software from the internet.

You should reach the point where the Pi has a supportive and empowering desktop image, and Ctrl-Alt-T will open a terminal
window.  You can close a terminal window with Ctrl-D, or at the '$' command prompt enter `shutdown -r now` to reboot the Pi.

Note that *nothing* in this guide installs anything other than via your editing of various configuration files (e.g. setting
your crontab to periodically auto-reboot). This is a major plus so you know exactly how this kiosk config actually works, but
perhaps has the downside that it's no a one-click install.

### Download the Cambridge configuration files

In a command window, type
```
git clone https://github.com/SmartCambridge/raspberry_pi_kiosk
```

You now have a `raspberry_pi_kiosk` directory (typically `/home/pi/raspberry_pi_kiosk`) containing exactly the files you're
browsing now in this GIT repo. For example, the directory will contain `raspberry_pi_kiosk/1920x1080_test.jpg` which is
about to become your Pi desktop background image...

## Overview

The idea is to use a Raspberry Pi to boot and auto-display the browser accessing the
pre-coded URL for the SmartPanel.

There are two main steps:
* Configure the Pi and the TV to display an image at the right resolution, i.e. 1920x1080. This is
slightly harder than it sounds as TV manufacturers make an art form of auto-adjusting the
displayed picture to compensate for the foibles of c. 1980's analogue TV transmissions.
* Set the Pi up to auto-boot into displaying the browser in 'fullscreen' mode, displaying the web
page of interest. The Pi is also configured to auto-reboot in the early hours of each morning.

## Get the Pi/TV combo to display an un-adjusted 1920x1080 image.

The first time you see the Pi display to the TV, unless you are very lucky the TV picture will
crop the edges of the full Pi desktop display.

Basically we need to persuade the TV to just display the 1920x1080 content from the Pi, no
overscan, no smoothing the pixels etc. By default, the TV will overscan, i.e. actually display
a smaller resolution image taken from the center of the content and you will see the edges of
intended content cut off. Unfortunately, getting the TV *not* to mess with the picture usually
involves a bit of trial-and-error. Any of these suggestions below might work.

### Set Pi desktop image to a 1920x1080 test image

Unless you chose something else, our test background image is at `/home/pi/raspberry_pi_kiosk/1920x1080_test.jpg`.

Below you can see the full image scaled to fit your window, so note it has an alternating black-and-white border.
This border is likely to disappear off the edge of your TV until you correct various display settings in both the Pi
and the TV.

![TV test image](1920x1080_test.jpg "Test TV image")

Set it as the Pi desktop image by right-clicking the desktop and choosing
'Desktop Preferences' then on the first tab ('Desktop') set
the 'Layout' to 'Center Image on Screen' and for 'Picture' choose the downloaded image.
It is *essential* you use the
Layout option 'Center image on screen' to place the test image in the center of the screen without scaling
(the point is to get an *unscaled* image to check the TV resolution...).

### Set the Pi screen resolution to 1920x1080

Click on the Application Menu (the Raspberry top-left of the destop), then Preferences, then
Raspberry Pi Configuration.

On the 'Resolution' option click the button 'Set Resolution' and select to use the `1920x1080 at 50Hz`.

Underneath the 'Resolution' option is one labelled 'Underscan'.  Set that to `Disabled`.

After you've hit OK a couple of times you will exit the Preferences window and be prompted to accept a
reboot. Select OK.

### Have the Pi desktop top taskbar auto-hide

Right-click the _taskbar_ at the top of the screen.  Choose 'Panel Settings' then on the 'Advanced' tab
under 'Automatic Hiding' set the checkbox 'Minimise panel when not in use' and set 'Size when minimised'
to 2 pixels. This will auto-hide the top menu bar with a 2-pixel 'hidden
size' so it should disappear but you can get it back by moving the mouse to the top
of the screen.

### You may need to mess with the *Pi* display overscan settings via the Pi 'sudo raspi-config' command

In the Raspberry Pi ```sudo raspi-config``` command, you can force overscan to 'disabled' in
the Advanced .. Overscan menu option. With a bit of luck you won't need this but if you've got this
far and the TV is still cropping the desktop it's worth a try.

At this point, if you still have a 'cropping' issue, the problem is almost certainly with the settings
on the TV, covered in the next section.  E.g. you can try the TV 'Picture Mode'..'Fill Screen' or other similar options.

If you are *really* desperate, you can edit the Raspberry Pi ```config.txt``` file (see Google) where you
have pixel-level 'overscan' adjustments where you can tell the Pi how to adjust its output to compensate for
the unhelpful adjustments being made by the TV. This should be considered a massive bodge though, and it's
better to persuade the TV not to mangle the picture in the first place.

### The HDMI input 'renaming' trick, via the TV remote control

This is far-and-away the biggest gotcha that causes most people to pull their hair our trying to get their
TV to simply leave the input alone and display the full 1920x1080 resolution without a crop...

If possible, rename the HDMI input the Raspberry Pi is connected to (yes, I'm serious).
On Samsung TV's you can do this by clicking the 'Source' button which brings up a list of
HDMI inputs, and then if you hit the 'Tools' button you will get a 'Rename' option.  Rename the
input to "PC".

### Other TV remote control options that allow full-HD display

1. On the TV, go to 'Settings'..'Picture'..'Picture Mode' which defaults to 'Standard', and change it to
'Entertainment'.
2. In 'Settings'..'Picture'..'Picture Size' choose 16:9. Another option may be 'Fit Picture' which works,
but may be grayed-out as a result of using option 1 above (which is generally a good sign).
3. Note the TV remote (e.g. Hitachi) may **also** have a dedicated button that sets the screen format,
from widescreen, to PC, to 3:4 or whatever. So give that a prod.  This may only work until the next
power-off of the TV though...

### Turn off TV power-saving modes

Via the TV remote, just go into whatever TV menu 'Eco' or 'Timer' modes you can find and disable the auto-screen-blanking.

### Test you got the TV setup right

1. Put the ```shutdown -r now``` command into a terminal (open with Ctrl-Alt-T) but do *not* hit enter yet.
2. Power off the TV at the mains.
3. Hit the enter key, so the Pi shuts down and restarts *while the TV is off*.
4. After a delay, so you're sure the Pi has finished rebooting into kiosk-mode, power the TV back on.
5. Check the 1920x1080 desktop background accurately fills the TV screen.

## Configure the Raspberry Pi to work as an effective 'kiosk' web-page display

### Install ntp (so the Pi has a corrected clock)

Open a terminal with Ctrl-Alt-T.

Enter the command:
```
sudo apt install ntp
```
Type 'Y', <return> if/when prompted.

### Disable screen blanking (i.e. no energy saving)

Basic method here is to _install_ a screensaver, and then set its options to 'Disabled'.  This is the
most reliable way to override the various historical methods the Pi has accumulated to mess with the screen
if no-one has interacted with it for a while.

In the terminal window,

```
sudo apt install xscreensaver
```
Again, hit 'Y' to confirm install.

After install is complete, in the terminal window do a reboot with
```
shutdown -r now
```

After reboot, click the Raspberry in the top-left corner of the screen, go into 'Preferences', an
you will see a (new) option 'Screensaver'.

Select this 'Screensaver' option, you will see the default setting is for some hideous random triangles, and
change the option to 'Disabled'.

### Copy run.sh and settime.sh into the /home/pi directory

You can either use the Pi graphical file manager app to copy the files, or from the command line:
```
cp raspberry_pi_kiosk/run.sh .
cp raspberry_pi_kiosk/settime.sh .
chmod +x run.sh
chmod +x settime.sh
```

The `settime.sh` command will repeatedly attempt to retrieve a page from
the smartcambridge.org web server (feel free to edit the file to use any other web server)
and use the returned server timestamp to set the Pi clock.

Test settime.sh manually on the command line with:
```
./settime.sh
```
You will see the current time (retrieved from the web server) displayed on the terminal.
The advantages of using this script are:

1. The ```settime.sh``` script won't exit until it has successfully connected to smartcambridge.org, so delaying
the launch of the web browser until the network is known to be ok, and
2. The ```settime.sh``` script picks up the *time* from smartcambridge.org and uses that to initialize
the Raspberry Pi clock. The Pi has no battery to back up its system clock and this can lead to
a variety of perverse system behaviour due to it believing a random date or time.
3. From an earlier step we installed the standard `ntp` time-synchronizing software but this may be blocked
by your firewall and so not work, while the `settime.sh` script purely uses a 'get' of a web page which should
get through any firewall ok (but the time won't be accurate to the millisecond).

### Edit the run.sh script to load the webpage you want

The run.sh script contains commands to set the time on the Pi via settime.sh, and then runs the
chromium browser with the command:

```
@chromium-browser --noerrdialogs --incognito --kiosk http://smartcambridge.org/smartpanel/display/<display_id> &
```

For your purpose, you will edit this file replacing the http://... web address with the one you want, via:
```
nano run.sh
```

Note if you want to change the scale of the displayed web page, you can add an additional startup
flag to chromium-browser e.g. to double the scale of the displayed page: ```--force-device-scale-factor 2```

### Add autostart rules to avoid screensaving and launch browser

We need to tell the Pi to execute the program `run.sh` at startup (as well as set up some screensaver-blocking commands), and
we do this by editting the file `/home/pi/.config/lxsession/LXDE-pi/autostart`.  Just leave unchanged any lines already in that file, *with the exception of adding the `#` before the `@screensaver` entry.
```
sudo nano ~/.config/lxsession/LXDE-pi/autostart
```

You should end up with these commands in the file, in addition to whatever your latest version of Raspbian put in there.

```
#@xscreensaver -no-splash
@xset s off
@xset -dpms
@xset s noblank

@/home/pi/run.sh
```
### Portrait mode

Edit `/boot/config.txt` (e.g. `sudo nano /boot/config.txt`).

Add line:
```
# smartpanel Portrait mode
display_rotate=1
```
Note this will rotate the display 90 degrees (i.e. clockwise).  If this is the 'wrong' way for your your actual monitor
then use `display_rotate=3` which will rotate 270 degrees.

### Miscellaneous raspi-config settings

You should make final changes to the `raspi-config` settings, and check others with:

```
sudo raspi-config
```

In `Boot Options` choose `Desktop/CLI`
In the new menu that appears, choose `Desktop Autologin Desktop GUI`

In `Network` set `Hostname` to any string hostname of your choice (lower case, no spaces).

Also now is a good time to check `Advanced` `Overscan` and `Screen Resolution` settings to make sure overscan is disabled
and the screen is still set for 1920x1080.

In localization options you can set appropriate language, timezone and WiFi country although this isn't usually critical.

## Set the Pi to reboot every morning, and regularly update the time

e.g. restart every day at 06:27 am

Via a command terminal:

```
sudo crontab -e
```
```
27 06 * * * /sbin/shutdown -r now

*/9 * * * * /home/pi/settime.sh
```

The first command will reboot the Pi at 06:27 every morning.

The second command will call the `settime.sh` script every 9 minutes.

# Well done

In a terminal window, type `shutdown -r now` and the Pi will reboot, loading your webpage after a short delay.

In 'kiosk-mode' displaying a web page, note the browser will not respond to 'exit' keys.
To access the Pi you should Ctrl-Alt-T to a command window, and type the command `killall chromium-browser`.

If your web page does *not* load,

1. first check `/home/pi/run.log` and look for clues there.
2. try `./run.sh` on the command line, it should launch the browser
3. type `nano ~/.config/lxsession/LXDE-pi/autostart` and check that looks ok
4. type `sudo crontab -e` and check that looks ok


