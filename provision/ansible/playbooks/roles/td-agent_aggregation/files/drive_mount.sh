#!/bin/bash

IFS='
'

# Loop over the output of lsblk to format volumes
for drive in $(lsblk -p -P -d -o name,serial,UUID,HCTL | tail -n +2); do
  # For Each line in lsblk eval the output into the following variable space
  # UUID=<blank if store is not formatted>
  # SERIAL=<either vol-id or AWSxxx> If AWS it indicates local volume
  # NAME=/dev/nvmeXn1 The name is not consistant between reboots
  eval $drive

  if [[ $UUID == "" ]]; then
    # Format remote volume and add it to fstab using UUID
    echo "Remote Volume:" $NAME
    mkfs -t xfs $NAME
    if [[ "$?" -ne "0" ]]; then
      echo "Skip Drive"
    elif [[ $HCTL == "" ]]; then
      mkdir -p /mnt/block/$SERIAL
      echo "UUID="$(blkid $NAME -s UUID -o value)" /mnt/block/$SERIAL xfs defaults,nofail 0 2" >>/etc/fstab
    else
      for lun in $(echo $HCTL | tr ":" "\n" | tail -n +4); do
        echo "Logic Number:" $lun
        mkdir -p /mnt/block/vol$lun
        echo "UUID="$(blkid $NAME -s UUID -o value)" /mnt/block/vol$lun xfs defaults,nofail 0 2" >>/etc/fstab
      done
    fi
  fi
done

# Mount All Drives in fstab
mount -a

# At this point all volumes have been formatted and mounted
# Here we will setup the links for the log archive directory
if [[ -d /mnt/block/vol${LOG_STORE#vol-} ]]; then
  # Link /log directory to remote volume /mnt/block/vol<ID> directory
  chown -R td-agent:td-agent /mnt/block/vol${LOG_STORE#vol-}
  ln -sf /mnt/block/vol${LOG_STORE#vol-} /log
elif [[ -z "$LOG_STORE" ]]; then
  # Setup /log directory on root volume
  echo "LOG_STORE is not set: Using Root Volume"
  mkdir -p /log
  chown -R td-agent:td-agent /log
else
  # In this case the expected LOG_STORE was not found so we throw an error
  echo "Cannot find LOG_STORE: $LOG_STORE"
  exit 1
fi
