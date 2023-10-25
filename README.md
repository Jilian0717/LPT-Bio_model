### LPT-Bio_model
Lagrangian particle tracking and biological (LPT-Bio) model developed based on [SCHISM](https://github.com/schism-dev/schism)

`/test_case/`

Include the revised particle tracking code (**ptrack3_bio.f90**) with algal bloom dynamics and diel vertical migrations, the example particle initialization file (particle.bp), and DIN, TSS files

`/sentinel_image/`

satellite data (with high quality) covering the tracking period from 2020.07.28 - 2020.08.06; downloaded from NOAA Algal Bloom Beta/Experimental [Products](https://coastwatch.noaa.gov/cw_html/NCCOS.html)

`/post_processing/`

Generate the maps of chl-a concentrations based on particle tracking in Xiong et al. 2023. 


References:

Xiong, J., Shen, J., Qin, Q., Tomlinson, M. C., Zhang, Y. J., Cai, X., Ye, F., Cui, L., Mulholland, M. R. (2023). Biophysical interactions control the progression of harmful algal blooms in Chesapeake Bay: a novel Lagrangian particle tracking model with mixotrophic growth and vertical migration. [Limnology and Oceanography Letters](https://aslopubs.onlinelibrary.wiley.com/doi/full/10.1002/lol2.10308).

Xiong, J., Shen, J., Wang, Q. (2022). Storm-induced coastward expansion of Margalefidinium polykrikides in Chesapeake Bay. [Marine Pollution Bulletin, 184, 114187](https://www.sciencedirect.com/science/article/abs/pii/S0025326X22008694).


Corresponding to Jilian Xiong: xiongjilian@gmail.com