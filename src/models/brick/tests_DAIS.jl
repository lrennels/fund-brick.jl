# -----------------------------------------------------------------------------
# Lisa Rennels
# September 28, 2017
# Script of tests comparing DAIS component in Julia to that in BRICK
# DAIS Component (The DCESS (Danish Center for Earth System Science)
# Antarctic Ice Sheet (DAIS) model)
# -----------------------------------------------------------------------------
# Input Parameters:
#
#    # A.  Model Constants and Parameters (Shaffer (2014) Table 1)

#   - dais_Tf            - Freezing temperature of seawater (deg C)
#   - dais_ρ_ice         - Ice density (kg/m^3)
#   - dais_ρ_seawater    - seawater density (kg/m^3)
#   - dais_ρ_rock        - rock density (kg/m^3)
#   - dais_SL₀           - initial condition - Present-day sea level (m) 
#   - dais_temp_ocean₀   - initial condition - Present-day, high-latitude ocean subsurface temperaturea (deg C)
#   - dais_radius₀       - initial condition - Reference ice sheet radius (m)

# B.  Model Parameters (Shaffer (2014) Table 1)

#   - dais_bedheight₀  - Undisturbed bed height at the continent center (m)
#   - dais_slope       - Slope of the undisturbed bed 
#   - dais_μ           - Profile parameter for parabolic ice sheet surface (m^0.5)
#   - dais_runoffline_snowheight₀ - Runoff line height for mean Antarctic temperature reduced to sea level (temp_SLprev) equal to 0 deg C (m)
#   - dais_c           - Proportionality constant for the dependency of runoff  line height on temp_SLprev (m/deg C)
#   - dais_precip₀     - Annual precipitation for temp_SLprev equal to 0 deg C (m ice)
#   - dais_κ           - Coefficient for the exponential dependency of precipitation on temp_SLprev (1/deg C)
#   - dais_ν           - Proportionality constant relating the runoff decrease  with height to precipitation (1/m^0.5yr^0.5)
#   - dais_flow₀       - Proportionality constant for ice flow at the grounding line (m/yr)
#   - dais_γ           - Power for the relation of ice flow speed to water depth 
#   - dais_α           - Partition parameter for effect of ocean subsurface temperature on ice flux

# C.  Other Model Parameters
#   - timestep    - time stetep
#   - dais_tempsensitivity - linear regression coefficient converting global mean surface temperature to Antarctic mean surface temperature
#   - dais_lf     - Mean AIS fingerprint at AIS shore

# D.  Model Parameters from Other Componenents

# from DOECLIM component: 
#   - temp        - Global mean surface temp relative to the 1850-1870 mean (deg C) 

# from ANTO component:
#   - anto_temp_ocean- high-latitude ocean subsurface temperaturea (deg C)  

# from other 3 SLR contribution components (GIC_MAGICC, SIMPLE, and TE):                       
#   - slr_gic     - rate of sea-level change from gic component (m/yr)      
#   - slr_gic     - rate of sea-level change from gis component (m/yr)      
#   - slr_gic     - rate of sea-level change from te component (m/yr)      
#   - SL          - sea level (m)       

# -----------------------------------------------------------------------------

using Mimi
using RCall
using Base.Test
using DataFrames

include("../src/DAIS.jl")

@testset "DAIS compreonent" begin

#set parameters (hard coded values from Shaffer (2014) and checked against dais.R)
# A.  Model Constants and Parameters (Shaffer (2014) Table 1)

dais_Tf            = -1.8    # Freezing temperature of seawater (deg C)
dais_ρ_ice         = 917.    # Ice density (kg/m^3)
dais_ρ_seawater    = 1030.   # seawater density (kg/m^3)
dais_ρ_rock        = 4000.   # rock density (kg/m^3)
dais_SL₀           = 0.     # initial condition - Present-day sea level (m) 
dais_temp_ocean₀   = 0.72   # initial condition - Present-day, high-latitude ocean subsurface temperaturea (deg C)
dais_radius₀       = 1.864 * (10.)^6 # initial condition - Reference ice sheet radius (m)

# B.  Model Parameters (Shaffer (2014) Table 1)

dais_bedheight₀  = 775.      # Undisturbed bed height at the continent center (m)
dais_slope       = 6. * (10.)^(-4) # Slope of the undisturbed bed 
dais_μ           = 8.7       # Profile parameter for parabolic ice sheet surface (m^0.5)
dais_runoffline_snowheight₀ = 1471.   # Runoff line height for mean Antarctic temperature reduced to sea level (temp_SLprev) equal to 0 deg C (m)
dais_c           = 95.       # Proportionality constant for the dependency of runoff  line height on temp_SLprev (m/deg C)
dais_precip₀     = 0.35      # Annual precipitation for temp_SLprev equal to 0 deg C (m ice)
dais_κ           = 4.0 * (10.)^(-2)  # Coefficient for the exponential dependency of precipitation on temp_SLprev (1/deg C)
dais_ν           = 1.2 * (10.)^(-2)  # Proportionality constant relating the runoff decrease  with height to precipitation (1/m^0.5yr^0.5)
dais_flow₀       = 1.2       # Proportionality constant for ice flow at the grounding line (m/yr)
#gamma is a value between 1/2 and 17/4 
dais_γ           = 2.5       # Power for the relation of ice flow speed to water depth 
#alpha is a value between 0 and 1 
dais_α           = 0.5       #Partition parameter for effect of ocean subsurface temperature on ice flux

# C.  Other Model Parameters
timestep    = 1.        # time step
dais_tempsensitivity = 1.    # linear regression coefficient converting global mean surface temperature to Antarctic mean surface temperature
dais_lf          = -1.18     # Mean AIS fingerprint at AIS shore

# D.  Model Parameters from Other Componenents
srand(123)

# from DOECLIM component: 
temp    = rand(100)*7   # Global mean surface temp ANOMLALY relative to the 1850-1870 mean (deg C) 
# from ANTO component:
anto_temp_ocean = rand(100)  # high-latitude ocean subsurface temperaturea (deg C)  

# from all 3 other contribution components (GIC_MAGICC, SIMPLE, and TE):                       
slr_gic = rand(100)     # rate of sea-level change (m/yr)   
slr_te = rand(100)
slr_gis = rand(100)

# TODO_1:  Set SL[1] to SL₀ so this will match up with the dais. R code, 
#          which does not use SL₀ but instead SL[1] as an initial condition 
#          (see TODO_5 in DAIS.jl)
SL      = rand(100)     #sea level (m)   
SL[1]   = dais_SL₀;

# run Julia version of DAIS

dais_model = Model()

setindex(dais_model, :time, length(temp))

addcomponent(dais_model, dais)

setparameter(dais_model, :dais, :dais_Tf, dais_Tf)
setparameter(dais_model, :dais, :dais_ρ_ice, dais_ρ_ice)
setparameter(dais_model, :dais, :dais_ρ_seawater, dais_ρ_seawater)
setparameter(dais_model, :dais, :dais_ρ_rock, dais_ρ_rock)
setparameter(dais_model, :dais, :dais_SL₀, dais_SL₀)
setparameter(dais_model, :dais, :dais_temp_ocean₀, dais_temp_ocean₀)
setparameter(dais_model, :dais, :dais_radius₀, dais_radius₀)

setparameter(dais_model, :dais, :dais_bedheight₀, dais_bedheight₀)
setparameter(dais_model, :dais, :dais_slope, dais_slope)
setparameter(dais_model, :dais, :dais_μ, dais_μ)
setparameter(dais_model, :dais, :dais_runoffline_snowheight₀, dais_runoffline_snowheight₀)
setparameter(dais_model, :dais, :dais_c, dais_c)
setparameter(dais_model, :dais, :dais_precip₀, dais_precip₀)
setparameter(dais_model, :dais, :dais_κ, dais_κ)
setparameter(dais_model, :dais, :dais_ν, dais_ν)
setparameter(dais_model, :dais, :dais_flow₀, dais_flow₀)
setparameter(dais_model, :dais, :dais_γ, dais_γ)
setparameter(dais_model, :dais, :dais_α, dais_α)

setparameter(dais_model, :dais, :timestep, timestep)
setparameter(dais_model, :dais, :dais_tempsensitivity, dais_tempsensitivity)
setparameter(dais_model, :dais, :dais_lf, dais_lf)

setparameter(dais_model, :dais, :temp, temp)
setparameter(dais_model, :dais, :anto_temp_ocean, anto_temp_ocean)
setparameter(dais_model, :dais, :slr_gic, slr_gic) 
setparameter(dais_model, :dais, :slr_gis, slr_gis) 
setparameter(dais_model, :dais, :slr_te, slr_te) 
setparameter(dais_model, :dais, :SL, SL)

run(dais_model)
resultsjulia =  dais_model[:dais, :slr]

#run R version of DAIS
r_filename = joinpath(@__DIR__, "original-BRICK", "R", "dais.R")

#requires input of sea level temperature
Rinput_Ta = temp * dais_tempsensitivity
Rinput_totaldslr = vcat((slr_gic[1] .+ slr_te[1] .+ slr_gis[1]), diff(slr_gic .+ slr_te .+ slr_gis))

R"""
filename <- $(r_filename)
source(filename)
resultsR <- dais(Ta = $Rinput_Ta,SL = $SL, Toc = $anto_temp_ocean, dSL = $Rinput_totaldslr)
"""

#compare results
@test resultsR ≈ resultsjulia atol= 0.

end