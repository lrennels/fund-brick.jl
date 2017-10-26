# Test script for GSIC module
# Compared against corresponding R-BRICK module 

using Mimi
using RCall
using Base.Test

include("../src/gic_magicc.jl")

# Uncertainty parameter
err = 0.0     # Assuming 0 error for now since using same params

# Generate random sequence of temperature values
srand(123)
tmp = rand(20)

# Test model component    
m = Model()
setindex(m, :time, length(temp))
addcomponent(m, gic_magicc)
    
setparameter(m, :gic_magicc, :timestep, 1.)
setparameter(m, :gic_magicc, :gic_β₀, 0.000577)
setparameter(m, :gic_magicc, :gic_v₀, 0.4)
setparameter(m, :gic_magicc, :gic_s₀, 0.0)
setparameter(m, :gic_magicc, :gic_n, 0.82)
setparameter(m, :gic_magicc, :gic_teq, -0.15)
setparameter(m, :gic_magicc, :temp, temp)
    
run(m)
    
mimiresults = m[:gic_magicc, :slr]

@testset "GIC-MAGICC component" begin

r_filename = joinpath(@__DIR__, "original-BRICK", "R", "GSIC_magicc.R")

R"""
source($(r_filename))

gsic_result <- gsic_magicc(Tg=$(temp))
"""

@rget gsic_result

@test gsic_result ≈ mimiresults atol = err 

end