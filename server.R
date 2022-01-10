# This is the server logic of this Shiny web application. 

library(shiny)

# Define server logic 
shinyServer(function(input, output, session) {
  
  LNAPLPresentServer("LNAPL_Present")
  
  LNAPLMigrateServer("LNAPL_Migrate")
  
  LNAPLPersistServer("LNAPL_Persist")
  
  LNAPLRiskServer("LNAPL_Risk")
  
  LNAPLRecoveryServer("LNAPL_Recovery")
  
  NSZDEstServer("NSZD_Est")


})
