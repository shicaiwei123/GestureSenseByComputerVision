%图片和视频录制部分
%三种录制方式，matlab两种调用方式，一种opencv调用方式
%图像尺寸默认是480x640，录制后截取为400x480，要调节 


%% 初始化
close all
clear all
doPhoto=false;   %是否录制图片
cnt=0;         %计数器初始化
j=0;           %控制录制图片的间隔
%% winvideo
% By lyqmath
clc; clear all; 
close all;
vid = videoinput('winvideo',1);
set(vid,'ReturnedColorSpace','rgb');
vidRes=get(vid,'VideoResolution');
width=vidRes(1);
height=vidRes(2);
nBands=get(vid,'NumberOfBands');
figure('Name', 'Matlab调用摄像头 By Lyqmath', 'NumberTitle', 'Off', 'ToolBar', 'None', 'MenuBar', 'None');
hImage=image(zeros(vidRes(2),vidRes(1),nBands));
tic
preview(vid,hImage);
toc

%% webcam
% 就是可以不断的录像显示，或者处理之后再显示
% 在这个过程中就可以进行图像的处理，得到结果，然后在其他地方调用
% 类似多普勒频移的手势识别，只不过换成了计算机视觉而已
%set up webcam
myCam=webcam;
%set up video writer
%生成对象后在命令行运行就可以看到对象属性
 myWriter=VideoWriter('myMoive3.avi');
 myWriter.FrameRate=5;
 open(myWriter);
% %Grab and Process frame
frames=20;
pause(5);
while(1)
    for i1=1:frames
        tic
        img=snapshot(myCam);
        toc
        figure(1)
        subplot(1,2,1)
        img1=img(80:end,80:end-80,:);
        imshow(img1);
        subplot(1,2,2)
        img2=img(160:end-160,120:end-120,:);
        imshow(img);
        photo.cdata=img1;
        photo.colormap=[];
        axis image
        axis off;
      
        writeVideo(myWriter,photo)
        if doPhoto
            if(cnt>20)
                j=2;
            end
            j=j+0.1;
            if(j>1)
                if cnt<10
                str=['0000',num2str(cnt),'.bmp'];
                elseif cnt<100
                    str=['000',num2str(cnt),'.bmp'];
                elseif cnt<1000
                     str=['00',num2str(cnt),'.bmp'];
                else
                   str=['0',num2str(cnt),'.bmp'];
                end
                imwrite(img1,str);
                cnt=cnt+1;
             end
        end
    end
end
delete(myCam);
  

%% opencv
camera =cv.VideoCapture();
while(1)
    tic
    img=camera.read;
    imshow(img);
    axis image
    axis off;
    toc
end
