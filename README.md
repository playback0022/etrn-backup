# etrn - rsync-based backup tool
## General description
**etrn** is a simple script designed as a front-end for the infamous rsync tool. 
**etrn** was designed with backups in mind and can be used when syncing files via
ssh between the host machine and a remote server (capable of rsync communication). 
The syncing process can occur both ways.

For security purposes, the remote address and the remote user are requested as input
during the execution of the script (instead of being passed as CLI arguments), in order 
to prevent such sensitive details from being stored in the bash history.

At first, a dry-run is issued and the changes which would occur as a result of the syncing
process are displayed in the terminal. The user is then prompted to either accept or decline
these changes. If the user proceeds, the command is executed as specified.

rsync is used in 'archive' and 'delete' mode, creating an exact copy of the provided
source at the provided destination.

## Dependencies
rsync must be installed on both the local and the remote machine and SSH must be configured
prior to the execution of etrn. This tool was developed for bash specifically.
