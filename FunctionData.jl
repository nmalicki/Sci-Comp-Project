module FunctionData

export Point2D, XYData, linearRegression, list_diff, list_dif_multi, list_append, get_season_driver_nums, dropmissing, createRegGraph, gradientDescentBB, bestFitLine, createGradDescGraph, createDualGraph

using Statistics

include("Rootfinding.jl")
using ForwardDiff, .Rootfinding, LinearAlgebra, LsqFit

import Base

using CairoMakie
CairoMakie.activate!()
Makie.inline!(true)


struct Point2D
    x::Real
    y::Real
end
struct XYData
    data::Vector{Point2D}

    function XYData(data::Vector{Point2D})
        new(data)
    end
    function XYData(x::Vector{T} , y::Vector{S}) where {T <: Real, S <: Real}
        if length(x) == length(y)
            data = map((x, y) -> Point2D(x,y), x, y)
        end
        XYData(data)
    end
    function XYData(data::Vector{Tuple{T}}) where T <: Real
        data = map(d -> Point2D(d[1], d[2]), data)
        XYData(data)
    end
end

function Base.show(io::IO, d::XYData)
    output = "{"
    for i in 1:length(d.data) - 1
        output *= string("(", d.data[i].x, " ,", d.data[i].y, "), ")
    end
    output *= string("(", d.data[end].x, " ,", d.data[end].y, ")}")
    print(output)
end

function list_diff(a, b)
    sort!(a)
    sort!(b)
    for i in eachindex(a)
        if (a[i] != b[i])
            return a[i]
        end
    end
end

function list_diff_multi(main_list, new)
    result = []
    for i in eachindex(new)
        if (new[i] in main_list) == false
            push!(result, new[i])
        end
    end
    return result
end

function list_append(main_list, to_add)
    result = main_list
    for i in eachindex(to_add)
        result = push!(main_list, to_add[i])
    end
    return result
end

function get_season_driver_nums(data)
    all_driver_nums = []
    sort!(map(d->d["driver_number"], data[1][2]))
    for i in 2:length(data)
        new_nums = []
        if data[i][2][20] != nothing
            new_nums = list_diff_multi(all_driver_nums, map(d->d["driver_number"], data[i][2]))
        else
            new_nums = list_diff_multi(all_driver_nums, map(d->d["driver_number"], data[i][2][1:end-1]))
        end
        if length(new_nums) != 0
            all_driver_nums = list_append(all_driver_nums, new_nums)
        end
    end
    return sort!(all_driver_nums)
end
function dropmissing(a::Vector{Any})
    result = Int64[]
    for i in 1:length(a)
        if (typeof(a[i]) != Missing)
            push!(result, a[i])
        end
    end
    return result
end

function dropmissing(a::Vector, b::Vector)
    a_result = Int64[]
    b_result = Int64[]
    for i in 1:length(a)
        if (typeof(b[i]) != Missing)
            push!(a_result, a[i])
            push!(b_result, b[i])
        end
    end
    return XYData(a_result, b_result)
end


function linearRegression(d::XYData)
    x = map(d->d.x, d.data)
    y = map(d->d.y, d.data)
    n = length(d.data)
    a = (n * sum(x.*y) - (sum(x) * sum(y)) )/((n * mapreduce(x->x^2, +, x)) - sum(x))
    b = (1/n) * (sum(y) - (a * sum(x)))
    return a,b
end

function createRegGraph(df, standings_num, driver_name="")
    standings_num = standings_num
    driver = Array(df[standings_num, :][2:end])
    cleaned = dropmissing(collect(1:length(driver)), driver)
    x_cleaned = map(d->d.x, cleaned.data)
    y_cleaned = map(d->d.y, cleaned.data)
    if driver_name != ""
        driver_name = string(": ", driver_name)
    end
    
    formatted = FunctionData.XYData(x_cleaned, y_cleaned)
    a, b = linearRegression(formatted)
    f(x) = a .*x .+ b
    
    fig = Figure()
    ax = Axis(fig[1,1], aspect = 1, limits = (0, 30, 0, 21), title=string("Driver #", df[standings_num, :][1], driver_name), xlabel="Race Number", ylabel="Finishing Position")
    scatter!(x_cleaned, y_cleaned, label = "Race Results")
    lines!(x_cleaned, f, label = "Linear Regression", color="red")
    Legend(fig[1,2], ax)
    fig
end

function gradientDescentBB(f::Function,x₀::Vector; max_steps = 100)
    local steps = 0
    local ∇f₀ = ForwardDiff.gradient(f,x₀)
    local x₁ = x₀ - 0.25 * ∇f₀
    while LinearAlgebra.norm(∇f₀) > 1e-4 && steps < max_steps
      ∇f₁ = ForwardDiff.gradient(f,x₁)
      Δ∇f = ∇f₁-∇f₀
      x₂ = x₁ - abs(dot(x₁-x₀,Δ∇f))/LinearAlgebra.norm(Δ∇f)^2*∇f₁
      x₀ = x₁
      x₁ = x₂
      ∇f₀ = ∇f₁
      steps += 1
    end
    steps < max_steps || throw(ErrorException("The number of steps has exceeded $max_steps"))
    x₁
  end
function bestFitLine(d::XYData)
    a, b = linearRegression(d)
    @show a, b
    f(x::Vector) = @. (a * x) + b
    #f(x::Vector) = @. sin(0.5x[1]^2-0.25x[2]^2+2)*cos(x[1]+x[2])
    @show gradientDescentBB(f, [0.1, 0.1])
end

"""
function createGradDescGraph(df, standings_num, driver_name="")
    standings_num = standings_num
    driver = Array(df[standings_num, :][2:end])
    cleaned_driver = dropmissing(driver)
    if driver_name != ""
        driver_name = string(": ", driver_name)
    end
    
    formatted = FunctionData.XYData(collect(1:length(cleaned_driver)), cleaned_driver)
    a, b = linearRegression(formatted)
    f(x) = a*x + b
    
    fig = Figure()
    ax = Axis(fig[1,1], aspect = 1, limits = (0, 30, 0, 21), title=string("Driver #", df[standings_num, :][1], driver_name), xlabel="Race Number", ylabel="Finishing Position")
    scatter!(1:length(driver), driver, label = "Race Results")
    lines!(1:length(driver), f, label = "Linear Regression", color="red")
    Legend(fig[1,2], ax)
    fig
end
"""

function createLsqGraph(df, standings_num, driver_name = "")
    driver = Array(df[standings_num, :][2:end])
    cleaned = dropmissing(collect(1:length(driver)), driver)
    x_cleaned = map(d->d.x, cleaned.data)
    y_cleaned = map(d->d.y, cleaned.data)
    #make it so drop missing retains the x data
    model(x, p) = @. p[1] + p[2]*x
    fit = curve_fit(model, x_cleaned, y_cleaned, [1e-8,1e-8])
    @show b, m = fit.param

    fig = Figure()
    f(x) = m .* x .+ b
    ax = Axis(fig[1,1], aspect = 1, limits = (0, 30, 0, 21), title=string("Driver #", df[standings_num, :][1], driver_name), xlabel="Race Number", ylabel="Finishing Position")
    scatter!(ax, x_cleaned , y_cleaned, label=string("Driver #", df[standings_num, :][1], driver_name))
    lines!(ax, 0:30, f, label="Lsq", color="red")
    Legend(fig[1,2], ax)

    fig
end

function createDualGraph(df, standings_num, driver_name = "")
    standings_num = standings_num
    driver = Array(df[standings_num, :][2:end])
    cleaned = dropmissing(collect(1:length(driver)), driver)
    x_cleaned = map(d->d.x, cleaned.data)
    y_cleaned = map(d->d.y, cleaned.data)
    if driver_name != ""
        driver_name = string(": ", driver_name)
    end
    
    a, b = linearRegression(cleaned)
    f(x) = a .*x .+ b

    fig = Figure()
    ax = Axis(fig[1,1], aspect = 1, limits = (0, 30, 0, 21), title=string("Driver #", df[standings_num, :][1], driver_name), xlabel="Race Number", ylabel="Finishing Position")
    scatter!(ax, x_cleaned, y_cleaned, label = "Race Results")
    lines!(ax, x_cleaned, f, label = "Linear Regression", color="red")

    model(x, p) = @. p[1] + p[2]*x
    fit = curve_fit(model, x_cleaned, y_cleaned, [1e-8,1e-8])
    b, m = fit.param
    g(x) = m .* x .+ b
    
    
    
    lines!(ax, 0:30, g, label="Lsq", color="green")
    Legend(fig[1,2], ax)
    fig
end
end