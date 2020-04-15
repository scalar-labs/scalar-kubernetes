#!/bin/bash

### Definitions
# local_volume -> Is definded as instance storage (not persistent)
# remote_volume -> Is definded as block storage (persistent)
# root_volume -> Is definded as the OS volume (persistent)


# Array for local volumes
declare -a LOCAL_VOLUMES

IFS='
'
# Loop over the output of lsblk to format remote and local stores
for drive in $(lsblk -p -P -d -o name,serial,UUID,HCTL | tail -n +2); do
  # For Each line in lsblk eval the output into the following variable space
  # UUID=<blank if store is not formatted>
  # SERIAL=<either vol-id or AWSxxx> If AWS it indicates local volume
  # NAME=/dev/nvmeXn1 The name is not consistant between reboots
  eval $drive

  if [[ $SERIAL == AWS* ]] && [[ $UUID == "" ]]; then
    # Add all local volume to LOCAL_VOLUMES
    echo "Local Volume:" $NAME
    LOCAL_VOLUMES=("${LOCAL_VOLUMES[@]}" "$NAME")
  elif [[ $UUID == "" ]]; then
    # Format remote volume and add it to fstab using UUID
    echo "Remote Volume:" $NAME
    mkfs -t xfs $NAME
    if [[ "$?" -ne "0" ]]; then
      echo "Skip Drive"
    elif [[ $HCTL == "" ]]; then
      # $SERIAL - volxxx   $DATA_STORE - vol-xxx
      if [[ ${SERIAL#vol} == ${DATA_STORE#vol-} ]]; then
        mkdir -p /data
        echo "UUID="$(blkid $NAME -s UUID -o value)" /data xfs defaults,nofail 0 2" >>/etc/fstab
        mount -a
        chown -R cassandra:cassandra /data
      elif [[ ${SERIAL#vol} == ${COMMIT_STORE#vol-} ]]; then
        mkdir -p /commitlog
        echo "UUID="$(blkid $NAME -s UUID -o value)" /commitlog xfs defaults,nofail 0 2" >>/etc/fstab
        mount -a
        chown -R cassandra:cassandra /commitlog
      fi
    else
      for lun in $(echo $HCTL | tr ":" "\n" | tail -n +4); do
        if [[ $lun == "5" ]]; then
          mkdir -p /data
          echo "UUID="$(blkid $NAME -s UUID -o value)" /data xfs defaults,nofail 0 2" >>/etc/fstab
          mount -a
          chown -R cassandra:cassandra /data
        elif [[ $lun == "6" ]]; then
          mkdir -p /commitlog
          echo "UUID="$(blkid $NAME -s UUID -o value)" /commitlog xfs defaults,nofail 0 2" >>/etc/fstab
          mount -a
          chown -R cassandra:cassandra /commitlog
        fi
      done
    fi
  fi
done

# All volumes in LOCAL_VOLUMES need to be formatted before use
if [[ ${#LOCAL_VOLUMES[@]} -gt 0 ]]; then
  # We use /mnt/resource for local volumes to keep it consistant with Azure
  mkdir -p /mnt/resource
  if [[ ${#LOCAL_VOLUMES[@]} -gt 1 ]]; then
    # If multiple local volumes are dected we will create one logical volume
    pvcreate ${LOCAL_VOLUMES[@]}
    vgcreate local_grp ${LOCAL_VOLUMES[@]}

    # Create a logical volume in raid0 and set the stripes count to the number of local volumes detected
    lvcreate --type raid0 --stripes ${#LOCAL_VOLUMES[@]} -l 100%FREE --name local_vol local_grp

    # Format the logical volume
    mkfs -t xfs /dev/local_grp/local_vol

    # Mount the logical volume to /mnt/resource
    mount /dev/local_grp/local_vol /mnt/resource
  else
    # Only 1 local volume was detected so format and mount directly
    mkfs -t xfs ${LOCAL_VOLUMES[@]}
    mount ${LOCAL_VOLUMES[@]} /mnt/resource
  fi
fi

# Check if we need to setup a local volume link or use root volume
if [[ $DATA_STORE == "local" ]] && [[ -d /mnt/resource ]]; then
  # Link /data directory to local volume /mnt/resource/data
  mkdir -p /mnt/resource/data
  chown -R cassandra:cassandra /mnt/resource/data
  ln -sf /mnt/resource/data /data
elif [[ -z "$DATA_STORE" ]]; then
  # Setup /data directory on root volume
  echo "DATA_STORE is not set: Using Root Volume"
  mkdir -p /data
  chown -R cassandra:cassandra /data
fi

if [[ $COMMIT_STORE == "local" ]] && [[ -d /mnt/resource ]]; then
  # Link /commitlog directory to local volume /mnt/resource/commitlog
  mkdir -p /mnt/resource/commitlog
  chown -R cassandra:cassandra /mnt/resource/commitlog
  ln -snf /mnt/resource/commitlog /commitlog
elif [[ -z "$COMMIT_STORE" ]]; then
  # Setup /commitlog directory on root volume
  echo "COMMIT_STORE is not set: Using Root Volume"
  mkdir -p /commitlog
  chown -R cassandra:cassandra /commitlog
fi
