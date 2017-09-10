## Shiny Application and Reproducible Pitch

This repository contains two reproducible files:

1. **UK Fisheries Activity.Rmd** for building my Shiny App - UK Fisheries Activity Explorer. As I used shiny's `flexdashboard` package to build my dashboard App, codes for *ui* and *server* are rendered in the Rmarkdown file with `context ="render"` and `context ="server"` indicating each respectively. 

2. **Week4 - Shiny application.Rpres** created with Rstudio Presenter for providing a reproducible pitch presentation about my App. 

Please note that the `ui.R` and `server.R` files contain codes directly copied from **UK Fisheries Activity.Rmd** for presence only.   

## My Shiny App

My Shiny App is an interactive dashboard that allows the exploration of fisheries activity for UK commercial vessels landing into the UK and abroad, as well as fisheries activity for foreign commercial vessels landing into the UK.

The dashboard has two sections: **Charts** and **Map of Ports**. 

Under **Charts** section, there is a sidebar panel and the main panel to the right includes 3 self-explantory titled tabs: "Fisheries over months of the year", "Fisheries by UK/foreign vessels", "Key fishes landed by UK vessels". Radiobutton widget is designed for users to interact with the plots. 

Under **Map of Ports** section, users can select the Year from a dropdown list. Data Viewer and Map both react to the input. Here users can view key fisheries statistics for a certain fishing port each year. 

## Links for App and Pitch Presetation

Please view my App [here at shinyapps.io](http://xyou.shinyapps.io/fisheriesactivityexplorer/). 

Please view my 5-slide pitch presentation [here at rpubs](http://rpubs.com/angashley/UK-Fisheries-Activity-Explorer). 

