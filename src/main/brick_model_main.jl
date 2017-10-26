# -----------------------------------------------------------------------------
# Lisa Rennels
# October 5, 2017
# script to run the SLR model
# -----------------------------------------------------------------------------

using Mimi

cd("/Users/lisarennels/Documents/UC Berkeley ERG/Mimi/Offline")

# set exogenous forcing
#msrand(123)
#temp = rand(100)    # Global mean surface temp relative to 1850-1870 (degC)
temp = Array{Float64}(100)
for i = 1:length(temp)
    if i == 1
        temp[i] = 0
    else
        temp[i] = temp[i-1] + 0.05
    end
end

timestep = 1.       # size of timestep (yr)

include("slr_model_constructmodel.jl")

run1 = run_model();

#check resultsS
writetable("slr_aggregate.csv", getdataframe(run1, :slr_aggregate, :slr_aggregate))
writetable("slr_slr_gic.csv", getdataframe(run1, :gic_magicc, :slr))
writetable("slr_slr_te.csv", getdataframe(run1, :te, :slr))
writetable("slr_slr_ais.csv", getdataframe(run1, :dais, :slr))
writetable("slr_slr_gis.csv", getdataframe(run1, :simple, :slr))
writetable("slr_deltaslr.csv", getdataframe(run1, :dais, :deltaslr))



