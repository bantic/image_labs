import Image  

# Uses hashes of tuples to simulate 2-d arrays for the masks.
def get_prewitt_masks():  
  xmask = {}  
  ymask = {}  
  
  xmask[(0,0)] = -1  
  xmask[(0,1)] = 0  
  xmask[(0,2)] = 1  
  xmask[(1,0)] = -1  
  xmask[(1,1)] = 0  
  xmask[(1,2)] = 1  
  xmask[(2,0)] = -1  
  xmask[(2,1)] = 0  
  xmask[(2,2)] = 1  
  
  ymask[(0,0)] = 1  
  ymask[(0,1)] = 1  
  ymask[(0,2)] = 1  
  ymask[(1,0)] = 0  
  ymask[(1,1)] = 0  
  ymask[(1,2)] = 0  
  ymask[(2,0)] = -1  
  ymask[(2,1)] = -1  
  ymask[(2,2)] = -1  
  return (xmask, ymask)

def prewitt(pixels, width, height):  
  xmask, ymask = get_prewitt_masks()  

  # create a new greyscale image for the output  
  outimg = Image.new('L', (width, height))  
  outpixels = list(outimg.getdata())  

  for y in xrange(height):  
    for x in xrange(width):  
      sumX, sumY, magnitude = 0, 0, 0  

      if y == 0 or y == height-1: magnitude = 0  
      elif x == 0 or x == width-1: magnitude = 0  
      else:  
        for i in xrange(-1, 2):  
          for j in xrange(-1, 2):  
            # convolve the image pixels with the Prewitt mask, approximating ∂I / ∂x  
            sumX += (pixels[x+i+(y+j)*width]) * xmask[i+1, j+1]  

        for i in xrange(-1, 2):  
          for j in xrange(-1, 2):  
            # convolve the image pixels with the Prewitt mask, approximating ∂I / ∂y  
            sumY += (pixels[x+i+(y+j)*width]) * ymask[i+1, j+1]  

        # approximate the magnitude of the gradient  
        magnitude = abs(sumX) + abs(sumY)  

      if magnitude > 255: magnitude = 255  
      if magnitude < 0: magnitude = 0  

      outpixels[x+y*width] = 255 - magnitude  

  outimg.putdata(outpixels)  
  return outimg

import sys  
if __name__ == '__main__':  
  img = Image.open(sys.argv[1])  
  # only operates on greyscale images  
  if img.mode != 'L': img = img.convert('L')  
  pixels = list(img.getdata())  
  w, h = img.size  
  outimg = prewitt(pixels, w, h)  
  outimg.save(sys.argv[2])