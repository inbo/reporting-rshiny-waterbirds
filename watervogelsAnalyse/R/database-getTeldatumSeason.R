#' get data.frame with all possible sampling date for each season
#' @param ch database connection, created with 
#' the \code{odbcConnect} function of the \code{RODBC} package
#' @return data.frame with columns 'surveyseason' and 'teldatum'
#' @author Laure Cougnaud
#' @export
getTeldatumSeason <- function(ch){
			
	query <- paste(
		getQuery(y = c("SeasonName", "W0004_01_Waterbirds.dbo.DimSample.SampleDate"), distinct = TRUE, table = "DimSeason"),
		getQueryJoin("W0004_01_Waterbirds.dbo.DimSeason", "W0004_01_Waterbirds.dbo.FactTaxonOccurrence", 
			key = "SeasonKey", typeJoin = "left"),
		getQueryJoin("W0004_01_Waterbirds.dbo.FactTaxonOccurrence", "W0004_01_Waterbirds.dbo.DimSample", 
			key = "SampleKey", typeJoin = "left")
	)

	teldatumSeasonDf <- sqlQuery(ch, query, stringsAsFactors = FALSE)
	colnames(teldatumSeasonDf) <- c("surveyseason", "teldatum")
	
	teldatumSeasonDf <- subset(teldatumSeasonDf, !is.na(teldatum))
	
	teldatumSeasonDf
		
}