# Firefox wayland -kiosk bug

Firefox v.125 has a bug with 'transparent window' on Wayland.

The fix is to add a user preference:

user_pref("widget.wayland.vsync.enabled", false);

## Firefox profiles

see `~/.mozilla/firefox/profiles.ini`

This will list each profile "name" and the associated folder.

For the "Name=default" folder (e.g. taakdcks.default) add the `user.js` into that folder.

## Starting firefox

```
firefox -P default --noerrdialogs -kiosk -private-window <panel url> <stdout/stderr redirects>
```
