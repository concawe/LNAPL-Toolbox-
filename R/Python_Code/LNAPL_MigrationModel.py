# -*- coding: utf-8 -*-
# CONCAWE LNAPL TOOLBOX: MIGRATION MODEL
import argparse

# Print argument value for debugging purposes and return None
def argEcho(argName,argValue):
    print(argName, ':', argValue)

# Enhanced Natural Source Zone Depletion (NSZD) rate in liters per hectare per year after subsurface heating
def migrationModel(Tn,i):
    # Initialize output data structure as a Python dictionary
    outDat = dict();
    
    # Compile output data structure
    outDat['Tn × i'] = Tn*i
    
    if Tn*i <= 0.0004:
        outDat['R'] = Tn*i*262397-20.1
    else:
        outDat['R'] = Tn*i*66329+61.7
    
    return outDat

# main program starts here
if __name__ == '__main__':
    # Setup the argument parser class
    parser = argparse.ArgumentParser(prog='LNAPL_MigrationModel',
                                     formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description='''\
CONCAWE LNAPL TOOLBOX: MIGRATION MODEL

What the Model Does

     This tool calculates the additional distance that the leading edge of an 
     LNAPL plume is expected to migrate in the presence of natural source zone 
     depletion (NSZD).

How the Model Works

     The model is based on multiple runs of the Hydrocarbon Spill Screening 
     Model (HSSM; Weaver et al., 1994). For each run, an average LNAPL 
     transmissivity and gradient were calculated across the oil lens at 
     different times and soil types. These average properties were used as 
     starting conditions to calculate the expected additional growth of an 
     LNAPL plume under an assumed zero-order NSDZ rate of 2.0 x 10-6 m/day 
     using the steady-state relationship for a circular source derived by 
     Mahler (Mahler et al., 2012). The plot shows the calculated LNAPL plume 
     length increase for different average values of LNAPL transmissivity × 
     gradient and piecewise linear fit to the data in the nomograph. To use 
     the model, the user enters an LNAPL gradient and transmissivity (in m2/d), 
     and the estimated additional LNAPL plume growth is calculated from one 
     of the following two equations:

     For Tn × i <= 4.0 × 10-4: R (m) = 262397 – 20.1
     For Tn × i  > 4.0 × 10-4: R (m) = 66329 × Tn × i + 61.7

     where R is the length increase of the LNAPL plume in meters.

Key Assumptions

     The model assumes that there is an unlimited source of LNAPL and that 
     the LNAPL flux is constant. This is an experimental model. Incorporation 
     of HSSM , 1995 and Mahler et al, 2012 represents a non-hysteric 
     methodology where entrapment of LNAPL is ignored and loss rate inputs 
     can account for partitioning and biodegradation losses.  Entrapment of 
     LNAPL has been evaluated (Sookhak Lari et al., 2016, Pasha et al., 2014 
     and Guarnaccia, et al., 1997) and demonstrated to slow the rate of LNAPL 
     migration.  Current methods to incorporate entrapment require numerical 
     models which are not within the scope of this tool.  The lack of 
     incorporating entrapment results in a conservative approach where the 
     upper bound of LNAPL migration extent is estimated.  The results of this 
     tool are intended to be used for demonstrating LNAPL body stability by 
     comparing the maximum potential for LNAPL migration to current extent.  
     The model is useful for estimating the upper bound of LNAPL migration.  
     However, if the calculated LNAPL extent is used in cumulative LNAPL loss 
     and time to depletion estimates then the resulting estimates would 
     overestimate losses and underestimate time to depletion. 
     (Sookhak Lari et al., 2016).  It is appropriate to use current delineated 
     LNAPL body extent for cumulative loss calculations or time to depletion 
     estimates.
                                     ''',
                                     epilog='''\
RETURN VALUES DESCRIPTION:
=========
Tn × i: LNAPL transmissivity (Tn) × gradient (i) in square meters per day.

R:      Estimated additional radial spread in meters.
             
ARGUMENT DESCRIPTIONS:
=========
Tn:     LNAPL transmissivity in square meters per day.
             
i:      LNAPL gradient (unitless).  

REFERENCES:
=========
[1] Guarnaccia, J. , Pinder, G. , Fishman, M. , 1997. NAPL: Simulator 
    Documentation, US EPA.
    
[2] Mahler et al., 2012. A mass balance approach to resolving LNAPL stability, 
    N. Mahler, T. Sale, and M. Lyverse, Ground Water 50(6): 861-571, 
    November/December 2012.
    
[3] Pasha, A.Y. , Hu, L. , Meegoda, J.N. , 2014. Numerical simulation of a 
    light nonaque- ous phase liquid (LNAPL) movement in variably saturated 
    soils with capillary hysteresis, Can. Geotech. J. 51, 1046–1062.
    
[4] Sookhak Lari, K., Davis, G.B., Johnston, C.D., 2016 Incorporating 
    hysteresis in a multi-phase multi-component NAPL modelling framework; 
    a multi-component LNAPL gasoline example, Advances in Water Resources. 
    96, 190-201.
    
[5] Weaver et al., 1994. The Hydrocarbon Spill Screening Model (HSSM); 
    Volume 1: User’s Guide, J.W. Weaver, R.J. Charbeneau, B.K. Lien, and J.B. 
    Provost, U.S. EPA, EPA/600/R-94/039a.

AUTHOR(S)
=========
     Brandon S. Sackmann, Ph.D.
     Kenia Whitehead, Ph.D.
     Hannah Podzorski

HISTORY
=======
     Date        Remarks
     ----------  -----------------------------------------------------------
     20210202    Initial script development. (BS)

Copyright (c) 2021 GSI Environmental Inc.
All Rights Reserved
E-mail: bssackmann@gsi-net.com
$Revision: 1.0$ Created on: 2021/02/02
                                     ''')
    # # We use the optional switch -- otherwise it is mandatory
    # parser.add_argument('--Tn', type=float, action='store', default=0.5, help='LNAPL transmissivity in square meters per day.')
    # parser.add_argument('--i', type=float, action='store', default=0.001, help='LNAPL gradient (unitless).')
    # # Run the argument parser
    # args = parser.parse_args()
    # 
    # # Separator
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    # print('INPUTS')
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    # 
    # # Check to ensure that argument values are valid
    # if (args.Tn is not None and args.Tn > 0):
    #     argEcho('Tn',args.Tn)
    # else:
    #     print('Tn is invalid! Calculated results should be discarded. Please try again...')
    #     
    # if (args.i is not None and args.i > 0):
    #     argEcho('i',args.i)
    # else:
    #     print('i is invalid! Calculated results should be discarded. Please try again...')
    # 
    # # Separator
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    # print('OUTPUTS')
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    # 
    # # Calculate Tn × i and R
    # print('Model_Output:', migrationModel(args.Tn,args.i))
    # 
