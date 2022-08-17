<h3> LNAPL Dissolution to Groundwater Model </h3>

<h3> What the Model Does </h3>

This model calculates the theoretical concentration of dissolved hydrocarbons <u>in groundwater</u> downgradient of an LNAPL source over time due to dissolution processes. The model produces a graph of dissolved constituent (such as B,T,E, X and MTBE) in groundwater over time in units of mg/L as an LNAPL source is depleted of these soluble constituents.


<hr class="featurette-divider">

<h3> How the Model Works </h3>

A known volume of LNAPL is released to the subsurface. The LNAPL is comprised of several components whose volume fractions and densities are known. The unidentified fraction of the LNAPL is a mixed petroleum product with unknown components, but with a known average molecular weight and density.

The LNAPL establishes a lens in the groundwater with a known width and average thickness. Groundwater flows through the LNAPL lens and dissolves the LNAPL constituents, reducing the remaining volume of LNAPL and changing its composition as the more soluble compounds dissolve out of the LNAPL. Equilibrium between the water and LNAPL within the lens is assumed, so that the concentration of constituents downgradient of the LNAPL are equal to the effective solubility of the LNAPL constituents. Effective solubility is the solubility of a pure phase component times its mole fraction in the LNAPL.

The key strengths of the model are:
- The model is simple and easy to understand.
- Because of its simplicity, the model can be modified by users if needed.

Weakness of the model are:
- Equilibrium is unlikely to be completely achieved at actual sites, so the model over-estimates downgradient aqueous phase concentrations.
- The explicit solution scheme can become inaccurate or unstable if the time step is too large.

<hr class="featurette-divider">

<h3> Key Assumptions </h3>

Key assumptions of the model are as follows:

- The groundwater concentration is directly downgradient of the LNAPL body before any attenuation or mixing occurs.
- Volume is conserved upon fluid mixing.
- The concentration of a constituent in the aqueous phase in equilibrium with the LNAPL is the constituent’s mole fraction in the LNAPL times the constituent’s pure phase solubility.
- Water exiting the LNAPL lens is saturated with each LNAPL constituent; i.e., there is perfect mixing between groundwater and LNAPL constituents in the LNAPL lens.
- LNAPL does not impede groundwater flow.
- Fluid densities and solubilities do not change significantly with temperature.
- The change in total number of moles in the LNAPL is slow over the time period of the model.

<hr class="featurette-divider">

<h3> Input Data </h3>

Many laboratory analysis of LNAPL show composition as mass concentrations (mg/L).  To convert a mass concentration of a constituent like benzene to a volume fraction, you will need to divide the mg/L value by the density of the constituent (78,000 mg per gram-mole for benzene). So 1 mg/L benzene concentration in LNAPL becomes a volume fraction of  1.3x10-5 Liters benzene per Liter of LNAPL (unitless).

Guidance on the selection of specific input parameters for this tool is provided in <b>Section 7.2</b> of the User’s Manual which can be seen here:

<div style = "text-align:center;">
<a class="btn btn-default btn btn-default shiny-download-link shiny-bound-output button1" onclick="window.open('https://www.concawe.eu/wp-content/uploads/Rpt_22-5.pdf#page=46')" role="button">Download User's Manual</a>
<a class="btn btn-default btn btn-default shiny-download-link shiny-bound-output button1" onclick="window.open('05_LNAPL-Risk/Tier_2/LNAPL_Dissolution_Calculator_Example.pdf')" role="button">Download Example</a>
</div>

<hr class="featurette-divider">

<h3> Developer </h3>

This LNAPL tool was developed by Dr. Phil de Blanc, GSI Environmental.

<hr class="featurette-divider">

de Blanc, P., 2021.  LNAPL Dissolution Calculator, Concawe LNAPL Toolbox.
