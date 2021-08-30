import numpy as np
import cv2
from numpy.core.records import array
I = cv2.imread('train.jpg', cv2.IMREAD_GRAYSCALE)


row,col=I.shape

array2D=[]
with open('p_out.txt', 'r') as f:
        for line in f.readlines():
            array2D.append(line)
print(len(array2D))            
array2D=np.uint8(array2D)
array2D.shape=(row,col)

cv2.imwrite("Image_out.png",array2D)
cv2.imshow("a",array2D)
if cv2.waitKey(0) & 0xFF == ord('q'):
    exit
