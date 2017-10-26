% Inclass16

%The folder in this repository contains code implementing a Tracking
%algorithm to match cells (or anything else) between successive frames. 
% It is an implemenation of the algorithm described in this paper: 
%
% Sbalzarini IF, Koumoutsakos P (2005) Feature point tracking and trajectory analysis 
% for video imaging in cell biology. J Struct Biol 151:182?195.
%
%The main function for the code is called MatchFrames.m and it takes three
%arguments: 
% 1. A cell array of data called peaks. Each entry of peaks is data for a
% different time point. Each row in this data should be a different object
% (i.e. a cell) and the columns should be x-coordinate, y-coordinate,
% object area, tracking index, fluorescence intensities (could be multiple
% columns). The tracking index can be initialized to -1 in every row. It will
% be filled in by MatchFrames so that its value gives the row where the
% data on the same cell can be found in the next frame. 
%2. a frame number (frame). The function will fill in the 4th column of the
% array in peaks{frame-1} with the row number of the corresponding cell in
% peaks{frame} as described above.
%3. A single parameter for the matching (L). In the current implementation of the algorithm, 
% the meaning of this parameter is that objects further than L pixels apart will never be matched. 

% Continue working with the nfkb movie you worked with in hw4. 

% Part 1. Use the first 2 frames of the movie. Segment them any way you
% like and fill the peaks cell array as described above so that each of the two cells 
% has 6 column matrix with x,y,area,-1,chan1 intensity, chan 2 intensity
reader1=bfGetReader('nfkb_movie1.tif');
iplane_1=reader1.getIndex(1-1,1-1,1-1)+1;
iplane_2=reader1.getIndex(1-1,1-1,2-1)+1;
reader1_im=bfGetPlane(reader1, iplane_1);
reader2_im=bfGetPlane(reader1, iplane_2);

lims =[100 2000];
figure;
subplot(1,2,1); imshow(reader1_im, lims);
subplot(1,2,2); imshow(reader2_im, lims);

figure;
imshowpair(imadjust(reader1_im), imadjust(reader2_im));

mask1 = reader1_im > 650;
mask2= reader2_im > 650;

mask1=imopen(mask1, strel('disk', 5));
mask2=imopen(mask2, strel('disk', 5));
%mask1=imfill(mask1, 'holes');
%mask2=imfill(mask2, 'holes');
%mask1=imdilate(mask1, strel('disk', 5));
%mask2=imdilate(mask2, strel('disk', 5));
imshow(mask1);
imshow(mask2);

im1_ch1tm1=regionprops(mask1, reader1_im, 'Area', 'Centroid', 'MeanIntensity');
im1_ch1tm2=regionprops(mask2, reader2_im, 'Area', 'Centroid', 'MeanIntensity');

iplane_ch2_1=reader1.getIndex(1-1,2-1,1-1)+1;
iplane_ch2_2=reader1.getIndex(1-1,2-1,2-1)+1;
reader1_im2=bfGetPlane(reader1, iplane_ch2_1);
reader2_im2=bfGetPlane(reader1, iplane_ch2_2);

im1_ch2tm1=regionprops(mask1, reader1_im2, 'Area', 'Centroid', 'MeanIntensity');
im1_ch2tm2=regionprops(mask2, reader2_im2, 'Area', 'Centroid', 'MeanIntensity');

xy1=cat(1, im1_ch1tm1.Centroid);
a1=cat(1, im1_ch1tm1.Area);
mi1=cat(1, im1_ch1tm1.MeanIntensity);
mi1ch2=cat(1, im1_ch2tm1.MeanIntensity);
tmp= -1*ones(size(a1));
peaks{1}=[xy1, a1, tmp, mi1, mi1ch2];

xy2=cat(1, im1_ch1tm2.Centroid);
a2=cat(1, im1_ch1tm2.Area);
mi2=cat(1, im1_ch1tm2.MeanIntensity);
mi2ch2=cat(1, im1_ch2tm2.MeanIntensity);
tmp= -1*ones(size(a2));
peaks{2}=[xy2, a2, tmp, mi2, mi2ch2];

% Part 2. Run match frames on this peaks array. ensure that it has filled
% the entries in peaks as described above. 
addpath('TrackingCode/');
matched_peaks=MatchFrames(peaks, 2, 0.1);

% Part 3. Display the image from the second frame. For each cell that was
% matched, plot its position in frame 2 with a blue square, its position in
% frame 1 with a red star, and connect these two with a green line. 

iplane3 = reader1.getIndex(1-1,1-1,2-1)+1;
im3 = bfGetPlane(reader1,iplane3);

figure; imshow(im3,lims); 

hold on;

plot(peaks{1}(:,1),peaks{1}(:,2),'r*');

plot(peaks{2}(:,1),peaks{2}(:,2),'cs');

