#!/bin/bash

cd aws
for file in $(find certs -type f); do
  base=$(basename $file)
  echo "
resource \"aws_s3_bucket_object\" \"${base%.*}-${base##*.}\" {
  bucket       = \"\${aws_s3_bucket.pki.bucket}\"
  key          = \"$file\"
  source       = \"\${path.module}/$file\"
  content_type = \"text/plain\"
  depends_on   = [\"null_resource.init_ca\"]
}
"

done
