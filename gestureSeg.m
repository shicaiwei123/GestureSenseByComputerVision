function img=gestureSeg(im)
a=im;
f = rgb2ycbcr(a);
f_cb = f(:,:,2);
f_cr = f(:,:,3);
f = (f_cb>=100)&(f_cb<=127)&(f_cr>=138)&(f_cr<=170);
%  figure;imshow(f);

I2 = f;

% figure;
% se=strel('ball',5,3);
%  se = [1;1;1];
% I3 = imerode(I2,se);                                  % 腐蚀Imerode(X,SE).其中X是待处理的图像，SE是结构元素对象
% subplot(1,3,1);imshow(I3);title('腐蚀后的图像');
I4 = bwareaopen(I2,2000);                              % 从二进制图像中移除所有少于2000像素的连接对象，消失的是连续的白色像素数量少于2000的字符
% subplot(1,3,2);imshow(I4);title('从对象中移除小对象');
se = strel('rectangle',[5,5]);                        % 5X5的矩形
I5 = imclose(I4,se);                                  % 用5*5的矩形对图像进行闭运算(先膨胀后腐蚀)
% subplot(1,3,3);imshow(I5);title('平滑图像的轮廓');
img=I5;