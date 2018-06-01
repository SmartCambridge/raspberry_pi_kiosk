# Raspberry Pi 'Kiosk' configuration

## Overview

The idea is to use a Raspberry Pi to boot and auto-display the browser accessing the 
pre-coded URL for the SmartPanel.

There are two main steps:
* Configure the Pi and the TV to display an image at the right resolution, i.e. 1920x1080. This is
slightly harder than it sounds as TV manufacturers make an art form of auto-adjusting the 
displayed picture to compensate for the foibles of c. 1980's analogue TV transmissions.
* Set the Pi up to auto-boot into displaying the browser in 'fullscreen' mode, displaying the web
page of interest. The Pi is also configured to auto-reboot in the early hours of each morning.

The URL will be of the for http://smartcambridge.org/smartpanel/<display_id>

## Step 1. Get the Pi/TV combo to display an un-adjusted 1920x1080 image.

The first time you see the Pi display to the TV, unless you are very lucky the TV picture will
crop the edges of the full Pi desktop display.

Basically we need to persuade the TV to just display the 1920x1080 content from the Pi, no
overscan, no smoothing the pixels etc. By default, the TV will overscan, i.e. actually display
a smaller resolution image taken from the center of the content and you will see the edges of
intended content cut off. Unfortunately, getting the TV *not* to mess with the picture usually
involves a bit of trial-and-error. Any of these suggestions below might work.

### Set Pi desktop image to a 1920x1080 test image

First of all, download the 1920x1080_test.jpg image in this folder to the Pi. It doesn't really matter where you
download it to but (home)/Pictures should make it easy to find for the next step.

Below you can see the full image scaled to fit your window, so note it has an alternating black-and-white border.
This border is likely to disappear off the edge of your TV until you correct various display settings in both the Pi
and the TV.

![TV test image](1920x1080_test.jpg "Test TV image")

Set it as the
Pi desktop image by right-clicking the desktop and choosing 'Desktop Preferences' then on the first tab ('Desktop') set
the 'Layout' to 'Center Image on Screen' and for 'Picture' choose the downloaded image. 
It is *essential* you use the 
Layout option 'Center image on screen' to place the test image in the center of the screen without scaling 
(the point is to get an *unscaled* image to check the TV resolution...).

### Set the Pi screen resolution to 1920x1080

Click on the Application Menu (the Raspberry top-left of the destop), then Preferences, then
Raspberry Pi Configuration.

On the 'Resolution' option click the button 'Set Resolution' and select to use the ```1920x1080 at 50Hz```

### Have the Pi desktop top taskbar auto-hide

Right-click the taskbar at the top of the screen.  Choose 'Panel Preferences' then on the 'Advanced' tab
under 'Automatic Hiding' set the checkbox 'Minimise panel when not in use' and set 'Size when minimised'
to 2 pixels. This will auto-hide the top menu bar with a 2-pixel 'hidden
size' so it should disappear but you can get it back by moving the mouse to the top
of the screen.

### You may need to mess with the *Pi* display overscan settings

In the Raspberry Pi ```sudo raspi-config``` command, you can force overscan to 'disabled' in
the Advanced .. Overscan menu option. With a bit of luck you won't need this but if you've got this
far and the TV is still cropping the desktop it's worth a try.

At this point, if you still have a 'cropping' issue, the problem is almost certainly with the settings
on the TV, covered in the next section.  E.g. you can try the TV 'Picture Mode'..'Fill Screen' or other similar options.

If you are *really* desperate, you can edit the Raspberry Pi ```config.txt``` file (see Google) where you
have pixel-level 'overscan' adjustments where you can tell the Pi how to adjust its output to compensate for
the unhelpful adjustments being made by the TV. This should be considered a massive bodge though, and it's
better to persuade the TV not to mangle the picture in the first place.

### Use TV remote to alter picture settings to remove overscanning

1. If possible, rename the HDMI input the Raspberry Pi is connected to (yes, I'm serious).
On Samsung TV's you can do this by clicking the 'Source' button which brings up a list of
HDMI inputs, and then if you hit the 'Tools' button you will get a 'Rename' option.  Rename the
input to "PC".
2. On the TV, go to 'Settings'..'Picture'..'Picture Mode' which defaults to 'Standard', and change it to
'Entertainment'.
3. In 'Settings'..'Picture'..'Picture Size' choose 16:9. Another option may be 'Fit Picture' which works,
but may be grayed-out as a result of using option 1 above (which is generally a good sign).

### Turn off TV power-saving modes

Just go into whatever TV 'Eco' or 'Timer' modes you can find and disable the auto-screen-blanking.

### Test you got the TV setup right

1. Put the ```shutdown -r now``` command into a terminal but do *not* hit enter.
2. Power off the TV at the mains.
3. Hit the enter key, so the Pi shuts down and restarts *while the TV is off*.
4. After a delay, so you're sure the Pi has finished rebooting into kiosk-mode, power the TV back on.
5. Check the 1920x1080 desktop background accurately fills the TV screen.

## Step 2. Configure the Raspberry Pi to work as an effective 'kiosk' web-page display

### Install ntp (so the Pi has a corrected clock)
Enter the command:
```sudo apt install ntp```

### Disable screen blanking (i.e. no energy saving)

```
sudo apt install xscreensaver
```
Launch screensaver on desktop and select option to DISABLE screen saving

### Add autostart rules to avoid screensaving and launch browser
```
sudo nano ~/.config/lxsession/LXDE-pi/autostart
```

Add comment to `screensaver` launch command
```
#@screensaver -no-splash
```
Add additional 'no screensaving' commands
```
@xset s off
@xset -dpms
@xset s noblank
```
Add command to persude Chrome it had a clean exit and re-launch cromium-browser. The 'sed' command
and the --incognito switch to chromium-browser are both designed to prevent the browser launching with
an unhelpful 'user message' which then prevents normal startup, particularly the 'Chrome closed unexpectedly,
would you like to re-open old tabs'.

Note if you want to change the scale of the displayed web page, you can add an additional startup
flag to chromium-browser e.g. to double the scale of the displayed page: ```--force-device-scale-factor 2```

```
@sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' ~/.config/chromium/Default/Preferences

@chromium-browser --noerrdialogs --incognito --kiosk http://smartcambridge.org/smartpanel/display/<display_id>
```
So total changes to ```~/.config/lxsession/LXDE-pi/autostart``` are

```
#@screensaver -no-splash
@xset s off
@xset -dpms
@xset s noblank

@sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' ~/.config/chromium/Default/Preferences

@chromium-browser --noerrdialogs --incognito --kiosk http://smartcambridge.org/smartpanel/<display_id>
```

### Miscellaneous raspi-config settings

```
sudo raspi-config
```

Set boot behaviour to 'desktop' (not tty)

In localization options set appropriate language, timezone and WiFi country.

## Create a cron job to reboot the screen every morning

e.g. at 06:27 am

Don't forget the 'sudo' to ensure 'root' crontab, not pi user...
```
sudo crontab -e
```
```
27 06 * * * /sbin/shutdown -r now
```

