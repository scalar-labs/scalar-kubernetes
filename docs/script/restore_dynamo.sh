#!/bin/sh -e
export AWS_PAGER=""

tables=()
while [ $# -gt 0 ]; do
  case ${1} in
  --time)
    time="${2}"
    shift 2
    ;;
  *)
    tables+=("${1}")
    shift 1
    ;;
  esac
done

#Create PITR backup
for table in "${tables[@]}"; do
  aws dynamodb restore-table-to-point-in-time \
    --source-table-name ${table} \
    --target-table-name ${time}-${table} \
    --no-use-latest-restorable-time \
    --restore-date-time ${time}

  while true; do
    status=$(aws dynamodb describe-table --table-name ${time}-${table} | jq '.Table.TableStatus')
    if [ "${status}" = "\"ACTIVE\"" ]; then
      aws dynamodb delete-table --table-name ${table}
      break
    fi
    sleep 60
  done
done

#PITR backup restore to scalar tables
for table in "${tables[@]}"; do
  backup_arn=$(aws dynamodb create-backup --table-name ${time}-${table} --backup-name ${time}-${table} | jq -r '.BackupDetails.BackupArn')

  while true; do
    status=$(aws dynamodb describe-backup --backup-arn ${backup_arn} | jq '.BackupDescription.BackupDetails.BackupStatus')
    if [ "${status}" = "\"AVAILABLE\"" ]; then
      break
    fi
    sleep 60
  done

  aws dynamodb restore-table-from-backup \
    --target-table-name ${table} \
    --backup-arn ${backup_arn}

  while true; do
    status=$(aws dynamodb describe-table --table-name ${table} | jq '.Table.TableStatus')
    if [ "${status}" = "\"ACTIVE\"" ]; then
      aws dynamodb delete-table --table-name ${time}-${table}
      break
    fi
    sleep 60
  done
done
