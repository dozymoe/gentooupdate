gentooupdate
============

Automation for gentoo regular update.

usage
-----

Just run `make` on the project directory, or run the script `bin/system_upgrade`
which utilized `flock`.

Ah, almost forgot, you need to `touch` the file `flags/system-upgrade` once a month
or once a week, depends on how often you'd like to update your system.

`touch flags/system-upgrade` would allow the Makefile commands to be executed, if,
if the timestamp of the file `flags/system-upgrade` is newer than the timestamp of
`/usr/portage/metadata/timestamp` which usually updated when you sync portage.
