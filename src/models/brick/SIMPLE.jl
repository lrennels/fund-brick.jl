# -----------------------------------------------------------------------------
# Lisa Rennels
# September 10, 2017
# SIMPLE Component (Simple Ice-sheet Model for Projecting Large Ensembles)
# BRICKv0.2 from Wong et al. (2017) (equations reference this paper)
# -----------------------------------------------------------------------------
# General Description:
#
# BRICK uses the mechanistically motivated, zero-dimensional
# SIMPLE (Simple Ice-sheet Model for Projecting Large Ensembles) model as the 
# parameterization for  the Greenland Ice Sheet (GIS) contribution to global mean
# sea-level change (Bakker et al., 2016). (Wong et al. 2017)
# -----------------------------------------------------------------------------

using Mimi

@defcomp simple begin

    #parameters
    timestep = Parameter() # timestep (year)
    simple_c = Parameter()     # sensitivity of the equilibrium volume to changes 
                        # in temperature (mSLEC/degC)
    simple_b = Parameter()     # equilibrium volume veq for 0 temperature anomaly (mSLE)
    simple_α = Parameter()     # sensitivity to temperature of the timescale of GIS 
                        # volume response to changes in temperature (1/C*m)
    simple_β = Parameter()     # equilibrium (temp D = 0 deg C) timescale of GIS volume 
                        # response to changes in temperature (1/yr)
    simple_v₀ = Parameter()    # initial total volume of GIS (mSLE)   
    temp = Parameter(index=[time])  # Global mean surface temp relative to the
                                    # 1961-1990 mean (degC) (received from doeclim 
                                    # component)

    #variables
    veq = Variable(index=[time])    #equilibrium ice sheet volume at which the 
                                    #sea-level contribution from the GIS is 0 (mle)
    τinv = Variable(index=[time])   #e-folding timescale of GIS volume changes due 
                                    #to changes in global temperature (1/yr)
    v = Variable(index=[time])      #volume of GIS (mSLE)
    slr = Variable(index=[time])    #cumulative sea level rise over time period (m)

end

function run_timestep(state::simple, t::Int)
    
    v = state.Variables
    p = state.Parameters
    
    #define an equation for veq (Wong et al. (2007) equation 3)
    v.veq[t] = p.simple_c * p.temp[t] + p.simple_b

    #define an equation for τinv (Wong et al. (2007) equation 4)
    v.τinv[t] = p.simple_α * p.temp[t] + p.simple_β

    #define an equation for v (Wong et al. (2007) equation 5)
    #use standard explicit forward Euler for discretization 
    if t == 1
        v.v[t] = p.simple_v₀
    else
        v.v[t] = v.v[t-1] + p.timestep * ( v.τinv[t-1] * ( v.veq[t-1] - v.v[t-1] ) )            
    end


    #define an equation for slr 
    v.slr = p.simple_v₀- v.v

end
    