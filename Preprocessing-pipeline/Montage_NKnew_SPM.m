% List of open inputs
% Montage: File Name - cfg_files
% Montage: Montage file name - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'C:\Users\parvizilab\Codes\codes\ECoG_preprocessing_SPM\Montage_NKnew_SPM_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Montage: File Name - cfg_files
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % Montage: Montage file name - cfg_files
end
spm('defaults', 'EEG');
spm_jobman('run', jobs, inputs{:});
