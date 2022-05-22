include("block_matching.jl")
include("utils.jl")
using Images
using Plots, FileIO
using Statistics

im2 = Gray.(load("Cones/im2.png"))
im6 = Gray.(load("Cones/im6.png"))

num_disparity = 64
window_size = (2,2)

map = construct_disparity_map(im2, im6, num_disparity, window_size)

map_picture = map/maximum(map)


Gray.(map_picture)

boundaries_matrix = create_statistical_boundaries_matrix(map, (10,10), 1.)

map_corrected = construct_disparity_map(im2, im6, num_disparity, window_size, boundaries_matrix)

corrected_map_picture = map/maximum(map_corrected)

Gray.(corrected_map_picture)
