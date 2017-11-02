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
preview(vid,hImage);


%% webcam
%就是可以不断的录像显示，或者处理之后再显示
%在这个过程中就可以进行图像的处理，得到结果，然后在其他地方调用
%类似多普勒频移的手势识别，只不过换成了计算机视觉而已
% %set up webcam
% myCam=webcam;
% %set up video writer
% myWriter=VideoWriter('myMoive.avi');
% open(myWriter);
% %Grab and Process frame
% frames=50;
% 
% for i1=1:frames
%     img=snapshot(myCam);
%     img=img>60 & img<170;
%     imagesc(img);
%     axis image
%     axis off;
%     
%     writeVideo(myWriter,double(img))
% end
delete(myCam);
    
