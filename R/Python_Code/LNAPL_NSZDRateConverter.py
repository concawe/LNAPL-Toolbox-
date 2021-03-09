# -*- coding: utf-8 -*-
# CONCAWE LNAPL TOOLBOX: NATURAL SOURCE ZONE DEPLETION (NSZD) RATE CONVERTER
import argparse

# Print argument value for debugging purposes and return None
def argEcho(argName,argValue):
    print(argName, ':', argValue)

# chemical property lookup table for key compounds - density (g/mL), molecular weight (g/mol), and molar ratio (unitless)
def pChemLookup_Rate(chemName):
    pChem = {"benzene" : (0.88, 78.1, 1/6),
             "toluene" : (0.74, 92.1, 1/7),
             "octane" : (0.7, 114.2, 1/8),
             "decane" : (0.73, 142.3, 1/10),
             "gasoline" : (0.73, 95, 1/8),
             "diesel" : (0.83, 200, 1/8),
             "jet_fuel" : (0.8, 185, 1/8)}
    return pChem[chemName]

# convert units per user inputs
def unitConv(valueIn,unitsIn,unitsOut,compound,treatmentArea):
    #retrieve density (g/mL), molecular weight (g/mol), and molar ratio (unitless) for desired LNAPL compound
    compoundProp = pChemLookup_Rate(compound)
    
    # create concatenated key to conversion lookup table
    convString = unitsIn + '_to_' + unitsOut
    
    # conversion constants
    value_in = valueIn
    LNAPL_density = compoundProp[0]
    LNAPL_molweight = compoundProp[1]
    LNAPL_ratio = compoundProp[2]
    area = treatmentArea
    gal_to_L = 3.79
    ac_to_m2 = 4046.9
    ac_to_ha = 0.4047
    lb_to_g = 453.6
    yr_to_sec = 365*24*60*60
    kg_to_g = 1000
    L_to_mL = 1000
    ha_to_m2 = 10000
    mol_to_umol = 1000000

    # print(LNAPL_density)
    # print(LNAPL_molweight)
    # print(LNAPL_ratio)
    
    unitConv = {"gal/ac/yr_to_gal/ac/yr" : "value_in * 1",
                "gal/ac/yr_to_L/ha/yr" : "value_in * gal_to_L * (1/ac_to_ha)",
                "gal/ac/yr_to_umol CO2/m2/sec" : "value_in * gal_to_L * L_to_mL * LNAPL_density * (1/LNAPL_molweight) * mol_to_umol * (1/yr_to_sec) * (1/ac_to_m2) * (1/LNAPL_ratio)",
                "gal/ac/yr_to_g/m2/yr" : "value_in * LNAPL_density * gal_to_L * L_to_mL * (1/ac_to_m2)",
                "gal/ac/yr_to_lb/ac/yr" : "value_in * LNAPL_density * gal_to_L * L_to_mL * (1/lb_to_g)",
                "gal/ac/yr_to_kg/ha/yr" : "value_in * LNAPL_density * gal_to_L * (1/ac_to_ha)",
                "L/ha/yr_to_gal/ac/yr" : "value_in * (1/gal_to_L) * ac_to_ha",
                "L/ha/yr_to_L/ha/yr" : "value_in * 1",
                "L/ha/yr_to_umol CO2/m2/sec" : "value_in * LNAPL_density * (1/LNAPL_molweight) * mol_to_umol * (1/yr_to_sec) * (1/ha_to_m2) * L_to_mL * (1/LNAPL_ratio)",
                "L/ha/yr_to_g/m2/yr" : "value_in * LNAPL_density * (1/ha_to_m2) * L_to_mL",
                "L/ha/yr_to_lb/ac/yr" : "value_in * LNAPL_density * L_to_mL * (1/lb_to_g) * ac_to_ha",
                "L/ha/yr_to_kg/ha/yr" : "value_in * LNAPL_density",
                "umol CO2/m2/sec_to_gal/ac/yr" : "value_in * (1/gal_to_L) * (1/L_to_mL) * (1/LNAPL_density) * LNAPL_molweight * (1/mol_to_umol) * yr_to_sec * ac_to_m2 * LNAPL_ratio",
                "umol CO2/m2/sec_to_L/ha/yr" : "value_in * (1/LNAPL_density) * LNAPL_molweight * (1/mol_to_umol) * yr_to_sec * ha_to_m2 * (1/L_to_mL) * LNAPL_ratio",
                "umol CO2/m2/sec_to_umol CO2/m2/sec" : "value_in * 1",
                "umol CO2/m2/sec_to_g/m2/yr" : "value_in * LNAPL_molweight * LNAPL_ratio * (1/mol_to_umol) * yr_to_sec",
                "umol CO2/m2/sec_to_lb/ac/yr" : "value_in * LNAPL_molweight * LNAPL_ratio * (1/mol_to_umol) * yr_to_sec * (1/lb_to_g) * ac_to_m2",
                "umol CO2/m2/sec_to_kg/ha/yr" : "value_in * LNAPL_molweight * LNAPL_ratio * (1/mol_to_umol) * yr_to_sec * (1/kg_to_g) * ha_to_m2",
                "g/m2/yr_to_gal/ac/yr" : "value_in * (1/LNAPL_density) * (1/gal_to_L) * (1/L_to_mL) * ac_to_m2",
                "g/m2/yr_to_L/ha/yr" : "value_in * (1/LNAPL_density) * ha_to_m2 * (1/L_to_mL)",
                "g/m2/yr_to_umol CO2/m2/sec" : "value_in * (1/LNAPL_molweight) * (1/LNAPL_ratio) * mol_to_umol * (1/yr_to_sec)",
                "g/m2/yr_to_g/m2/yr" : "value_in * 1",
                "g/m2/yr_to_lb/ac/yr" : "value_in * (1/lb_to_g) * ac_to_m2",
                "g/m2/yr_to_kg/ha/yr" : "value_in * (1/kg_to_g) * ha_to_m2",
                "lb/ac/yr_to_gal/ac/yr" : "value_in * (1/LNAPL_density) * (1/gal_to_L) * (1/L_to_mL) * lb_to_g",
                "lb/ac/yr_to_L/ha/yr" : "value_in * (1/LNAPL_density) * (1/L_to_mL) * lb_to_g * (1/ac_to_ha)",
                "lb/ac/yr_to_umol CO2/m2/sec" : "value_in * (1/LNAPL_molweight) * (1/LNAPL_ratio) * mol_to_umol * (1/yr_to_sec) * lb_to_g * (1/ac_to_m2)",
                "lb/ac/yr_to_g/m2/yr" : "value_in * lb_to_g * (1/ac_to_m2)",
                "lb/ac/yr_to_lb/ac/yr" : "value_in * 1",
                "lb/ac/yr_to_kg/ha/yr" : "value_in * lb_to_g * (1/kg_to_g) * (1/ac_to_ha)",
                "kg/ha/yr_to_gal/ac/yr" : "value_in * (1/LNAPL_density) * (1/gal_to_L) * ac_to_ha",
                "kg/ha/yr_to_L/ha/yr" : "value_in * (1/LNAPL_density)",
                "kg/ha/yr_to_umol CO2/m2/sec" : "value_in * (1/LNAPL_molweight) * (1/LNAPL_ratio) * mol_to_umol * (1/yr_to_sec) * kg_to_g * (1/ha_to_m2)",
                "kg/ha/yr_to_g/m2/yr" : "value_in * kg_to_g * (1/ha_to_m2)",
                "kg/ha/yr_to_lb/ac/yr" : "value_in * (1/lb_to_g) * kg_to_g * ac_to_ha",
                "kg/ha/yr_to_kg/ha/yr" : "value_in * 1",
                "kg/yr_to_kg/yr" : "value_in * 1",
                "kg/yr_to_L/ha/yr" : "value_in * (1/area) * ha_to_m2 * (1/LNAPL_density)",
                "L/yr_to_L/yr" : "value_in * 1",
                "L/yr_to_L/ha/yr" : "value_in * (1/area) * ha_to_m2"}
    return eval(unitConv[convString])

# main program starts here
if __name__ == '__main__':
    # Setup the argument parser class
    parser = argparse.ArgumentParser(prog='LNAPL_NSZDRateConverter',
                                     formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description='''\
CONCAWE LNAPL TOOLBOX: NATURAL SOURCE ZONE DEPLETION (NSZD) RATE CONVERTER
                                     ''',
                                     epilog='''\
RETURN VALUE DESCRIPTION:
=========
valueOut:       valueIn after conversion of units per user inputs.
             
ARGUMENT DESCRIPTIONS:
=========
valueIn:        Input value with units as specified by unitsIN.

unitsIn:        Units that correspond with valueIn.

                Available options:
                    "gal/ac/yr"
                    "L/ha/yr"
                    "umol CO2/m2/sec"
                    "g/m2/yr"
                    "lb/ac/yr"
                    "kg/ha/yr"
                    --------------------
                    "kg/yr"  >>>  "L/ha/yr" only (requires valid inputs for 
                                                  compound and treatmentArea)
                    "L/yr"   >>>  "L/ha/yr" only (requires valid inputs 
                                                  treatmentArea)
                      
unitsOut:       Desired output units.

                Available options:
                    "gal/ac/yr"
                    "L/ha/yr"
                    "umol CO2/m2/sec"
                    "g/m2/yr"
                    "lb/ac/yr"
                    "kg/ha/yr"
                      
compound:       LNAPL reference compound (only required for specific unit
                conversions).

                Available options:
                    "benzene"
                    "toluene"
                    "octane"
                    "decane"
                    "gasoline"
                    "diesel"
                    "jet_fuel"

treatmentArea:  Treatment area in square meters (only required for specific
                unit conversions).
    
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

Copyright (c) 2020 GSI Environmental Inc.
All Rights Reserved
E-mail: bssackmann@gsi-net.com
$Revision: 1.0$ Created on: 2020/12/16
                                     ''')
    # We use the optional switch -- otherwise it is mandatory
    parser.add_argument('--valueIn', type=float, default=1.0, action='store', help='Value to be converted.')
    parser.add_argument('--unitsIn', type=str, default="gal/ac/yr", action='store', help='Input unit string (e.g., "gal/ac/yr").')
    parser.add_argument('--unitsOut', type=str, default="L/ha/yr", action='store', help='Output unit string (e.g., "L/ha/yr").')
    parser.add_argument('--compound', type=str, default='octane', action='store', help='Representative LNAPL compound (e.g., "benzene").')
    parser.add_argument('--treatmentArea', type=float, default=1000.0, action='store', help='Treatment area in square meters.')
    # Run the argument parser
    args = parser.parse_args()

    # Separator
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    # print('INPUTS')
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    
    # Check to ensure that argument values are valid
    # if (args.valueIn is not None and args.valueIn > 0):
    #     argEcho('valueIn',args.valueIn)
    # else:
    #     print('valueIn is invalid! Calculated results should be discarded. Please try again...')
    #     
    # if (args.unitsIn is not None):
    #     argEcho('unitsIn',args.unitsIn)
    # else:
    #     print('unitsIN is invalid! Calculated results should be discarded. Please try again...')
    #     
    # if (args.unitsOut is not None):
    #     argEcho('unitsOut',args.unitsOut)
    # else:
    #     print('unitsOut is invalid! Calculated results should be discarded. Please try again...')
    #     
    # if (args.compound is not None):
    #     argEcho('compound',args.compound)
    # else:
    #     print('compound is invalid! Calculated results should be discarded. Please try again...')
    #     
    # if (args.treatmentArea is not None and args.treatmentArea > 0):
    #     argEcho('treatmentArea',args.treatmentArea)
    # else:
    #     print('treatmentArea is invalid! Calculated results should be discarded. Please try again...')
    
    # Separator
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    # print('OUTPUTS')
    # print('**********^^^^^^^^^^**********^^^^^^^^^^')
    
    # Translate units
    # print('Converted Value:', unitConv(args.valueIn,args.unitsIn,args.unitsOut,args.compound,args.treatmentArea))
