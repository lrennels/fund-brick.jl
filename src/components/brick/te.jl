# Thermal Expansion (TE)
# Computes sea level rise from thermal expansion (TE) as part of BRICK 
# component framework (Wong et al, 2017). 

using Mimi

@defcomp te begin

    te_a = Parameter()                     # Sensitivity of equilibrium slr from TE (m/degC) 
    te_b = Parameter()                     # Equilibrium slr from te with no temp anomaly (m) 
    te_τ = Parameter()                     # e-folding timescale at which current sea level adjusts to equilibrium (yr) 
    te_s₀ = Parameter()                    # Initial sea level rise designated in 1850 (m)
        
    temp = Parameter(index = [time])    # Global mean surface temperature relative to 1850-1870 mean (degC)
    
    slreq = Variable()                  # Equilibrium sea level rise from TE (m)
    slr = Variable(index=[time])        # Sea level rise due to TE (m)
        
end

function run_timestep(s::te, t::Int)
    p = s.Parameters
    v = s.Variables

    
    # Explicit forward Euler to discretize
    if t==1
        v.slr[t] = p.te_s₀
    else
        v.slreq = p.te_a * p.temp[t-1] + p.te_b
        v.slr[t] = v.slr[t-1] + (1/p.te_τ)*(v.slreq - v.slr[t-1])
    end 

 end
 