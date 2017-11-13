%inital
close all
clear all


%Create System objects for reading and displaying video and
%for drawing a bounding box of the object.
videoFileReader = vision.VideoFileReader('myMoive3.avi');
videoPlayer = vision.VideoPlayer('Position',[100,100,680,520]);


%Read the first video frame, which contains the object, define the region.
objectFrame = step(videoFileReader);
figure; imshow(objectFrame); 
objectRegion=round(getPosition(imrect));
% objectRegion = [264,122,93,93];

%Show initial frame with a red bounding box.
objectImage = insertShape(objectFrame,'Rectangle',objectRegion,'Color','red');
figure;
imshow(objectImage);
title('Red box shows object region');


%Detect interest points in the object region.
%Ãÿ’˜Ã·»°
points = detectMinEigenFeatures(rgb2gray(objectFrame),'ROI',objectRegion);

%Display the detected points.
pointImage = insertMarker(objectFrame,points.Location,'+','Color','white');
figure;
imshow(pointImage);
title('Detected interest points');

%Create a tracker object.
tracker = vision.PointTracker('MaxBidirectionalError',1);

%Initialize the tracker.
initialize(tracker,points.Location,objectFrame);

%Read, track, display points, and results in each video frame.
while ~isDone(videoFileReader)
      frame = step(videoFileReader);
      [points, validity] = step(tracker,frame);
      out = insertMarker(frame,points(validity, :),'+');
      step(videoPlayer,out);
      pause(0.06);
end

