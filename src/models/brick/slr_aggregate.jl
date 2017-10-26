# -----------------------------------------------------------------------------
# Lisa Rennels
# October 5, 2017
# Component to add together sea level rise from four components:
#   1.  glaciers and small ice caps (GIC) - gic_magicc compenent
#   2.  Greenland Ice Sheet (GIS) - SIMPLE component
#   3.  Thermal Expansion (TE) - te component
#   4.  Antarctic Ice Sheet (AIS) - DAIS component 
# -----------------------------------------------------------------------------

using Mimi

@defcomp slr_aggregate begin

    slr_gic = Parameter(index=[time])  # sea level rise contribution from GIC (m)
    slr_gis = Parameter(index=[time])   # sea level rise contribution from GIS (m)
    slr_ais = Parameter(index=[time])   # sea level rise contribution from AIS (m)
    slr_te  = Parameter(index=[time])    # sea level rise contribution from TE (m)

    slr_aggregate = Variable(index=[time])  # total sea level rise from all components
    deltaslr = Variable(index=[time])       # change in total sea level rise
end

function run_timestep(state::slr_aggregate, t::Int)
    
    v = state.Variables
    p = state.Parameters
    
    if t == 1
        v.slr_aggregate[t] = 0
    else
        v.slr_aggregate[t] = p.slr_gic[t] + p.slr_gis[t] + p.slr_ais[t] + p.slr_te[t]
    end
    
end




        