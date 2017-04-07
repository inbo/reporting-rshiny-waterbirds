#' simple wrapper to extract all data tables from set of files
#' @return list of data.frame (each one is a different table)
#' @author Laure Cougnaud
#' @importFrom utils read.csv unzip
#' @export
readData <- function(){
	
	pathData <- system.file("extdata", package = "watervogelsAnalyse")

	pathArchive <- list.files(pathData, full.names = TRUE, pattern = "data.bz2")
	
	dataFilesName <- unzip(pathArchive, list = TRUE)$Name
	
	dataAll <- sapply(dataFilesName, function(file)
		read.csv(
			unz(pathArchive, filename = file), 
			stringsAsFactors = FALSE
		), simplify = FALSE
	)
	names(dataAll) <- sub("WB_report_(.+).csv", "\\1", basename(dataFilesName))
	
	return(dataAll)
	
}