#!/bin/bash
# Replace `bucket-name` with the name of the S3 bucket that contains the objects
BUCKET_NAME="bucket-name"
check_restore="restoring.txt"

if [ -f "$check_restore" ]; then
    rm "$check_restore"
fi

# Get a list of all objects in the bucket with storage class set to GLACIER or DEEP_ARCHIVE
OBJECTS=$(aws s3api list-objects --bucket $BUCKET_NAME --query 'Contents[?StorageClass==`GLACIER` || StorageClass==`DEEP_ARCHIVE`].[Key]' --output text)

# Loop through all objects in the bucket and check the restore status
for OBJECT in $OBJECTS
do
  RESTORE_STATUS=$(aws s3api head-object --bucket $BUCKET_NAME --key $OBJECT --query "Restore" 2>/dev/null)
  if [[ "$RESTORE_STATUS" == *"true"* ]]; then
    echo "$OBJECT" >> $check_restore
  fi
    echo "Scanning objects in $BUCKET_NAME to see which objects are still being restored"

done
