# matlab_video_hr

 VideoAnalysis.m - Kyle Mathewson, UAlberta, March 2018 

 this loads a video and analyzes a subsection of the video over time to extract average red green and blue channel values in an ROI.  

 Step one - load video and select ROI from a frame 

 Step two - loop through frames and average the RGB channels on each frame in the ROI (takes a long time, alternative is to load whole movie not enough memory, probably a good middle ground) 

 Step three - Filter the data in narrow band of possible heart rates (this leads to ringing artifacts when there are big changes in the video so this technique is sensitive to movement)
 
 Step four - FFT - 
