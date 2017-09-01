# load library with report/functions
library(watervogelsAnalyse)

# connect to the database
library(RODBC)

server <- FALSE

# currently placeholder for the connection
if(server){
	
	ch <- odbcConnect(dsn = "[mySqlServerIP]", uid = "[userID]", pwd = "[pwd]")
	
	# extract available projects
	projects <- getProjects()
	
	# extract unique teldatum per season
	teldatumSeasonDf <- getTeldatumSeason(ch)
	
}else{
	# load the data
	dataTables <- readData()

	# projects (surveyname)
	projects <- sort(unique(dataTables$survey$surveyname))

	# extract unique teldatum per season
	library(plyr)
	teldatumSeasonDf <- ddply(dataTables$occurrences, "surveyseason", 
		function(x) 
		matrix(unique(x$teldatum), dimnames = list(NULL, 'teldatum'))
	)
	
}

# parameters used for testing
#input <- list(
#	project = "Watervogeltellingen Zeeschelde", # survey$surveyname
#	regio = ifelse(server, 'Antwerpen', '15 - Antwerpen'), # occurrences$[regiocode - regio]
#	gebied = 'Galgenschoor (Schelde Lillo-Fort - Containerkaai) (RO)',
#	soortgroep = c('Eenden', 'Rallen en Koeten'), # taxongroup$taxongroup, multiple
#	soort = c('Wilde Eend', 'Wintertaling'), # taxon$commonname, multiple
#	telseizoen = c("2005-06", "2006-07", "2007-08", "2008-09",
#		"2009-10", "2010-11", "2011-12", "2012-13", "2013-14", 
#		"2014-15", "2015-16")# occurrences$surveyseason, multiple
#)