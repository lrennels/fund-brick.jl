# -----------------------------------------------------------------------------
# Lisa Rennels
# September 10, 2017
# script of tests comparing ANTO component in Julia to that in BRICK
# ANTO Component (ANTarctic Ocean temperature model)
# -----------------------------------------------------------------------------
# General Description:
#
# The Antarctic surface temperature is estimated from a linear regression with 
# global mean surface temperature (Morice et al., 2012; Shaffer, 2014). The 
# Antarctic Ocean temperatures are modeled through a simple relation with the
# global mean surface temperature (relative to the 1850–
# 1870 mean).  The Antarctic surface temperature is bounded below at the 
# freezing point of salt water (1:8 C). (Wong et al. 2017)
# -----------------------------------------------------------------------------
# Input Parameters:
#
#   - Tf    - freezing temperature of seawater (deg C)
#   - α    - sensitivity of the Antarctic Ocean temperature to global  mean 
#             surface temperature
#   - β     - the approximate Antarctic Ocean temperature for temp = 0
#   - temp    - Global mean surface temp relative to the 1850-1870 mean (degC) 
#             (received from doeclim component)
# -----------------------------------------------------------------------------

using Mimi
using RCall
using Base.Test
using DataFrames

include("../src/ANTO.jl")

@testset "ANTO component" begin

#set parameters
anto_α = 0.26    #from R model
anto_β = 0.62    #from R model
anto_Tf = -1.8   #from R model

srand(123)     
temp = rand(101)*7

# run Julia version of ANTO

anto_model = Model()

setindex(anto_model, :time, length(temp))

addcomponent(anto_model, anto)

setparameter(anto_model, :anto, :anto_α, anto_α)
setparameter(anto_model, :anto, :anto_β, anto_β)
setparameter(anto_model, :anto, :anto_Tf, anto_Tf)
setparameter(anto_model, :anto, :temp, temp)

run(anto_model)
resultsjulia =  anto_model[:anto, :temp_ocean]
    

#run R version of ANTO
r_filename = joinpath(@__DIR__, "test", "original-BRICK", "R", "anto.R")

R"""
filename <- $(r_filename)
source(filename)
resultsR <- anto(Tg = $temp)
"""

@rget resultsR

#compare results
@test resultsR ≈ resultsjulia atol=0.0

end

