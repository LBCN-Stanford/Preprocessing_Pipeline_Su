% List of open inputs
% Named Input: Input Variable - cfg_entry
% Named Input: Input Variable - cfg_entry
% Time-frequency analysis: File Name - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'C:\Users\parvizilab\Codes\codes\ECoG_preprocessing_SPM\Hilbert_Transform_SPM_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(3, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Named Input: Input Variable - cfg_entry
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % Named Input: Input Variable - cfg_entry
    inputs{3, crun} = MATLAB_CODE_TO_FILL_INPUT; % Time-frequency analysis: File Name - cfg_files
end
spm('defaults', 'EEG');
spm_jobman('run', jobs, inputs{:});
