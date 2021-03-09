<h3> What the Model Does </h3>

This model calculates the theoretical concentrations of LNAPL constituents downgradient of an LNAPL release over time caused by  dissolution processes alone.

<hr class="featurette-divider">

<h3> How the Model Works </h3>

A known volume of LNAPL is released to the subsurface. The LNAPL has several components whose volume fractions are known, and the density of the LNAPL is also known. The unidentified fraction of the LNAPL is a mixed petroleum product with unknown components, but with a known average molecular weight.

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

- Volume is conserved upon fluid mixing.
- The concentration of a constituent in the aqueous phase in equilibrium with the LNAPL is the constituent’s mole fraction in the LNAPL times the constituent’s pure phase solubility.
- Water exiting the LNAPL lens is saturated with each LNAPL constituent; i.e., there is perfect mixing between groundwater and LNAPL constituents in the LNAPL lens.
- LNAPL does not impede groundwater flow.
- Fluid densities and solubilities do not change significantly with temperature.
- The change in total number of moles in the LNAPL is slow over the time period of the model.

<hr class="featurette-divider">

<h3> Developer </h3>

This LNAPL tool was developed by Dr. Phil de Blanc, GSI Environmental.

<hr class="featurette-divider">

de Blanc, P., 2021.  LNAPL Dissolution Calculator, Concawe LNAPL Toolbox.