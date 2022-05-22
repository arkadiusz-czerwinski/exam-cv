include("block_matching.jl")
using Images
using Plots, FileIO


im2 = Gray.(load("Cones/im2.png"))
im6 = Gray.(load("Cones/im6.png"))

num_disparity = 64
window_size = (2,2)

map = construct_disparity_map(im2, im6, num_disparity, window_size)

map_picture = map/maximum(map)


Gray.(map_picture)

