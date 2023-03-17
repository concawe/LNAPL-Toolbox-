# -*- coding: utf-8 -*-
# CONCAWE LNAPL TOOLBOX: SUBSURFACE VOLUME AND EXTENT CALCULATOR
import math
# import pickle

def mwCalc(waterDensity,lnaplDensity,lnaplViscosity,airWaterTension,lnaplWaterTension,lnaplAirTension,lnaplResidSatFact,locR,soilR,stratR):
# def mwCalc(locR,soilR,stratR):
    # Copyright Phillip C. de Blanc, 2014.
    # This function computes the average LNAPL seepage velocity based on an observed
    # monitoring well thickness (bo) for up to X layers (Layers) given the depth
    # to the bottom of the LNAPL (depth) using Gaussian quadrature.
    # Reference: Charbeneau, R.J., LNAPL Distribution and Recover Model (LDRM), Volume 1: Distribution
    # and Recovery of Petroleum Hydrocarbon Liquids in Porous Media, API Publication 4760, January 2007.
    # This code converts meters used in input to cm. Output units are cm3/cm2.

    # # -----------------------------------
    # # FOR TESTING - PICKLE R DATA OBJECTS
    # # -----------------------------------
    # # >>> SAVE VARIABLES <<<
    # with open('data_out.pickle', 'wb') as f:
    #     pickle.dump([locR, soilR, stratR], f)
    # # >>> LOAD VARIABLES <<<
    # with open('data_out.pickle', 'rb') as f:
    #     locR, soilR, stratR = pickle.load(f)
    # # -----------------------------------
    # # -----------------------------------
    
    # Initialize output data structure as a Python dictionary
    outDat = dict();
    
    # # Initialize default values
    # waterDensity       = 1   # g/cm3
    # lnaplDensity       = 0.8 # g/cm3
    # lnaplViscosity     = 2   # cp
    # airWaterTension    = 65  # dyn/cm
    # lnaplWaterTension  = 15  # dyn/cm
    # lnaplAirTension    = 25  # dyn/cm
    # lnaplResidSatFact  = 0.2 # unitless
    den_r              = lnaplDensity/waterDensity
     
    # Unpack stratigraphy dict
    layer_location     = stratR['Location']
    layer_bottom_depth = stratR['Layer_Bottom_Depth_m']
    layer_top_depth    = stratR['Layer_Top_Depth_m']
    layer_soil_type    = stratR['Soil_Type'] 
        
    # Re-assign variable names to mimic existing VBA code
    denrel = den_r
    st_ao  = lnaplAirTension
    st_ow  = lnaplWaterTension
    st_aw  = airWaterTension
    fr     = lnaplResidSatFact

    # Location ID -- outermost loop
    for locID in dict.keys(locR):
        # Initialize layer-specific data structure as a Python dictionary
        layDat = dict();
    
        # Re-assign variable names to mimic existing VBA code
        bo    = (locR[locID]['LNAPL_Bottom_Depth_m'] - locR[locID]['LNAPL_Top_Depth_m']) * 100     # convert bo from meters to cm
        depth = locR[locID]['LNAPL_Bottom_Depth_m'] * 100  # convert from meters to cm

        # Datum is depth to bottom of LNAPL = 0 elevation. All other elevations are computed relative
        # to this datum, up to the maximum height of LNAPL in soil above the datum which is equal to zmax.
        zao  = bo
        zao_m = zao/100 #converting back to meters
        zmax = bo + (1 - denrel) * (st_ao / st_ow) / (denrel - (1 - denrel) * (st_ao / st_ow)) * bo

        # Layer -- 2nd loop
        # print("-----")
        layBottom = []
        layTop    = []
        laySoil   = []
        layInteg  = []
        layFirst  = 0
        layLast   = 0
        # Identify layers containing LNAPL
        count = 0
        for layer in range(len(layer_location)):
            if layer_location[layer] == locID:
                layBottom.append(depth - (layer_bottom_depth[layer] * 100)) # convert from meters to cm
                layTop.append(depth - (layer_top_depth[layer] * 100))       # convert from meters to cm
                laySoil.append(layer_soil_type[layer])
                if layBottom[count] > zmax:
                    layInteg.append(0)
                    # print(locID + " - zmax: " + str(round(zmax,2)) + " >>> Layer" + str(count) + ": " + str(round(layBottom[count],2)) + " to " + str(round(layTop[count],2)) + " (" + laySoil[count] + ")")
                elif layTop[count] > 0:
                    layInteg.append(1)
                    # print(locID + " - zmax: " + str(round(zmax,2)) + " >>> Layer" + str(count) + "*: " + str(round(layBottom[count],2)) + " to " + str(round(layTop[count],2)) + " (" + laySoil[count] + ")")
                    # identify first layer and adjust top so that it equals zmax
                    if layFirst == 0:
                        layTop[count] = zmax    
                        # print(locID + " - zmax: " + str(round(zmax,2)) + " >>> Layer" + str(count) + "*MOD: " + str(round(layBottom[count],2)) + " to " + str(round(layTop[count],2)) + " (" + laySoil[count] + ")")
                        layFirst = 1
                else:
                    layInteg.append(0)
                    # identify last layer and adjust bottom so that it equals 0
                    if layLast == 0:
                        layBottom[count-1] = 0  
                        # print(locID + " - zmax: " + str(round(zmax,2)) + " >>> Layer" + str(count-1) + "*MOD: " + str(round(layBottom[count-1],2)) + " to " + str(round(layTop[count-1],2)) + " (" + laySoil[count-1] + ")")
                        layLast = 1
                    # print(locID + " - zmax: " + str(round(zmax,2)) + " >>> Layer" + str(count) + ": " + str(round(layBottom[count],2)) + " to " + str(round(layTop[count],2)) + " (" + laySoil[count] + ")")
                count = count + 1
                
        # Remove unnecessary layers
        count = 0
        for layer in range(len(layInteg)):
            if layInteg[count] == 0:
                layInteg.pop(count)
                layTop.pop(count)
                layBottom.pop(count)
                laySoil.pop(count)
                count = count - 1
            count = count + 1
            
        # Lookup soil properties for each layer
        alpha   = []
        alpha_o = []
        alpha_a = []
        N       = []
        M       = []
        Swr     = []
        Por     = []
        Ksat    = []
        for layer in range(len(layInteg)):
            alpha.append(soilR[laySoil[layer]]['alpha_m'] / 100)
            alpha_o.append((1 - denrel) * st_aw * alpha[layer] / st_ow)
            alpha_a.append(alpha[layer] * denrel * st_aw / st_ao)
            N.append(soilR[laySoil[layer]]['N'])
            M.append(soilR[laySoil[layer]]['M'])
            Por.append(soilR[laySoil[layer]]['Porosity'])
            Swr.append(soilR[laySoil[layer]]['Theta_wr'] / Por[layer])
            Ksat.append(soilR[laySoil[layer]]['Ks_m-d'] * 100)
            
        # Compile layer-specific data structure
        layDat['Top']     = layTop
        layDat['Bottom']  = layBottom
        layDat['Soil']    = laySoil
        layDat['alpha_o'] = alpha_o
        layDat['alpha_a'] = alpha_a
        layDat['N']       = N
        layDat['M']       = M
        layDat['Swr']     = Swr
        layDat['Por']     = Por
        layDat['Ksat']    = Ksat
        layDat['zao']     = zao
        layDat['zao_m']   = zao_m
        layDat['zmax']    = zmax
        layDat['fr']      = fr
            
        # Output from code
        calcVars = ['Do','Dom','kro_avg','Kn_avg']
        for calcVar in calcVars:
            layDat[calcVar]          = 0
            for layer in range(len(layInteg)):
                # Integrate above and below sat peak as separate layers
                if (layDat['Top'][layer] > bo) and (layDat['Bottom'][layer] < bo):
                    layDat[calcVar] = layDat[calcVar] + gauss10m(layDat['Bottom'][layer],bo,layer,calcVar,layDat)[calcVar]
                    layDat[calcVar] = layDat[calcVar] + gauss10m(bo,layDat['Top'][layer],layer,calcVar,layDat)[calcVar]
                else:
                    layDat[calcVar] = layDat[calcVar] + gauss10m(layDat['Bottom'][layer],layDat['Top'][layer],layer,calcVar,layDat)[calcVar]
        
        # Adjust units as needed                                                                                                                      
        layDat['Do'] = layDat['Do'] / 100
        layDat['Dom'] = layDat['Dom'] / 100
        layDat['kro_avg'] = layDat['kro_avg']
        layDat['Kn_avg'] = layDat['Kn_avg'] * lnaplDensity / lnaplViscosity / 100
        
        # Calculated from output
        layDat['zmax_m'] = layDat['zmax'] / 100
        layDat['T_avg']  = layDat['Kn_avg'] * layDat['zmax_m']
        layDat['U']      = layDat['Kn_avg'] * locR[locID]['LNAPL_Gradient']
        layDat['lnaplVolCont'] = layDat['Do'] / layDat ['zmax_m']
        layDat['vn_avg'] = layDat['Kn_avg'] * locR[locID]['LNAPL_Gradient'] / layDat['lnaplVolCont']

        # Print results to terminal - useful for debugging
        # print("Layer-specific Metrics >>>")
        # print("   Top:     " + str(layDat['Top']))
        # print("   Bottom:  " + str(layDat['Bottom']))
        # print("   Soil:    " + str(layDat['Soil']))
        # print("   alpha_o: " + str(layDat['alpha_o']))
        # print("   alpha_a: " + str(layDat['alpha_a']))
        # print("   N:       " + str(layDat['N']))
        # print("   M:       " + str(layDat['M']))
        # print("   Swr:     " + str(layDat['Swr']))
        # print("   Por:     " + str(layDat['Por']))
        # print("   Ksat:    " + str(layDat['Ksat']))
        # print("Scalar Inputs >>>")
        # print("   zao:     " + str(layDat['zao']))
        # print("   zmax:    " + str(layDat['zmax']))
        # print("   fr:      " + str(layDat['fr']))
        # print("Scalar Outputs >>>")
        # print("   Do:      " + str(layDat['Do']))
        # print("   Dom:     " + str(layDat['Dom']))
        # print("   kro_avg: " + str(layDat['kro_avg']))
        # print("   Kn_avg:  " + str(layDat['Kn_avg']))
        # print("   vn_avg:  " + str(layDat['vn_avg']))
        # print("-----")

        # Subset output to includ only the desired calculated values
        outDat[locID]      = [layDat['Do'], layDat['Dom'], layDat['kro_avg'], layDat['zao_m'], layDat['Kn_avg'], layDat['T_avg'], layDat['U'], layDat['vn_avg']]
        
    return outDat
  
# Integrates the user-defined function "gfx" (which must be defined by the user)
# by 10-point Gaussian Quadrature
def gauss10m(a,b,j,funcName,inDat):
    # Initialize output data structure as a Python dictionary
    outDat = inDat;
    
    bma = (b - a) / 2
    bpa = (b + a) / 2
    tmp = 0
    z = (bpa + bma * -0.97390653)
    tmp = tmp + 0.06667134 * gfxm(z,j,funcName,inDat)[funcName]
    z = (bpa + bma * -0.86506337)
    tmp = tmp + 0.14945135 * gfxm(z,j,funcName,inDat)[funcName]
    z = (bpa + bma * -0.67940957)
    tmp = tmp + 0.21908636 * gfxm(z,j,funcName,inDat)[funcName]
    z = (bpa + bma * -0.43339539)
    tmp = tmp + 0.26926672 * gfxm(z,j,funcName,inDat)[funcName]
    z = (bpa + bma * -0.14887434)
    tmp = tmp + 0.29552422 * gfxm(z,j,funcName,inDat)[funcName]
    z = (bpa + bma * 0.14887434)
    tmp = tmp + 0.29552422 * gfxm(z,j,funcName,inDat)[funcName]
    z = (bpa + bma * 0.43339539)
    tmp = tmp + 0.26926672 * gfxm(z,j,funcName,inDat)[funcName]
    z = (bpa + bma * 0.67940957)
    tmp = tmp + 0.21908636 * gfxm(z,j,funcName,inDat)[funcName]
    z = (bpa + bma * 0.86506337)
    tmp = tmp + 0.14945135 * gfxm(z,j,funcName,inDat)[funcName]
    z = (bpa + bma * 0.97390653)
    tmp = tmp + 0.06667134 * gfxm(z,j,funcName,inDat)[funcName]
    outDat['gauss10'] = tmp * bma
    if funcName == "Do":
        outDat['Do']      = outDat['gauss10']
    if funcName == "Dom":
        outDat['Dom']     = outDat['gauss10']
    if funcName == "kro_avg":
        outDat['kro_avg'] = outDat['gauss10']
    if funcName == "Kn_avg":
        outDat['Kn_avg']  = outDat['gauss10']
                
    return outDat
    
def gfxm(z,j,funcName,inDat):
    # Initialize output data structure as a Python dictionary
    outDat = inDat;

    Se_w = (1 + (inDat['alpha_o'][j] * z) ** inDat['N'][j]) ** (-inDat['M'][j])
    if (z - inDat['zao'] <= 0):  
        Se_t = 1
    else:
        Se_t = (1 + (inDat['alpha_a'][j] * (z - inDat['zao'])) ** inDat['N'][j]) ** (-inDat['M'][j])
        
    Sn_i = (1 - inDat['Swr'][j]) * (Se_t - Se_w) / (1 - inDat['fr'] * (1 + Se_w - Se_t))
    Sn_r = inDat['fr'] * Sn_i
    Sn = (Sn_r + (1 - inDat['Swr'][j] - Sn_r) * (Se_t - Se_w))

    if funcName == "Do":
        outDat['Do'] = Sn * inDat['Por'][j]
        
    if funcName == "Dom":
        outDat['Dom'] = (Sn - Sn_r) * inDat['Por'][j]
            
    if funcName == "kro_avg":
        outDat['kro_avg'] = math.sqrt(Sn) / inDat['zmax'] * ((1 - Se_w ** (1 / inDat['M'][j])) ** inDat['M'][j] - ((1 - Se_t ** (1 / inDat['M'][j])) ** inDat['M'][j])) ** 2
    
    if funcName == "Kn_avg":
        outDat['Kn_avg'] = inDat['Ksat'][j] * math.sqrt(Sn) / inDat['zmax'] * ((1 - Se_w ** (1 / inDat['M'][j])) ** inDat['M'][j] - ((1 - Se_t ** (1 / inDat['M'][j])) ** inDat['M'][j])) ** 2

    return outDat

# # main program starts here
# if __name__ == '__main__':	
