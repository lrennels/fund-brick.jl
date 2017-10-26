# -----------------------------------------------------------------------------
# Lisa Rennels
# September 10, 2017
# script of tests comparing SIMPLE component in Julia to that in BRICK
# SIMPLE Component (Simple Ice-sheet Model for Projecting Large Ensembles)
# -----------------------------------------------------------------------------
# General Description:
#
# BRICK uses the mechanistically motivated, zero-dimensional
# SIMPLE (Simple Ice-sheet Model for Projecting Large Ensembles) model as the 
# parameterization for  the Greenland Ice Sheet (GIS) contribution to global mean
# sea-level change (Bakker et al., 2016). (Wong et al. 2017)
# -----------------------------------------------------------------------------
# Input Parameters:
#
#   - tstep - timestep (year)
#   - c     - sensitivity of the equilibrium volume to changes in temperature (mSLEC/degC)
#   - b     - equilibrium volume veq for 0 temperature anomaly (mSLE)
#   - α     - sensitivity to temperature of the timescale of GIS 
#             volume response to changes in temperature (1/C*m)
#   - β     - equilibrium (temp D = 0 deg C) timescale of GIS volume 
#             response to changes in temperature (1/yr)
#   - v0    - initial total volume of GIS (mSLE)   
#   - temp    -  Global mean surface temp relative to the 1961-1990 mean (degC) 
#             (received from doeclim component)
# -----------------------------------------------------------------------------

using Mimi
using RCall
using Base.Test
using DataFrames

include("../src/SIMPLE.jl")

@testset "SIMPLE component" begin

#set parameters
timestep = 1.; 
simple_c = -0.827      #from R model
simple_b = 7.242       #from R model
simple_α = 1.630e-4    #from R model
simple_β = 2.845e-05   #from R model
simple_v₀= 7.242      #from R model

srand()     
temp = [0.; rand(100)]*7  #start with 0 because above b == v0

#run Julia version of SIMPLE
simple_model = Model()

setindex(simple_model, :time, length(temp))

addcomponent(simple_model, simple)

setparameter(simple_model, :simple, :timestep, timestep)
setparameter(simple_model, :simple, :simple_c, simple_c)
setparameter(simple_model, :simple, :simple_b, simple_b)
setparameter(simple_model, :simple, :simple_α, simple_α)
setparameter(simple_model, :simple, :simple_β, simple_β)
setparameter(simple_model, :simple, :simple_v₀, simple_v₀)
setparameter(simple_model, :simple, :temp, temp)

run(simple_model)
resultsjulia = simple_model[:simple, :slr]

#run R version of SIMPLE
r_filename = joinpath(@__DIR__, "test", "original-BRICK", "R", "simple.R")

R"""
filename <- $(r_filename)
source(filename)
resultsRdict <- simple(Tg = $temp)
"""
@rget resultsRdict
resultsRarray = get(resultsRdict, Symbol("sle.gis"), 0)

#compare results
@test resultsRarray ≈ resultsjulia atol=0.0

end

