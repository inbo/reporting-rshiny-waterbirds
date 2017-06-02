shinyServer(function(input, output, session) {
		
	# reactiveValue to store possible values
	# (to avoid redundant calls to the db)
	possibleValues <- reactiveValues(
		locationId = NULL,
		taxonId = NULL
	)		
			
	# reactiveValues to store selected parameters
	# (to avoid redundant calls to the db)
	selectedParams <- reactiveValues(
		surveyId = NULL,
		locationId = NULL,
		taxonId = NULL
	)		
		
	# reactiveValues to store
	# data and visualization
	# (to be used within the report)
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
#				surveyId <- subset(dataTables$survey, surveyname %in% input$project)$surveyid
#				selectedParams$surveyId <- surveyId
#				
#				# surveyId -> regio (region table)
#				regio <- unique(subset(dataTables$region, surveyid %in% surveyId)$region)
					
				resInfoProject <- getRegioFromSurvey(surveyName = input$project, ch = ch)
				selectedParams$surveyId <- resInfoProject$surveyId
				possibleValues$locationId <- resInfoProject$locationId
				regions <- resInfoProject$regioName
				
				updateSelectInput(session, inputId = 'regio', choices = regions)	
		
			})
		
		}
				
	})

	# when regio selected, update gebied
	observe({
				
		# check if regio non empty
		if(isTruthy(input$regio) & isTruthy(possibleValues$locationId)){
			
			isolate({
					
				# regio -> regioid (region table)
#				regioId <- unique(subset(dataTables$region, region %in% input$regio)$regionid)
#				
#				# surveyid + regionid -> locationname (location table)
#				locationname <- sort(unique(
#					subset(dataTables$location, 
#						regionid %in% regioId & 
#						surveyid %in% selectedParams$surveyId
#					)$locationname))
	
				locations <- getLocationFromRegionLocationId(
					regionName = input$regio, 
					locationId = possibleValues$locationId, 
					ch = ch)

				updateSelectInput(session, 
					inputId = 'gebied',
					choices = locations)	
		
			})
					
		}
				
	})

	# when gebied selected, update soortgroep
	observe({
				
		# check if gebied non empty
		if(isTruthy(input$gebied) && isTruthy(selectedParams$surveyId)){
			
			isolate({
			
				# gebied (locationname) -> locationid (region table)
#				locationId <- unique(subset(dataTables$location, locationname %in% input$gebied)$locationid)
#				selectedParams$locationId <- locationId
#				
#				# locationid + surveyid -> taxonid (occurrences table)
#				taxonId <- unique(
#					subset(dataTables$occurrences, 
#						locationid %in% locationId & 
#						surveyid %in% selectedParams$surveyId
#					)$taxonid)
#			
#				# taxonid -> taxongroupid (taxon table)
#				taxonGroupId <- unique(subset(dataTables$taxon, 
#					taxonid %in% taxonId
#				)$taxongroupid)
#		
#				# taxongroupid -> taxongroup (taxongroup table)
#				taxonGroups <- sort(subset(dataTables$taxongroup, 
#					taxongroupid %in% taxonGroupId
#				)$taxongroup)
		
				resInfoTaxonGroup <- getTaxonGroupFromLocationSurvey(
					locationName = input$gebied, 
					surveyId = selectedParams$surveyId,
					ch = ch
				)
			
				selectedParams$locationId <- resInfoTaxonGroup$locationId
				possibleValues$taxonId <- resInfoTaxonGroup$taxonId
				
				taxonGroups <- resInfoTaxonGroup$taxonGroup
				
				updateSelectInput(session, 
					inputId = 'soortgroep',
					choices = taxonGroups)	
		
			})
			
		}
		
	})


	# when soortgroep selected, update soort
	observe({
			
		# check if soortgroep non empty
		if(isTruthy(input$soortgroep) && isTruthy(possibleValues$taxonId)){
				
#			# taxongroup -> taxongroupid (taxongroup table)
#			taxonGroupId <- subset(dataTables$taxongroup, taxongroup %in% input$soortgroep)$taxongroupid
#				
#			# taxongroupid -> taxonid (taxon table)
#			taxonId <- subset(dataTables$taxon, taxongroupid %in% taxonGroupId)$taxonid
#							
#			# only keep taxon counted in survey and gebied (occurrences table)
#			taxonIdCounted <- unique(
#				subset(dataTables$occurrences, 
#					locationid %in% selectedParams$locationId &
#					surveyid %in% selectedParams$surveyId &
#					taxonid %in% taxonId
#				)$taxonid
#			)
#			# extract their common name
#			commonname <- sort(subset(dataTables$taxon, taxonid %in% taxonIdCounted)$commonname)

			# assume that taxon group description is unique identifier for taxon
			taxons <- getTaxonFromTaxonGroupTaxonId(
				taxonId = possibleValues$taxonId,
				taxonGroup = input$soortgroep,
				ch = ch)
				
			updateSelectInput(session, 
				inputId = 'soort',
				choices = taxons
			)
				
		}
			
	})

	# when soort selected, update telseizoen
	observe({
				
		# check if soort non empty
		if(isTruthy(input$soort) && isTruthy(selectedParams$surveyId) && isTruthy(selectedParams$locationId)){
			
			isolate({
					
#				# soort (commonname) -> taxonid (taxon table)
#				taxonId <- subset(dataTables$taxon, commonname %in% input$soort)$taxonid
#				selectedParams$taxonId <- taxonId
#				
#				# soort + gebied + project -> telseizoen (occurrences table)
#				telseizoen <- sort(unique(
#					subset(dataTables$occurrences, 
#						locationid %in% selectedParams$locationId &
#						surveyid %in% selectedParams$surveyId &
#						taxonid %in% taxonId
#					)$surveyseason
#				))
		
				seasons <- getSeasonFromSurveyLocationTaxon(
					surveyId = selectedParams$surveyId,
					locationId = selectedParams$locationId,
					taxon = input$soort,
					ch = ch
				)
				
				updateSelectInput(session, 
					inputId = 'telseizoen',
					choices = seasons)
		
			})
					
		}
		
	})

	# extract selected data (used for plot and data.table)
	observe({
				
		if(isTruthy(input$telseizoen) &&
			isTruthy(selectedParams$surveyId) &&
			isTruthy(selectedParams$locationId) &&
			isTruthy(selectedParams$taxonId)
		){
			
			isolate({
						
#				# extract corresponding data [surveyId + locationId + taxonId + telseizoen] (occurrences table)
#				selectedData <- subset(dataTables$occurrences,
#					surveyid %in% selectedParams$surveyId &
#					locationid %in% selectedParams$locationId &
#					taxonid %in% selectedParams$taxonId &
#					surveyseason %in% input$telseizoen
#				)	
#				
#				colsOfInterest <- c('project', 'regio', 'gebied', 'surveyseason',
#					'telling', 'teldatum', 'tellingstatus', 'euringcode', 'soort', 
#					'aantal')
#							
#				results$selectedData <- selectedData[, colsOfInterest]
						
				# TODO: finish implementation in progress!
				selectedData <- getData(
					surveyId = selectedParams$surveyId, 
					locationId = selectedParams$locationId,
					taxonId = selectedParams$taxonId,
					surveyseason = input$telseizoen,
					ch = ch
				)			
							
				results$selectedData <- selectedData

			})
			
		}		
				
	})

	# plot the distribution
	output$countDistributionPlot <- renderPlotly({
		validate(
			need(results$selectedData,
				message = "" 
			)
		)
		plot <- plotCountsDistribution(
			inputDataPlot = results$selectedData, 
			teldatumSeasonDf = teldatumSeasonDf,
			typePlot = 'plotly')
		results$countDistributionPlot <<- plot
		plot
	})

	# print data.table
	output$countData <- shiny:::renderDataTable({
		validate(
			need(results$selectedData,
				message = ""
			)
		)
		results$selectedData
	})
		
	output$exportResults <- downloadHandler(
		filename = 'results.zip',
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
			pathReport <- watervogelsAnalyse::getPathReport()
			
			# get report name
			reportName <- basename(pathReport)
			
			# create temporary files in temp
			tmpDir <- tempdir()
			dir.create(tmpDir, recursive = TRUE)
			
			# copy start template in working directory
			file.copy(from = pathReport, to = tmpDir, overwrite = TRUE)
			
			# run report
			library(rmarkdown)
			res <- rmarkdown::render(file.path(tmpDir, reportName), params = params)
			
			# export the data
			write.csv(results$selectedData, 
				file = file.path(tmpDir, "data.csv"), row.names = FALSE)
			
			# zip results
			zipPath <- file.path(tmpDir, 'results.zip')
			zip(zipPath, 
				files = file.path(tmpDir, c('data.csv', 'watervogels.html')),
				flag = '-j')
			
			# return the zip file
			file.copy(zipPath, file)
			
			# clean directory
			unlink(tmpDir)
			
		}, 
		
		contentType = "application/zip"

	)

})