#!/bin/bash

helpAndUsage="etrn is a simple script designed as a front-end for the infamous rsync
tool. etrn was designed with backups in mind and can be used when syncing files via
ssh between the host machine and a remote server (capable of rsync communication).

Usage: $(basename $0) [OPTIONS]

Options:
	mandatory
	-l <local path>		local path to be synced
	-r <remote path>	remote path to be synced
	-p <port>		SSH port of remote machine

	optional
	-i <path to ssh key>	local path to the private key used in SSH connection
	-e 			enable remote->local syncing

When syncing directories, make sure to include a front slash ('/') after the source
path, if you intend to only sync their contents! Failure to do so will result in the
copying of the directories themselves at the specified destination.
"

# helper function called upon when invalid arguments are provided
getHelp() {
	# output will be redirected to stderr;
	# since it is not an internal error which
	# caused the failure of the script, but
	# some user error, 0 is returned;
	echo "$helpAndUsage" 1>&2; exit 0;
}

# used to indicate the route used in the syncing process:
# 	- 0 = local->remote
#	- 1 = remote->local
operationMode=0

# parsing CLI arguments;
# all flags expect arguments to be provided, except '-e'
while getopts ":l:r:p:i:e" flag;
do
	# storing arguments in the corresponding variables
	case "${flag}" in
		l)
			localPath=$OPTARG;;
	 	r)
			remotePath=$OPTARG;;
		p)
			remotePort=$OPTARG;;
		i)
			sshKeyPath=$OPTARG;;
		e)
			# overwrite the syncing route
			operationMode=1;;
		# any unrecognized flags will prompt the help section
		*)
			getHelp;;
	esac
done

# the ssh key path may be omitted when password-based login is allowed
# on the remote machine, but the other arguments are mandatory
if [ -z "${localPath}" ] || [ -z "${remotePath}" ] || [ -z "${remotePort}" ];
then
	getHelp;
fi

# for security purposes, the remote address and the remote user will be
# requested as input during the execution of the script, in order to prevent
# such sensitive details from being stored in the bash history;
# the input prompts will appear as long as the provided input is empty
read -e -p "Enter the user to login on the remote machine as: " remoteUser
while [ -z "${remoteUser}" ]; do
	read -e -p "Enter the user to login on the remote machine as: " remoteUser
done

read -e -p "Enter the remote machine address: " remoteAddress
while [ -z "${remoteAddress}" ]; do
	read -e -p "Enter the remote machine address: " remoteAddress
done


# dry run! prompting the user with the changes which will occur;
# local->remote operation mode
if [ $operationMode -eq 0 ]; then
	# ssh key path was provided
	if [ -n "${sshKeyPath}" ]; then
		sudo rsync -ahvn --delete -e 'ssh -p '"$remotePort"' -i '"${sshKeyPath}"'' "${localPath}" "${remoteUser}"@"${remoteAddress}":"${remotePath}"
	# password-based ssh login is used
	else
		sudo rsync -ahvn --delete -e 'ssh -p '"${remotePort}"'' "${localPath}" "${remoteUser}"@"${remoteAddress}":"${remotePath}"
	fi

	# when, for any reason, the dry-run encounters an error,
	# the program will exit, propagating the error code
	if [ $? -ne 0 ]; then
		exit $?;
	fi
# remote->local operation mode
else
	# ssh key path was provided
	if [ -n "${sshKeyPath}" ]; then
		sudo rsync -ahvn --delete -e 'ssh -p '"${remotePort}"' -i '"${sshKeyPath}"'' "${remoteUser}"@"${remoteAddress}":"${remotePath}" "${localPath}"
	# password-based ssh login is used
	else
		sudo rsync -ahvn --delete -e 'ssh -p '"${remotePort}"'' "${remoteUser}"@"${remoteAddress}":"${remotePath}" "${localPath}"
	fi

	# when, for any reason, the dry-run encounters an error,
	# the program will exit, propagating the error code
	if [ $? -ne 0 ]; then
		exit $?;
	fi
fi


# making sure the user agrees with the changes
read -e -p "Do you accept these changes? [y/n]: " proceed
while [ "$proceed" != "y" ] && [ "$proceed" != "n" ]; do
	read -e -p "Do you accept these changes? [y/n]: " proceed
done

if [ "$proceed" = "n" ]; then
	exit 0;
fi


# 'wet' run!
# local->remote operation mode
if [ $operationMode -eq 0 ]; then
	if [ -n "${sshKeyPath}" ]; then
		sudo rsync -ahv --progress --delete -e 'ssh -p '"${remotePort}"' -i '"${sshKeyPath}"'' "${localPath}" "${remoteUser}"@"${remoteAddress}":"${remotePath}"
	else
		sudo rsync -ahv --progress --delete -e 'ssh -p '"${remotePort}"'' "${localPath}" "${remoteUser}"@"${remoteAddress}":"${remotePath}"
	fi

else
	if [ -n "${sshKeyPath}" ]; then
		sudo rsync -ahv --progress --delete -e 'ssh -p '"${remotePort}"' -i '"${sshKeyPath}"'' "${remoteUser}"@"${remoteAddress}":"${remotePath}" "${localPath}"
	else
		sudo rsync -ahv --progress --delete -e 'ssh -p '"${remotePort}"'' "${remoteUser}"@"${remoteAddress}":"${remotePath}" "${localPath}"
	fi
fi
