function sortedData = importRecordings(idxPath,dataDir,sessionDir)
%% Import event table of every recording in a folder.
% Events will be sorted by time and iei of each event will be computed.
% Sorted data will be saved for further processing.
% Man Ho Wong, University of Pittsburgh.
% -------------------------------------------------------------------------
% Inputs: - idxPath : path of the file with info of each recording
%         - dataDir : path of the data directory
%         - sessionDir : path of the directory for this analysis session
% Output: - sortedData.mat will be saved in sessionDir for later use.
% Example of a path: 'C:\Users' (Windows: '\' or '/'; Mac: '/')

%% Read recording file info from idxPath and store info in 'sortedData'

sortedData = readIndex(idxPath);
sortedData.events{1} = [];   % add a column "events" for storing event data


%% Copy data in event files to 'sortedData'

fprintf('Importing data...')
nRecording = height(sortedData);
for f = 1:nRecording
    % import only the indicated files
    if sortedData.include(f) == 1
        % Read file and use file's column names directly
        fname = [dataDir '/' sortedData.fileName{f}];
        sortedData.events{f} = readtable(fname,'ReadVariableNames',true);
        % Sort events by time
        sortedData.events{f} = sortrows(sortedData.events{f},'Time_ms_','ascend');
        % Get iei of the first event
        sortedData.events{f}.iei(1) = sortedData.events{f}.Time_ms_(1);
        % Compute iei of the rest of the events
        sortedData.events{f}.iei(2:end) = diff(sortedData.events{f}.Time_ms_);
        % Remove first event
        sortedData.events{f}(1,:) = [];
    end
end

% Turn all MATLAB warnings
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
fprintf('Done!\n''sortedData'' was added to the Workspace.\n')

%% Save

fprintf('Saving data...')
save([sessionDir '/sortedData.mat'],'sortedData');
fprintf('Done!\nSorted data was saved as ''sortedData.mat'' in: \n%s\n',sessionDir);

end