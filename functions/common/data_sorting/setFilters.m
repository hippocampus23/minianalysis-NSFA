function filters = setFilters(fileIndex, filters)
%% Read variable values in 'fileIndex' & let user set values for filters.
% Man Ho Wong, University of Pittsburgh.
% -------------------------------------------------------------------------
% Input: - fileIndex : A table containing file info;
%                      can be imported from xlsx file by readIndex.m
%        - filters : - An empty struct OR
%                    - existing struct to modify
% Output: - filters : A struct with values of different variables stored in
%                     different fields; will be used in grouping data

%% Prompt user to set age range

AgePrompt = {'Enter minimum age (days):','Enter maximum age (days):'};
dlgtitle = 'Age range';

pass = false;
while pass == false

    % input box
    ageRange = str2double( inputdlg(AgePrompt, dlgtitle) );

    % if user clicked 'Cancel'
    if isempty(ageRange)
        filters = []; % return empty 'filters'
        return
    end

    % if user entered a non-numeric input or a negative number
    if isnan(ageRange(1)) || isnan(ageRange(2)) || prod(ageRange) < 0
        msg = sprintf('Age should be a positive number.\n');
        uiwait(warndlg(msg));
    else
        pass = true;
    end

end

filters.minAge = ageRange(1);  % Minimum age
filters.maxAge = ageRange(2);  % Maximum age

%% Prompt user to set other filters

% Read available variables in 'fileIndex' and select only categorical
% variables as filtering factors
varNames = fileIndex.Properties.VariableNames;
i = 1;
for k = 1:length(varNames)
    if class( fileIndex.(varNames{k})) == "categorical" && ...
       ~contains(varNames{k},'id','IgnoreCase',true)  % exclude variables related to ID
        factors{i} = varNames{k};
        i = i+1;
    end
end

nFactors = length(factors);
for k = 1:nFactors
    list = categories(fileIndex.(factors{k}));
    prompt = {['Select ' factors{k} '(s)'], ...
              'Press and hold ''Ctrl'' key to select multiple groups.',''};
    
    % get previous filter values (if exist) and preselect them in listdlg
    if ismember(factors{k},fieldnames(filters))
        initialVal = [];
        for n = 1:length(filters.(factors{k}))
            initialVal = [initialVal, ...
                          find(list == string(filters.(factors{k}){n}))];
        end
    else
        initialVal = 1;
    end
    
    [index,tf] = listdlg('PromptString', prompt, 'ListSize', [250,300], ...
                         'ListString', list, 'InitialValue',initialVal, ...
                         'OKString', 'Next');
    filters.(factors{k}) = list(index);
    % if user clicked 'Cancel'
    if tf == 0
        filters = []; % return empty 'filters'
        return 
    end
end

disp('<a href="matlab:openvar filters">Click here to review filters.</a>');