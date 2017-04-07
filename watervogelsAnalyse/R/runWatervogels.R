#' launch watervogels shiny application
#' @return no returned value, the shiny application is launched
#' @author Laure Cougnaud
#' @importFrom shiny runApp
#' @export
runWatervogels <- function(){
	shiny::runApp(system.file("ui", package = "watervogelsAnalyse"))
}