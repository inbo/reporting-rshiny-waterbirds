library(shiny)
library(plotly)

shinyUI(
		
#	fluidPage(
	pageWithSidebar( # sidebarLayout
			
		headerPanel('Watervogels application'),
			
#		theme = "custom.css",
#		includeCSS("./www/custom.css"),
				
		sidebarPanel(
			
			selectInput("project", label = "Project", 
				multiple = TRUE, choices = projects),
			
			selectInput("regio", label = "Regio", 
				multiple = TRUE, choices = ''),
			
			selectInput("gebied", label = "Gebied", 
				multiple = TRUE, choices = ''),
		
			selectInput("soortgroep", label = "Soortgroep", 
				multiple = TRUE, choices = ''),
			
			selectInput("soort", label = "Soort", 
				multiple = TRUE, choices = ''),
			
			selectInput("telseizoen", label = "Telseizoen", 
				multiple = TRUE, choices = ''),
	
			downloadButton(
				outputId = "exportResults", 
				label = "Export results", 
			),
			
			width = 2

		),

		mainPanel(
			plotlyOutput("countDistributionPlot"),
			br(), br(),
			dataTableOutput('countData')
		)

#	)

	)

)

