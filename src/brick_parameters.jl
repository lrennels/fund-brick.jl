# -----------------------------------------------------------------------------
# Lisa Rennels
# October 5, 2017
# script to set the full SLR model parameters
# -----------------------------------------------------------------------------

# Step 1.  Set parameters for gic_magicc

gic_β₀ = 0.000577   # Initial mass-balance sensitivity to global temperatures (m/degC/yr)
gic_v₀ = 0.4        # Initial total volume of GSIC (m sea-level equivalent (SLE)) 
gic_s₀ = 0.0        # Initial cumulative slr (m)
gic_n = 0.82        # Exponential parameter for area to volume scaling (unitless)
gic_teq = -0.15     # Theoretical equilibrium temp at which GSIC mass balance 
                    # is steady state (degC)

# Step 2.  Set parameters for simple

simple_c = -0.827   # sensitivity of the equilibrium volume to changes 
                    # in temperature (mSLEC/degC)
simple_b = 7.242    # equilibrium volume veq for 0 temperature anomaly (mSLE)
simple_α = 1.630e-4 # sensitivity to temperature of the timescale of GIS 
                    # volume response to changes in temperature (1/C*m)
simple_β = 2.845e-05   # equilibrium (temp D = 0 deg C) timescale of GIS volume 
                    # response to changes in temperature (1/yr)
simple_v₀ = 7.242   # initial total volume of GIS (mSLE)   

# Step 3.  Set parameters for te

te_a = 0.5          # Sensitivity of equilibrium slr from TE (m/degC) 
te_b = 0.0          # Equilibrium slr from te with no temp anomaly (m) 
te_τ = (1./0.005)   # e-folding timescale at which current sea level adjusts to equilibrium (yr) 
te_s₀ = 0.0         # Initial sea level rise designated in 1850 (m)

# Step 4.  Set parameters for anto

anto_α = 0.26   # sensitivity of the Antarctic Ocean temperature to global 
                # mean surface temperature
anto_β = 0.62   # the approximate Antarctic Ocean temperature for temp = 0 
anto_Tf = -1.8  # freezing temperature of seawater (deg C)

# Step 5.  Set parameters for dais

# A.  Model Constants and Parameters (Shaffer (2014) Table 1)

dais_Tf = -1.8           # Freezing temperature of seawater (deg C)
dais_ρ_ice = 917.        # Ice density (kg/m^3)
dais_ρ_seawater = 1030.  # seawater density (kg/m^3)
dais_ρ_rock = 4000.      # rock density (kg/m^3)
dais_SL₀ = 0.            # initial condition - Present-day sea level (m) 
dais_temp_ocean₀ = 0.72  # initial condition - Present-day, high-latitude ocean 
                         # subsurface temperaturea (deg C)
dais_radius₀  = 1.864 * (10.)^6 # initial condition - Reference ice sheet radius (m)

# B.  Model Parameters (Shaffer (2014) Table 1)

dais_bedheight₀  = 775.      # Undisturbed bed height at the continent center (m)
dais_slope = 6. * (10.)^(-4) # Slope of the undisturbed bed 
dais_μ = 8.7                 # Profile parameter for parabolic ice sheet surface (m^0.5)
dais_runoffline_snowheight₀ = 1471. # Runoff line height for mean Antarctic temperature 
                                    #reduced to sea level (temp_SLprev) equal to 0 deg C (m)
dais_c = 95.            # Proportionality constant for the dependency of runoff  
                        # line height on temp_SLprev (m/deg C)
dais_precip₀ = 0.35     # Annual precipitation for temp_SLprev equal to 0 deg C (m ice)
dais_κ = 4.0 * (10.)^(-2)   # Coefficient for the exponential dependency of precipitation 
                            # on temp_SLprev (1/deg C)
dais_ν = 1.2 * (10.)^(-2)   # Proportionality constant relating the runoff decrease  
                            # with height to precipitation (1/m^0.5yr^0.5)
dais_flow₀ = 1.2    # Proportionality constant for ice flow at the grounding line (m/yr)
                    # gamma is a value between 1/2 and 17/4 
dais_γ = 2.5        # Power for the relation of ice flow speed to water depth 
                    # alpha is a value between 0 and 1 
dais_α = 0.5        # Partition parameter for effect of ocean subsurface temperature on ice flux

# C.  Other Model Parameters
dais_tempsensitivity = 1.    # linear regression coefficient converting global mean 
                        # surface temperature to Antarctic mean surface temperature
dais_lf = -1.18              # Mean AIS fingerprint at AIS shore

