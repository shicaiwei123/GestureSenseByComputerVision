%主函数
%手离开摄像头的逻辑
%算法逻辑
%开启摄像头时，先检测确定背景已经静止，一直检测到45帧的帧差低于一个阈值时才算是背景静止
%然后检测手进入摄像头范围和手静止，也就是开始做手势（这是基于在手势开始和结束之前要有一个停顿，方便特征提取）
%然后检测手是否开始运动，开始运动则开始记录，然后直到手停止
%提取这段时间的内的图片的特征量做手势识别

%要求
%背景可以移动，但是在手移动范围内不能有肤色和近肤色物体存在，不然会影响判决
%如果想要更好的使用手离开摄像头判决的逻辑两个办法
%一个是背景中完全无肤色和近肤色物体，二是跟根据背景中的肤色范围大小手动调节阈值，但是这样背景就不能运动了
%目前选择方案一，较为简单

%% 初始化
close all
clear all
strWrite=0; %写图片的标号
strRead=0;  %读图片的标号5
%set up webcam
myCam=webcam;
img=snapshot(myCam);
backGroundRead=img(80:end,80:end-80,:);
while(1)  %大循环，一直不退出


%开始检测手进入
%如果相减做手势分割后有阈值高于一定程度就视为有手进入
numStable=0;% 记录手势稳定的帧数
meanAxisTemp=0;
xAxisTemp=0;  %质心坐标初始化
yAxisTemp=0;
xAxisSub=100;  %质心坐标差初始化
yAxisSub=100;
numMove=1;   %记录读入的图片数，两张之后开始做减法
% figure;
while(1)
    %读入图片，背景相减，做手势识别判断是否有手势进入
    img=snapshot(myCam);
    imgRead=img(80:end,80:end-80,:);
    imshow(imgRead);
    imgSub=imgRead-backGroundRead;
    backGroundRead=imgRead;
    imgPrcess=gestureSeg(imgSub);
    imgSubMean=mean(imgPrcess(:));
    if(imgSubMean>0.001)    %有手进入开始开始等待手稳定,二值化话图片像素不再全为0
        display('手进入');
        hand=1;
        while(1)
          img=snapshot(myCam);
          imgRead=img(80:end,80:end-80,:);
          imshow(imgRead);
          imgSub=imgRead-backGroundRead;
          backGroundRead=imgRead;
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
          
%            if((xAxisSub<10)&&(yAxisSub<10))     %手势稳定，稳定手势的帧数加一
           if(isnan(xAxisSub)&&isnan(yAxisSub))
               numStable=numStable+1;       
           else
               numStable=0;   %否则一旦波动重新计数
           end
           if(numStable>4)    %一旦稳定帧数超过3个，就认为手势稳定，开始进行手势跟踪
               display('手势稳定，开始追踪手势');
               break;
           end

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
figureStay=[];
figureTime=1; %手势帧数静止判断
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
while(1)   %直到手开始运动或者手离开摄像头范围才跳出这个循环

      img=snapshot(myCam);
      imgRead=img(80:end,80:end-80,:);
      imshow(imgRead);
      %求质心坐标
    %           imshow(imgRead);
      imgSub=imgRead-backGroundRead;
      backGroundRead=imgRead;
      imgPrcess=gestureSeg(imgSub);  
      imgSubMean=mean(imgPrcess(:));
      if(imgSubMean<0.01)    %像素为近0时，手势静止判断加一
          figureTime=figureTime+1;
          if(figureTime>10) %连续十帧检测不到运动，则检查看手是否离开了摄像头
              figureStay=gestureSeg(imgRead);  
              imgSubMean=mean(figureStay(:));
              if(imgSubMean<0.05)    %手离开了摄像头范围 
                 display('手离开了摄像头范围');
                 hand=0;
                 break;
              end
          end
      else
          figureTime=1;
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

end
       
       
       
%开始记录轨迹
while(1) %直到手势运行结束才跳出这个循环

      img=snapshot(myCam);
      imgRead=img(80:end,80:end-80,:);
      imshow(imgRead);
      %求质心坐标

      imgSub=imgRead-backGroundRead;
      backGroundRead=imgRead;
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

          numStable=1;               %一旦移动则重新计数
      else                            %否则认为手停止，或者是已经划出了摄像头
         numStable=numStable+1; 
      end
      if(numStable>3)            %连续5次停止，则任务手势识别结束，
          display('手移动完成开始判断手势');
          pos.xMaxFinal=max(xAxis);     %记录手开始动作时手的最下方位置的坐标
          pos.yMaxFinal=max(yAxis);
          i=0;
          numMove=1;
          break;
      end

end  

 
%基于规则的识别
    if(hand)
         stdX=std(pos.x);            %求x轴y轴标准差
         stdY=std(pos.y);
         if((stdX>20)&&(stdY>20))    %识别为圆
             xTemp=diff(pos.x);
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
%                  if(abs(pos.xMaxBegin-pos.xMaxFinal<10))  %竖直方向是zoomOut而不是手向上平移
%                      display('zoomOut');
%                  else
                 drection=2;  
                 display('up');
%                  end
             else
%                  if(abs(pos.yMaxBegin-pos.yMaxFinal)<10)
%                      display('zoomIn');
%                  else
                 drection=-2;  
                 display('down');    
%                  end
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
    else
        break;
    end
end
end

    pause(4);
 delete(myCam);
