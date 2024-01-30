"""
transformations.py
Purpose: List of functions used to augment the training set images. Uses Pillow
Author: Leigh Tanji
"""

from PIL import Image, ImageEnhance
import skimage
from load_data import load_data 
import numpy as np
import matplotlib.pyplot as plt


"""
all_noise
Input: 28x28 array with greyscale pixel value from 0 (black) to 255 (white)
Description: Transforms an image into new images each augmented with different types of noise. 
Output: An array 7x784 with different noise applied to input image. 
"""
def all_noise(img_arr):
    #library of noise types
    noises = ['gaussian', 'localvar', 'salt', 'pepper', 's&p', 'speckle', 'poisson']

    loud= np.ones((7, 784)) #space to put transformations
    for i in range(len(noises)):
        noisier = skimage.util.random_noise(img_arr, noises[i])
        loud[i]= noisier.reshape((1, 784))
    return loud


"""
all_rot
Input: 28x28 array with grey scale pixel value from 0 (black) to 255 (white) 
        and number of rotations desired.
Description: Rotates given images by a random degree between -10 and 10.
Output: An array of all images rotated by a random degree.
"""
def all_rot(img_arr, num_trans):
    all_rotations = np.ones((num_trans, 784))
    degree = np.random.uniform(-10, 10, size=num_trans)
    
    for i in range(0, num_trans):
        rotated = skimage.transform.rotate(img_arr, degree[i])
        all_rotations[i] = rotated.reshape((1, 784))
    return all_rotations


"""
all_expo
Input: 28x28 array with grey scale pixel image, number of transformations       
        desired, and direction of exposure ('dark' or 'light')
Description: Transforms a 2D numpy array into new arrays with different 
            exposure levels. Exposure levels are randomly assigned. 
Output: An array of pixels with applicable number of dark/light exposures.
"""
def all_expo(img_arr, num_trans, dir):
    all_exposures = np.ones((num_trans, 784))
    
    if dir == 'light':
        up = np.random.uniform(0.1, 0.9, size=num_trans)

        for i in range(num_trans):
            lighter = skimage.exposure.adjust_gamma(img_arr, up[i])
            all_exposures[i]= lighter.reshape((1, 784))

    elif dir == 'dark': 
        dwn = np.random.uniform(2, 3, size=num_trans)

        for i in range(num_trans):
            darker = np.asarray(skimage.exposure.adjust_gamma(img_arr, dwn[i]))
            all_exposures[i]= (darker.reshape((1, 784)))

    return all_exposures


"""
show_image
Input: the array original image is coming from (training, validation, test), the specific index, and 28x28 array of the new image.
Description: function just to see ONE instance to make sure picture looks as intended.
Output: The images (human visible) of the new and augmented pictures. 
"""
def show_image(x_set, index, newImg):
    fig, axgrid = plt.subplots(1, 2, figsize=(8, 4))

    ax1 = axgrid[0]
    ax2 = axgrid[1]
    x_SS2 = x_set[index].reshape((28,28))

    #shows the original image
    ax1.imshow(x_SS2, vmin=0, vmax=1, cmap='gray')
    ax1.set_xticks([]); ax1.set_yticks([]);

    #display new image.
    ax2.imshow(newImg, vmin=0, vmax=1, cmap='gray')
    ax2.set_xticks([]); ax2.set_yticks([]);

    plt.tight_layout();
    plt.show();


"""
noise_exp
Input: 28x28 image array, number of transformations desired, and direction 
        ('light' / 'dark') of the exposure.
Description: function just to see ONE instance to make sure picture looks as 
            intended.
Output: A z x 784 array of noisy and exposed images. Where z is the number of 
        transformations we want.
"""
def noise_exp(img_arr, num_trans, dir):
    #library of noise types
    noises = ['gaussian', 'localvar', 'salt', 'pepper', 's&p', 'speckle', 'poisson']

    noisy_exp= np.ones((num_trans, 784)) #space to put transformations
       
    for i in range(num_trans):
        sound = np.random.choice(noises)   #picks random sound 
        noisy_img = skimage.util.random_noise(img_arr, sound)
        
        if dir == 'light':
            up = np.random.uniform(0.1, 0.9, size=1)
            lighter = skimage.exposure.adjust_gamma(noisy_img, up)
            noisy_exp[i]= lighter.reshape((1, 784))
        elif dir == 'dark': 
            dwn = np.random.uniform(2, 3, size=1)
            darker = np.asarray(skimage.exposure.adjust_gamma(noisy_img, dwn))
            noisy_exp[i]= (darker.reshape((1, 784)))

    return noisy_exp


"""
noise_flip
Input: 28x28 image array, number of transformations desired
Description: adds noise and flips ONE IMAGE and . Where z 
        is the number of noisy and flipped images we want. Must give (28, 28 
        array)
Output: (z, 782) array of noisy and flipped images.
"""
def noise_flip(img_arr, num_trans):
    flipped = (np.fliplr(img_arr))

    #library of noise types
    noises = ['gaussian', 'localvar', 'salt', 'pepper', 's&p', 'speckle', 'poisson']

    noisy_flips = np.ones((num_trans, 784)) #space to put transformations
    sound = np.random.choice(noises, size=num_trans)   #picks random sounds 

    # Randomly chooses noise and puts it into the array.
    for i in range(num_trans):
        noisy_img = skimage.util.random_noise(flipped, sound[i])
        noisy_flips[i] = (noisy_img.reshape((1, 784)))

    return noisy_flips


"""
rot_expose
Input: 28x28 image array, number of transformations desired, and direction 
        ('light' / 'dark') of the exposure. 
Description: Randomly rotates and lighten/darken ONE IMAGE and returns (z, 
            782) array. Where z is the number of noisy and flipped images we want. 
Output: (z, 782) array of rotated and exposed images.
"""
def rot_expose(img_arr, num_trans, dir):
    rotated_exp = np.ones((num_trans, 784))
    degree = np.random.uniform(-10, 10, num_trans)  #choose random degrees rot.

    for i in range(num_trans):
        rotated = skimage.transform.rotate(img_arr, degree[i])
        
        if dir == 'light':
            up = np.random.uniform(0.1, 0.9, size=1)
            lighter = skimage.exposure.adjust_gamma(rotated, up)
            rotated_exp[i]= lighter.reshape((1, 784))
        elif dir == 'dark': 
            dwn = np.random.uniform(2, 3, size=1)
            darker = np.asarray(skimage.exposure.adjust_gamma(rotated, dwn))
            rotated_exp[i]= (darker.reshape((1, 784)))

    return rotated_exp