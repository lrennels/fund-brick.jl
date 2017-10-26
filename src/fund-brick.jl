# -----------------------------------------------------------------------------
# Lisa Rennels
# October 5, 2017
# function to to construct the SLR model
# -----------------------------------------------------------------------------

using Mimi
using DataFrames

#include fund
include("fund.jl")

#include brick components and parameters
include(joinpath(dirname(@__FILE__), "components/brick/gic_magicc.jl"))
include(joinpath(dirname(@__FILE__), "components/brick/SIMPLE.jl"))
include(joinpath(dirname(@__FILE__), "components/brick/te.jl"))
include(joinpath(dirname(@__FILE__), "components/brick/ANTO.jl"))
include(joinpath(dirname(@__FILE__), "components/brick/DAIS.jl"))
include(joinpath(dirname(@__FILE__), "components/brick/slr_aggregate.jl"))

function construct_fund-brick()

    # ---------------------------------------------
    # Load original fund and modify with brick components
    # ---------------------------------------------   
    #construct fund
    model = getfund()
    setindex(model, :time, length(temp))

    #delete fund sea level rise component
    delete!(model, :impactsealevelrise)

    # Add fund-brick specific components.
    addcomponent(model, gic_magicc, after=:impactwaterresources)
    addcomponent(model, simple, after=:gic_magicc)
    addcomponent(model, te, after=:simple)
    addcomponent(model, anto, after=:te)
    addcomponent(model, dais, after=:anto)
    addcomponent(model, slr_aggregate, after=:dais)

    # ---------------------------------------------
    # Set all fund-brick model parameters
    # ---------------------------------------------   

    include(joinpath(dirname(@__FILE__), "brick_parameters.jl")
    
    # Set parameters for gic_magicc
    setparameter(model, :gic_magicc, :timestep, timestep)
    connectparameter(m, :gic_magicc, :temp, :climatedynamics, :temp)
    
    setparameter(model, :gic_magicc, :gic_β₀, gic_β₀)
    setparameter(model, :gic_magicc, :gic_v₀, gic_v₀)
    setparameter(model, :gic_magicc, :gic_s₀, gic_s₀)
    setparameter(model, :gic_magicc, :gic_n, gic_n)
    setparameter(model, :gic_magicc, :gic_teq, gic_teq)
    
    
    # Set parameters for simple    
    setparameter(model, :simple, :timestep, timestep)
    connectparameter(m, :simple, :temp, :climatedynamics, :temp)
    
    setparameter(model, :simple, :simple_c, simple_c)
    setparameter(model, :simple, :simple_b, simple_b)
    setparameter(model, :simple, :simple_α, simple_α)
    setparameter(model, :simple, :simple_β, simple_β)
    setparameter(model, :simple, :simple_v₀, simple_v₀)
    
    # Set parameters for te
    connectparameter(m, :te, :temp, :climatedynamics, :temp)
    
    setparameter(model, :te, :te_a, te_a)
    setparameter(model, :te, :te_b, te_b)
    setparameter(model, :te, :te_τ, te_τ)
    setparameter(model, :te, :te_s₀, te_s₀)

    # Set parameters for anto  
    connectparameter(m, :anto, :temp, :climatedynamics, :temp)
    
    setparameter(model, :anto, :anto_α, anto_α)
    setparameter(model, :anto, :anto_β, anto_β)
    setparameter(model, :anto, :anto_Tf, anto_Tf)
    
    # Set parameters for dais    
    setparameter(model, :dais, :timestep, timestep)
    
    connectparameter(model, :dais, :anto_temp_ocean, :anto, :anto_temp_ocean)
    connectparameter(model, :dais, :SL, :slr_aggregate, :slr_aggregate)
    connectparameter(model, :dais, :slr_gic, :gic_magicc, :slr)
    connectparameter(model, :dais, :slr_gis, :simple, :slr)
    connectparameter(model, :dais, :slr_te, :te, :slr)
    connectparameter(m, :dais, :temp, :climatedynamics, :temp)
    
    setparameter(model, :dais, :dais_Tf, dais_Tf)
    setparameter(model, :dais, :dais_ρ_ice, dais_ρ_ice)
    setparameter(model, :dais, :dais_ρ_seawater, dais_ρ_seawater)
    setparameter(model, :dais, :dais_ρ_rock, dais_ρ_rock)
    setparameter(model, :dais, :dais_SL₀, dais_SL₀)
    setparameter(model, :dais, :dais_temp_ocean₀, dais_temp_ocean₀)
    setparameter(model, :dais, :dais_radius₀, dais_radius₀)
    
    setparameter(model, :dais, :dais_bedheight₀, dais_bedheight₀)
    setparameter(model, :dais, :dais_slope, dais_slope)
    setparameter(model, :dais, :dais_μ, dais_μ)
    setparameter(model, :dais, :dais_runoffline_snowheight₀, dais_runoffline_snowheight₀)
    setparameter(model, :dais, :dais_c, dais_c)
    setparameter(model, :dais, :dais_precip₀, dais_precip₀)
    setparameter(model, :dais, :dais_κ, dais_κ)
    setparameter(model, :dais, :dais_ν, dais_ν)
    setparameter(model, :dais, :dais_flow₀, dais_flow₀)
    setparameter(model, :dais, :dais_γ, dais_γ)
    setparameter(model, :dais, :dais_α, dais_α)
    
    setparameter(model, :dais, :dais_tempsensitivity, dais_tempsensitivity)
    setparameter(model, :dais, :dais_lf, dais_lf)

    # Set parameters for SLR_aggregate
    connectparameter(model, :slr_aggregate, :slr_gic, :gic_magicc, :slr)
    connectparameter(model, :slr_aggregate, :slr_gis, :simple, :slr)
    connectparameter(model, :slr_aggregate, :slr_te, :te, :slr)
    connectparameter(model, :slr_aggregate, :slr_ais, :dais, :slr)

    # ---------------------------------------------
    # Return new model
    # ---------------------------------------------   

    return(model)
  
end
