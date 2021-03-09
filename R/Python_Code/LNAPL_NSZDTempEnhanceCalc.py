# -*- coding: utf-8 -*-
# CONCAWE LNAPL TOOLBOX: NATURAL SOURCE ZONE DEPLETION (NSZD) TEMPERATURE ENHANCEMENT CALCULATOR
import argparse

# Print argument value for debugging purposes and return None
def argEcho(argName,argValue):
    print(argName, ':', argValue)

# Enhanced Natural Source Zone Depletion (NSZD) rate in liters per hectare per year after subsurface heating
def NSZD_T2Rate(T1,T2,NSZD_T1Rate,Q10):
    return round(NSZD_T1Rate*Q10**((T2-T1)/10.0),-1)

# main program starts here
if __name__ == '__main__':
    # Setup the argument parser class
    parser = argparse.ArgumentParser(prog='LNAPL_NSZDTempEnhanceCalc',
                                     formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description='''\
CONCAWE LNAPL TOOLBOX: NATURAL SOURCE ZONE DEPLETION (NSZD) TEMPERATURE ENHANCEMENT CALCULATOR
                                     ''',
                                     epilog='''\
RETURN VALUE DESCRIPTION:
=========
NSZD_T2Rate: Enhanced Natural Source Zone Depletion (NSZD) rate in liters per 
             hectare per year after subsurface heating.
             
ARGUMENT DESCRIPTIONS:
=========
T1:          Use average annual temperature from groundwater sampling, or as 
             an approximation, use average annual air temperature as a proxy 
             for subsurface temperature (Kusuda and Achenbach, 1965; USDA Soil 
             Survey Staff, 1999).
             
T2:          Heated temperature in degrees C. Note for mesophilic anaerobic 
             digestors, optimum temperature range between 30 and 38 °C 
             (Metcalf and Eddy, 1991; Gerardi, 2003). Maximum temperature of 
             40 °C, after which bacterial populations decline.  

             Sustainable Thermally-Enhanced LNAPL Attenuation (STELA) includes 
             various methods for providing low-level subsurface heating: 
                 i)   Electrical resistance heaters in vertical wells 
                      (e.g., heat tape); 
                 ii)  geothermal U-tube heat exchanger with circulating heated 
                      water; 
                 iii) application of (i) or (ii) using either solar panels or 
                      electricity as an energy source; and 
                 iv)  soil solarization using plastic sheeting on ground 
                      surface for shallow sites (<5 m) (Akhbari et al., 2013; 
                      Kulkarni et al., 2015).
                      
NSZD_T1Rate: Natural Source Zone Depletion (NSZD) rate at temperature T1. 

             Option 1: Site measurement using methods described in 
                       ITRC, 2018 (NSZD Appendix). These include: 
                           i)   Gradient Method; 
                           ii)  Dynamic Closed Chamber, LI-COR; 
                           iii) Carbon Traps; or 
                           iv)  Thermal Monitoring. 

             Option 2: Use 15,900 liters biodegraded per hectare per year as a 
                       typical value (median from Garg et al., 2017, 
                       1,700 gallons per acre per year). 
                      
Q10:         Temperature Coefficient. Note for most biological systems, per the 
             Arrhenius law, the Temperature Coefficient value is approximately 
             2.0 (Atlas and Bartha 1986 ; Riser-Roberts 1992)
    
REFERENCES:
=========
[1]  Akhbari, D. 2013. Thermal aspects of sustainable thermally enhanced LNAPL 
     attenuation (STELA). M.S. thesis, Colorado State University, Fort Collins, 
     Colorado.
[2]  Atlas, R.M. and R. Bartha. 1986. Microbial Ecology: Fundamentals
[3]  Garg, S., C.J. Newell, P.R. Kulkarni, D.C. King, D.T. Adamson, M.
     Irianni Renno, and T. Sale. 2017. Overview of natural source zone 
     depletion: Processes, controlling factors, and composition change. 
     Groundwater Monitoring & Remediation.
[4]  Gerardi, M.H. 2003. The Microbiology of Anaerobic Digesters. Hoboken, 
     New Jersey: John Wiley & Sons.
[5]  ITRC, 2018. LNAPL-3 LNAPL Site Management: LCSM Evolution, Decision 
     Process, and Remedial Technologies: Natural Source Zone Depletion (NSZD) 
     Appendix. Interstate Technology Regulatory Council. March 2018. 
     Available at: https://lnapl-3.itrcweb.org/
[6]  Kulkarni, P.R., C.J. Newell, T. Sale, Renno M. Irianni, E. Stockwell, 
     H. Hopkins, M. Malander, J. Chillemi, and J.H. Higinbotham. 2015. 
     Sustainable thermally enhanced LNAPL attenuation (STELA) using soil 
     solarization. Platform presentation at the Third International Symposium 
     on Bioremediation and Sustainable Environmental Technologies, May 18–21, 
     Miami, Florida.
[7]  Kusuda, T. , and P.R. Achenbach. 1965. Earth temperatures and thermal
     diffusivity at selected stations in the United States. ASHRAE
     Transactions 71, no. 1: 61– 74.
[8]  Metcalf and Eddy. 1991. Wastewater Engineering—Treatment, Disposal, and 
     Reuse. 3rd ed. New York: McGraw-Hill Publishing Company.
[9]  Riser-Roberts, E. 1992. Bioremediation of Petroleum Contaminated Sites. 
     Boca Raton, Florida: CRC Press Inc.
[10] USDA Soil Survey Staff. 1999. Soil Taxonomy: A Basic System of Soil 
     Classification for Making and Interpreting Soil Surveys. 2nd ed. 
     U.S. Department of Agriculture Handbook 436. Washington, DC: 
     Natural Resources Conservation Service.

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

Copyright (c) 2020 GSI Environmental Inc.
All Rights Reserved
E-mail: bssackmann@gsi-net.com
$Revision: 1.0$ Created on: 2020/10/22
                                     ''')
    # We use the optional switch -- otherwise it is mandatory
    parser.add_argument('--T1', type=float, action='store', default=15.0, help='Average annual temperature from groundwater sampling in degrees C.')
    parser.add_argument('--T2', type=float, action='store', default=30.0, help='Heated temperature in degrees C.')
    parser.add_argument('--NSZD_T1Rate', type=float, action='store', default=7500.0, help='Natural Source Zone Depletion (NSZD) rate at temperature T1 in liters per hectare per year.')
    parser.add_argument('--Q10', type=float, action='store', default=2.0, help='Temperature coefficient.')
    #Run the argument parser
    args = parser.parse_args()

    # Separator
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    # print('INPUTS')
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    # 
    # # Check to ensure that argument values are valid
    # if (args.T1 is not None and args.T1 > 0 and args.T1 < 40):
    #     argEcho('T1',args.T1)
    # else:
    #     print('T1 is invalid! Calculated results should be discarded. Please try again...')
    #     
    # if (args.T2 is not None and args.T2 > 0 and args.T2 < 40):
    #     argEcho('T2',args.T2)
    # else:
    #     print('T2 is invalid! Calculated results should be discarded. Please try again...')
    #     
    # if (args.NSZD_T1Rate is not None and args.NSZD_T1Rate > 0):
    #     argEcho('NSZD_T1Rate',args.NSZD_T1Rate)
    # else:
    #     print('NSZD_T1Rate is invalid! Calculated results should be discarded. Please try again...')
    #     
    # if (args.Q10 is not None and args.Q10 > 0):
    #     argEcho('Q10',args.Q10)
    # else:
    #     print('Q10 is invalid! Calculated results should be discarded. Please try again...')
    # 
    # # Separator
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    # print('OUTPUTS')
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    # 
    # # Calculate NSZD rate at T2
    # print('NSZD_T2Rate:', NSZD_T2Rate(args.T1,args.T2,args.NSZD_T1Rate,args.Q10))
