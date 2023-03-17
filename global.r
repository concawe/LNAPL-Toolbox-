# GSI Environmental -------------
##
## Script name: 5538_Concawe_LNAPL-Webtool_1.0a
##
## Purpose of script: Version 1.0a of the Concawe Webtool
##
## Author: K.Whitehead
##         H. Podzorski
##
## Date Created: 2020-04-02
##
## Job Name: CONCAWE 
## Job Number: 5538
## 
## Notes:  https://www.concawe.eu/wp-content/uploads/2018/03/logo-new-concawe.png

options(stringsAsFactors = FALSE)

# Load Packages ----------------

require(tidyverse)
require(readxl)
require(leaflet)
require(leaflet.extras)
require(scales)
require(gridExtra)
require(gt)
require(openxlsx)
require(ggforce)
library(gstat)
library(sp)
library(rgdal)
library(raster)
library(shinycssloaders)
library(dismo)
library(leafem)
library(deldir)
library(rgeos)

require(plotly)
library(rsconnect)

library(reticulate)
# py <- rminiconda::find_miniconda_python("concawe")
# reticulate::use_python(py, required = TRUE)

# Plot Parameters -------------
# Colors
# The palette with grey:
plot_col <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# GGPLOT Theme Object
theme <- theme(
  #Panel Border
  panel.border = element_rect(color = "black", fill = NA, linetype = 1, size = 0.5),
  plot.margin = unit(c(0.5,0.5,.5,0.5),"cm"),
  #Background
  panel.background = element_rect(fill = NA),
  strip.background =element_rect(fill = NA),
  #Grid Lines
  panel.grid.major.x = element_blank(),
  panel.grid.minor.x = element_blank(),
  panel.grid.major.y =  element_line(color = "grey", linetype = 1, size = 0.5),
  panel.grid.minor.y = element_blank(),
  #Text
  text = element_text(family = "sans"),
  axis.text.x = element_text(color="black", size=14, vjust=0.5,hjust = 0.5, angle=0),
  axis.text.y = element_text(color="black", size=14, vjust=0.5), 
  axis.title.x=element_text(color="black", size=22, face="bold"),
  axis.title.y=element_text(color="black", size=22, vjust=2, face="bold"),
  plot.title = element_text(size = 25, hjust = 0.5, face="bold"),
  strip.text = element_text(size = 10, hjust = 0, face="bold"),
  #Legend
  legend.title = element_blank(), 
  legend.position = "none",
  legend.text = element_text(color = "black", size = 14, family = "sans"),
  legend.key = element_rect(fill = NA, color = NA),
  legend.spacing.x = unit(0.25,"cm")
) 

# Functions -----------------
#Convert lat/long
convert_coords <- function(x,y) {
  
  library(rgdal)
  
  loc.points <- data.frame(x_coords=x, y_coords=y)
  
  sputm <- SpatialPoints(loc.points, proj4string=CRS("+init=epsg:3582"))  
  spgeo <- spTransform(sputm, CRS("+init=epsg:4326"))
  
  loc.points <- spgeo@coords
  
  x_coords = loc.points[,1]
  y_coords = loc.points[,2]
  
  coords <- data.frame(x=x_coords, y=y_coords)
  
  return(coords)
  
}

# Format axis numbers 
fmt_dcimals <- function(decimals=5, format = "G"){ 
  function(x) formatC(x, digits = decimals, big.mark = ",", format = format)
}

# Source Python Code ------------------
# Define any Python packages needed for the app

# Define any Python packages needed for the app

source_python("./R/Python_Code/LNAPL_SubsurfVolExt.py")
source_python("./R/Python_Code/LNAPL_NSZDTempEnhanceCalc.py")
source_python("./R/Python_Code/LNAPL_NSZDSourceLifetime.py")
source_python("./R/Python_Code/LNAPL_NSZDRateConverter.py")
source_python("./R/Python_Code/LNAPL_ConcHistCalculator_v1-1.py")
source_python("./R/Python_Code/LNAPL_DarcyCalculator.py")
source_python("./R/Python_Code/LNAPL_MigrationModel.py")

# Formatting --------------------------
##Set styles for buttons --------------

button_style <- "white-space: normal;
                        background-color:#eee;
                        text-align:center;
                        height:60px;
                        width:150px;
                        font-size: 14px;
                        padding: 10px 0;
                        margin:5px;"

button_style_big <- "white-space: normal;
                        text-align:center;
                        height:100px;
                        width:300px;
                        font-size: 18px;"

## Tab Titles ----------------
Tier1 <- HTML("<p style='text-align:center; margin-bottom:0;'>Tier 1<br>Quick Info</p>")
Tier2 <- HTML("<p style='text-align:center; margin-bottom:0;'>Tier 2<br>Models/Tools</p>")
Tier3 <- HTML("<p style='text-align:center; margin-bottom:0;'>Tier 3<br>Gateway to Complex Tools</p>")

# LNAPL Volume -----------------
## Tier 2 ----------------------

default_loc <- read_xlsx("./data/LNAPL_Volume_Data_Template.xlsx", sheet = "Location_Information", range = cell_cols("A:G"), 
                 col_types = c("text", "text", "numeric", "numeric", "numeric", "numeric", "numeric")) %>%
  select(Location = `Monitoring Well`, 
         Date, Latitude, Longitude, 
         LNAPL_Top_Depth_m = `LNAPL Top Depth Below Ground Surface (m)`, 
         LNAPL_Bottom_Depth_m = `LNAPL Bottom Depth Below Ground Surface (m)`,
         LNAPL_Gradient = `LNAPL Gradient (m/m)`) %>% 
  filter(Location != "Add additional rows as needed.") %>%
  mutate(Date = as.character(Date))

default_strat <- read_xlsx("./data/LNAPL_Volume_Data_Template.xlsx", sheet = "Stratigraphy", range = cell_cols("A:D"),
                   col_types = c("text", "numeric", "numeric", "text")) %>%
  select(Location = `Monitoring Well`, 
         Layer_Top_Depth_m = `Layer Top Depth Below Ground Surface (m)`, 
         Layer_Bottom_Depth_m = `Layer Bottom Depth Below Ground Surface (m)`, 
         Soil_Type = `Soil Type`) %>% 
  filter(Location != "Add additional rows as needed.")

default_soil <- read_xlsx("./data/LNAPL_Volume_Data_Template.xlsx", sheet = "Soil_Types", range = cell_cols("A:H"),
                  col_types = c("text", "text", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric")) %>%
  na.omit() %>%
  select(Soil_Num = 1, Soil_Type = 2, Porosity = 3, `Ks_m-d` = 4, Theta_wr = 5, N = 6, alpha_m = 7, M = 8) %>% 
  mutate(Soil_Num = as.numeric(Soil_Num))

gen_map <- leaflet() %>%
  addTiles(urlTemplate = 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
           attribution = '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy; <a href="http://cartodb.com/attributions">CartoDB</a>',
           group='Base', options = providerTileOptions(maxNativeZoom=19,maxZoom=100)) %>%
  addTiles(urlTemplate = "https://mts1.google.com/vt/lyrs=m&hl=en&src=app&x={x}&y={y}&z={z}&s=G", group="Roads (Google)",
           options = providerTileOptions(maxNativeZoom=19,maxZoom=100)) %>%
  addProviderTiles(providers$Esri.WorldTopoMap, group="Topo (ESRI)",
                   options = providerTileOptions(maxNativeZoom=19,maxZoom=100)) %>%
  addTiles(urlTemplate = "https://mts1.google.com/vt/lyrs=p&hl=en&src=app&x={x}&y={y}&z={z}&s=G", group="Topo (Google)",
           options = providerTileOptions(maxNativeZoom=19,maxZoom=100)) %>%
  addProviderTiles(providers$Esri.WorldImagery, group="Satellite (ESRI)",
                   options = providerTileOptions(maxNativeZoom=19,maxZoom=100)) %>%
  addTiles(urlTemplate = "https://mts1.google.com/vt/lyrs=s&hl=en&src=app&x={x}&y={y}&z={z}&s=G", group="Satellite (Google)",
           options = providerTileOptions(maxNativeZoom=19,maxZoom=100)) %>%
  addTiles(urlTemplate = "https://mts1.google.com/vt/lyrs=y&hl=en&src=app&x={x}&y={y}&z={z}&s=G", group="Hybrid (Google)",
           options = providerTileOptions(maxNativeZoom=19,maxZoom=100)) %>%
  addMapPane("polygons", zIndex = 410) %>%
  addMapPane("markers", zIndex = 420) %>%
  addScaleBar(position = "bottomleft", options = scaleBarOptions(metric = T, imperial = F))

# LNAPL-Migrate ---------------------------
## Tier-2 ---------------------------------
LNAPL_MigrationModel <- read.csv("./data/LNAPL_MigrationModel.csv")
LNAPLMigrate_Mahler <- read.csv("./data/LNAPL-Migrate_Mahler-Migration.csv")

# LNAPL-Persist ---------------------------
## Tier 1 ---------------------------------
# Table
LNAPLPersist_Table <- read.csv("./data/LNAPL-Persist_Tier-1.csv", encoding = "UTF-8")
colnames(LNAPLPersist_Table)[1] <- "rows"

LNAPLPersist_Table <- LNAPLPersist_Table %>% gt(rowname_col = "rows") %>%
  cols_label(Number.of.Sites = "Number of Sites",
             Minimum.Monitoring.Time.Period..years. = HTML("Minimum Monitoring Time Period <br> (years)"),
             Median.Apparent.LNAPL.Thickness.in.Monitoring.Wells.During.Monitoring.Period..meters. = 
               HTML("Median Apparent LNAPL Thickness in Monitoring Wells During Monitoring Period <br> (meters)"),
             Median.Reduction.in.Apparent.LNAPL.Thickness.in.Monitoring.Wells.Over.Monitoring.Period....reduction. = 
               HTML("Median Reduction in Apparent LNAPL Thickness in Monitoring Wells Over Monitoring Period <br> (% reduction)"),
             Time.for.Benzene.Groundwater.Conc..To.Be.Reduced.by.50...Half.Life...years. = 
               HTML("Time for Benzene Groundwater Conc. To Be Reduced by 50% <br> (Half Life) <br> (years)")) %>%
  tab_style(style = list(cell_text(align = "center"),
                         cell_borders(sides = "all", color = "black", weight = px(2))),
            locations = list(cells_body(), cells_column_labels(columns = 1:5))) %>%
  tab_style(style = list(cell_text(align = "center"),
                         cell_borders(sides = "all", color = "black", weight = px(2))),
            locations = list(cells_stub(), cells_stubhead()))

# LNAPL Risk ----------------------------
## Tier 1 -------------------------------
# Table 1
LNAPLRisk_Table1 <- read.csv("./data/LNAPL-Risk_Tier-1-1.csv", encoding = "UTF-8", colClasses = "character")
colnames(LNAPLRisk_Table1)[1] <- "Col. 1"
  

LNAPLRisk_Table1 <- LNAPLRisk_Table1 %>% gt() %>%
  tab_header("Change in Risk Due to LNAPL Weathering: A Hypothetical Example") %>%
  cols_label(Col..2 = "Col. 2", Col..3 = "Col. 3", Col..4 = "Col. 4", Col..5 ="Col. 5", 
             Col..6 = "Col. 6", Col..7 = "Col. 7", Col..8 = "Col. 8", Col..9 = "Col. 9") %>%
  tab_options(row.striping.include_table_body = FALSE) %>%
  tab_style(style = list(cell_text(weight = "bold")),
            locations = cells_title(group = "title")) %>%
  tab_style(style = list(cell_text(style = "italic", align = "center")),
            locations = cells_column_labels(columns = everything())) %>%
  tab_style(style = list(cell_borders(sides = "all", color = NULL),
                         cell_text(align = "center")),
            locations = cells_body(columns = everything())) %>%
  tab_style(style = list(cell_borders(sides = "b", style = "solid", weight = px(3))),
            locations = cells_body(columns = everything(), rows = 1)) %>%
  tab_style(style = list(cell_borders(sides = "r")),
            locations = cells_body(columns = "Col. 1", rows = 1:7)) %>%
  tab_style(style = list(cell_text(align = "right")),
            locations = cells_body(columns = "Col. 1", rows = 2:7)) %>%
  tab_style(style = list(cell_borders(sides = c("r"))),
            locations = cells_body(columns = 4, rows = 1:7)) %>%
  tab_style(style = list(cell_borders(sides = c("r"))),
            locations = cells_body(columns = 3, rows = 1:7))%>%
  tab_style(style = list(cell_borders(sides = c("r"))),
            locations = cells_body(columns = 6, rows = 1:7)) %>%
  tab_style(style = list(cell_borders(sides = c("r"))),
            locations = cells_body(columns = 7, rows = 1:7)) %>%
  tab_style(style = list(cell_borders(sides = c("b"))),
            locations = cells_body(columns = everything(), rows = 7)) %>%
  tab_style(style = list(cell_text(weight = "bold")),
            locations = cells_body(columns = everything(), rows = 8)) %>%
  tab_style(style = list(cell_text(color = "red", weight = "bold")),
            locations = cells_body(columns = everything(), rows = 9)) %>%
  tab_style(style = list(cell_text(align = "right")),
            locations = cells_body(columns = 8, row = 9))

LNAPLRisk_Table2 <- read.csv("./data/LNAPL-Risk_Tier-1-2.csv", encoding = "UTF-8")
colnames(LNAPLRisk_Table2)[1] <- "Compound Name"
  
# NSZD Est ----------------------------
##Tier 2 ------------------------------
# Key Assumption Table
para <- read.csv("./data/NSZD-Est_Parameter-Table_Tier-2.csv")

para <- para %>% gt() %>%
  cols_label(LNAPL.Type.or.Representative.Compound = "LNAPL Type or Representative Compound", 
             Density..g.mL. = "Density (g/mL)",
             Molecular.Weight..g.mol. = "Molecular Weight (g/mol)") %>%
  tab_style(style = list(cell_borders(sides = "all", color = "black"),
                         cell_text(align = "center", size = "small")),
            locations = list(cells_body(columns = everything()),
                             cells_column_labels(columns = everything()))) %>%
  tab_style(style = list(cell_fill(color = "#DDEBF7")),
            locations = list(cells_column_labels(columns = everything())))
  

# Rate Converter Constants
conv_all <- c("gal/ac/yr_to_gal/ac/yr", "gal/ac/yr_to_L/ha/yr", "gal/ac/yr_to_umol CO2/m2/sec", "gal/ac/yr_to_g/m2/yr",
              "gal/ac/yr_to_lb/ac/yr", "gal/ac/yr_to_kg/ha/yr", "L/ha/yr_to_gal/ac/yr","L/ha/yr_to_L/ha/yr",
              "L/ha/yr_to_umol CO2/m2/sec","L/ha/yr_to_g/m2/yr","L/ha/yr_to_lb/ac/yr","L/ha/yr_to_kg/ha/yr",
              "umol CO2/m2/sec_to_gal/ac/yr","umol CO2/m2/sec_to_L/ha/yr","umol CO2/m2/sec_to_umol CO2/m2/sec",
              "umol CO2/m2/sec_to_g/m2/yr","umol CO2/m2/sec_to_lb/ac/yr","umol CO2/m2/sec_to_kg/ha/yr","g/m2/yr_to_gal/ac/yr",
              "g/m2/yr_to_L/ha/yr","g/m2/yr_to_umol CO2/m2/sec","g/m2/yr_to_g/m2/yr","g/m2/yr_to_lb/ac/yr","g/m2/yr_to_kg/ha/yr",
              "lb/ac/yr_to_gal/ac/yr","lb/ac/yr_to_L/ha/yr","lb/ac/yr_to_umol CO2/m2/sec","lb/ac/yr_to_g/m2/yr",
              "lb/ac/yr_to_lb/ac/yr","lb/ac/yr_to_kg/ha/yr","kg/ha/yr_to_gal/ac/yr","kg/ha/yr_to_L/ha/yr","kg/ha/yr_to_umol CO2/m2/sec",
              "kg/ha/yr_to_g/m2/yr","kg/ha/yr_to_lb/ac/yr","kg/ha/yr_to_kg/ha/yr","kg/yr_to_kg/yr","kg/yr_to_L/ha/yr",
              "L/yr_to_L/yr","L/yr_to_L/ha/yr")

conv_w_area <- c("L/yr_to_L/ha/yr")

conv_w_compound_area <- c("kg/yr_to_L/ha/yr")

conv_w_compounds <-c("gal/ac/yr_to_umol CO2/m2/sec", "gal/ac/yr_to_g/m2/yr", 
                     "gal/ac/yr_to_lb/ac/yr","gal/ac/yr_to_kg/ha/yr", 
                     "L/ha/yr_to_umol CO2/m2/sec", "L/ha/yr_to_g/m2/yr", "L/ha/yr_to_lb/ac/yr", "L/ha/yr_to_kg/ha/yr",
                     "umol CO2/m2/sec_to_gal/ac/yr","umol CO2/m2/sec_to_L/ha/yr","umol CO2/m2/sec_to_g/m2/yr","umol CO2/m2/sec_to_lb/ac/yr",
                     "umol CO2/m2/sec_to_kg/ha/yr","g/m2/yr_to_gal/ac/yr","g/m2/yr_to_L/ha/yr","g/m2/yr_to_umol CO2/m2/sec",
                     "lb/ac/yr_to_gal/ac/yr","lb/ac/yr_to_L/ha/yr","lb/ac/yr_to_umol CO2/m2/sec","kg/ha/yr_to_gal/ac/yr",
                     "kg/ha/yr_to_L/ha/yr","kg/ha/yr_to_umol CO2/m2/sec")


# HTML labels for NSZDEst RateConverter
data_for_select_in <- tibble(value = c("gal/ac/yr", "L/ha/yr", "umol CO2/m2/sec", "g/m2/yr", "lb/ac/yr", "kg/ha/yr", "kg/yr", "L/yr"),
                          label = c("gal/ac/yr", "L/ha/yr", "umol CO2/m2/sec", "g/m2/yr", "lb/ac/yr", "kg/ha/yr", "kg/yr", "L/yr"),
                          html = c("gal/ac/yr", "L/ha/yr", 
                                   HTML("µmol CO<sub>2</sub>/m<sup>2</sup>/sec"), 
                                   HTML("g/m<sup>2</sup>/yr"),
                                   "lb/ac/yr", "kg/ha/yr", "kg/yr", "L/yr"))

data_for_select_out <- tibble(value = c("gal/ac/yr", "L/ha/yr", "umol CO2/m2/sec", "g/m2/yr", "lb/ac/yr", "kg/ha/yr"),
                             label = c("gal/ac/yr", "L/ha/yr", "umol CO2/m2/sec", "g/m2/yr", "lb/ac/yr", "kg/ha/yr"),
                             html = c("gal/ac/yr", "L/ha/yr", 
                                      HTML("µmol CO<sub>2</sub>/m<sup>2</sup>/sec"), 
                                      HTML("g/m<sup>2</sup>/yr"),
                                      "lb/ac/yr", "kg/ha/yr"))

## Tier 3 ---------------------------------------------
# HTML Table1
NSZD_Est_Table1 <- read.csv("./data/LNAPL-NSZD_Est_Tier-1.csv", colClasses = "character")

NSZD_Est_Table1  <- NSZD_Est_Table1 %>% gt() %>%
  tab_spanner(label = "Site Wide NSZD Rate (Gallons/Acre/Year)",
              columns = vars(Site.Wide.NSZD.Rate..Gallons.Acre.year.__.All.Sites.,
                             Site.Wide.NSZD.Rate...Gallons.Acre.year.__.Middle.50..)) %>%
  tab_header("Examples of Site-Wide Average NSZD Rate Measurements at Field Sites") %>%
  cols_label(NSZD.Study = "NSZD Study", Number.of.Sites = "Number of Sites", 
             Site.Wide.NSZD.Rate..Gallons.Acre.year.__.All.Sites. = "All Sites", 
             Site.Wide.NSZD.Rate...Gallons.Acre.year.__.Middle.50.. = "Middle 50%", 
             Reference = "Reference") %>%
  tab_options(row.striping.include_table_body = FALSE) %>%
  tab_style(style = list(cell_text(weight = "bold")),
            locations = cells_title(group = "title")) %>%
  tab_style(style = list(cell_text(align = "center")),
            locations = cells_column_labels(columns = everything())) %>%
  tab_style(style = list(cell_borders(sides = "all", color = NULL),
                         cell_text(align = "center")),
            locations = cells_body(columns = everything())) %>%
  tab_style(style = list(cell_text(align = "left")),
            locations = cells_body(columns = c(1, 5), row = everything())) %>%
  tab_style(style = list(cell_text(weight = "bold")),
            locations = cells_body(columns = 2:4, row = 8)) %>%
  tab_source_note(source_note = "Notes: Middle 50% column shows the 25th and 75th percentile values. To demonstrate the 
                  significance of methanogenesis, NSZD rates calculated from the biodegradation capacity of electron acceptors 
                  in the saturated zone, ignoring methanogenesis, are shown in the last row.")

# HTML Table2
NSZD_Est_Table2 <- read.csv("./data/NSZD-Table_Tier-3.csv", colClasses = "character")

NSZD_Est_Table2  <- NSZD_Est_Table2 %>% gt() %>%
  tab_header("SUMMARY OF NSZD RATES FROM 31 SITES") %>%
  cols_label(Fuel.Type = "Fuel Type",
             Fuel.Carbon.Range = "Fuel Carbon Range",                         
             Number.of.Distinct.Sites = "Number of Distinct Sites",
             Total.No..of.Measurements = "Total No. of Measurements",                 
             Range.of.NSZD.Rates.Measured..L.ha.yr. = "Range of NSZD Rates Measured (L/ha/yr)",    
             Median.NSZD.Rate...L.ha.yr. = "Median NSZD Rate (L/ha/yr)") %>%
  tab_options(row.striping.include_table_body = FALSE) %>%
  tab_style(style = list(cell_text(weight = "bold")),
            locations = cells_title(group = "title")) %>%
  tab_style(style = list(cell_text(align = "center", weight = "bold")),
            locations = cells_column_labels(columns = everything())) %>%
  tab_style(style = list(cell_borders(sides = "all", color = NULL),
                         cell_text(align = "center")),
            locations = cells_body(columns = everything())) %>%
  tab_style(style = list(cell_text(align = "right")),
            locations = cells_body(columns = c(1), row = everything())) %>%
  tab_style(style = list(cell_text(align = "right")),
            locations = cells_body(columns = c(1, 5), row = 7)) %>%
  tab_style(style = list(cell_text(weight = "bold")),
            locations = cells_body(columns = everything(), row = 7)) %>%
  tab_source_note(source_note = "*May also contain smaller amounts of C7-C12 hydrocarbons")%>%
  tab_style(style = list(cell_borders(sides = "all", color = "black")),
            locations = list(cells_body(columns = everything()),
                             cells_column_labels(columns = everything()))) %>%
  tab_style(style = list(cell_fill(color = "#DDEBF7")),
            locations = list(cells_column_labels(columns = everything())))


## Loading Modules ------------------------------------

source("./R/LNAPLPresent.R")

source("./R/LNAPLMigrate.R")

source("./R/LNAPLPersist.R")

source("./R/LNAPLRisk.R")

source("./R/NSZDEst.R")

source("./R/LNAPLRecovery.R")

# Shinyio ------------------------------------------
# rsconnect::deployApp()

