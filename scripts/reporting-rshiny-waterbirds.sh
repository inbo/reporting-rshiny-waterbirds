#!/bin/bash
# Make a tar.gz from the R-package from the code
cd /home/ubuntu/reporting-rshiny-waterbirds
if [ -f reporting-rshiny-waterbirds.tar.gz ]; then
    rm reporting-rshiny-waterbirds.tar.gz
fi
tar -zcvf reporting-rshiny-waterbirds.tar.gz watervogelsAnalyse
# Build the docker image
sudo docker build -t openanalytics/watervogels .