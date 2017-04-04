#' generate a plot with counts distribution
#' @param inputDataPlot data.frame with input data
#' @param typePlot string, 'ggplot' for static plot of 'plotly' for interactive plot
#' @return a code{ggplot} or a \code{plotly} object, depending on the parameter \code{typePlot}
#' @import ggplot2
#' @importFrom plotly ggplotly
#' @author Laure Cougnaud
#' @export
plotCountsDistribution <- function(inputDataPlot, typePlot = c('ggplot', 'plotly')){

	# create a variable combining date and soort
	# to be able to use it in the x-axis
	teldatumAndSoort <- with(inputDataPlot, paste(teldatum, soort))
	teldatumAndSoortLevels <- sort(unique(teldatumAndSoort))
	inputDataPlot$`teldatum and soort` <- factor(teldatumAndSoort, 
		levels = teldatumAndSoortLevels)
	inputDataPlot$telling <- as.integer(inputDataPlot$telling)
	
	# create the plot
	gg <- ggplot(data = inputDataPlot, 
		aes(x = `teldatum and soort`, y = telling, fill = soort)) +

		geom_bar(stat = "identity") + 
		theme_bw() +
		labs(x = 'telseizoen', y = 'telling', title = "Telling distributie") +
	#	scale_x_discrete(breaks = NULL) +
			
		# only include the date in the x-axis
		scale_x_discrete(
			breaks = teldatumAndSoortLevels,
			labels = sub("([[:digit:]]{1,}-[[:digit:]]{1,}-[[:digit:]]{1,}).+", 
				"\\1", teldatumAndSoortLevels)
		)+
		
		# rotate x-labels
		theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 4))

	# render the plot, static or interactive
	switch(typePlot,
		'ggplot' = gg,
		'plotly' = ggplotly(gg, tooltip = c('x', 'y'))
	)
	
}
