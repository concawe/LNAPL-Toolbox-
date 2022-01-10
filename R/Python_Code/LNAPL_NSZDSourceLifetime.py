# -*- coding: utf-8 -*-
# CONCAWE LNAPL TOOLBOX: NATURAL SOURCE ZONE DEPLETION (NSZD) SOURCE LIFETIME ESTIMATOR
import argparse
import numpy as np

# Print argument value for debugging purposes and return None
def argEcho(argName,argValue):
    print(argName, ':', argValue)

# Natural Source Zone Depletion (NSZD) rate in liters per year
def NSZD_RateOut(LNAPL_Area,NSZD_Rate1):
    return LNAPL_Area*NSZD_Rate1

# Estimate range (in years) when most/all LNAPL will be removed by NSZD
def NSZD_RemovalRng(LNAPL_Vol,LNAPL_Area,NSZD_Rate1):
    # Calculate NSZD rate - output
    NSZD_Rate2 = NSZD_RateOut(LNAPL_Area,NSZD_Rate1)
    
    yrRem1 = LNAPL_Vol/NSZD_Rate2
    yrRem2 = -LNAPL_Vol*np.log(0.01)/NSZD_Rate2 # 99% removal for first-order
    return(yrRem1,yrRem2)
    
# LNAPL volume as a function of time
def NSZD_VolOut(LNAPL_Vol,LNAPL_Area,NSZD_Rate1,Yr_start,Yr_end):
    # Calculate NSZD rate - output
    NSZD_Rate2 = NSZD_RateOut(LNAPL_Area,NSZD_Rate1)
    
    yrRng = range(Yr_start,Yr_end+1)
    datOut = np.zeros((Yr_end-Yr_start+1,4))
    count = 0
    for yr in yrRng:
        datOut[count,0] = yr
        datOut[count,1] = count
        
        if (LNAPL_Vol-(datOut[count,1]*NSZD_Rate2)) > 0:
            datOut[count,2] = LNAPL_Vol-(datOut[count,1]*NSZD_Rate2) # zero-order estimate
        else:
            datOut[count,2] = 0 # zero-order estimate
            
        if (LNAPL_Vol*np.exp((-NSZD_Rate2/LNAPL_Vol*datOut[count,1]))) > 0:
            datOut[count,3] = LNAPL_Vol*np.exp((-NSZD_Rate2/LNAPL_Vol*datOut[count,1])) # first-order estimate
        else:
            datOut[count,3] = 0 # first-order estimate
            
        count = count + 1
    return(datOut)

# main program starts here
if __name__ == '__main__':
    # Setup the argument parser class
    parser = argparse.ArgumentParser(prog='LNAPL_NSZDSourceLifetime',
                                     formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description='''\
CONCAWE LNAPL TOOLBOX: NATURAL SOURCE ZONE DEPLETION (NSZD) SOURCE LIFETIME ESTIMATOR

This calculator shows two different models of how NSZD will remove LNAPL over time.
  • “zero order” NSZD model:  The current NSZD rate stays constant over a long 
                              period of time, as suggested by Garg et al., 2017 
                              (see excerpt below).
  • “first order” NSZD model: The current NSZD rate drops in proportion to the 
                              mass of LNAPL remaining.  Many natural attenuation 
                              models assume this type of relationship 
                              (e.g., BIOSCREEN model, Newell et al., 1996).
                              
These two models can be used to frame a range of potential years when the LNAPL 
is all or substantially gone.   
                                     ''',
                                     epilog='''\
RETURN VALUES DESCRIPTION:
=========
NSZD_RateOut:    Enhanced Natural Source Zone Depletion (NSZD) rate in liters 
                 per year.
              
NSZD_RemovalRng: Estimated range (in years) when most/all LNAPL will be removed 
                 by NSZD.

NSZD_VolOut:     LNAPL volume as a function of time for both "zero order" and 
                 "first order" models.
     
ARGUMENT DESCRIPTIONS:
=========
LNAPL_Vol:  Estimated volume of total LNAPL at site in liters.
             
LNAPL_Area: Estimated footprint of LNAPL at site in hectares.
    
NSZD_Rate1: Natural Source Zone Depletion (NSZD) rate in liters per hectare 
            per year. 
            
            Option 1: Site measurement using methods described in 
                      ITRC, 2018 (NSZD Appendix). These include: 
                           i)   Gradient Method; 
                           ii)  Dynamic Closed Chamber, LI-COR; 
                           iii) Carbon Traps; or 
                           iv)  Thermal Monitoring. 

            Option 2: Use 15,900 liters biodegraded per hectare per year as a 
                      typical value (median from Garg et al., 2017, 
                      1,700 gallons per acre per year). 
          
Yr_start:   Output starting year.

Yr_end:     Output ending year.
    
REFERENCES:
=========
[1] Newell, C.J., J. Gonzales, R. McLeod. 1996. BIOSCREEN Natural Attenuation 
    Decision Support System. U.S. Environmental Protection Agency. 
    Available at: https://www.gsi-net.com/en/software/free-software/bioscreen.html

[2] Garg, S., C.J. Newell, P. Kulkarni, D. King, M. Irianni Renno, and 
    T. Sale. 2017. Overview of Natural Source Zone Depletion: Processes, 
    Controlling Factors, and Composition Change. Groundwater Monitoring and 
    Remediation 37. 
    Available at: https://ngwa.onlinelibrary.wiley.com/doi/full/10.1111/gwmr.12219.

    --------------------------------------------------------------------------
    --------------------------------------------------------------------------
    Excerpt from Garg et al., 2017: 
    Does the NSZD rate change over time? How does LNAPL composition change over 
    long time periods as NSZD progresses? 
    
    While there is considerable temporal variability in measured NSZD rates 
    possibly due to factors such as “signal shredding,” soil moisture, etc., 
    there are several lines of evidence that suggest that over decades, the 
    NSZD rate is generally zero order: 
      (1) the presence of controls such as acetate, predation, and so on that 
          may provide a feedback mechanism on the long-term NSZD rate; 
      (2) long term laboratory studies (e.g., Siddique et al. 2008 ) showing 
          zero-order behavior at higher hydrocarbon concentrations); 
      (3) the semi-sequenced biodegradation of different buckets observed at 
          Bemidji, add up to a fairly constant bulk NSZD rate (Ng et al. 2015 ) 
          (Figure 9 ); and 
      (4) the hydrocarbon composition literature that shows the potential for 
          sequenced biodegradation of different hydrocarbon chemical classes. 

    Therefore, current knowledge suggests that a zero-order depletion rate can 
    be assumed for much of the life of the LNAPL until a low saturation of 
    LNAPL or a relatively recalcitrant fraction is left, but research is 
    needed to determine if this fraction should be considered important for 
    site management, for example, its magnitude and any persisting secondary 
    water quality effects.
    --------------------------------------------------------------------------
    --------------------------------------------------------------------------

AUTHOR(S)
=========
     Brandon S. Sackmann, Ph.D.
     Kenia Whitehead, Ph.D.
     Hannah Podzorski

HISTORY
=======
     Date        Remarks
     ----------  -----------------------------------------------------------
     20201022    Initial script development. (BS)
     20200504    Removed rounding of output and intermediate calculations - per B. Strasert (BS)

Copyright (c) 2020 GSI Environmental Inc.
All Rights Reserved
E-mail: bssackmann@gsi-net.com
$Revision: 1.0$ Created on: 2020/10/22
                                     ''')
    # We use the optional switch -- otherwise it is mandatory
    parser.add_argument('--LNAPL_Vol', type=float, action='store', default=250000.0, help='Estimated volume of total LNAPL at site in liters.')
    parser.add_argument('--LNAPL_Area', type=float, action='store', default=5.0, help='Estimated footprint of LNAPL at site in hectares.')
    parser.add_argument('--NSZD_Rate1', type=float, action='store', default=1500.0, help='Natural Source Zone Depletion (NSZD) rate in liters per hectare per year.')
    parser.add_argument('--Yr_start', type=int, action='store', default=1965, help='Output starting year.')
    parser.add_argument('--Yr_end', type=int, action='store', default=2065, help='Output ending year.')
    # Run the argument parser
    args = parser.parse_args()

    # Separator
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    # print('INPUTS')
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    # 
    # # Check to ensure that argument values are valid
    # if (args.LNAPL_Vol is not None and args.LNAPL_Vol > 0):
    #     argEcho('LNAPL_Vol',args.LNAPL_Vol)
    # else:
    #     print('LNAPL_Vol is invalid! Calculated results should be discarded. Please try again...')
    #     
    # if (args.LNAPL_Area is not None and args.LNAPL_Area > 0):
    #     argEcho('LNAPL_Area',args.LNAPL_Area)
    # else:
    #     print('LNAPL_Area is invalid! Calculated results should be discarded. Please try again...')
    #     
    # if (args.NSZD_Rate1 is not None and args.NSZD_Rate1 > 0):
    #     argEcho('NSZD_Rate1',args.NSZD_Rate1)
    # else:
    #     print('NSZD_Rate1 is invalid! Calculated results should be discarded. Please try again...')
    #     
    # if (args.Yr_start is not None and args.Yr_start > 0):
    #     argEcho('Yr_start',args.Yr_start)
    # else:
    #     print('Yr_start is invalid! Calculated results should be discarded. Please try again...')
    # 
    # if (args.Yr_end is not None and args.Yr_end > 0):
    #     argEcho('Yr_end',args.Yr_end)
    # else:
    #     print('Yr_end is invalid! Calculated results should be discarded. Please try again...')
    #     
    # # Separator
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    # print('OUTPUTS')
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    # 
    # # Calculate NSZD rate - output
    # print('NSZD_RateOut:', NSZD_RateOut(args.LNAPL_Area,args.NSZD_Rate1))
    # 
    # # Estimate range (in years) when most/all LNAPL will be removed by NSZD
    # print('NSZD_RemovalRng:', NSZD_RemovalRng(args.LNAPL_Vol,args.LNAPL_Area,args.NSZD_Rate1))
    # 
    # # Calculate LNAPL volume as a function of time
    # print('NSZD_VolOut:', NSZD_VolOut(args.LNAPL_Vol,args.LNAPL_Area,args.NSZD_Rate1,args.Yr_start,args.Yr_end))
