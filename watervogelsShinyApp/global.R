# load library with report/functions
library(watervogelsAnalyse)
#tmp <- sapply(list.files("../watervogelsAnalyse/R", full.names = TRUE), source)

# path with the tables
pathData <- "../data/Testdata waterbirds OpenAnalytics"
# load the data
dataTables <- readData(pathData)

# projects (surveyname)
projects <- sort(unique(dataTables$survey$surveyname))

# parameters used for testing
#input <- list(
#	project = "Watervogeltellingen Zeeschelde", # survey$surveyname
#	regio = '15 - Antwerpen', # occurrences$[regiocode - regio]
#	gebied = 'Galgenschoor (Schelde Lillo-Fort - Containerkaai) (RO)',
#	soortgroep = c('Eenden', 'Rallen en Koeten'), # taxongroup$taxongroup, multiple
#	soort = c('Wilde Eend', 'Wintertaling'), # taxon$commonname, multiple
#	telseizoen = c("2005-06", "2006-07", "2007-08", "2008-09",
#		"2009-10", "2010-11", "2011-12", "2012-13", "2013-14", 
#		"2014-15", "2015-16")# occurrences$surveyseason, multiple
#)