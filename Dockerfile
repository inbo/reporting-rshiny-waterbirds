FROM openanalytics/r-base

MAINTAINER Laure Cougnaud "laure.cougnaud@openanalytics.eu"

RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    tk-dev \
    libssl1.0.0 \
    unixodbc \
    freetds-bin \
    tdsodbc
    
RUN wget https://github.com/jgm/pandoc/releases/download/1.17.2/pandoc-1.17.2-1-amd64.deb
RUN dpkg -i pandoc-1.17.2-1-amd64.deb  

### configure connection to the database

# configuration of FreeTDS in the 'odbcinst.ini' file 
RUN echo -e "[FreeTDS]
Description = FreeTDS Driver v0.91
Driver = /usr/lib/x86_64-linux-gnu/odbc/libtdsodbc.so
Setup = /usr/lib/x86_64-linux-gnu/odbc/libtdsS.so
fileusage=1
dontdlclose=1
UsageCount=1" >> /etc/odbcinst.ini

# append DSN configuration to the 'freetds.conf' file (path might be system-specific)
RUN echo -e "[inbo-sql05-dev]
host = 172.28.11.46
port = 1435
tds version = 4.2" >> /usr/local/etc/freetds.conf

# append DSN configuration in 'odbc.ini' file
RUN echo -e "[inbo-sql05-dev]
Driver = FreeTDS
Description = Development server
Trace = No
Server = 172.28.11.46
Port = 1435
Database = W0004_01_Waterbirds
TDS_Version = 4.2" >> /etc/odbc.ini

# package
RUN R -e "install.packages(c('ggplot2', 'plotly', 'shiny'), repos = 'https://cloud.r-project.org')"

# shiny app
RUN R -e "install.packages(c('plyr', 'rmarkdown'), repos = 'https://cloud.r-project.org')"

# report
RUN R -e "install.packages('DT', repos = 'https://cloud.r-project.org')"

# package
COPY ./reporting-rshiny-waterbirds.tar.gz /root/
RUN R CMD INSTALL /root/reporting-rshiny-waterbirds.tar.gz
RUN rm /root/reporting-rshiny-waterbirds.tar.gz

COPY Rprofile.site /usr/lib/R/etc/

EXPOSE 3838

CMD ["R", "-e library(watervogelsAnalyse);runWatervogels()]