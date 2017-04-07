# load library with report/functions
library(watervogelsAnalyse)
#tmp <- sapply(list.files("../watervogelsAnalyse/R", full.names = TRUE), source)

# path with the tables
pathData <- "/home/lcougnaud/git/waterbirds/data/Testdata waterbirds OpenAnalytics"
# load the data
dataTables <- readData(pathData)

# projects (surveyname)
projects <- sort(unique(dataTables$survey$surveyname))

## what is the unique identifier for the occurrences table?

# remove the  # 6 duplicated rows
dataTables$occurences <- dataTables$occurences[!duplicated(dataTables$occurences), ]

# is it [locationid, surveyid, taxonid, teldatum]
test <- with(dataTables$occurrences, paste0(locationid, surveyid, taxonid, teldatum))
table(duplicated(test))# 43
textX <- dataTables$occurrences[duplicated(test), ]
testDupl <- apply(testX, 1, function(x) 
	subset(dataTables$occurrences, 
		locationid == x['locationid'] & 
		surveyid == x['surveyid'] & 
		taxonid == x['taxonid'] & 
		teldatum == x['teldatum']
	)
)
write.csv(do.call(rbind, testDupl), file = "occurrencesDuplicates.csv", row.names = FALSE)

## telling

length(unique(dataTables$occurrences$telling))# 20 telling
length(unique(dataTables$occurrences$surveyseason)) # 28 survey seasons
table(dataTables$occurrences$telling)
length(unique(dataTables$occurrences$teller)) # 158 tellers
table(dataTables$occurrences$teller)

# occurrences contain 6 duplicated lines, 43 duplicates i