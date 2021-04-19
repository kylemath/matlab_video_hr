% VideoAnalysis.m - Kyle Mathewson, UAlberta, March 2018

% this loads a video and analyzes a subsection of the video over time to
% extract average red green and blue channel values in an ROI. 

% Step one - load video and select ROI from a frame
% Step two - loop through frames and average the RGB channels on each frame
% in the ROI (takes a long time, alternative is to load whole movie not
% enough memory, probably a good middle ground)
% Step three - Filter the data in narrow band of possible heart rates (this
% leads to ringing artifacts when there are big changes in the video so
% this technique is sensitive to movement)
% Step four - FFT - 


clear all
close all

[filename, pathname] = uigetfile('*.*');

xyloObj = VideoReader([pathname, filename]);

segment_start = 1;
segment_end = xyloObj.NumberOfFrames;
step  = 1000/xyloObj.FrameRate;

%% Get Bounding Box (currently uses the 100th frame, can adjust)

frame_num = 1;
vidFrames = read(xyloObj,frame_num);
vidFrames = permute(vidFrames,[2,1,3,4]);
figure; image(vidFrames); axis image;
       rect = getrect;
       rectangle('Position',rect);
       rect = round(rect);



%% Extract mean in window

%make into loop here to grab frame, take mean, and discard
times = (step*segment_start:step:step*segment_end)/1000;
test = zeros(3,length(times));
for i_frame = segment_start:segment_end
    vidFrames = read(xyloObj,i_frame);
    vidFrames = permute(vidFrames,[2,1,3,4]);
    test(:,i_frame) = squeeze(mean(mean(vidFrames(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3),:,:),1),2));
    fprintf(['Frame ' num2str(i_frame) '. \n']);
end
figure; subplot(3,1,1); plot(times,test(1,:),'r',times,test(2,:),'g',times,test(3,:),'b');
xlabel('Time (s)');



%% Filter
test_filt  = test;
high_pass = .01;
low_pass = 5;
order = 2;
srate = xyloObj.FrameRate;
bandpass = [(high_pass*2)/srate, (low_pass*2)/srate];          % Bandwidth of bandpass filter
[Bbp,Abp] = butter(order,bandpass);                 % Generation of Xth order Butterworth highpass filter
for c = 1:3 %color channels
    test_filt(c,:) = FiltFiltM(Bbp,Abp,(test(c,:)));       % Butterworth bandpass filtering of YY
end
subplot(3,1,2); plot(times,test_filt(1,:),'r',times,test_filt(2,:),'g',times,test_filt(3,:),'b');
xlabel('Time (s)');



%% FFT
points = 2^14;
X = fft(test_filt',points);
Y = X.*conj(X)/points;
freq = srate*(0:(points/2)-1)/points;
freq = freq*60;
subplot(3,1,3); plot(freq,Y(1:points/2,1),'r',freq,Y(1:points/2,2),'g',freq,Y(1:points/2,3),'b');
xlabel('HR (bpm)')
xlim([0 300]);


%% Parafac analysis - can use to try to seprate out independent sources
% of variance, uses n-way toolbox, then do fft on that instead

% const=[1,0];
% [I,J]=size(test_filt);
% 
% 
% [Factors,it,SSerr,cor] = parafac(test_filt,3,[],const,[],[],[]);
% 
% A=Factors{1,1};
% B=Factors{1,2};
% figure; subplot(2,1,1); plot(times,B(:,1),'r',times,B(:,2),'g',times,B(:,3),'b');
% 
% X = fft(B,points);
% Y = X.*conj(X)/points;
% freq = srate*(0:(points/2)-1)/points;
% subplot(2,1,2); plot(freq,Y(1:points/2,1),'r',freq,Y(1:points/2,2),'g',freq,Y(1:points/2,3),'b');
% xlabel('Frequency (Hz)')







