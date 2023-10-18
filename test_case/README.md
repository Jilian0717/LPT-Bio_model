2023.10.17

Note: All files in this directory were used for a one-time release case in 2021.06.31 for Dr. Margaret Mulholland's heatwave work.

### ptrack3_bio.f90

Source code for the harmful algal bloom model developed in [Xiong et al (2023)](https://aslopubs.onlinelibrary.wiley.com/doi/full/10.1002/lol2.10308). Search 'jx' to see the revisions compared to the original particle tracking code of [SCHISM](https://github.com/schism-dev/schism/tree/master/src/Utility/Particle_Tracking). Note: SCHISM's particle tracking is constantly updated by the developers.

The general idea for this particle-tracking model is to treat a numerical particle as a **virtual sensor** to record the water temperature, salinity, nutrient concentrations (mainly DIN here), turbidity, and light intensity (or other factors) that were experienced by each particle during its transport. The particle will also **record a changing concentration** to represent the algal biomass, which can increase (algae grow) or decrease (algae die) based on the surrounding environments of each particle. Given an initial concentration C<sub>0</sub>, the changing algal biomass can be solved via dC/dt = gC, where g is the net growth rate. In this study, we tested the harmful algal species *Margalefidinium polykrikoides* because of the relatively well-developed equations that govern its bloom cycle ([Qin et al., 2021](https://www.sciencedirect.com/science/article/abs/pii/S1568988321000858) and [Hofmann et al., 2021](https://www.sciencedirect.com/science/article/abs/pii/S1568988321000949)). Another important part of this particle model is [**satellite data**](https://coastwatch.noaa.gov/cw_html/NCCOS.html). We used the satellite to initiate C<sub>0</sub> and evaluate the model performance. 

### input files:
- particle.bp: specify particle release time, release location, etc
- DIN_2020.txt & TSS_2020.txt: interpolated DIN and TSS to each grid node from Cheaspeake Bay Program observations since the hydrodynamic model I used didn't include the biogeochemical module; the start time is 2020.01.01; outside the bay mouth, the DIN value is the averaged value from CB7.4N, CB7.4, and CB8.1E; DIN and TSS were vertically averaged in the present version, can be revised with vertical variation in the future.
