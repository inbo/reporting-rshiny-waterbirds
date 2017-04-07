#' get path of start template available in the package
#' @return string with path of start template
#' @author Laure Cougnaud and Kirsten Van Hoorde
#' @export
getPathReport <- function(){
	
	basePathReport <- system.file("report", package = "watervogelsAnalyse")
	pathReport <- dir(basePathReport , pattern = "watervogels.Rmd", full.names = TRUE)
	
	return(pathReport)
	
}
