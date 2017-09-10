library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(plotly)
library(lubridate)
library(leaflet)
library(htmltools)

sidebar <- dashboardSidebar(
        
        radioButtons("Criteria", h4("Choose criteria:"), choiceNames =c("Live Weight ('000 tonnes)", "Total Value (Million GBP)", "Price (GBP/tonne)"), choiceValues = c("Live Weight ('000 tonnes)", "Total Value (Million GBP)", "Price (GBP/tonne)"))

)

body <- dashboardBody(

        fluidRow(
                tabBox(title = "Charts", 
                tabPanel("Fisheries over 12 months", plotlyOutput("plot1"), height=250),
                tabPanel(radioButtons("Species.Group", h4("Select a species:"), inline = TRUE, choiceNames =c("Demersal", "Pelagic", "Shellfish"), choiceValues = c("Demersal", "Pelagic", "Shellfish")), 
                         "Fisheries by UK/foreign vessels", plotlyOutput("plot2"), height=250),
                tabPanel("Key species caught by UK vessels", plotlyOutput("plot3"), height=250)
        
        )),

fluidRow(
        selectInput("Year", label = h4("Select the Year"), choices=list("2017" = "2017","2016" = "2016","2015" = "2015", "2014" = "2014"), selected = "2017"),
        tabBox(
                title =("Map of Ports"),
                tabPanel("Date Viewer", dataTableOutput("dataviewerperyear")),
                tabPanel("Map", leafletOutput("map", height=800)))))
           

# put together into a dashboardPage
dashboardPage(
        dashboardHeader("UK Fisheries Activity Explorer"), sidebar, body)

