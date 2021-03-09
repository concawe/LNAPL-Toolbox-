# USER INTERFACE -------------
## Load packages -------------

library(shiny)
library(shinyBS)
library(shinythemes)
library(shinyjs)
require(shinyWidgets)

require(DT)
require(dbplyr)

require(leaflet)
require(leaflet.extras)

require(plotly)

## Define UI ---------------------------------
shinyUI <- navbarPage(theme="styles.css", 
                      collapsible = TRUE, fluid=TRUE, 
                      windowTitle = "LNAPL Toolbox",
                      title=div(a(" ",
                                  img(src="https://www.concawe.eu/wp-content/uploads/2018/03/logo-new-concawe.png"), 
                                  href = 'https://www.concawe.eu/', target="_blank")),
                      id="nav",
                      # Tab panels 
                      tabPanel("Home",
                               includeHTML("./www/00_Home-Page/home.html"),
                               tags$script(src = "./plugins/scripts.js"),
                               tags$head(
                                 tags$link(rel = "stylesheet", 
                                           type = "text/css", 
                                           href = "./plugins/font-awesome-4.7.0/css/font-awesome.min.css"),
                                 tags$link(rel = "icon",  
                                           type = "image/png", 
                                           href = "./images/logo_icon.png")
                                 )
                   ), #end home tab
                   
                   tabPanel("Toolbox Overview",
                            fluidRow(
                              column(8,
                                     includeMarkdown("./www/01_LNAPL-Overview/app_info.md"))
                            )# end Fluid Row
                   ), #end LNAPL Overview tab

                   LNAPLPresentUI("LNAPL_Present"),

                   LNAPLMigrateUI("LNAPL_Migrate"),

                   LNAPLPersistUI("LNAPL_Persist"),

                   LNAPLRiskUI("LNAPL_Risk"),

                   LNAPLRecoveryUI("LNAPL_Recovery"),

                   NSZDEstUI("NSZD_Est")

) # End UI
