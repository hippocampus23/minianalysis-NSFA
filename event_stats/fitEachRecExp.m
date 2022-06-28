function [allparams,allgof]= fitEachRecExp(groupedData,group)
% fitEachRecExp: Fit each recording of a group to exponential model.
% This function requires data organized in Man Ho's data structure (see
% analyzeMini.mlx). It runs the function ieifit on each recording of a
% user-defined group. Graphs and parameter values of exponential model
% for each recording are generated.

% Input:
%   groupedData: dataset containing grouped data (by default, this is
%                'groupedData' generated by analyzeMini.mlx)
%   group: name of the group in groupedData (e.g. 'maleControl')

% Output:
%   allparams and allgof are optional output arguments
%   allparams: parameters of exponential model
%              (column 1-3: freq, freq CI, number of analyzed events)
%              Note: freq unit is Hz; it is 1000*lambda of CDF
%              (lamda is same as reciprocal of IEI, whose unit is ms)
%   allgof: goodness-of-fit results otained by comparing data to
%           exponential model with MATLAB function kstest2
%           (column 1-3: null hypothesis decision, p value, KS statistic)
%   
%   The function generates:
%   - screen output: number of analyzed events and lambda of each recording
%   - figures containing plots of the fitted data for each recording;
%   - ieistats_all.mat containing allparams, allgof, allfiles (file names
%     of recordings) for the group.
%   - The above files are saved in ../analysis/exponFitting/groupName/

% Note: This function was adapted from run_ieifit.m to fit Man Ho's data
% structure. 

%% Read data and initialize variables

data = groupedData.events{group};
allfiles=data.fileName(:,1);
allparams=zeros(height(data),3);
allgof=zeros(height(data),3);

%threshold: event filtering thresholds (4 numbers):
%           {min iei, [min rise time, max rise time], min amplitude}
%           by default: {0, [0 99], 0} (should include all events)
threshold = {0, [0 99], 0}; 

outputDir = ['analysis/exponFitting/' char(group) '/'];
if ~isfolder(outputDir)
    mkdir(outputDir);
end

%% Fit each recording to exponential model and save outputs

for iRecording=1:height(data)
    % Fit exponential model
    [allparams(iRecording,:),allgof(iRecording,:)]= ...
        ieifit(table2array(data.events{iRecording}),threshold);
    % Save plot of interest
    allFigs = findobj('Type','figure'); % Get the list of all opened figures
    currFigs = allFigs(1:4); % figures made by ieifit are the last 4 figures in the list allFigs
    % Show the figure windows when the fucntion is called in live script
    set(currFigs,'Visible','on');

    saveas(currFigs,[outputDir data.fileName{iRecording}(1:end-4) '_expon.fig']);
    close(currFigs);
end
save([outputDir 'ieistats_all.mat'],'allfiles','allparams','allgof');
addpath(genpath(outputDir)); % Add newly created folders/files to path
end
