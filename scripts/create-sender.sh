#!/bin/bash -x

# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

TIMESTAMP=`date +%Y%M%dt%H%M`
STARTUP_SCRIPT=gs://vbench-testing/sender-startup.sh

gcloud compute instances create srt-stream-sender-$TIMESTAMP \
  --zone=us-central1-f \
  --machine-type=n2d-highmem-4 \
  --maintenance-policy=MIGRATE \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --tags=allow-srt \
  --image-project=ubuntu-os-cloud \
  --image-family=ubuntu-2204-lts \
  --boot-disk-size=100 \
  --boot-disk-type=pd-balanced \
  --network=default \
  --metadata=startup-script-url=$STARTUP_SCRIPT
