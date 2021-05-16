# Scripts
## ./status.sh _A FreeBSD Statusbar customised for thinkpad t480_

Very simple statusbar script which displays the used memory, battery %, state and time remaining (this script is t480 specific in that it takes the battery values from both the internal and removable battery).

## ./acpi_brightness_control.sh

Use with your window manager, set the brightness keys (in my case 0x10, 0x11) in /etc/sysctl.conf:
```
dev.acpi_ibm.0.handlerevents=0x10\ 0x11
```
To use these brightness keys, create /etc/devd/acpi_brightness.conf:
```
# /etc/devd/acpi_brightness.conf
notify 20 {
 match "system" "ACPI";
 match "subsystem" "IBM";
 match "notify" "0x10";
 action "/usr/local/bin/acpi_brightness_control.sh 1";
};
notify 20 {
 match "system" "ACPI";
 match "subsystem" "IBM";
 match "notify" "0x11";
 action "/usr/local/bin/acpi_brightness_control.sh 0";
}
```
## ./sbg.sh
Set Background with feh randomly from directory.
