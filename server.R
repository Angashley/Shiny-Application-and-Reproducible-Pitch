
# Load required packages
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(lubridate)
library(leaflet)
library(htmltools)

# load fisheriesData date set to be used for the App

fisheriesData <- read.csv("www/fisheriesData.csv",header = TRUE,stringsAsFactors = FALSE)

fisheriesData$Date <- as.Date(fisheriesData$Date)

# create data frame for bubble graph over 12 months

fisheriesmonth <- mutate(fisheriesData, Month.number = month(fisheriesData$Date))

fisheriesym <- mutate(fisheriesmonth, Year = factor(year(fisheriesmonth$Date),levels= c("2014","2015","2016","2017")))

fisheries_trim <- fisheriesym %>% mutate(Month.name=month.abb[Month.number]) %>% group_by(Year, Month.number, Month.name) %>% summarise(Live.Weight=sum(Live.weight..tonnes./1000),Value=sum(Value..000s.))

fisheries_price <- mutate(fisheries_trim, Price = Value/Live.Weight)

# subset data file to 3 types: UK vessels landing into the UK, foreign vessels landing into the UK, UK vessels landing abroad

# 1. UK vessels landing into the UK
subset_UK <- subset(fisheriesData, (Port.Nationality %in% c("England","Wales", "Scotland", "Northern Ireland")) & Vessel.Nationality == "UK")  

n1 <- subset_UK %>% tally() 

UKVesselsHome <-  subset_UK %>% mutate(Type = factor( rep("UK.vessels.fishing.in.the.UK",n1),levels="UK.vessels.fishing.in.the.UK"))

# 2. Landings into the UK by foreign vessels  

subset_foreignVessels <- subset(fisheriesData, (Port.Nationality %in% c("England","Wales", "Scotland", "Northern Ireland")) & Vessel.Nationality != "UK")

n2 <- subset_foreignVessels %>% tally() 

foreignVessels <-  subset_foreignVessels %>% mutate(Type = factor(rep("Foreign.vessels.fishing.in.the.UK",n2),levels="Foreign.vessels.fishing.in.the.UK"))

# 3. Landings abroad by UK vessels 

subset_UKabroad <- subset(fisheriesData, !(Port.Nationality %in% c("England","Wales", "Scotland", "Northern Ireland")) & Vessel.Nationality == "UK")

n3 <-subset_UKabroad %>% tally() 

UKVesselsAbroad <- subset_UKabroad %>% mutate(Type = factor(rep("UK.vessels.fishing.abroad",n3),levels="UK.vessels.fishing.abroad"))

fisheriesData1 <- rbind(UKVesselsHome,UKVesselsAbroad,foreignVessels) %>% mutate(Year = factor(year(as.Date(Date)),levels=c("2014","2015","2016","2017")))

fisheries_plot2 <- fisheriesData1  %>% group_by(Year, Type, Species.Group) %>% summarise(Live.Weight=sum(Live.weight..tonnes.),Value=sum(Value..000s.))

fisheries_priceplot2  <- fisheries_plot2  %>% mutate(Price=Value*1000/Live.Weight)

# Top 3 fishes landed by the UK vessels in the UK and abroad
# Remove rows that contain 0. 

Top3Species.w <-  subset(subset(fisheriesData1, Type!="Foreign.Vessels.fishing.in.the.UK"), Live.weight..tonnes.!=0) %>%
        group_by(Year, Species.Group, Species) %>% tally(Live.weight..tonnes.) %>% top_n(3) %>% rename(Live.Weight = n)

Top3Species.v <- subset(subset(fisheriesData1, Type!="Foreign.Vessels.fishing.in.the.UK"), Value..000s.!=0)  %>%
        group_by(Year, Species.Group, Species) %>% tally(Value..000s.) %>% top_n(3) %>% rename(Value = n)

Top3Species <- subset(subset(fisheriesData1, Type!="Foreign.Vessels.fishing.in.the.UK"), Live.weight..tonnes.!=0)  %>%
        group_by(Year, Species.Group, Species) %>% summarise (Live.Weight=sum(Live.weight..tonnes.),Value=sum(Value..000s.)) 

Top3Species.p <- Top3Species %>% 
        group_by(Year, Species.Group, Species)  %>%  mutate(Price=Value*1000/Live.Weight) %>% tally(Price) %>% top_n(3) %>% rename(Price = n)

Top3Species_plot3 <- rbind(Top3Species.w,Top3Species.v,Top3Species.p)

# Shiny server

function(input, output) {

# Fishing activity over month of the year  
        string <- reactive(substring(input$Criteria,1,5))
        
        output$plot1 <- renderPlotly ({ 
                if (string() == "Live ") { 
                        p1 <-   ggplot(fisheries_trim, aes(x = Month.number, y = Live.Weight, fill = Year, colour = Year)) + geom_point(size = 6, shape = 18) + scale_x_continuous(name="Month of the Year", breaks=seq(1,12,1),labels= c("Jan", "Feb", "Mar", "Apr", "May", "Jun","Jul", "Aug", "Sep", "Oct", "Nov", "Dec")) + scale_y_continuous(name="Live Weight in '000 tonnes") + ggtitle("Fisheries activity over 12 months (Live Weight)") + theme(plot.title = element_text(size=12, face="bold")) 
                        
                        ggplotly(p1)%>%layout(margin=list(l=70, b=120))
                }
                
                else if (string() == "Total") {
                        p1 <-   ggplot(fisheries_trim, aes(x = Month.number, y = Value/1000, fill = Year, colour = Year)) + geom_point(size = 6, shape = 21, colour = "mediumvioletred") + scale_x_continuous(name="Month of the Year", breaks=seq(1,12,1),labels= c("Jan", "Feb", "Mar", "Apr", "May", "Jun","Jul", "Aug", "Sep", "Oct", "Nov", "Dec")) + scale_y_continuous(name="Total Fish Value in Million GBP") + ggtitle("Fisheries activity over 12 months (Total Value)") + theme(plot.title = element_text(size=12, face="bold"))    
                        
                        ggplotly(p1)%>%layout(margin=list(l=70, b=120))
                }
                
                else {
                        p1 <- ggplot(fisheries_price, aes(x = Month.number, y = Price, fill = Year, colour = Year)) + geom_point(size = 6, shape = 18) + scale_x_continuous(name="Month of the Year", breaks=seq(1,12,1),labels= c("Jan", "Feb", "Mar", "Apr", "May", "Jun","Jul", "Aug", "Sep", "Oct", "Nov", "Dec")) + scale_y_continuous(name="Average Fish Price (GBP per tonne)") + ggtitle("Average fish price over 12 months") + theme(plot.title = element_text(size=12, face="bold")) 
                        
                        ggplotly(p1)%>%layout(margin=list(l=70, b=120))
                }
        })
        
        # Comparing fishing activity of UK vessels in the UK and abroad, and foreign vessels in the UK 
        
        output$plot2 <- renderPlotly({
                
                if (string() == "Live ") { 
                        p2 <- ggplot(fisheries_priceplot2,aes(x=Year,y = Live.Weight/1000, fill=Type)) + geom_bar(position="dodge",stat="identity") + ggtitle("Landings over the years by species group") + labs(x = "Year", y = "Live Weight in '000 tonnes", fill="") + theme(plot.title = element_text(size=12, face="bold")) + facet_grid(.~Species.Group)  
                        
                        ggplotly(p2) %>% layout(margin=list(l=70, b=120)) 
                        
                }  else if (string() == "Total") {
                        p2 <- ggplot(fisheries_priceplot2, aes(x=Year,y = Value/1000, fill=Type)) + geom_bar(position="dodge",stat="identity") + ggtitle("Total fish value over the years by Species Group") + labs(x = "Year", y = "Total Value in Million GBP", fill="") + theme(plot.title = element_text(size=12, face="bold")) + facet_grid(.~Species.Group)       
                        ggplotly(p2)%>%layout(margin=list(l=70, b=120))
                        
                } else {
                        
                        p2 <- ggplot(fisheries_priceplot2, aes(x=Year,y=Price, fill=Type)) + geom_bar(position="dodge",stat="identity") + ggtitle("Average fish price over the years by Species Group") + labs(x = "Year", y = "Average Fish Price (GBP per tonne)", fill="") + theme(plot.title = element_text(size=12, face="bold")) + facet_grid(.~Species.Group) 
                        
                        ggplotly(p2)%>%layout(margin=list(l=70, b=120))
                }
        })
        
        # Key fishes landed by UK vessels in terms of quantity, total value and average price
        
        subset_species <- reactive({
                Top3Species_plot3[Top3Species_plot3$Species.Group == input$Species.Group,]})    
        output$plot3 <- renderPlotly({
                if (string() == "Live ") {
                        p3 <- ggplot(subset_species()[c(1:12),c(1:4)], aes(x = Year , y = Live.Weight/1000, fill=Species)) + geom_bar(position="dodge",stat = "identity") + labs(x = "Year", y = "Live Weight in '000 tonnes", fill="Species") + theme(plot.title = element_text(size=12, face="bold"))
                        
                        ggplotly(p3) %>% layout(margin=list(l=70, b=180))
                }
                else if (string() == "Total") {
                        p3 <- ggplot(subset_species()[c(13:24),c(1:3,5)], aes(x = Year, y = Value/1000, fill=Species)) + geom_bar(position="dodge",stat = "identity") + labs(x = "Year", y = "Total Value in Million GBP", fill="Species") + theme(plot.title = element_text(size=12, face="bold")) 
                        
                        ggplotly(p3) %>% layout(margin=list(l=70, b=180))
                }
                else{
                        p3 <-  ggplot(subset_species()[c(25:36),c(1:3,6)], aes(x = Year, y = Price, fill = Species)) + geom_bar(position="dodge", stat = "identity") + labs(x = "Year", y = "Average Fish Price (GBP per tonne)", fill="Species") + theme(plot.title = element_text(size=12, face="bold"))  
                        
                        ggplotly(p3) %>% layout(margin=list(l=70, b=180))
                }
        })
        

                
   
        subset_year <- reactive({
                fisheriesData1[fisheriesData1$Year == input$Year,]
                
        })
        
        output$dataviewerperyear <- renderDataTable({
                subset_year() %>% 
                        group_by(Year, Port.of.Landing, Port.Nationality) %>% summarise(Live.Weight = sum(Live.weight..tonnes.),Value=sum(Value..000s.*1000))
                
        })
        
        output$map <- renderLeaflet({
                
                mapdata <- subset_year() %>% group_by(Port.of.Landing, Lon, Lat) %>% summarise(Live.Weight=sum(Live.weight..tonnes.),Value=sum(Value..000s.*1000))
                
                leaflet(mapdata) %>% 
                        addProviderTiles(providers$Esri.NatGeoWorldMap) %>%
                        addMarkers(clusterOptions=markerClusterOptions(),~Lon,~Lat,popup= ~htmlEscape(paste(Port.of.Landing, " - ", paste0("Year: ", input$Year), "  ", paste0("Quantity: ", Live.Weight," tonnes"), "  ", paste0("Worth: GBP ", Value))))
        })
        
}
        
        
        
        


