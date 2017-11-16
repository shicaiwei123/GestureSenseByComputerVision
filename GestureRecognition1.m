% 每次使用之前必须clear画布或者开启的摄像头

function varargout = GestureRecognition1(varargin)
% GESTURERECOGNITION1 MATLAB code for GestureRecognition1.fig
%      GESTURERECOGNITION1, by itself, creates a new GESTURERECOGNITION1 or raises the existing
%      singleton*.
%
%      H = GESTURERECOGNITION1 returns the handle to a new GESTURERECOGNITION1 or the handle to
%      the existing singleton*.
%
%      GESTURERECOGNITION1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GESTURERECOGNITION1.M with the given input arguments.
%
%      GESTURERECOGNITION1('Property','Value',...) creates a new GESTURERECOGNITION1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GestureRecognition1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GestureRecognition1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GestureRecognition1

% Last Modified by GUIDE v2.5 16-Nov-2017 13:39:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GestureRecognition1_OpeningFcn, ...
                   'gui_OutputFcn',  @GestureRecognition1_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GestureRecognition1 is made visible.
function GestureRecognition1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GestureRecognition1 (see VARARGIN)

% Choose default command line output for GestureRecognition1
global flag
global myCam
myCam=webcam;
flag=1;
handles.output = hObject;
MyStruct=struct('fs',44100,'time',0.5);
handles.MyStruct=MyStruct;
% handles.flag=flag;
% flag=0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GestureRecognition1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GestureRecognition1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.flag=1;
global flag
global myCam;
flag=1;
while(flag)  %大循环，一直不退出
readCnt=1;
imgSubMean=100;
imgRead=[];
threshold=0;
numBackGround=0;  %背景稳定的帧数
hand=0;   %1手在摄像头范围，0不在。
set(handles.edit3,'string','检测背景')
while(flag)  %当背景稳定后退出
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
    if(numBackGround>5)   %连续44帧稳定，则背景稳定
        backGroundRead=imgRead;
        set(handles.edit3,'string','背景稳定')
%         figure;
%         imshow(gestureSeg(backGroundRead));
        break;
    end
    if(imgSubMean<threshold)       %当总体像素低于这个值时，认为背景稳定，状态机进入下一个状态
        numBackGround=numBackGround+1;
    else
        numBackGround=0;
    end
end

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
while(flag)
    %读入图片，背景相减，做手势识别判断是否有手势进入
    img=snapshot(myCam);
    imgRead=img(80:end,80:end-80,:);
    imshow(imgRead);
    imgSub=imgRead-backGroundRead;
    imgPrcess=gestureSeg(imgSub);
    imgSubMean=mean(imgPrcess(:));
    if(imgSubMean>0.001)    %有手进入开始开始等待手稳定,二值化话图片像素不再全为0
        set(handles.edit3,'string','手进入')
        hand=1;
        while(flag)
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
               set(handles.edit3,'string','开始追踪')    
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
set(handles.edit3,'string','等待手势输入')    
while(flag)   %直到手开始运动或者手离开摄像头范围才跳出这个循环

      img=snapshot(myCam);
      imgRead=img(80:end,80:end-80,:);
      imshow(imgRead);
      %求质心坐标
    %           imshow(imgRead);
      imgSub=imgRead-backGroundRead;
      imgPrcess=gestureSeg(imgSub);  
      imgSubMean=mean(imgPrcess);
      if(imgSubMean<0.01)    %手离开了摄像头范围 
      set(handles.edit3,'string','手离开了摄像头范围')
         hand=0;
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
          set(handles.edit3,'string','手开始移动')
          j=j+1;
          if(j>8)
              j=j;
          end
          numStable=1;    
          break;
      end

end
       
       
       
%开始记录轨迹
while(flag) %直到手势运行结束才跳出这个循环

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
          numStable=1;               %一旦移动则重新计数
      else                            %否则认为手停止，或者是已经划出了摄像头
         numStable=numStable+1; 
      end
      if(numStable>3)            %连续5次停止，则任务手势识别结束，
          set(handles.edit3,'string','开始判断')
          pos.xMaxFinal=max(xAxis);     %记录手开始动作时手的最下方位置的坐标
          pos.yMaxFinal=max(yAxis);
          i=0;
          numMove=1;
          break;
      end

end  

   if(hand) %如果手离开了摄像头
%基于规则的识别
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
%                      if(abs(pos.xMaxBegin-pos.xMaxFinal<10))  %竖直方向是zoomOut而不是手向上平移
%                          display('zoomOut');
%                      else
                     drection=2;  
                        set(handles.edit2,'string','up')
%                      end
                 else
%                      if(abs(pos.yMaxBegin-pos.yMaxFinal)<10)
%                          display('zoomIn');
%                      else
                     drection=-2;  
                         set(handles.edit2,'string','down') 
%                      end
                 end
             else
                 if(pos.y(1)>pos.y(end))
                 drection=1;  
                     set(handles.edit2,'string','right')
                 else
                 drection=-1;  
                     set(handles.edit2,'string','left')   
                 end
             end
     toc    
         end
   else
       break;
       end
    end
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.flag=0;
% guidata(hObject, handles);
global flag
flag=0;



% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1)
cla;
close all
clear all



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
