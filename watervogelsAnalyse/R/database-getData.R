#' extract data of interest from a certain survey, location, taxon and survey season
#' @param surveyId survey identifier(s)
#' @param locationId location identifier(s)
#' @param taxonId taxon identifier(s)
#' @param surveyseason survey season name(s)
#' @param personKey integer with person key
#' @param ch database connection, created with 
#' the \code{odbcConnect} function of the \code{RODBC} package
#' @return data.frame with data of interest
#' @author Laure Cougnaud
#' @export
getData <- function(surveyId, locationId, taxonId, surveyseason, personKey, ch){
	
	# surveyseasonName -> surveySeasonId
	surveySeasonId <- extractYFromXTable(
		x = list('SeasonName' = surveyseason), 
		y = "SeasonKey", table = "DimSeason",
		ch = ch)
	
	# surveyId + locationId + taxonId + seasonId -> count table
	querySubsetCountTable <- getQuery(
		x = list(
			'SurveyKey' = surveyId,
			'LocationWVKey' = locationId,
			'TaxonWVKey' = taxonId,
			'SeasonKey' = surveySeasonId,
			'PersonKey' = personKey
		), 
		y = c('SurveyKey', 'LocationWVKey', 'TaxonWVKey', 'SeasonKey',
			'SampleKey', 'SampleDate', 'TaxonCount', 'EventKey'), 
		table = "FactTaxonOccurrence"
	)
	resQuerySubset <- sqlQuery(ch, querySubsetCountTable, stringsAsFactors = FALSE)
	
	# join on other tables to have required information
	
	getQueryJoinCustom <- function(tableY, key)
		getQueryJoin(tableX = "countTable", tableY = tableY, 
			key = key, typeJoin = "left")
	
	columnsToSelect <- c(
		# DimSurvey
		'project' = "SurveyNaam",
		# DimLocationWV
		'regio' = "RegioWVNaam", 'gebied' = "LocationWVNaam",
		# DimSeason
		'surveyseason' = "SeasonName",
		# DimEvent
		'telling' = "EventCode",
		# DimSample
		'teldatum' = "W0004_01_Waterbirds.dbo.DimSample.SampleDate", 
		'tellingstatus' = "Samplestatus",
		# DimTaxonWV
		'euringcode' = "euringcode", 
		'soort' = "commonname",
		'aantal' = "TaxonCount"
	)
	queryJoin <- paste(
		"SELECT", toString(columnsToSelect), "FROM",
		"(", querySubsetCountTable, ")",
		"AS countTable",
		getQueryJoinCustom("W0004_01_Waterbirds.dbo.DimEvent", "EventKey"),
		getQueryJoinCustom("W0004_01_Waterbirds.dbo.DimSeason", "SeasonKey"),
		getQueryJoinCustom("W0004_01_Waterbirds.dbo.DimSample", "SampleKey"),
		getQueryJoinCustom("W0004_01_Waterbirds.dbo.DimSurvey", "SurveyKey"),
		getQueryJoinCustom("W0004_01_Waterbirds.dbo.DimLocationWV", "LocationWVKey"),
		getQueryJoinCustom("W0004_01_Waterbirds.dbo.DimTaxonWV", "TaxonWVKey")
	)
	resQueryJoin <- sqlQuery(ch, queryJoin, stringsAsFactors = FALSE)
	
	# set names as previously exported data
	colnames(resQueryJoin) <- names(columnsToSelect)
	
	# reformat telling as integer
	resQueryJoin$telling <- as.integer(sub(".+([[:digit:]]{1,})", "\\1", resQueryJoin$telling))
	
	return(resQueryJoin)
	
}