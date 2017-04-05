
library(watervogelsAnalyse)

shinyServer(function(input, output, session) {
			
	results <- reactiveValues(
		selectedData = 	NULL,
		countDistributionPlot = NULL
	)
			
	# when project selected, update regio
	observe({
				
		# check if project non empty
		if(isTruthy(input$project)){
			
			isolate({
				
				# project (surveyname) -> surveyId (survey table)
				surveyId <- subset(dataTables$survey, surveyname %in% input$project)$surveyid
				# surveyId -> regio (region table)
				regio <- unique(subset(dataTables$region, surveyid %in% surveyId)$region)
				
				message('Update regio to:', toString(regio))
	
				updateSelectInput(session, 
					inputId = 'regio',
					choices = regio)	
		
			})
		
		}
				
	})

	# when regio selected, update gebied
	observe({
				
		# check if regio non empty
		if(isTruthy(input$regio)){
			
			isolate({
					
				# regio -> regioid (region table)
				regioId <- unique(subset(dataTables$region, region %in% input$regio)$regionid)
				
				# surveyname -> surveyid (survey table)
				surveyId <- subset(dataTables$survey, surveyname %in% input$project)$surveyid
				
				# surveyid + regionid -> locationname (location table)
				locationname <- sort(unique(
					subset(dataTables$location, 
						regionid %in% regioId & surveyid %in% surveyId
					)$locationname))
		
				updateSelectInput(session, 
					inputId = 'gebied',
					choices = locationname)	
		
			})
					
		}
				
	})

	# when gebied selected, update soortgroep
	observe({
				
		# check if gebied non empty
		if(isTruthy(input$gebied)){
			
			isolate({
			
				# gebied (locationname) -> locationid (region table)
				locationId <- unique(subset(dataTables$location, locationname %in% input$gebied)$locationid)
				
				# surveyname -> surveyid (survey table)
				surveyId <- subset(dataTables$survey, surveyname %in% input$project)$surveyid
				
				# locationid + surveyid -> taxonid (occurrences table)
				taxonId <- unique(
					subset(dataTables$occurrences, 
						locationid %in% locationId & surveyid %in% surveyId
					)$taxonid)
			
				# taxonid -> taxongroupid (taxon table)
				taxonGroupId <- unique(subset(dataTables$taxon, 
					taxonid %in% taxonId
				)$taxongroupid)
		
				# taxongroupid -> taxongroup (taxongroup table)
				taxonGroups <- sort(subset(dataTables$taxongroup, 
					taxongroupid %in% taxonGroupId
				)$taxongroup)
								
				updateSelectInput(session, 
					inputId = 'soortgroep',
					choices = taxonGroups)	
		
			})
			
		}
		
	})


	# when soortgroep selected, update soort
	observe({
			
		# check if soortgroep non empty
		if(isTruthy(input$soortgroep)){
				
			# taxongroup -> taxongroupid (taxongroup table)
			taxonGroupId <- subset(dataTables$taxongroup, taxongroup %in% input$soortgroep)$taxongroupid
				
			# taxongroupid -> commonname (taxon table)
#			commonname <- sort(subset(dataTables$taxon, taxongroupid %in% taxonGroupId)$commonname)
				
			# taxongroupid -> taxonid (taxon table)
			taxonId <- subset(dataTables$taxon, taxongroupid %in% taxonGroupId)$taxonid
				
			# surveyname -> surveyid (survey table)
			surveyId <- subset(dataTables$survey, surveyname %in% input$project)$surveyid
			
			# gebied -> locationid (location table)
			locationId <- unique(subset(dataTables$location, locationname %in% input$gebied)$locationid)
			
			# only keep taxon counted in survey and gebied (occurrences table)
			taxonIdCounted <- unique(
				subset(dataTables$occurrences, 
					locationid %in% locationId &
					surveyid %in% surveyId &
					taxonid %in% taxonId
				)$taxonid
			)
			# extract their common name
			commonname <- sort(subset(dataTables$taxon, taxonid %in% taxonIdCounted)$commonname)
			
			updateSelectInput(session, 
				inputId = 'soort',
				choices = commonname)	
				
		}
			
	})

	# when soort selected, update telseizoen
	observe({
				
		# check if soort non empty
		if(isTruthy(input$soort)){
			
			isolate({
					
				# surveyname -> surveyid (survey table)
				surveyId <- subset(dataTables$survey, surveyname %in% input$project)$surveyid
					
				# gebied -> locationid (location table)
				locationId <- unique(subset(dataTables$location, locationname %in% input$gebied)$locationid)
				
				# soort (commonname) -> taxonid (taxon table)
				taxonId <- subset(dataTables$taxon, commonname %in% input$soort)$taxonid
				
				# soort + gebied + project -> telseizoen (occurrences table)
				telseizoen <- sort(unique(
					subset(dataTables$occurrences, 
						locationid %in% locationId &
						surveyid %in% surveyId &
						taxonid %in% taxonId
					)$surveyseason
				))
				
				updateSelectInput(session, 
					inputId = 'telseizoen',
					choices = telseizoen)
		
			})
					
		}
		
	})

	# extract selected data (used for plot and data.table)
	observe({
				
		if(isTruthy(input$telseizoen)){
			
			isolate({
											
				# project (surveyname) -> surveyid (survey table)
				surveyId <- subset(dataTables$survey, surveyname %in% input$project)$surveyid
						
				# gebied (locationname) -> locationid (location table)
				locationId <- unique(subset(dataTables$location, locationname %in% input$gebied)$locationid)
						
				# soort (commonname)-> taxonid (taxon table)
				taxonId <- subset(dataTables$taxon, commonname %in% input$soort)$taxonid
						
				# extract corresponding data [surveyId + locationId + taxonId + telseizoen] (occurrences table)
				selectedData <- subset(dataTables$occurrences,
					surveyid %in% surveyId &
					locationid %in% locationId &
					taxonid %in% taxonId &
					surveyseason %in% input$telseizoen
				)	
				
#				message("Update results$selectedData to", str(selectedData))		
				colsOfInterest <- c('project', 'regio', 'gebied', 'surveyseason',
					'telling', 'teldatum', 'tellingstatus', 'euringcode', 'soort', 
					'aantal')
				results$selectedData <- selectedData[, colsOfInterest]

			})
			
		}		
				
	})

	# plot the distribution
	output$countDistributionPlot <- renderPlotly({
		validate(
			need(results$selectedData,
				message = "" #"Please select the parameters."
			)
		)
		plot <- plotCountsDistribution(
			inputDataPlot = results$selectedData, 
			typePlot = 'plotly')
		results$countDistributionPlot <<- plot
		plot
	})

	# print data.table
	output$countData <- renderDataTable({
		validate(
			need(results$selectedData,
				message = ""#"Please select the parameters."
			)
		)
		results$selectedData
	})
		
	output$exportResults <- downloadHandler(
		filename = "waterbirds.html",
		content = function(file) {
			
			# check if selected data and plot not NULL
			validate(
				need(results$countDistributionPlot, message = ""),
				need(results$selectedData, message = "")
			)
				
			# extract parameters
			params <- list(
				countDistributionPlot = results$countDistributionPlot,
				selectedData = results$selectedData,
				project = input$project,
				regio = input$regio,
				gebied = input$gebied,
				soortgroep = input$soortgroep,
				soort = input$soort,
				telseizoen = input$telseizoen
			)
			
			# get path template report
			pathReport <- watervogelsAnalyse::getPathStartTemplate()
			
			# get report name
			reportName <- basename(pathReport)
			
			# copy start template in working directory
			file.copy(
				from = pathReport, 
				to = ".", 
				overwrite = TRUE
			)
			
			# run report
			res <- rmarkdown::render(
				reportName, 
				params = params
			)
			
			file.copy("waterbirds.html", file)
			
		}, 
		
		contentType = "text/html"

	)

})