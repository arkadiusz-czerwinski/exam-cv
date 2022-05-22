include("block_matching.jl")
include("utils.jl")
using Images
using Plots, FileIO
using Statistics

im2 = Gray.(load("Cones/im2.png"))
im6 = Gray.(load("Cones/im6.png"))

num_disparity = 124
window_size = (3,3)

map = construct_disparity_map(im2, im6, num_disparity, window_size)

map_picture = map/maximum(map)


Gray.(map_picture)

boundaries_matrix = create_statistical_boundaries_matrix(map, (7,7), 1.)

map_corrected = construct_disparity_map(im2, im6, num_disparity, window_size, boundaries_matrix)

corrected_map_picture = map_corrected/maximum(map)

Gray.(corrected_map_picture)

difference = abs.(map - map_corrected)

Gray.(difference/maximum(difference))

Gray.(map_picture)
Gray.(corrected_map_picture)
