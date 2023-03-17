# -*- coding: utf-8 -*-
# CONCAWE LNAPL TOOLBOX: DARCY CALCULATOR
import math

def darcyCalc(soilType,lnaplName,lnaplThickness,lnaplGradient):
    # Initialize output data structure as a Python dictionary
    outDat = dict();
    
    # Initialize default values
    airWaterTension   = 65  # dyn/cm   -- Default value is 65 dyn/cm. You may over-write with your own value.
    lnaplResidSatFact = 0.3 # unitless -- Typical range 0. 2 to 0.5. Values increase with decreasing average pore size.
    waterDensity      = 1   # g/cm3    -- Default value is 1 g/cm3. You may over-write with your own value.
    waterViscosity    = 1   # cp       -- Default value is 1 cp. You may over-write with your own value.
    krflag            = 2
    
    # LNAPL lookup values
    lnaplParams       = lnaplParamLookup(lnaplName)
    lnaplDensity      = lnaplParams[0] # g/cm3  -- Use the value for the chosen LNAPL or enter your own value.
    lnaplViscosity    = lnaplParams[2] # cp     -- Use the value for the chosen LNAPL or enter your own value.
    lnaplAirTension   = lnaplParams[4] # dyn/cm -- Use the value for the chosen LNAPL or enter your own value.
    lnaplWaterTension = lnaplParams[6] # dyn/cm -- Use the value for the chosen LNAPL or enter your own value.
    
    # Soil lookup values
    soilParams        = soilPropLookup(soilType)
    soilPorosity      = soilParams[1] # unitless         -- Use the value for the chosens oil type or enter your own value.
    soilWaterResidSat = soilParams[3]/soilPorosity # m/d -- Use the value for the chosens oil type or enter your own value.
    soilSatHydCond    = soilParams[2] # m/d              -- Use the value for the chosens oil type or enter your own value.
    soilN             = soilParams[4] # unitless         -- Use the value for the chosens oil type or enter your own value.
    soilAlpha         = soilParams[5] # 1/m              -- Use the value for the chosens oil type or enter your own value.
    
    # Calculated values
    calcRelDensity    = lnaplDensity/waterDensity
    calcMaxHeight     = lnaplThickness+(1-calcRelDensity)*(lnaplAirTension/lnaplWaterTension)/(calcRelDensity-(1-calcRelDensity)*(lnaplAirTension/lnaplWaterTension))*lnaplThickness
    calcAirIntHeight  = lnaplThickness
    calcM             = (soilN-1)/soilN # unitless -- Use the value for the chosens oil type or enter your own value (could also use pre-calculated value available as soilParams[6]).
    calcAirAlpha      = soilAlpha * calcRelDensity * airWaterTension / lnaplAirTension
    calcWaterAlpha    = (1 - calcRelDensity) * airWaterTension * soilAlpha / lnaplWaterTension
    
    # Compile output data structure (variables ordered per 'Transmissivity_Calculator_dev_3_BSS.xlsm')
    # Re-assign variable names to mimic existing VBA code
    outDat['inputSoilType']  = soilType
    outDat['inputLNAPLName'] = lnaplName
    outDat['bo']             = lnaplThickness
    outDat['inputLNAPLGrad'] = lnaplGradient
    outDat['st_aw']          = airWaterTension
    outDat['fr']             = lnaplResidSatFact
    outDat['denwat']         = waterDensity
    outDat['waterViscosity'] = waterViscosity
    outDat['krflag']         = krflag
    outDat['denoil']         = lnaplDensity
    outDat['lnaplViscosity'] = lnaplViscosity
    outDat['st_nw']          = lnaplWaterTension
    outDat['st_an']          = lnaplAirTension
    outDat['Por']            = soilPorosity
    outDat['Swr']            = soilWaterResidSat
    outDat['Ksat']           = soilSatHydCond
    outDat['alpha']          = soilAlpha
    outDat['vg_N']           = soilN
    outDat['zmax']           = calcMaxHeight
    outDat['zan']            = calcAirIntHeight
    outDat['den_r']          = calcRelDensity
    outDat['vg_M']           = calcM
    outDat['alpha_an']       = calcAirAlpha
    outDat['alpha_nw']       = calcWaterAlpha
    
    # Output from code
    outDat                   = gauss10(0,outDat['zan'],'Do',outDat) # initialize outDat['Do']
    outDat['Do']             = outDat['Do'] + gauss10(outDat['zan'],outDat['zmax'],'Do',outDat)['Do'] # m3/m2    -- The volume of LNAPL per unit area.
    
    outDat                   = gauss10(0,outDat['zan'],'Dom',outDat) # initialize outDat['Dom']
    outDat['Dom']            = outDat['Dom'] + gauss10(outDat['zan'],outDat['zmax'],'Dom',outDat)['Dom'] # m3/m3 -- The volume of recoverable LNAPL per unit area.
    
    outDat                   = gauss10(0,outDat['zan'],'kro_avg',outDat) # initialize outDat['kro_avg']
    outDat['kro_avg']        = (outDat['kro_avg'] + gauss10(outDat['zan'],outDat['zmax'],'kro_avg',outDat)['kro_avg'])/outDat['zmax'] # unitless -- The average relative permeability over the thickness of LNAPL in the formation.
    
    # Calculated from output
    outDat['Ko_avg']         = outDat['kro_avg'] * outDat['Ksat'] * outDat['denoil'] / outDat['denwat'] * outDat['waterViscosity'] / outDat['lnaplViscosity'] # m/d -- The average LNAPL hydraulic conductivity over the thickness of LNAPL in the formation.
    outDat['Tn']             = outDat['Ko_avg'] * outDat['zmax']                         # m2/d     -- The average LNAPL transmissivity over the thickness of LNAPL in the formation.
    outDat['darcyFlux']      = outDat['Tn'] * outDat['inputLNAPLGrad'] / outDat['zmax']  # m/d      -- The volume of LNAPL flow per unit area of formation.
    outDat['lnaplSat']       = outDat['Do'] / outDat['zmax'] / outDat['Por']             # unitless -- The average LNAPL volume per unit por volume.
    outDat['lnaplVolCont']   = outDat['Do'] / outDat['zmax']                             # unitless -- The average LNAPL volume per unit bulk formation volume.
    outDat['lnaplSeepVel']   = outDat['darcyFlux'] / outDat['lnaplVolCont']              # m/d      -- The average flow velocity of the LNAPL under the given LNAPL gradient.
    
    # Subset output to includ only the desired calculated values
    outDatFinal = dict();
    outDatFinal['zmax']         = outDat['zmax']
    outDatFinal['zan']          = outDat['zan']
    outDatFinal['den_r']        = outDat['den_r']
    outDatFinal['vg_M']         = outDat['vg_M']
    outDatFinal['Do']           = outDat['Do']
    outDatFinal['Dom']          = outDat['Dom']
    outDatFinal['kro_avg']      = outDat['kro_avg']
    outDatFinal['Ko_avg']       = outDat['Ko_avg']
    outDatFinal['Tn']           = outDat['Tn']
    outDatFinal['darcyFlux']    = outDat['darcyFlux'] 
    outDatFinal['lnaplVolCont'] = outDat['lnaplVolCont']
    outDatFinal['lnaplSeepVel'] = outDat['lnaplSeepVel']
    
    return outDatFinal
  
# Integrates the user-defined function "gfx" (which must be defined by the user)
# by 10-point Gaussian Quadrature
def gauss10(a,b,funcName,inDat):
    # Initialize output data structure as a Python dictionary
    outDat = inDat;
    
    bma = (b - a) / 2
    bpa = (b + a) / 2
    tmp = 0
    z = (bpa + bma * -0.97390653)
    tmp = tmp + 0.06667134 * gfx(z,funcName,inDat)[funcName]
    z = (bpa + bma * -0.86506337)
    tmp = tmp + 0.14945135 * gfx(z,funcName,inDat)[funcName]
    z = (bpa + bma * -0.67940957)
    tmp = tmp + 0.21908636 * gfx(z,funcName,inDat)[funcName]
    z = (bpa + bma * -0.43339539)
    tmp = tmp + 0.26926672 * gfx(z,funcName,inDat)[funcName]
    z = (bpa + bma * -0.14887434)
    tmp = tmp + 0.29552422 * gfx(z,funcName,inDat)[funcName]
    z = (bpa + bma * 0.14887434)
    tmp = tmp + 0.29552422 * gfx(z,funcName,inDat)[funcName]
    z = (bpa + bma * 0.43339539)
    tmp = tmp + 0.26926672 * gfx(z,funcName,inDat)[funcName]
    z = (bpa + bma * 0.67940957)
    tmp = tmp + 0.21908636 * gfx(z,funcName,inDat)[funcName]
    z = (bpa + bma * 0.86506337)
    tmp = tmp + 0.14945135 * gfx(z,funcName,inDat)[funcName]
    z = (bpa + bma * 0.97390653)
    tmp = tmp + 0.06667134 * gfx(z,funcName,inDat)[funcName]
    outDat['gauss10'] = tmp * bma
    if funcName == "Do":
        outDat['Do']      = outDat['gauss10']
    if funcName == "Dom":
        outDat['Dom']     = outDat['gauss10']
    if funcName == "kro_avg":
        outDat['kro_avg'] = outDat['gauss10']

    return outDat
    
def gfx(z,funcName,inDat):
    # Initialize output data structure as a Python dictionary
    outDat = inDat;
    
    Se_w = (1 + (inDat['alpha_nw'] * z) ** inDat['vg_N']) ** (-inDat['vg_M'])
    if (z - inDat['zan'] <= 0): 
        Se_t = 1
    else:
        Se_t = (1 + (inDat['alpha_an'] * (z - inDat['zan'])) ** inDat['vg_N']) ** (-inDat['vg_M'])

    if funcName == "kro_avg":
        if (Se_w > Se_t):
            Se_t = Se_w
        
    Sn_i = (1 - inDat['Swr']) * (Se_t - Se_w) / (1 - inDat['fr'] * (1 + Se_w - Se_t))
    Sn_r = inDat['fr'] * Sn_i
    Sn = Sn_r + (1 - inDat['Swr'] - Sn_r) * (Se_t - Se_w)
    
    if funcName == "Do":
        outDat['Do'] = Sn * inDat['Por']
        
    if funcName == "Dom":
        outDat['Dom'] = (Sn - Sn_r) * inDat['Por']
            
    if funcName == "kro_avg":
        if (inDat['krflag'] == 1):
            outDat['kro_avg'] = Sn ** 2 * (1 - Se_w ** (1 / inDat['vg_M'])) ** inDat['vg_M'] - ((1 - Se_t ** (1 / inDat['vg_M'])) ** inDat['vg_M'])
        else:
            outDat['kro_avg'] = math.sqrt(Sn) * ((1 - Se_w ** (1 / inDat['vg_M'])) ** inDat['vg_M'] - ((1 - Se_t ** (1 / inDat['vg_M'])) ** inDat['vg_M'])) ** 2
    
    return outDat
    
# LNAPL Parameter Lookup - 27 January 2021 
# Col_IDX Col_Desc
#   (0)  density (g/cm3)
#   (1)  density reference ID
#   (2)  viscosity (cp)
#   (3)  viscosity reference ID
#   (4)  NAPL surface tension (dynes/cm)
#   (5)  NAPL surface tension reference ID
#   (6)  NAPL/water interfacial tension (dynes/cm)
#   (7)  NAPL/water interfacial tension reference ID
#   (8)  vadose zone residual saturation - sand
#   (9)  vadose zone residual saturation - sandreference ID
#   (10) vadose zone residual saturation - silt
#   (11) vadose zone residual saturation - silt reference ID
#   (12) saturated zone residual saturation - sand
#   (13) saturated zone residual saturation - sandreference ID
#   (14) saturated zone residual saturation - silt
#   (15) saturated zone residual saturation - silt reference ID
#
# REFERENCES
#   1. Mercer, J.W. and Cohen, R.M., A review of immiscible fluids in the subsurface: properties, models, characterization and remediation, Journal of Contaminant Hydrology, v6:107-163, 1990.
#      a Table 3, line 16, R = 12.5 for gasoline in fine to medium sand. Assumed n = 0.4.
#      b Table 3, line 17, R = 20.0 for gasoline in silt to fine sand. Assumed n = 0.4.
#      c Table 3, line 21, R = 25 for middle distillates in fine to medium sand. Assumed n = 0.4.
#      d Table 3, line 22, R = 40 for middle distillates in silt to fine sand. Assumed n = 0.4.
#      e Table 3, line 21, R = 50 for fuel oil in fine to medium sand. Assumed n = 0.4.
#      f Table 3, line 22, R = 80 for fuel oil in silt to fine sand. Assumed n = 0.4.
#      g Appendix B, midpoint of 0.7 - 0.98 range for crude oil.
#      h Appendix B, midpoint of 8 - 87 range for crude oil.
#      i Appendix B, midpoint of 24 - 38 range for crude oil.
#      j Appendix B, midpoint of 0.8 - 0.85 range for diesel fules 1-D and 2-D.
#      k Appendix B, midpoint of 1.1 - 3.5 for diesel fules 1-D and 2-D.
#      l Appendix B, diesel fuels 1-D and 2-D.
#      m Appendix B, gasoline (automotive).
#      n Appdendix B, fuel oil no. 2.
#      o Appdendix B, typical value for petroleum hydrocarbons.
#   2. Assumed that residual saturation in the saturated zone is 50% greater than the residual saturation in the vadose zone.
#   3. Charbeneau, 2003, Appdendix D, p. 67.
#      a Midpoint of 24 - 38 range.
def lnaplParamLookup(lnaplName):
    lnaplChem = {"crude_oil"               : [0.84, '1g', 48,   '1h', 31, '1i', 50, '1o', -9999, 'NA', -9999, 'NA', -9999, 'NA', -9999, 'NA'],
                 "gasoline"                : [0.73,	'1m', 0.45,	'1m', 21, '1m', 50, '1m', 0.03, '1a',  0.05,  '1b', 0.05,  '2',  0.08,  '2'],
                 "diesel/kerosene/jetfuel" : [0.83,	'1j', 2.3,	'1k', 25, '1l', 50,	'1l', 0.06,	'1c',  0.1,   '1d', 0.09,  '2',  0.15,  '2'],
                 "heavy_fuel_oil"          : [0.88, '1n', 5.9,  '1n', 25, '1n', 50, '1n', 0.13,	'1e',  0.2,   '1f', 0.2,   '2',  0.3,   '2']}
    return lnaplChem[lnaplName]
	
# LNAPL Soil Property Lookup - 27 January 2021 
# Col_IDX Col_Desc
#   (0)  soil num
#   (1)  porosity
#   (2)  Ks (m/d)
#   (3)  theta_wr
#   (4)  van Genuchten Param. - N
#   (5)  van Genuchten Param. - alpha (1/m)
#   (6)  van Genuchten Param. - M
#
# REFERENCES
#   All soil types with '_CP' (first 12) correspond to the Soil_Prop and Parrish (1988) dataset - others are custom soil types not otherwise listed  
def soilPropLookup(soilType):
    soilProp = {"clay"                     : [1,  0.38, 0.048,  0.068, 1.09, 0.8,  0.08],
                "clay loam"                : [2,  0.41, 0.062,  0.095, 1.31, 1.9,  0.24],
                "loam"                     : [3,  0.43, 0.25,   0.078, 1.56, 3.6,  0.36],
                "loamy sand"               : [4,  0.41, 3.5,    0.057, 2.28, 12.4, 0.56],
                "silt"                     : [5,  0.46, 0.06,   0.034, 1.37, 1.6,  0.27],
                "silt loam"                : [6,  0.45, 0.11,   0.067, 1.41, 2,    0.29],
                "silty clay"               : [7,  0.36, 0.0048, 0.07,  1.09, 0.5,  0.08],
                "silty clay loam"          : [8,  0.43, 0.017,  0.089, 1.23, 1,    0.19],
                "sand"                     : [9,  0.43, 7.1,    0.045, 2.68, 14.5, 0.63],
                "sandy clay"               : [10, 0.38, 0.029,  0.1,   1.23, 2.7,  0.19],
                "sandy clay loam"          : [11, 0.39, 0.31,   0.1,   1.48, 5.9,  0.32],
                "sandy loam"               : [12, 0.41, 1.1,    0.065, 1.89, 7.5,  0.47],
                "clayey sand"              : [13, 0.38, 0.029,  0.1,   1.23, 2.7,  0.18699187],
                "clayey silt"              : [14, 0.36, 0.0048, 0.07,  1.09, 0.5,  0.082568807],
                "coal or black anthracite" : [15, 0.43, 0.25,   0.078, 1.56, 3.6,  0.358974359],
                "fill"                     : [16, 0.45, 0.11,   0.067, 1.41, 2,    0.290780142],
                "gravel"                   : [17, 0.43, 7.1,    0.045, 2.68, 14.5, 0.626865672],
                "no recovery"              : [18, 0.43, 7.1,    0.045, 2.68, 14.5, 0.626865672],
                "sandy silt"               : [19, 0.41, 1.1,    0.065, 1.89, 7.5,  0.470899471],
                "silty sand"               : [20, 0.41, 3.5,    0.057, 2.28, 12.4, 0.561403509]}
    return soilProp[soilType]

# main program starts here
# if __name__ == '__main__':
#     
#     print(darcyCalc("silt","gasoline",10,0.001))
    # Choose a standard soil type from the drop-down list or enter your own.
    # Choose a standard LNAPL type from the drop-down list or enter your own.
    # The thickness of floating LNAPL in the well (m).
    # Change in LNAPL elevation over distance (use consistent units).
    #
    # REFERENCES
    #   Charbeneau, 2007. LNAPL Distribution and Recovery Model (LDRM), Vol 1, Distribution and Recovery of Petroleum Hydrocarbo Liquids in Porous Media, Randall J. Charbeneau, API Publication 4760, January, 2007.
    #   Carsel and Parish, 1988.  Developing joint probability distributions of soil water retention characteristics, R.F. Carsel and R.S. Parrish, Water Resources Research, 24(5): 755-769, 1988.
    #   Mercer, J.W. and R.M. Cohen, 1990.  A Review of Immiscible Fluids in the Subsurface:  Properties, Models, Characterization and Remediation, Journal of Contaminant Hydrology 6:107-163

