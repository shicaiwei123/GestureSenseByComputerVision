%主函数
%手开始移动的阈值问题
%手离开摄像头的逻辑
%只录制到一张图片的问题
%这两个都要解决
%% 初始化
close all
clear all
% backGroundRead=imread('00001.bmp');
strWrite=0; %写图片的标号
strRead=0;  %读图片的标号5
%set up webcam
myCam=webcam;
img=snapshot(myCam);
backGroundRead=img(80:end,80:end-80,:);
%% 先相减再处理
%读入图片初始化
%相减，当像素均值低于一定阈值认为背景已经固定，开始进行下一步
while(1)  %大循环，一直不退出
readCnt=1;
imgSubMean=100;
imgRead=[];
threshold=0;
numBackGround=0;  %背景稳定的帧数
while(1)  %当背景稳定后退出
%     imgRead=imread(['0000',num2str(strRead),'.bmp']);
%     strRead=strRead+1;
       img=snapshot(myCam);
       imgRead=img(80:end,80:end-80,:);
       imshow(imgRead);
    if(readCnt>1)     %读入了两张图片就开始做减法
        imgSub=imgTemp-imgRead;
        imgTemp=imgRead;
        imgSubGray=rgb2gray(imgSub);
        imgSubMean=mean(imgSubGray(:));
    else
        imgTemp=imgRead;
        imgGray=rgb2gray(imgRead);
        threshold=mean(imgGray(:))/6;  %把原始图片的像素均值的1/6当做阈值，
        imgSub=imgRead;
        readCnt=readCnt+1;
    end
    if(numBackGround>45)   %连续3帧稳定，则背景稳定
        backGroundRead=imgRead;
        display('背景稳定');
        break;
    end
    if(imgSubMean<threshold)       %当总体像素低于这个值时，认为背景稳定，状态机进入下一个状态
        numBackGround=numBackGround+1;
    end
end

%开始检测手进入
%如果相减做手势分割后有阈值高于一定程度就视为有手进入
% readCnt=1; %图片计数归一
numStable=0;% 记录手势稳定的帧数
meanAxisTemp=0;
xAxisTemp=0;  %质心坐标初始化
yAxisTemp=0;
xAxisSub=100;  %质心坐标差初始化
yAxisSub=100;
numMove=1;   %记录读入的图片数，两张之后开始做减法
while(1)
    %读入图片，背景相减，做手势识别判断是否有手势进入
%     imgRead=imread(['0000',num2str(strRead),'.bmp']);
%     strRead=strRead+1;
    img=snapshot(myCam);
    imgRead=img(80:end,80:end-80,:);
    imshow(imgRead);
    imgSub=imgRead-backGroundRead;
    imgPrcess=gestureSeg(imgSub);
    imgSubMean=mean(imgPrcess(:));
    if(imgSubMean>0.001)    %有手进入开始开始等待手稳定,二值化话图片像素不再全为0
        display('手进入');
        while(1)
%           if(strRead>9)
%                imgRead=imread(['000',num2str(strRead),'.bmp']);
%           elseif(strRead>99)
%                imgRead=imread(['00',num2str(strRead),'.bmp']);
%           else
%               imgRead=imread(['0000',num2str(strRead),'.bmp']);
%           end
%           imshow(imgRead);
%           strRead=strRead+1;
          img=snapshot(myCam);
          imgRead=img(80:end,80:end-80,:);
          imshow(imgRead);
          imgSub=imgRead-backGroundRead;
          imgPrcess=gestureSeg(imgSub);
          [xAxis,yAxis]=find(imgPrcess);
          xAxisMean=mean(xAxis);
          yAxisMean=mean(yAxis);
          if(numMove<2)
              numMove=numMove+1;
          else
          xAxisSub=abs(xAxisTemp-xAxisMean);
          yAxisSub=abs(yAxisTemp-yAxisMean);
          end
          xAxisTemp=xAxisMean;
          yAxisTemp=yAxisMean;
          
           if((xAxisSub<10)&&(yAxisSub<10))     %手势稳定，稳定手势的帧数加一
               numStable=numStable+1;       
           else
               numStable=0;   %否则一旦波动重新计数
           end
           if(numStable>4)    %一旦稳定帧数超过3个，就认为手势稳定，开始进行手势跟踪
               display('手势稳定，开始追踪手势');
               break;
           end
%           readCnt=readCnt+1;
        end
        break;
    end     
end

%手势已经稳定，开始进行手势跟踪
%检测看手是否开始移动，若是开始，则开始记录帧间的质心直到手离开画面或者再次停止
%图片坐标系是从左上角开始，水平是x，竖直是y。所以负值是往右下角方向移动，正是往左上角移动
%单独求质心的x和y值
j=0;
while(1)    %直到手离开相机范围内之后，才跳出这个循环
xAxisTemp=0;  %质心坐标初始化
yAxisTemp=0;
xAxisSub=0;  %质心坐标差初始化
yAxisSub=0;
pos.x=[];    %记录质心位置
pos.y=[];
i=1;       %质心的个数
readCnt=1; %图片计数归一
direction=0; %方向，正为左，负为右，1为水平，2为竖直
numMove=1;   %记录读入的图片数，两张之后开始做减法
numStable=1;
display('等待手势输入');      
       while(1)   %直到手开始运动才跳出这个循环
           
          img=snapshot(myCam);
          imgRead=img(80:end,80:end-80,:);
          imshow(imgRead);
          %求质心坐标
%           imshow(imgRead);
          imgSub=imgRead-backGroundRead;
          imgPrcess=gestureSeg(imgSub);  
          if(imgSubMean<0.001)    %手离开了摄像头范围 
             display('手离开了摄像头范围');
             break;
          end
          [xAxis,yAxis]=find(imgPrcess);
          xAxisMean=mean(xAxis);
          yAxisMean=mean(yAxis);
          if(numMove<2)
              numMove=numMove+1;
          else
             xAxisSub=abs(xAxisTemp-xAxisMean);
             yAxisSub=abs(yAxisTemp-yAxisMean);
          end
          xAxisTemp=xAxisMean;
          yAxisTemp=yAxisMean;
          %比较质心坐标
           
          if((xAxisSub>10)||(yAxisSub>10)) %手开始移动
              pos.x(i)=xAxisTemp;
              pos.y(i)=yAxisTemp;
              pos.xMaxBegin=max(xAxis);     %记录手开始动作时手的最下方位置的坐标
              pos.yMaxBegin=max(yAxis);
              i=i+1;
              tic
              display('手开始移动');
              j=j+1;
              if(j>8)
                  j=j;
              end
              numStable=1;    
              break;
          end
%            readCnt=readCnt+1;
       end
       
       
       
       %开始记录轨迹
      while(1) %直到手势运行结束才跳出这个循环

          img=snapshot(myCam);
          imgRead=img(80:end,80:end-80,:);
          imshow(imgRead);
          %求质心坐标

          imgSub=imgRead-backGroundRead;
          imgPrcess=gestureSeg(imgSub);  
          [xAxis,yAxis]=find(imgPrcess);
          xAxisMean=mean(xAxis);
          yAxisMean=mean(yAxis); 
          xAxisSub=abs(xAxisTemp-xAxisMean);
          yAxisSub=abs(yAxisTemp-yAxisMean);
          xAxisTemp=xAxisMean;
          yAxisTemp=yAxisMean;          
          if((xAxisSub>10)||(yAxisSub>10)) %手在移动
              pos.x(i)=xAxisTemp;
              pos.y(i)=yAxisTemp;
              i=i+1; 
%               if(i>2)
%                 a=[pos.x;pos.y];
%                 insertMarker(imgRead,a','+','Color','red');
%                 imshow(imgRead);
%               end
              numStable=0;               %一旦移动则重新计数
          else                            %否则认为手停止，或者是已经划出了摄像头
             numStable=numStable+1; 
          end
          if(numStable>5)            %连续5次停止，则任务手势识别结束，
              display('手移动完成开始判断手势');
              pos.xMaxFinal=max(xAxis);     %记录手开始动作时手的最下方位置的坐标
              pos.yMaxFinal=max(yAxis);
              i=0;
              numMove=1;
              break;
          end

       end  
       
     stdX=std(pos.x);            %求x轴y轴标准差
     stdY=std(pos.y);
     if((stdX>20)&&(stdY>20))    %识别为圆
         xTemp=pos.x;
         xTemp(xTemp<0)=0;
         postiveX=find(xTemp);  %找到正向变化的x的坐标值
         yTemp=pos.y(postiveX);
         if(yTemp(2)>yTemp(1))  %如果差分为负那么是顺时针，否则为逆时针，假设至少有两张图片
             display('逆时针');
         else
             display('顺时针')
         end
     else
         
     if(stdX>stdY)    %整体是竖直方向上的变化
         if(pos.x(1)>pos.x(end))   %竖直方向是往上变化 
             if(abs(pos.xMaxBegin-pos.xMaxFinal<10))  %竖直方向是zoomOut而不是手向上平移
                 display('zoomOut');
             else
             drection=2;  
             display('up');
             end
         else
             if(abs(pos.yMaxBegin-pos.yMaxFinal)<10)
                 display('zoomIn');
             else
             drection=-2;  
             display('down');    
             end
         end
     else
         if(pos.y(1)>pos.y(end))
         drection=1;  
         display('right');
         else
         drection=-1;  
         display('left');    
         end
     end
 toc    
     end
     imgSubMean=mean(imgPrcess(:));
     if(imgSubMean<0.001)    %手离开了摄像头范围 
         display('手离开了摄像头范围');
         break;
     end
end
end

    pause(4);
 delete(myCam);
%     tic
%     img=imgRead-backGroundRead;
%     imgPrcess=gestureSeg(img);
%     toc
%     imshow(imgPrcess)
%     str=[num2str(cnt),'.jpg'];
%     imwrite(imgPrcess,str);
%     cnt=cnt+1;
%% 先处理再相减
% clear all
% tic
% backGroundProcess=gestureSeg(backGroundRead);
% imgProcess=gestureSeg(imgRead);
% img=imgProcess-backGroundProcess;
% img = bwareaopen(img,2500);  % 从二进制图像中移除所有少于2000像素的连接对象
% toc
% figure;
% imshow(img);
