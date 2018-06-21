function [d] = batch_AverageFrequencies(fname,script)

% Function to perform multiple pre-processing operations such as artefact
% rejection, time frequency decomposition, and averaging within a frequency
% band using SPM batch tools. The options within the batch should be
% modified depending on the question to investigate.
% Defaults:
% Average frequencies in the following bands:
% - Delta: 1-3 Hz
% - Theta: 4-7 Hz
% - Alpha: 8-12 Hz
% - Beta1: 13-29 Hz
% - Beta2: 30-39 Hz
% - Gamma: 40-69 Hz
% - HFB  : 70-170 Hz
% Inputs:
% - fname  : name of file(s) to process (SPM format)
% - script : name of batch script to call
% Output:
% - d      : cell array with final MEEG objects
%--------------------------------------------------------------------------
% Written by J. Schrouff, LBCN, Stanford, 10/28/2015

% Get inputs
% -------------------------------------------------------------------------
if nargin<1 || isempty(fname)
    fname = spm_select([1 Inf],'.mat', 'Select files to process',{},pwd,'.mat');
end

if nargin<2 || isempty(script)
    jobfile = {which('batch_AverageFrequencies_job.m')};
else
    jobfile = script;
end

% Perform artefact rejection and TF (Morlet wavelets)
% -------------------------------------------------------------------------
d = cell(size(fname,1),1);
for i = 1:size(fname,1)
    if i==1
        spm_jobman('initcfg')
        spm('defaults', 'EEG');
    end
    input_array{1} = {deblank(fname(i,:))};
    input_array{2} = {deblank(fname(i,:))};
    input_array{3} = {deblank(fname(i,:))};
    input_array{4} = {deblank(fname(i,:))};
    input_array{5} = {deblank(fname(i,:))};
    input_array{6} = {deblank(fname(i,:))};
    input_array{7} = {deblank(fname(i,:))};
    [out] = spm_jobman('run', jobfile,input_array{:});
    d{i} = out{end}.D;
end
