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
    r-cran-rodbc
    
RUN wget https://github.com/jgm/pandoc/releases/download/1.17.2/pandoc-1.17.2-1-amd64.deb
RUN dpkg -i pandoc-1.17.2-1-amd64.deb    
    
### install packages

# dependencies

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
