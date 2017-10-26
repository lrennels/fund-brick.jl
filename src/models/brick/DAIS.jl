# -----------------------------------------------------------------------------
# Lisa Rennels
# September 26, 2017
# DAIS Component (The DCESS (Danish Center for Earth System Science)
# Antarctic Ice Sheet (DAIS) model)
# for BRICKv0.2 from Wong et al. (2017) 
# from Shaffer (2014) (equations reference this paper)
# -----------------------------------------------------------------------------

using Mimi

@defcomp dais begin

# -----------------------------------------------------------------------------
# Model Parameters
# -----------------------------------------------------------------------------

    # TODO_1:  For Table 1 in Shaffer (2014), there is a note that "Present day 
    #          refers to the mean for the period AD1961–1990.  It will be important 
    #          to keep this reference period in mind when picking values.

    # A.  Model Constants and Parameters (Shaffer (2014) Table 1)

    dais_Tf          = Parameter()       # Freezing temperature of seawater (deg C)
    dais_ρ_ice       = Parameter()       # Ice density (kg/m^3)
    dais_ρ_seawater  = Parameter()       # seawater density (kg/m^3)
    dais_ρ_rock      = Parameter()       # rock density (kg/m^3)
    dais_SL₀         = Parameter()       # initial condition - Present-day sea level (m) 
    dais_temp_ocean₀ = Parameter()       # initial condition - Present-day, high-latitude ocean subsurface temperaturea (deg C)
    dais_radius₀     = Parameter()       # initial condition - Reference ice sheet radius (m)

    # B.  Model Parameters (Shaffer (2014) Table 1)

    dais_bedheight₀  = Parameter()       # Undisturbed bed height at the continent center (m)
    dais_slope       = Parameter()       # Slope of the undisturbed bed 
    dais_μ           = Parameter()       # Profile parameter for parabolic ice sheet surface (m^0.5)
    dais_runoffline_snowheight₀ = Parameter() #Runoff line height for mean Antarctic temperature reduced to sea level (temp_SLprev) equal to 0 deg C (m)
    dais_c           = Parameter()       # Proportionality constant for the dependency of runoff  line height on temp_SLprev (m/deg C)
    dais_precip₀     = Parameter()       # Annual precipitation for temp_SLprev equal to 0 deg C (m ice)
    dais_κ           = Parameter()       # Coefficient for the exponential dependency of precipitation on temp_SLprev (1/deg C)
    dais_ν           = Parameter()       # Proportionality constant relating the runoff decrease  with height to precipitation (1/m^0.5yr^0.5)
    dais_flow₀       = Parameter()       # Proportionality constant for ice flow at the grounding line (m/yr)
    dais_γ           = Parameter()       # Power for the relation of ice flow speed to water depth 
    dais_α           = Parameter()       # Partition parameter for effect of ocean subsurface temperature on ice flux

    # C.  Other Model Parameters
    timestep    = Parameter()       # time step
    # TODO_2:  Look at Tony Wong's Github comment do understand how this coefficient
    #          should be calculated.
    dais_tempsensitivity = Parameter()   # linear regression coefficient converting 
                                    # global mean surface temperature to Antarctic mean surface temperature
    dais_lf     = Parameter()       # Mean AIS fingerprint at AIS shore
                                    
    # D.  Model Parameters from Other Componenents
 
    # from DOECLIM component:
    # TODO_3:  Here I am assuming that this temp should be the same as that taken by anto,
    #          and thus in relation to the 1850-1870 mean, but this is not consistent with the 
    #          Table 1 instructions on time periods in TODO_1. 
    temp        = Parameter(index=[time])   # Global mean surface temp ANOMALY relative to the 1850-1870 mean (deg C) 
    
    # from ANTO component:
    anto_temp_ocean  = Parameter(index=[time])   # high-latitude ocean subsurface temperaturea (deg C)  
    
    # from all 4 SLR contribution components (GIC_MAGICC, SIMPLE, TE, and DAIS):    
    slr_gic     = Parameter(index=[time])   #sea-level rise from gic (m/yr)
    slr_gis     = Parameter(index=[time])   #sea-level rise from gis (m/yr)
    slr_te      = Parameter(index=[time])   #sea-level rise from te (m/yr)
    SL          = Parameter(index=[time])   # sea level (m)       
    
# -----------------------------------------------------------------------------
# Model Variables
# -----------------------------------------------------------------------------
    deltaslr    = Variable(index=[time])        # rate of sea-level change from gic, gis, and te components (m/yr)    
    temp_SLprev = Variable(index=[time])        # Antarctic mean surface temperature ANOMALY for the previous year
    runoffline_snowheight = Variable(index=[time])  # Height of runoff line above which precipitation accumulates as snow (m)                                                                                    
    precip      = Variable(index=[time])        # Annual precipitation (m ice)
    β           = Variable(index=[time])        # mass balance gradient  (m^0.5)
    dist_center2runoffline = Variable(index=[time]) #Distance from the continent center to where the runoff line intersects the ice sheet surface (m)
    dist_center2sea = Variable(index=[time])    # the distance from the continent center to where the ice sheet enters the sea (m)
    radius      = Variable(index=[time])        # ice sheet radius (m)    
    waterdepth  = Variable(index=[time])        # water depth at grounding line
    flux        = Variable(index=[time])        # Total ice flux across the grounding line (m3/yr)        
    volume_ais  = Variable(index=[time])        # volume of antarctic ice sheet (m^3)
    βtotal      = Variable(index=[time])        # total rate of accumulation of mass on the Antarctic Ice Sheet (m^3/yr)
    slr         = Variable(index=[time])        # the volume of the antarctic ice sheet in SLE equivilent (m)
    
end

function run_timestep(state::dais, t::Int)
    
    v = state.Variables
    p = state.Parameters

    # DEFINE deltaslr
    contribution_thisyear = p.slr_gic[t] + p.slr_gis[t] + p.slr_te[t];
    if t == 1
        v.deltaslr[t] = contribution_thisyear
    else
        contribution_lastyear = p.slr_gic[t-1] + p.slr_gis[t-1] + p.slr_te[t-1];
        v.deltaslr[t]   = contribution_thisyear - contribution_lastyear
    end

    # DEFINE dist_center2sea (equation 1 as discussed after equation 3)
    # TODO_4: In dais.R [line 121] the code sets the initial value using SL[1]
    #         instead of SL₀ ... but in Shaffer (2014) they use a SL₀ constant.
    if t == 1
        v.dist_center2sea[t] = (p.dais_bedheight₀ - p.dais_SL₀)/p.dais_slope
    else
        v.dist_center2sea[t] = (p.dais_bedheight₀ - p.SL[t-1])/p.dais_slope
    end

    # --------------------------------------------------------------------------
    # Case where NOT in first timestep
    #
    # If t == 1, radius and volume have initial values and the variables in the 
    # if/then loop below do not need to be calculated.  These will be NaN for 
    # t == 1.
    # --------------------------------------------------------------------------

    if t > 1

        # DEFINE equation for temp_SLprev (anto section of BRICKv0.2)
        # Here we define temp_SLprev based on last year's temp, as indicated in
        # Wong et al. (2017). The R code handles this as an 
        # intermediate step between anto and dais in daisanto.R [line 120].  
        # Thus, the following  variables that are calculated based on 
        # temp_SLprev are also descriptors of the ice sheet in the PREVIOUS year. 

        v.temp_SLprev[t] = p.temp[t-1] * p.dais_tempsensitivity 

        # DEFINE equation for precip (equation 6)
        v.precip[t] = p.dais_precip₀ * exp(p.dais_κ * v.temp_SLprev[t])

        # DEFINE equation for β (equation 7)
        # dais.R multiplies nu in this equation and notes "corrected
        # "with respect to text", so this does not perfectly match Shaffer (2014).
        v.β[t] = p.dais_ν * v.precip[t]^(0.5)
    
        # DEFINE equation for runoffline_snowheight (equation 5)
        v.runoffline_snowheight[t] = p.dais_runoffline_snowheight₀ + p.dais_c * v.temp_SLprev[t]
    
        # DEFINE and equation for dist_center2runoffline (equation 8)
        # this will only be used if the Height of runoff line above which 
        # precipitation accumulates as snow is greater than 0 
        v.dist_center2runoffline[t] = (v.radius[t-1] - ((v.runoffline_snowheight[t] - 
            p.dais_bedheight₀ + p.dais_slope * v.radius[t-1])^2) / p.dais_μ)  

        # DEFINE an equation for βtotal (equation 8)
        term1 = v.precip[t] * π * (v.radius[t-1]^2)
        term2 = (π * v.β[t] * (v.runoffline_snowheight[t] - p.dais_bedheight₀ + p.dais_slope * v.radius[t-1]) *
        (v.radius[t-1]^2 - v.dist_center2runoffline[t]^2) ) 
        
        term3 = (4 * π * v.β[t] * p.dais_μ^0.5 * (v.radius[t-1] - v.dist_center2runoffline[t]) ^(5/2) ) / 5
        term4 = (4 * π * v.β[t] * p.dais_μ^0.5 * v.radius[t-1] * (v.radius[t-1] - v.dist_center2runoffline[t]) ^(3/2) ) / 3
        
        if v.runoffline_snowheight[t] > 0 #warm enough fo runoff to occur 
            v.βtotal[t] =  term1 - term2 - term3 + term4
        else
            v.βtotal[t] = term1
        end

        # ----------------------------------------------------------------------
        # Marine Ice Sheet Case
        # ----------------------------------------------------------------------

        # DEFINE an equation for water depth
        # DEFINE an equation for flux
        # use intermediate parameters fac, speed, and ISO

        #dV/dR (equation 14)
        fac_term1 = (π * (1 + p.dais_ρ_ice/(p.dais_ρ_rock - p.dais_ρ_ice)) * ( 4/3 * p.dais_μ^0.5 * v.radius[t-1]^1.5 - 
        p.dais_slope * v.radius[t-1]^2))

        fac_term2 = (2 * π * (p.dais_ρ_seawater/(p.dais_ρ_rock - p.dais_ρ_ice)) * (p.dais_slope * v.radius[t-1]^2 -
        p.dais_bedheight₀ * v.radius[t-1]))

        #cases to adjust in case there is a marine ice sheet / grounding line
        if (v.radius[t-1] > v.dist_center2sea[t]) #marine ice sheet /grounding line
            
            #use correction term for dV/dR 
            fac = fac_term1 - fac_term2
    
            #water depth (equation 10)
            v.waterdepth[t] = p.dais_slope * v.radius[t-1] - p.dais_bedheight₀ + p.SL[t-1]     

            #Ice speed at grounding line (eq 11)
            speed = (p.dais_flow₀ *
            ((1 - p.dais_α) + p.dais_α * ((p.anto_temp_ocean[t-1] - p.dais_Tf)/(p.dais_temp_ocean₀ - p.dais_Tf))^2) *
            (v.waterdepth[t]^p.dais_γ) / ( (p.dais_slope * p.dais_radius₀ - p.dais_bedheight₀) ^(p.dais_γ - 1) ) ) 

            #ice flux (equation 9)
            v.flux[t] = ( -(2 * π * v.radius[t-1] * (p.dais_ρ_seawater/p.dais_ρ_ice) *
                v.waterdepth[t]) * speed )

            #third term equation 14
            # c_iso is ratio ItSO / deltaslr (all components)
                            
            c_iso = (2 * π * (p.dais_ρ_seawater/(p.dais_ρ_rock - p.dais_ρ_ice)) * (p.dais_slope * 
            v.dist_center2sea[t]^2 - (p.dais_bedheight₀ / p.dais_slope) * v.dist_center2sea[t]))
            
            ISO = c_iso * v.deltaslr[t]

        else #no marine ice sheet / grounding line
            fac = fac_term1         #ratio dV/dR
            v.waterdepth[t] = NaN   #unused in this case        
            v.flux[t] = 0           #no ice flux
            ISO = 0                 #third term equation 14  
        end
    end

# -----------------------------------------------------------------------------
# Output Variables 
# -----------------------------------------------------------------------------

    # DEFINE equation for radius (equation 13)
    if t == 1
        v.radius[t] = p.dais_radius₀
    else
        v.radius[t] = v.radius[t-1] + p.timestep*(v.βtotal[t] + v.flux[t] + ISO)/fac
    end

    # DEFINE equation for volume_ais  (equation 13)
    if t == 1

        term1 = (π * (1 + (p.dais_ρ_ice/(p.dais_ρ_rock - p.dais_ρ_ice))) * ( (8/15) * p.dais_μ^0.5 * 
        p.dais_radius₀^2.5 - (1/3) * p.dais_slope * p.dais_radius₀^3))
       
        term2 = (π * (p.dais_ρ_seawater/(p.dais_ρ_rock - p.dais_ρ_ice)) * ( (2/3) * p.dais_slope *
        (p.dais_radius₀^3 - v.dist_center2sea[t]^3) - p.dais_bedheight₀ *
        (p.dais_radius₀^2 - v.dist_center2sea[t]^2) ) )

        if p.dais_radius₀ > v.dist_center2sea[t] #marine ice sheet
            v.volume_ais[t] = term1 - term2
        else
            v.volume_ais[t] = term1
        end
        
    else
        v.volume_ais[t] = v.volume_ais[t-1] + p.timestep*(v.βtotal[t] + v.flux[t] + ISO)
    end
    
    #DEFINE an equation for slr
    #Takes steady state present day volume to correspond to 57m SLE
    v.slr[t] = 57. * (1 - v.volume_ais[t]/v.volume_ais[1]) 

end
