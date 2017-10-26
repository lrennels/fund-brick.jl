# Test script for TE module
# Compared against corresponding R-BRICK module

using Mimi
using RCall
using Base.Test

include("../src/te.jl")

# Error tolerance
err = 0.0

# Generate random sequence of temperature values
srand(123)
temp = rand(20)

# Test TE component
m = Model()
setindex(m, :time, length(temp))

addcomponent(m, te)

setparameter(m, :te, :te_a, 0.5)
setparameter(m, :te, :te_b, 0.0)
setparameter(m, :te, :te_τ, (1./0.005))    
setparameter(m, :te, :te_s₀, 0.0)
setparameter(m, :te, :temp, temp)

run(m)

mimiresults= m[:te, :slr]

@testset "TE component" begin

r_filename = joinpath(@__DIR__, "original-BRICK", "R", "brick_te.R")

R"""
source($(r_filename))

te_result <- brick_te(Tg=$(temp))
"""

@rget te_result

@test te_result ≈ mimiresults atol = err

end
