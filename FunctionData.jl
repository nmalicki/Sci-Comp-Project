module FunctionData

export Point2D, XYData, linearRegression

import Base


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

function linearRegression(d::XYData)
    x = map(d->d.x, d.data)
    y = map(d->d.y, d.data)
    n = length(d.data)
    a = (n * sum(x.*y) - (sum(x) * sum(y)) )/((n * mapreduce(x->x^2, +, x)) - sum(x))
    b = (1/n) * (sum(y) - (a * sum(x)))
    return a,b
end
end