# LNAPL Migrate Modules -----------------------------

## UI Module -----------------------------------------
LNAPLMigrateUI <- function(id, label = "LNAPL Migrate"){
  ns <- NS(id)
  
  tabPanel("LNAPL Migration",
           tags$i(h1("How far will the LNAPL migrate?")),
           tabsetPanel(
             ### Tier 1 -----------------------
             tabPanel(Tier1,
                      # Text
                      includeMarkdown("./www/03_LNAPL-Migration/Tier-1/LNAPL-Migration_Tier-1.md")
                      ), # end Tier 1
             ### Tier 2 -----------------------
             tabPanel(Tier2,
                      tabsetPanel(
                        ### Tier 2.1 -----------------------
                        tabPanel(HTML("<i>Additional Migration Tool</i>"),
                                 br(),
                                 fluidRow(
                                   column(4, style='border-right: 1px solid black',
                                          includeMarkdown("./www/03_LNAPL-Migration/Tier-2/LNAPL-Migrate_Tier-2-1.md"),
                                          br(), br()
                                          ), # end column 1
                                   column(2,
                                          HTML("<h3><b>Inputs:</b></h3>"),
                                          numericInput(ns("Trans"), HTML("LNAPL Transmissivity (m<sup>2</sup>/day)"), value = 0.1, min = 0, step = 0.1),
                                          numericInput(ns("Gradient"), HTML("LNAPL Gradient (m/m)"), value = 0.001, min = 0, step = 0.001),
                                          pickerInput(ns("Rate1"), HTML("NSZD Rate (L/ha/yr)"), 
                                                      choices = c(5000, 7300, 10000, 25000, 50000), 
                                                      selected = 5000, multiple = F),
                                          numericInput(ns("radius"),HTML("Current LNAPL Body Radius (m)"), value = 100, min = 0)
                                          ), # end column 2
                                   column(6, align = "center", style='border-left: 1px solid black',
                                          fluidRow(
                                          plotOutput(ns("T_v_Radius")),
                                          column(6, align = "center", br(), br(),
                                                 uiOutput(ns("Radial_Spread"))),
                                          column(6, align = "center",
                                                 plotOutput(ns("Radius_Spread")))
                                          )
                                          )# end column 3
                                   ) # end fluid row
                                 ), # end Tier 2.1
                        ### Tier 2.2 ---------------------------
                        tabPanel(HTML("<i>Mahler Migration Model</i>"),
                                 br(),
                                 fluidRow(
                                   column(4, style='border-right: 1px solid black',
                                          includeMarkdown("./www/03_LNAPL-Migration/Tier-2/LNAPL-Migrate_Tier-2-2.md"),
                                          br(), br()
                                          ), # end column 1
                                   column(2,
                                          HTML("<h3><b>Inputs:</b></h3>"), style='border-right: 1px solid black',
                                          pickerInput(ns("Release_Rate"), HTML("Long-Term LNAPL Release Rate (L/yr)"), 
                                                      choices = c(250, 510, 1010), 
                                                      selected = 250, multiple = F),
                                          pickerInput(ns("Rate"), HTML("NSZD Rate (L/ha/yr)"), 
                                                      choices = c(5000, 10000, 20000), 
                                                      selected = 5000, multiple = F),
                                          pickerInput(ns("Time_sel"), HTML("Time Period Of Model (years)"), 
                                                      choices = c(40, 80, 160), 
                                                      selected = 40, multiple = F)
                                          ), # end column 2
                                   column(6, align = "center",
                                          # plotOutput(ns("Length_Plot"))
                                          uiOutput(ns("Length_Text"))
                                          ) # end column 3
                                   ) # end fluid row
                                 ) # end Tier 2.2
                        ) 
                      ), # end Tier 2
             ### Tier 3 -----------------------------
             tabPanel(Tier3,
                      br(),
                      fluidRow(
                        column(2,), 
                        column(8, 
                               # Markdown Text
                               br(),
                               includeMarkdown("./www/03_LNAPL-Migration/Tier-3/LNAPL-Migration_Tier-3.md"),
                               br(),
                               gt_output(ns("Table_5")),
                               br(),
                               includeMarkdown("./www/03_LNAPL-Migration/Tier-3/LNAPL-Migration_Tier-3-2.md"),
                               br(), br()
                        ), # end column 1
                        column(2,
                        ) # end column 2
                        ) # end fluid row 
                      ) # end Tier 3
             )
           )
}# LNAPL Migrate UI

## Server Module --------------------------------------
LNAPLMigrateServer <- function(id) {
  moduleServer(
    id,
    
    function(input, output, session) {
      
      ## Tier 2.1 ------------------------
      ### Function to Calculate Migration -------------------
      
      cd_mig <- eventReactive({input$Trans
        input$Gradient
        input$Rate1},{
          
          req(input$Trans,
              input$Gradient,
              input$Rate1)
          
          validate(need(!is.na(input$Trans) & input$Trans > 0, 
                        "LNAPL Transmissivity is invalid! Calculated results should be discarded. Please try again..."))
          validate(need(!is.na(input$Gradient) & input$Gradient > 0, 
                        "LNAPL Gradient is invalid! Calculated results should be discarded. Please try again..."))
          
          # Filter Lookup table by NSZD Rate
          r_lookup <- LNAPL_MigrationModel %>% filter(NSZD_Lhayr == input$Rate1)
          
          # Calculating Tn * i
          Tn_x_i <- input$Trans * input$Gradient
          
          # Find Numeric Answer 
          cd_ans <- data.frame(Tn_i = Tn_x_i,
                               R = ifelse(Tn_x_i <= 0.0004, Tn_x_i*r_lookup$Lower.Slope + r_lookup$Lower_yint, 
                                          Tn_x_i*r_lookup$Upper.Slope + r_lookup$Upper_yint))
          
          # Create df for line on plot
          cd_line <- data.frame(Tn_i = seq(0, Tn_x_i*2, length.out = 100)) %>%
            mutate(R = ifelse(Tn_i <= 0.0004, Tn_i*r_lookup$Lower.Slope + r_lookup$Lower_yint, 
                              Tn_i*r_lookup$Upper.Slope + r_lookup$Upper_yint)) %>%
            filter(R >= 0)
          
          validate(need(cd_ans$R > 0,
                        "Nomograph indicates negative additional spreading, so no additional spreading assumed."))
          
          list(ans = cd_ans, line = cd_line)
        }) # end cd_mig
      
      ### Plot of Migration Results -----------------------
      output$T_v_Radius <- renderPlot({
        
        cd <- cd_mig()
      
        # Determine Max limits based on calculated Value
        y_lim <- cd[["ans"]]$R*2
        x_lim <- cd[["ans"]]$Tn_i*2
        
        # Create Plot
        plot <- ggplot(data = cd[["line"]]) +
          geom_path(data = cd[["line"]], aes(x = Tn_i, y = R, color = "black"), size = 2) +
          geom_point(data = cd[["ans"]], aes(x = Tn_i, y = R, color = "red"), size = 5) +
          labs(x = expression(bold("\nTn x i "~(m^2/day)),"\n"), 
               y = "Estimated Additional\nRadial Spread (m)") +
          scale_x_continuous(limits = c(0, x_lim), labels = fmt_dcimals(1, "E")) +
          scale_y_continuous(limits = c(0, y_lim), labels = fmt_dcimals(0, "f"))  +
          scale_color_identity(breaks = c("black", "red"),
                               labels = c("Migration nomograph","Modeled LNAPL plume"),
                               guide = guide_legend(override.aes = list(
                                 linetype = c("solid", "blank"),
                                 shape = c(NA, 16)))) +
          theme +
          theme(legend.position = "bottom")
        
        plot
      }) # end T_v_Radius
      
      ### Answer: Radial Spread -----------------------
      output$Radial_Spread <- renderUI({
        # Calculate Result and format
        cd <- cd_mig()[["ans"]]
        # colnames(cd) <- c("Tn_i", "R")
        
        HTML(paste0("<h2><b>Answer: Estimated Additional Radial Spread of the LNAPL:<br>", formatC(round(cd$R,0), big.mark = ",")), "meters</b></h2>")
         
      }) # end Radial_Spread
      
      
      ### Circle Plot of Calculated and Given Radius ----------
      output$Radius_Spread <- renderPlot({
        # Calculate Result and format
        cd <- cd_mig()[["ans"]]
        
        req(input$radius)
        validate(need(!is.na(input$radius) & input$radius >= 0, 
                      "Current LNAPL Body Radius is invalid! Calculated results should be discarded. Please try again..."))
        r <- input$radius
        
        cd <- data.frame(Name = c("Estimated Ultimate Extent of LNAPL Body (m)", "Approximate Current LNAPL Body (m)"), 
                        Value = c(cd$R + r, r))
        
        plot <- ggplot(cd) +
          geom_circle(aes(x0 = 0, y0 = 0, r = Value, color = Name, linetype = Name), size = 2) +
          scale_color_manual(values = c("Approximate Current LNAPL Body (m)" = "black",
                                        "Estimated Ultimate Extent of LNAPL Body (m)" = "grey")) + 
          guides(color = guide_legend(nrow=2,byrow=TRUE)) +
          labs(x = "\nRadial Spread (m)\n") +
          coord_fixed() + 
          theme +
          theme(panel.border = element_blank(),
                axis.text.y = element_blank(), 
                axis.title.y = element_blank(),
                panel.grid.major.y =  element_blank(),
                axis.ticks.y = element_blank(),
                axis.ticks.x = element_line(colour = "black"),
                axis.line.x = element_line(colour = "black"),
                legend.position = "bottom")
        plot
      })# end Radius_Spread
      
      ## Tier 2.2 ------------------------
      ### Update Time Dropdown --------------------
      observeEvent({
        input$Release_Rate
        input$Rate},{
          
          req(input$Release_Rate,
              input$Rate)
          
          choices <- unique((LNAPLMigrate_Mahler %>%
                               filter(LNAPL.Source.L.yr == input$Release_Rate, NSZD.Rate.L.ha.yr == input$Rate))$Time.Period.yr)
          
          updatePickerInput(session = session, inputId = "Time_sel",
                            choices = choices)
        }) # end updatePickerInput for Time_sel
      
      ### Function to subset look-up table based on inputs --------------
      ans <- eventReactive({
        input$Release_Rate
        input$Rate
        input$Time_sel},{
          
        req(input$Release_Rate,
            input$Rate,
            input$Time_sel)
        
        cd <- LNAPLMigrate_Mahler %>% 
          filter(NSZD.Rate.L.ha.yr == input$Rate, Time.Period.yr == input$Time_sel) %>%
          mutate(color = ifelse(LNAPL.Source.L.yr == input$Release_Rate, "red",  plot_col[1]),
                 size = ifelse(LNAPL.Source.L.yr == input$Release_Rate, 8, 5))
        
        cd
      }) # end ans
      
      ## Create Text Output --------------------
      output$Length_Text <- renderUI({
        cd <- ans()

        ans <- filter(cd, color == "red")
        ans <- prettyNum(signif(ans$Plume.Length.m, 3), big.mark = ",")
        
        HTML(paste0("<h2>Estimated Ultimate LNAPL Body Length: <br><b>", ans, " m</b></h2>"))
      })# end Length_Text
      
      ## Tier 3 -----------------------------
      ## Table 5 ----------------
      output$Table_5 <- render_gt({
        
        Table5 <- read.csv("./data/LNAPL-Migrat_Tier-3_Table_5.csv", encoding = "UTF-8", colClasses = "character")
        
        Table5 %>% gt() %>%
          tab_header("Table 5 Outline of HSSM-WIN Interface") %>%
          cols_label(Interface.Function = "Interface Function", Section.References = "Section References") %>%
          tab_style(style = list(cell_text(weight = "bold", align = "center")),
                    locations = cells_title(group = "title"))%>%
          tab_style(style = list(cell_text(align = "center")),
                    locations = cells_body(columns = "Section.References", rows = everything())) %>%
          tab_style(style = list(cell_text(align = "center")),
                    locations = cells_column_labels(columns = everything())) %>%
          tab_style(style = list(cell_borders(sides = "all", color = "black", weight = px(2))),
                    locations = list(cells_body(), cells_column_labels(columns = everything()), cells_title(group = "title")))
        
      }) # end Table5
      
    }
  )}
      