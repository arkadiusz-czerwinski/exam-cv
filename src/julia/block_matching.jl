include("utils.jl")
using Images
using Plots, FileIO
using StandardizedMatrices


function block_matching_iteration(image_l, image_r, index::CartesianIndex, num_disparity::Int, window_size::Tuple{Vararg{Int}})

    start_ind = max(1 + window_size[2], index[2]-num_disparity +window_size[2])
    end_ind = min(size(image_l)[2] - window_size[2],index[2]+num_disparity-window_size[2])
    ref_block = @view image_l[neighbourhood(index, window_size, size(image_l))]

    metric_val = Inf
    disparity = 0

    for i in start_ind:end_ind

        cur_index = CartesianIndex(index[1], i);
        nbh = neighbourhood(cur_index, window_size, size(image_l));
        comparable = @view image_r[nbh];
        err = ssd(ref_block, comparable);
        if err < metric_val
            metric_val = err
            disparity = abs(index[2] - i)
        end

    end

    return disparity
end

function block_matching_iteration(image_l, image_r, index::CartesianIndex, num_disparity::Int, window_size::Tuple{Vararg{Int}}, boundaries_matrix::Array{Int64, 3})

    start_ind = max(1 + window_size[2], index[2]-num_disparity +window_size[2])
    end_ind = min(size(image_l)[2] - window_size[2],index[2]+num_disparity-window_size[2])
    ref_block = @view image_l[neighbourhood(index, window_size, size(image_l))]

    metric_val = Inf
    min_disparity = boundaries_matrix[index, 1]
    max_disparity = boundaries_matrix[index, 2]
    disparity = Int(floor(mean([min_disparity, max_disparity])))
    for i in start_ind:end_ind

        cur_index = CartesianIndex(index[1], i);
        nbh = neighbourhood(cur_index, window_size, size(image_l));
        comparable = @view image_r[nbh];

        cur_disparity = abs(index[2] - i)

 
        if ~(min_disparity < cur_disparity < max_disparity)
            continue
        end

        err = ssd(ref_block, comparable);

        if err < metric_val
            metric_val = err
            disparity = cur_disparity
        end

    end

    return disparity
end


function get_padded_images(image_l::Array, image_r::Array, window_size::Tuple{Vararg{Int}})

    parent(padarray(image_l, Pad(window_size))), parent(padarray(image_r, Pad(window_size)))
end


function init_map_and_shape(image)
    return zeros(size(image)), size(image)
end

function construct_disparity_map(image_l::Array, image_r::Array, num_disparity::Int, window_size::Tuple{Vararg{Int}})

    map, shape = init_map_and_shape(image_l)

    image_l_padded, image_r_padded = get_padded_images(image_l, image_r, window_size)

    for i in 1:shape[1] - window_size[1]
        println(i)
        for j in 1:shape[2] - window_size[2]
            index = CartesianIndex(i + window_size[1], j+window_size[2])
            disparity = block_matching_iteration(image_l_padded, image_r_padded, index, num_disparity, window_size)
            map[i, j] = disparity
        end
    end
    return map
end

function construct_disparity_map(image_l::Array, image_r::Array, num_disparity::Int, window_size::Tuple{Vararg{Int}}, boundaries_matrix::Array{Int64, 3})

    map, shape = init_map_and_shape(image_l)

    image_l_padded, image_r_padded = get_padded_images(image_l, image_r, window_size)

    for i in 1:shape[1] - window_size[1]
        println(i)
        for j in 1:shape[2] - window_size[2]
            index = CartesianIndex(i + window_size[1], j+window_size[2])
            disparity = block_matching_iteration(image_l_padded, image_r_padded, index, num_disparity, window_size, boundaries_matrix)
            map[i, j] = disparity
        end
    end
    return map
end

function create_statistical_boundaries_matrix(disparity_map::Matrix{Float64}, window_radius::Tuple{Int, Int}, coefficient::Float64)

    start_y = window_radius[2]
    start_x = window_radius[1]

    boundaries = zeros(size(disparity_map)..., 2)

    for y_coord in start_y:2*window_radius[2]:size(disparity_map)[2]
        for x_coord in start_x:2*window_radius[1]:size(disparity_map)[1]

            cur_index = CartesianIndex(x_coord, y_coord);
            nbh = neighbourhood(cur_index, window_radius, size(disparity_map));
            im_part = @view disparity_map[nbh]
            μ = mean(im_part)
            σ = std(im_part)

            boundaries[nbh, 1] .= μ - coefficient * σ
            boundaries[nbh, 2] .= μ + coefficient * σ

        end
    end

    return Int.(round.(boundaries))
end

function calculate_distance_matrix(disparity_map::Matrix{Float64}, focal_length::Float64, camera_distance::Float64)

    return focal_length * camera_distance ./ disparity_map
end