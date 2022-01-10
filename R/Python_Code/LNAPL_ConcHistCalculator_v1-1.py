# -*- coding: utf-8 -*-
# CONCAWE LNAPL TOOLBOX: PARTITIONING MODEL
import argparse
import numpy as np

# Print argument value for debugging purposes and return None
def argEcho(argName,argValue):
    print(argName, ':', argValue)

# LNAPL partitioning model calculates the concentrations of LNAPL constituents downgradient of an LNAPL release over time
def partModel(hydraulCond,hydraulGrad,lensWidth,lensThick,timeStep,releaseVol,constList,constVolFrac,constMolWeight,constSol,constDens,simLen):
    
    # Initialize output data structure as a Python dictionary
    outDat = dict();
    
    # Calculate lnaplDens - LNAPL density in grams per cubic centimeter (den_N)
    lnaplDens = 0
    for i in range(len(constList)):
        lnaplDens = lnaplDens + (constVolFrac[i] * constDens[i])
    
    # Calculate scalar quantities - PART 1
    specDisc = hydraulCond * hydraulGrad    # specific discharge in meters per day (q)
    xsectArea = lensWidth * lensThick       # LNAPL lens cross-sectional area in square meters (A)
    volFlowRate = specDisc * xsectArea      # volumetric flow rate through LNAPL in cubic meters per day (Q_gw)
    iniMass = releaseVol * lnaplDens * 1000 # initial LNAPL mass in kg (M_N)
    
    # Compile constituent parameters and initial values - calculate missing values
    iniMols = 0
    compoundProp = []
    count = 0
    for compound in constList: 
        # Col_IDX Col_Desc
        #   (0) molecular weight (g/mol)
        #   (1) solubility (mg/L)
        #   (2) volume fraction (unitless)
        #   (3) volume (m3)
        #   (4) density (g/cm3)
        #   (5) initial mols
        #   (6) initial mol fraction (unitless)
        #   (7) initial mass fraction (unitless)
        #   (8) initial mass (kg)
        compoundProp.append([-9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999])
        compoundProp[count][0] = constMolWeight[count]
        compoundProp[count][1] = constSol[count]
        compoundProp[count][2] = constVolFrac[count]
        compoundProp[count][3] = releaseVol * constVolFrac[count]
        compoundProp[count][4] = constDens[count]
        compoundProp[count][5] = compoundProp[count][3] * compoundProp[count][4] / compoundProp[count][0] * 1000000
        compoundProp[count][7] = compoundProp[count][2] * compoundProp[count][4] / lnaplDens
        compoundProp[count][8] = compoundProp[count][7] * iniMass
        iniMols = iniMols + compoundProp[count][5]
        count = count + 1
    count = 0
    for compound in constList:
        compoundProp[count][6] = compoundProp[count][5] / iniMols
        count = count + 1
    # print('Constituent Parameters:')
    # print(compoundProp) 
    # print('')      
     
    # Calculate scalar quantities - PART 2
    # print('Scalar Quantitites:')
    # print('q = ', specDisc)
    # print('A = ', xsectArea)
    # print('Q_gw = ', volFlowRate)
    # print('M_N = ', iniMass)
    # print('')
    
    # Calculate time series
    timeDays = np.arange(0,(simLen*365.24+timeStep),timeStep)
    timeSeries = np.zeros([len(timeDays),((len(constList)*3)+3)])
    count1 = 0
    for t in timeDays:
        timeSeries[count1][0] = t
        timeSeries[count1][1] = timeSeries[count1][0] / 365.24
        count2 = 0
        for compound in constList:
            if count1 == 0:
                timeSeries[count1][3+count2] = compoundProp[count2][5]
            else:
                timeSeries[count1][3+count2] = timeSeries[count1-1][3+count2] - timeSeries[count1-1][3+(2*len(constList))+count2] * volFlowRate / compoundProp[count2][0] * timeStep
            timeSeries[count1][2] = timeSeries[count1][2] + timeSeries[count1][3+count2]
            count2 = count2 + 1
        count2 = 0
        for compound in constList:
            if count1 == 0:
                timeSeries[count1][3+(1*len(constList))+count2] = compoundProp[count2][6]
            else:
                timeSeries[count1][3+(1*len(constList))+count2] = timeSeries[count1][3+count2] / timeSeries[count1][2]
            timeSeries[count1][3+(2*len(constList))+count2] = compoundProp[count2][1] * timeSeries[count1][3+(1*len(constList))+count2]
            count2 = count2 + 1
        count1 = count1 + 1
    
    # print('Time Series:')
    # print(timeSeries)
    # print('')
    # print('Time Series - LAST ROW ONLY (for debugging purposes only)')
    # print(timeSeries[-1])
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    
    # Compile output data structure
    outDat['constituentParam'] = compoundProp
    outDat['q'] = specDisc
    outDat['A'] = xsectArea
    outDat['Q_gw'] = volFlowRate
    outDat['M_N'] = iniMass
    outDat['timeSeries'] = timeSeries
    
    return outDat
    
# main program starts here
if __name__ == '__main__':
    # Setup the argument parser class
    parser = argparse.ArgumentParser(prog='LNAPL_PartitioningModel',
                                     formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description='''\
CONCAWE LNAPL TOOLBOX: PARTITIONING MODEL
                                     ''',
                                     epilog='''\
RETURN VALUE DESCRIPTION:
=========
outDat:      Output data structure (Python dictionary).
                constituentParam - complete table of LNAPL constituent 
                                   parameters and initial values
                q                - specific discharge
                A                - LNAPL lens cross-sectional area
                Q_gw             - volumetric flow rate through LNAPL
                M_N              - initial LNAPL mass
                timeSeries       - time series output
                                   =================================
                                   Time (days), Time (yrs), N_T, ...
                                   N_1, N_2,  ... N_num,
                                   x_1, x_2,  ... x_num,
                                   Se1, Se_2, ... Se_num
                                   =================================
                                   * where 'num' is the number of prescribed 
                                   LNAPL constituents (including "other")
             
ARGUMENT DESCRIPTIONS:
=========
hydraulCond:    Hydraulic conductivity in meters per day (default = 1000.0).
             
hydraulGrad:    Hydraulic gradient, unitless (default = 0.005).
             
lensWidth:      Width of LNAPL lens in meters (default = 10.0).
             
lensThick:      Average thickness of LNAPL lens in meters (default = 0.5).
             
timeStep:       Time step in days (default = 0.005 day).
             
releaseVol:     Release volume of LNAPL in cubic meters (default = 1.0).
             
constList:      List of LNAPL constituents (default = "benzene" "toluene").
             
constVolFrac:   Volume fraction of LNAPL constituents, unitless (default = 0.89 0.1).

constMolWeight: Molecular weight in grams per mol for LNAPL constituents (default = 78.1 92.1).

constSol:       Solubility in milligrams per liter for LNAPL constituents (default = 1770 530).

constDens:      Density in grams per cubic centimeter for LNAPL constituents (default = 0.87 0.74).

otherMolWeight: Molecular weight in grams per mol for 'Other' constituent (default = 100.0).

otherSol:       Solubility in milligrams per liter for 'Other' constituent (default = 10.0).

otherDens:      Density in grams per cubic centimeter for 'Other' constituent (default = 0.78).
             
simLen:         Length of simulation in years (default = 0.15).
    
REFERENCES:
=========

AUTHOR(S)
=========
     Brandon S. Sackmann, Ph.D.
     Kenia Whitehead, Ph.D.
     Hannah Podzorski

HISTORY
=======
     Date        Remarks
     ----------  -----------------------------------------------------------
     20201216    Initial script development. (BS)
     20201218    Error identified when length of constList == 1 and/or sum(constVolFrac) == 1.0 (HP)
     20201221    Updated script to address edge cases identified on 20201218 (BS)
     20201221    Identified minor code redundencies and updated script accordingly (BS, BS)
     20201221    Implemented additonal check to ensure lnaplDens < 1 (BS, BS)
     20210212    Changed timeStep default value from 36.542 days to 1 day (BS, per Phil de Blanc)
     20210315    Updated script so that users can prescribe PChem information for 'Other' (BS)
     20210421    Refactor script to reflect updates in '5538_Conc_Hist_Calculator_rev1.xlsm' (BS, per Phil de Blanc)

Copyright (c) 2021 GSI Environmental Inc.
All Rights Reserved
E-mail: bssackmann@gsi-net.com
$Revision: 1.1$ Created on: 2021/04/21
                                     ''')
    # We use the optional switch -- otherwise it is mandatory
    parser.add_argument('--hydraulCond', type=float, action='store', default=1000.0, help='Hydraulic conductivity in meters per day.')
    parser.add_argument('--hydraulGrad', type=float, action='store', default=0.005, help='Hydraulic gradient (unitless).')
    parser.add_argument('--lensWidth', type=float, action='store', default=10.0, help='Width of LNAPL lens in meters.')
    parser.add_argument('--lensThick', type=float, action='store', default=0.5, help='Average thickness of LNAPL lens in meters.')
    parser.add_argument('--timeStep', type=float, action='store', default=0.005, help='Time step in days.')
    parser.add_argument('--releaseVol', type=float, action='store', default=1.0, help='Release volume of LNAPL in cubic meters.')
    parser.add_argument('--constList', type=str, action='store', nargs="+", default=["benzene","toluene"], help='List of LNAPL constituents.')
    parser.add_argument('--constVolFrac', type=float, action='store', nargs="+", default=[0.89,0.1], help='Volume fraction of LNAPL constituents.')
    parser.add_argument('--constMolWeight', type=float, action='store', nargs="+", default=[78.1,92.1], help='Molecular weight in grams per mol for LNAPL constituents.')
    parser.add_argument('--constSol', type=float, action='store', nargs="+", default=[1770.0,530.0], help='Solubility in milligrams per liter for LNAPL constituents.')
    parser.add_argument('--constDens', type=float, action='store', nargs="+", default=[0.87,0.74], help='Density in grams per cubic centimeter for LNAPL constituents.')
    parser.add_argument('--otherMolWeight', type=float, action='store', default=100.0, help='Molecular weight in grams per mol for ''Other'' constituent.')
    parser.add_argument('--otherSol', type=float, action='store', default=10.0, help='Solubility in milligrams per liter for ''Other'' constituent.')
    parser.add_argument('--otherDens', type=float, action='store', default=0.78, help='Density in grams per cubic centimeter for ''Other'' constituent.')
    parser.add_argument('--simLen', type=float, action='store', default=0.15, help='Length of simulation in years.')
    #Run the argument parser
    args = parser.parse_args()

    # Separator
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    # print('INPUTS')
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    # 
    # # Check to ensure that argument values are valid
    # if (args.hydraulCond is not None and args.hydraulCond > 0):
    #     argEcho('hydraulCond',args.hydraulCond)
    # else:
    #     print('hydraulCond is invalid! Calculated results should be discarded. Please try again...')
    #     
    # if (args.hydraulGrad is not None and args.hydraulGrad > 0):
    #     argEcho('hydraulGrad',args.hydraulGrad)
    # else:
    #     print('hydraulGrad is invalid! Calculated results should be discarded. Please try again...')
    #     
    # if (args.lensWidth is not None and args.lensWidth > 0):
    #     argEcho('lensWidth',args.lensWidth)
    # else:
    #     print('lensWidth is invalid! Calculated results should be discarded. Please try again...')
    #     
    # if (args.lensThick is not None and args.lensThick > 0):
    #     argEcho('lensThick',args.lensThick)
    # else:
    #     print('lensThick is invalid! Calculated results should be discarded. Please try again...')
    # 
    # if (args.timeStep is not None and args.timeStep > 0):
    #     argEcho('timeStep',args.timeStep)
    # else:
    #     print('timeStep is invalid! Calculated results should be discarded. Please try again...')
    #     
    # if (args.releaseVol is not None and args.releaseVol > 0):
    #     argEcho('releaseVol',args.releaseVol)
    # else:
    #     print('releaseVol is invalid! Calculated results should be discarded. Please try again...')
    #  
    # if sum(args.constVolFrac) < 1:
    #     args.constList.append("other")
    # if (args.constList is not None):
    #     argEcho('constList',args.constList)
    # else:
    #     print('constList is invalid! Calculated results should be discarded. Please try again...')
    #     
    # if sum(args.constVolFrac) < 1:
    #     args.constMolWeight.append(args.otherMolWeight)
    # if (args.constMolWeight is not None):
    #     argEcho('constMolWeight',args.constMolWeight)
    # else:
    #     print('constMolWeight is invalid! Calculated results should be discarded. Please try again...')
    # 
    # if sum(args.constVolFrac) < 1:    
    #     args.constSol.append(args.otherSol)
    # if (args.constSol is not None):
    #     argEcho('constSol',args.constSol)
    # else:
    #     print('constSol is invalid! Calculated results should be discarded. Please try again...')
    #     
    # if sum(args.constVolFrac) < 1:
    #     args.constDens.append(args.otherDens)
    # if (args.constDens is not None):
    #     argEcho('constDens',args.constDens)
    # else:
    #     print('constDens is invalid! Calculated results should be discarded. Please try again...')
    # 
    # if sum(args.constVolFrac) < 1:
    #     args.constVolFrac.append(1-sum(args.constVolFrac))
    # if (args.constVolFrac is not None):
    #     argEcho('constVolFrac',args.constVolFrac)
    # else:
    #     print('constVolFrac is invalid! Calculated results should be discarded. Please try again...')
    # 
    # if (args.otherMolWeight is not None and args.otherMolWeight > 0):
    #     argEcho('otherMolWeight',args.otherMolWeight)
    # else:
    #     print('otherMolWeight is invalid! Calculated results should be discarded. Please try again...')
    #     
    # if (args.otherSol is not None and args.otherSol > 0):
    #     argEcho('otherSol',args.otherSol)
    # else:
    #     print('otherSol is invalid! Calculated results should be discarded. Please try again...')
    #     
    # if (args.otherDens is not None and args.otherDens > 0):
    #     argEcho('otherDens',args.otherDens)
    # else:
    #     print('otherDens is invalid! Calculated results should be discarded. Please try again...')
    #     
    # if (args.simLen is not None and args.simLen > 0):
    #     argEcho('simLen',args.simLen)
    # else:
    #     print('simLen is invalid! Calculated results should be discarded. Please try again...')
    #     
    # # Separator
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    # print('OUTPUTS')
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    # 
    # # Execute LNAPL partitioning model
    # print('Model_Output:', partModel(args.hydraulCond,args.hydraulGrad,args.lensWidth,args.lensThick,args.timeStep,args.releaseVol,args.constList,args.constVolFrac,args.constMolWeight,args.constSol,args.constDens,args.simLen))
    
