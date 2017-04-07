# check docker images
sudo docker images

# to create Docker image
cd /home/lcougnaud/git/waterbirds
sudo docker build -t openanalytics/watervogels .

# update app: sudo gedit application.yml&

# launch shinyProxy
# application.yml should be in same directory of the yaml file resides, otherwise only show application 'Hello World'
sudo java -jar /usr/bin/shinyproxy/shinyproxy-0.8.4.jar

# point browser to: http://localhost:8080
# login: 'euler', password: 'password'

## for testing

sudo docker run -p 3838:3838 openanalytics/watervogels R -e "library(watervogelsAnalyse);watervogelsAnalyse::runWatervogels()"
#point browser to: http://localhost:3838

# inspect mounted volumns
docker inspect openanalytics/shinyproxy-template



Status code: 500
Message: Failed to start container: java.util.concurrent.ExecutionException: javax.ws.rs.ProcessingException: org.apache.http.conn.HttpHostConnectException: Connect to localhost:2375 [localhost/127.0.0.1] failed: Connection refused (Connection refused) 
# disable firewall: 
sudo ufw disable

