# -----------------------------------------------------------------------------
# Lisa Rennels
# September 10, 2017
# ANTO Component (ANTarctic Ocean temperature model)
# BRICKv0.2 from Wong et al. (2017) (equations reference this paper)
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

using Mimi

@defcomp anto begin

    anto_α = Parameter()    # sensitivity of the Antarctic Ocean temperature to global 
                            # mean surface temperature
    anto_β = Parameter()    # the approximate Antarctic Ocean temperature for temp = 0 
    anto_Tf = Parameter()   # freezing temperature of seawater (deg C)
    temp = Parameter(index=[time]) # Global mean surface temp relative to the
                                # 1850-1870 mean (degC) (received from doeclim 
                                # component)
    anto_temp_ocean = Variable(index=[time])    #Temperature of ocean surface at Antarctica (degC)

end

function run_timestep(state::anto, t::Int)
    
    v = state.Variables
    p = state.Parameters
    
    #define an T (Wong et al. (2007) equation 6)
    temporary_numerator = p.anto_α * p.temp[t] + p.anto_β - p.anto_Tf
    temporary_denominator = 1 + exp( - (p.anto_α * p.temp[t] + p.anto_β - p.anto_Tf) / p.anto_α)
    v.anto_temp_ocean[t] = p.anto_Tf + (temporary_numerator / temporary_denominator)

end
     
