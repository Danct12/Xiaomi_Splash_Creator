# Xiaomi Splash Creator

**THIS TOOL HAS ONLY BEEN TESTED ON REDMI 4X, AS IT'S THE ONLY XIAOMI DEVICE I HAD.**

```
Your warranty is now being voided.

I'll still not take responsible for:
- Bricked devices
- French Toast'd SD Cards
- Alarm clock failed and you're getting fired
..and much more after using this tool.
```

## What is `Xiaomi Splash Creator`?
This is a utility for *NIX/*NIX-like systems to create custom splash screens (the ones that shows before Android loaded)

So far, this tool has only tested on my desktop computer running Arch Linux, but it should work perfectly fine on other systems, including macOS.

## How do I use it?
- Backup your original splash image (can be done through TWRP or just dd)
- Type `--help` on the script as parameter:
```
USAGE: ./make_splash.sh -b boot_image.png -u unlocked_bl.png -f fastboot.png -o splash.img

-b : Boot splash image, the splash that shows the MI logo.
-f : Fastboot splash image
-u : Unlocked bootloader image, which shows if you got the bootloader unlocked.
-o : Output of the splash image.
```

## How to install my new splash?
- Reboot to fastboot (Volume Down + Power)
- Type `fastboot flash splash new_splash.img`. Replace `new_splash.img` as the output to the new splash file.
- Type `fastboot reboot` and enjoy.
