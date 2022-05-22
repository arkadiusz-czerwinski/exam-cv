function neighbourhood(index::CartesianIndex, radius::Int)

    return CartesianIndices(Tuple(a-radius:a+radius for a in index.I))

end

function neighbourhood(index::CartesianIndex, radius::Int, shape::Tuple{Vararg{Int}})

    return CartesianIndices(Tuple(max(1, a-radius):min(shape_boundary, a+radius) for (a, shape_boundary) in zip(index.I, shape)))

end

function neighbourhood(index::CartesianIndex, radiuses::Tuple{Vararg{Int}}, shape::Tuple{Vararg{Int}})

    if length(radiuses) != length(shape)
        throw(error("Inconsistent shapes"))
    end

    return CartesianIndices(Tuple(max(1, a-radius):min(shape_boundary, a+radius) for (a, shape_boundary, radius) in zip(index.I, shape, radiuses)))

end