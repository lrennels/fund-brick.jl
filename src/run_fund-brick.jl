# Load required packages.
using NLopt
using Mimi

#Include helper functions and all model source code.
include(joinpath(dirname(@__FILE__), "components/fund/helper.jl"))
include("fund.jl")

####################################################################################################
# fund-brick PARAMETERS TO CHANGE
####################################################################################################

timestep = 1.       # size of timestep (yr)

####################################################################################################
# run everything 
####################################################################################################

include("fund-brick.jl")
model = construct_fund-brick()
run1 = run(model)

