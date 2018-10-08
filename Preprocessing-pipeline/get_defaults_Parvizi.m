function [def]=get_defaults_Parvizi()

% function to load default values into scripts. Those values are specific
% to the Laboratory of Behavioral and Cognitive Neuroscience (Parvizi Lab,
% Stanford University).
%--------------------------------------------------------------------------
% Written by J. Schrouff, Laboratory of Behavioral and Cognitive
% Neuroscience, Stanford University, 10/21/2014.

def = struct();

% Default sampling rates
%--------------------------------------------------------------------------
def.TDTfsample = 1525.88; % default for >2012 TDT files
def.oldNKfsample  = 1000;    % default for clinical data
def.newNKfsample  = 1000;    % default for clinical data

% Default values for pre-processing
%--------------------------------------------------------------------------
def.new_fs = 500;
def.noise_freq = 60; %default line noise
def.lineband = 3;    % band to cut around line: freq-band:freq+band
def.nharmonics = 3; %Number of harmonics including 0

% Default values for bad channel detection
% -------------------------------------------------------------------------
def.varmult = 5; % overall variance on each channel
% def.stdmult = 100; % detection of 'jumps' on each channel, threshold in muV
def.stdmult = 3; % detection of 'jumps' on each channel
def.kurt_thresh = 3; % detection based on Kurtosis/skewness values

% Default value for event detection on diod
% -------------------------------------------------------------------------
def.ichan = 1; % for exported edf (new NK) data, the diod should be the second channel
def.fsample_diod = 24414.1; % sampling for TDT diod
def.thresh_dur = 0.01; % Minimum duration of an event (in seconds)

% Default values for epoching
% -------------------------------------------------------------------------
def.fieldons = 'start'; %epoch on the stimulus onset
def.fieldbc = 'start'; %baseline correction relative to onset
def.twbc = [-200 0]; %baseline of -200 to 0 ms around onset 
def.twepoch = [0 1000]; %epoch of 1s

% Default values for Hilbert Transform
% -------------------------------------------------------------------------
def.bands = [1 3;4 7; 8 12;13 39;40 70;70 175];
def.listrescale = {'LogR', 'Diff', 'Rel','Zscore', 'Log','LogEps', 'Sqrt'};
def.sc_baseline = [-Inf, 0];
def.sc_file = [];

% Default values for Smoothing
% -------------------------------------------------------------------------
def.smooth_win = 50/1000; % s


% Default values for reading SODATA files
% -------------------------------------------------------------------------

% MMR
def.MMR.skip_before = 12;
def.MMR.skip_after = 0;
def.MMR.thresh_dur = 0.01;
def.MMR.listcond = {'self-internal','other','self-external','autobio','math','rest'};

% VTCLoc
def.VTCLoc.skip_before = 5;
def.VTCLoc.skip_after = 0;
def.VTCLoc.thresh_dur = 0.01;
def.VTCLoc.listcond =  {'animals','faces','falsefonts','logos','numbers','places',...
        'spanish_words','words','persian_numbers'};
    
% Animal
def.Animal.skip_before = 12;
def.Animal.skip_after = 1;
def.Animal.thresh_dur = 0.01;
def.Animal.listcond = {'animal_F','animal_NF','bird_F','bird_NF','fish_F','fish_NF',...
        'human_F','human_NF','object','place','limbs'};
    
% category
def.category.skip_before = 12;  % 12
def.category.skip_after = 0;
def.category.thresh_dur = 0.01;
def.category.listcond =  {'words','pseodowords','tools','numbers','mammal_faces','mammal_bodies','bird_faces','bird_bodies' ...
    ,'human_faces','human_bodies','cars_front','logos','buildings','shapes','cars_sides','chairs','false_fonts','hands','natural_scenes' ...
    ,'scrambled_images'};
% Emotion faces
def.EmotionF.skip_before = 0;
def.EmotionF.skip_after = 0;
def.EmotionF.thresh_dur = 0.01;
def.EmotionF.listcond = {'Negative', 'Positive', 'Neutral', 'ITI', 'responses'};

%Race categorization
def.RACE_CAT.block = 'race';
def.RACE_CAT.skip_before = 0;
def.RACE_CAT.skip_after = 0;
def.RACE_CAT.thresh_dur = 0.01;
def.RACE_CAT.listcond = {'B','W','A'};

%Race
def.RACE.block = 'Active_Response';
def.RACE.skip_before = 0;
def.RACE.skip_after = 0;
def.RACE.thresh_dur = 0.01;
def.RACE.listcond = {'True-positive','True-negative','False-positive','False-negative'};

% RACE recall
def.RACE_RECALL.block = '';
def.RACE_RECALL.skip_before = 0;
def.RACE_RECALL.skip_after = 0;
def.RACE_RECALL.thresh_dur = 0.01;
def.RACE_RECALL.listcond = {'B','W','A'};

%Undefined
def.other.skip_before = 0;
def.other.skip_after = 0;
def.other.thresh_dur = 0.01;
def.other.listcond = {''};


def.ictalmemrecall.skip_before = 0;
def.ictalmemrecall.skip_after = 0;
def.ictalmemrecall.thresh_dur = 0.01;
def.ictalmemrecall.listcond = cell(1, 6);
def.ictalmemrecall.listcond{1} = 'Cond1';
def.ictalmemrecall.listcond{2} = 'Cond2';
def.ictalmemrecall.listcond{3} = 'Cond3';
def.ictalmemrecall.listcond{4} = 'Cond4';
def.ictalmemrecall.listcond{5} = 'ITI';
def.ictalmemrecall.listcond{6} = 'Conf';


def.ictalmemrecallnew.skip_before = 12;
def.ictalmemrecallnew.skip_after = 0;
def.ictalmemrecallnew.thresh_dur = 0.01;
def.ictalmemrecallnew.listcond = cell(1, 5);
def.ictalmemrecallnew.listcond{1} = 'Cond1';
def.ictalmemrecallnew.listcond{2} = 'Cond2';
def.ictalmemrecallnew.listcond{3} = 'Cond3';
def.ictalmemrecallnew.listcond{4} = 'Cond4';
def.ictalmemrecallnew.listcond{5} = 'Conf';

def.ictalcogtaskold.skip_before = 12;
def.ictalcogtaskold.skip_after = 0;
def.ictalcogtaskold.thresh_dur = 0.01;
def.ictalcogtaskold.listcond = cell(1, 2);
def.ictalcogtaskold.listcond{1} = 'Stim';
def.ictalcogtaskold.listcond{2} = 'ITI';

def.sponmem.skip_before = 0;
def.sponmem.skip_after = 0;
def.sponmem.thresh_dur = 0.01;
def.sponmem.listcond = cell(1, 3);
def.sponmem.listcond{1} = 'Cond1';
def.sponmem.listcond{2} = 'Cond2';
def.sponmem.listcond{3} = 'Cond3';


def.ictalcogbaselinecombined.skip_before = 0;
def.ictalcogbaselinecombined.skip_after = 0;
def.ictalcogbaselinecombined.thresh_dur = 0.01;
def.ictalcogbaselinecombined.listcond = cell(1, 2);
def.ictalcogbaselinecombined.listcond{1} = 'Stim';
def.ictalcogbaselinecombined.listcond{2} = 'ITI';

def.ictalcogrecallcombined.skip_before = 0;
def.ictalcogrecallcombined.skip_after = 0;
def.ictalcogrecallcombined.thresh_dur = 0.01;
def.ictalcogrecallcombined.listcond = cell(1, 4);
def.ictalcogrecallcombined.listcond{1} = 'Old';
def.ictalcogrecallcombined.listcond{2} = 'New';
def.ictalcogrecallcombined.listcond{3} = 'ITI';
def.ictalcogrecallcombined.listcond{4} = 'Conf';

def.ictalcogmem2.skip_before = 0;
def.ictalcogmem2.skip_after = 0;
def.ictalcogmem2.thresh_dur = 0.01;
def.ictalcogmem2.listcond = cell(1, 6);
def.ictalcogmem2.listcond{1} = 'Cond1';
def.ictalcogmem2.listcond{2} = 'Cond2';
def.ictalcogmem2.listcond{3} = 'Cond3';
def.ictalcogmem2.listcond{4} = 'Cond4';
def.ictalcogmem2.listcond{5} = 'ITI';
def.ictalcogmem2.listcond{6} = 'Conf';

def.emotiona_facelock.skip_before = 0;
def.emotiona_facelock.skip_after = 0;
def.emotiona_facelock.thresh_dur = 0.01;
def.emotiona_facelock.listcond = cell(1, 8);
def.emotiona_facelock.listcond{1} = 'ITI';
def.emotiona_facelock.listcond{2} = 'Cond1';
def.emotiona_facelock.listcond{3} = 'Cond2';
def.emotiona_facelock.listcond{4} = 'Cond3';
def.emotiona_facelock.listcond{5} = 'Negitive';
def.emotiona_facelock.listcond{6} = 'Positive';
def.emotiona_facelock.listcond{7} = 'Neutral';
def.emotiona_facelock.listcond{8} = 'Rsp';


