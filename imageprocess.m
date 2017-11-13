%程序很难受，晚上试，白天试，不同的环境光，效果差别太大了......


%% 初始化
clear
% camera = cv.VideoCapture();
%a=camera.read;
test=load('test');
a=test.a;

%%
%HSV模式，不小心把阙值给改了.....之前的阙值是从一篇论文上转过来的，效果挺好的,,,,,
% a = camera.read; 
tic
hv = rgb2hsv(a); 
size_image = size(a);
processed = zeros(size_image(1),size_image(2));

for i = 1:size_image(1)
    for j = 1:size_image(2)
         if (abs(hv(i,j,1)-0.22) <= 0.16||hv(i,j,1) >= 0.8)&&abs(hv(i,j,2)-0.4) <= 0.2&&hv(i,j,3)>=0.4
            processed(i,j) = 1;
        end
    end
end

figure;
subplot(1,3,1);imshow(a);title('camera');
subplot(1,3,2);imshow(hv);title('HSV');
subplot(1,3,3);imshow(processed);title('binary');


I2 = processed;
figure;

se = [1;1;1];
I3 = imerode(I2,se);                                  % 腐蚀
subplot(1,3,1);imshow(I3);title('腐蚀后的图像');
I4 = bwareaopen(I3,100);                              % 从二进制图像中移除所有少于100像素的连接对象
subplot(1,3,2);imshow(I4);title('移除小对象');
se = strel('rectangle',[5,5]);                        % 5X5的矩形
I5 = imclose(I4,se);                                  % 用5*5的矩形对图像进行闭运算(先膨胀后腐蚀)
subplot(1,3,3);imshow(I5);title('平滑图像');

H = hv(:,:,1);
S = hv(:,:,2);
V = hv(:,:,3);

figure;
subplot(1,3,1);imshow(H);title('HSV空间H分量图像');
subplot(1,3,2);imshow(S);title('HSV空间S分量图像');
subplot(1,3,3);imshow(V);title('HSV空间V分量图像');
toc
%%
%Ycbcr模式1,实测速度过慢...效果比上一个强
% clear

%camera = cv.VideoCapture();
%a= camera.read; 
%  a=imread(a);
tic 
Ycbcr = rgb2ycbcr(a);

fThreshold = 0.22;                          %人脸分割阈值

[M,N,D] = size(Ycbcr);                      %获取图像宽度，高度和维度。
processed1 = zeros(M,N);
FaceProbImg = zeros(M,N);                   %肤色后验概率矩阵
Mean = [117.4316 148.5599]';                %肤色均值
C = [97.0946 24.4700;  24.4700 141.9966];   %肤色方差
cbcr = zeros(2,1);                          %颜色分量，Y分量差异较大，只用CbCr分量。
for i = 1:M
    for j = 1:N
        cbcr(1) = Ycbcr(i,j,2);
        cbcr(2) = Ycbcr(i,j,3);
        FaceProbImg(i,j) = exp(-0.5*(cbcr-Mean)'*inv(C)*(cbcr-Mean));     %计算肤色高斯后验概率         
        if FaceProbImg(i,j) > fThreshold                                  %如果大于阈值认为是人脸区域
            processed1(i,j) = 1;
        end          
    end
end

figure
imshow(processed1);title('YCbCr');

I2 = processed1;

figure;
se = [1;1;1];
I3 = imerode(I2,se);                                  % 腐蚀Imerode(X,SE).其中X是待处理的图像，SE是结构元素对象
subplot(1,3,1);imshow(I3);title('腐蚀后的图像');
I4 = bwareaopen(I3,250);                              % 从二进制图像中移除所有少于2000像素的连接对象，消失的是连续的白色像素数量少于2000的字符
subplot(1,3,2);imshow(I4);title('从对象中移除小对象');
se = strel('rectangle',[5,5]);                        % 5X5的矩形
I5 = imclose(I4,se);                                  % 用5*5的矩形对图像进行闭运算(先膨胀后腐蚀)
subplot(1,3,3);imshow(I5);title('平滑图像的轮廓');
toc
%%
%Ycbcr模式2,效果似乎比上一个要好点
% clear

% camera = cv.VideoCapture();
% %a = camera.read; 
backGroundRead=imread('00001.bmp');
imRead=imread('00069.bmp');
a=imRead-backGroundRead;
%a = imread('00002.bmp');
 tic
f = rgb2ycbcr(a);
f_cb = f(:,:,2);
f_cr = f(:,:,3);
f = (f_cb>=100)&(f_cb<=127)&(f_cr>=138)&(f_cr<=170);
 figure;imshow(f);

I2 = f;

figure;
% se=strel('ball',5,3);
 se = [1;1;1];
% I3 = imerode(I2,se);                                  % 腐蚀Imerode(X,SE).其中X是待处理的图像，SE是结构元素对象
% subplot(1,3,1);imshow(I3);title('腐蚀后的图像');
I4 = bwareaopen(I2,2500);                              % 从二进制图像中移除所有少于2000像素的连接对象，消失的是连续的白色像素数量少于2000的字符
subplot(1,3,2);imshow(I4);title('从对象中移除小对象');
se = strel('rectangle',[5,5]);                        % 5X5的矩形
I5 = imclose(I4,se);                                  % 用5*5的矩形对图像进行闭运算(先膨胀后腐蚀)
subplot(1,3,3);imshow(I5);title('平滑图像的轮廓');
toc