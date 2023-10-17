**ptrack3_bio.f90**

source code for the harmful algal bloom model developed in [Xiong et al (2023)](https://aslopubs.onlinelibrary.wiley.com/doi/full/10.1002/lol2.10308). The general idea for this particle-tracking model is to treat a numerical particle as a virtual sensor to record the water temperature, salinity, nutrient concentration (mainly DIN here), turbidity, light intensity (or other factors) that are experienced by each particle during their transport. The particle will also record a concentration to represent the changing algae, which can grow or die based on the surrounding environments of each particle. 

Search 'jx' to see the revisions compared to the original particle tracking code of [SCHISM](https://github.com/schism-dev/schism/tree/master/src/Utility/Particle_Tracking). Note: SCHISM's particle tracking is constantly updated by the developers.
