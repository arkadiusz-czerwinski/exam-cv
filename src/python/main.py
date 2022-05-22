import numpy as np
import cv2 as cv
from matplotlib import pyplot as plt
from pathlib import Path
from time import sleep
from tqdm import tqdm

DATA_DIR = Path(__file__).parents[1] /  'data' / 'Teddy'
print(DATA_DIR.resolve())
imgR = cv.imread(str(DATA_DIR / "im2.png")) / 255
imgL = cv.imread(str(DATA_DIR / "im6.png")) / 255

imgR = cv.resize(imgR, (imgL.shape[1]//2, imgL.shape[0]//2))
imgL = cv.resize(imgL, (imgL.shape[1]//2, imgL.shape[0]//2))
print(f"Block matching... image of size {imgL.shape}")
initial_points = []
windows_size = (3,3)
max_disparity = 16


disparity_map = np.zeros_like(imgL) + max_disparity

def block_matching_iteration(window_size, imgL, imgR, i, j):
    min_similarity = float('inf')
    disparity = 0
    start_ind = max(0 + window_size[1], i-max_disparity +window_size[1])
    end_ind = min(imgL.shape[1] - window_size[1],i+max_disparity)
    current_window = imgL[i-window_size[0]:i+window_size[0]+1,j-window_size[1]:j+window_size[1]+1]
    for z in range(start_ind, end_ind):
        compared_window = imgR[i-window_size[0]:i+window_size[0]+1,z-window_size[1]:z+window_size[1]+1]
        dist = np.sum((current_window - compared_window)**2)

        if dist < min_similarity:
            min_similarity = dist
            disparity = np.abs(i - z)

    return disparity

for i in tqdm(range(windows_size[0],imgL.shape[0] - windows_size[0])):
    for j in range(windows_size[1],imgL.shape[1] - windows_size[1]):
        disparity_map[i, j] = block_matching_iteration(windows_size, imgL, imgR, i, j)
        


print(disparity_map)
plt.imshow(disparity_map[windows_size[0]:-windows_size[0],windows_size[1]:-windows_size[1]])
plt.show()


# val = block_matching_iteration(windows_size, imgL, imgR, 100,100)
# print(val)