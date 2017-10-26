# GSIC-MAGICC
# Computes sea level rise (slr) from glaciers and small ice caps (GSIC) using the formulation
# used in MAGICC (Meinshausen et al, 2011). Adapted for the BRICK model by Wong et al (2017). 

using Mimi

@defcomp gic_magicc begin

    timestep = Parameter()            # size of timestep (yr)
    gic_β₀ = Parameter()                # Initial mass-balance sensitivity to global temperatures (m/degC/yr)
    gic_v₀ = Parameter()                # Initial total volume of GSIC (m sea-level equivalent (SLE)) 
    gic_s₀ = Parameter()                # Initial cumulative slr (m)
    gic_n = Parameter()                 # Exponential parameter for area to volume scaling (unitless)
    gic_teq = Parameter()               # Theoretical equilibrium temp at which GSIC mass balance 
                                    #   is steady state (degC)
    temp = Parameter(index=[time])    # Global mean surface temp relative to 1850-1870 (degC);
                                    #   received from doeclim component. 

    slr = Variable(index=[time])    # Cumulative slr from glaciers and small ice caps (m)
    
end


function run_timestep(s::gic_magicc, t::Int)

    v = s.Variables
    p = s.Parameters
 
    # Standard explicit forward Euler
    if t==1
        v.slr[t] = p.gic_s₀ 
    else
        v.slr[t] = v.slr[t-1] + p.timestep * p.gic_β₀ * (p.temp[t-1] - p.gic_teq)*(1 - v.slr[t-1]/p.gic_v₀)^p.gic_n
    end   

end
