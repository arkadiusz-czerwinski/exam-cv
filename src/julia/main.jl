include("block_matching.jl")
include("utils.jl")
using Images
using Plots, FileIO
using Statistics

im2 = Gray.(load("Cones/im2.png"))
im6 = Gray.(load("Cones/im6.png"))

num_disparity = 124
window_size = (3,3)

map_ = construct_disparity_map(im2, im6, num_disparity, window_size)

map_picture = map_/maximum(map_)


Gray.(map_picture)

boundaries_matrix = create_statistical_boundaries_matrix(map_, (7,7), 1.)

map_corrected = construct_disparity_map(im2, im6, num_disparity, window_size, boundaries_matrix)

corrected_map_picture = map_corrected/maximum(map_)

Gray.(corrected_map_picture)

difference = abs.(map_ - map_corrected)

Gray.(difference/maximum(difference))

Gray.(map_picture)
Gray.(corrected_map_picture)

λ = 1e-10

distance_matrix = calculate_distance_matrix(map_corrected .+ λ, 1280., 6.)
