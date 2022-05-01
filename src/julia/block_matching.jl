include("utils.jl")
using Images
using Plots, FileIO


im2 = load("Teddy/im2.png")
im6 = Gray.(load("Teddy/im6.png"))

nb = neighbourhood(CartesianIndex(30,30), (3,3), size(im2))

im2


function block_matching_iteration(image_l, image_r, index::CartesianIndex, num_disparity::Int, window_size::Tuple{Vararg{Int}})

    start_ind = max(1 + window_size[2], index[2]-num_disparity +window_size[2])
    end_ind = min(size(image_l)[2] - window_size[2],index[2]+num_disparity)


    ref_block = image_l[neighbourhood(index, window_size, size(image_l))]

    metric_val = Inf
    disparity = 0

    for i in start_ind:end_ind

        cur_index = CartesianIndex(index[1], i)
        nbh = neighbourhood(cur_index, window_size, size(image_l))
        comparable = image_r[nbh]
        err = ssd(ref_block, comparable)
        # println("i = $i and error is $err")
        # println(channelview(comparable))
        break
        if err < metric_val
            metric_val = err
            disparity = abs(index[2] - i)
        end

    end

    disparity
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


num_disparity = 128
window_size = (0,0)

size(im2)

map = construct_disparity_map(im2, im6, num_disparity, window_size)

@show map

Gray.(map)

map2 = map/maximum(map)*255

Gray.(map2)


block_matching_iteration(im2, im6, CartesianIndex(201,201), 20, (3,3))
x = 3
"bla $x 232a"


ret = im2[neighbourhood(CartesianIndex(201,184), (2,2), size(im2))]

print(ret)
size(ret)
channelview(ret)


neighbourhood(CartesianIndex(201,184), (2,2), size(im2))

ret

im2[1, 1] * 255
Gray(im2[1,1]) 
im2[1,1] ^ 2

@timed x = im2[neighbourhood(CartesianIndex(201,184), (2,2), size(im2))]

@timed x = @view im2[neighbourhood(CartesianIndex(201,184), (2,2), size(im2))]

using BenchmarkTools

@benchmark @view im2[neighbourhood(CartesianIndex(201,184), (2,2), size(im2))]

@benchmark  im2[neighbourhood(CartesianIndex(201,184), (2,2), size(im2))]

@benchmark block_matching_iteration(im2, im6, CartesianIndex(201,201), 20, (3,3))