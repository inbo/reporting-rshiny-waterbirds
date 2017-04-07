# check docker images
sudo docker images

# to create Docker image
cd /home/lcougnaud/git/waterbirds
sudo docker build -t openanalytics/watervogels .

# update app: sudo gedit application.yml&

# launch shinyProxy
sudo java -jar /usr/bin/shinyproxy/shinyproxy-0.8.4.jar

# point browser to: http://localhost:8080
# login: 'euler', password: 'password'

## for testing

sudo docker run -p 3838:3838 openanalytics/watervogels R -e "library(watervogelsAnalyse);watervogelsAnalyse::runWatervogels()"
# point browser to: http://localhost:3838

# inspect mounted volumns
docker inspect openanalytics/watervogels

