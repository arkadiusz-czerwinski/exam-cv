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

function get_padded_images(image_l::Array, image_r::Array, window_size::Tuple{Vararg{Int}})

    parent(padarray(image_l, Pad(window_size))), parent(padarray(image_r, Pad(window_size)))
end


function construct_disparity_map(image_l::Array, image_r::Array, num_disparity::Int, window_size::Tuple{Vararg{Int}})

    shape = size(image_l)

    map = zeros(shape)

    image_l_padded, image_r_padded = get_padded_images(image_l, image_r, window_size)

    for i in 1:shape[1]
        println(i)
        for j in 1:shape[2]
            index = CartesianIndex(i + window_size[1], j+window_size[2])
            disparity = block_matching_iteration(image_l_padded, image_r_padded, index, num_disparity, window_size)
            map[i, j] = disparity
        end
    end
    return map
end

