import numpy as np
import cv2
from numpy.core.records import array
I = cv2.imread("train.jpg", cv2.IMREAD_GRAYSCALE)
I = cv2.resize(I, (100,65), interpolation = cv2.INTER_AREA)

row,col=I.shape
cv2.imshow("a",I)
if cv2.waitKey(0) & 0xFF == ord('q'):
    exit
print(I.shape)
I.shape=(row*col,1)
print(I.shape)
bin8 = lambda x : ''.join(reversed( [str((x >> i) & 1) for i in range(8)] ) )

I_b=[]

for i in range(0,row*col):

    s=bin8(int(I[i]))
    I_b.append(str(s))
np.savetxt("pixels.txt",I_b,fmt='%s')
