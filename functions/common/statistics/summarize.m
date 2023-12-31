function summary = summarize(sortedData,groupIndex,fileIndex,dv)
%% Calculate summary statistics of the selected variable by groups.
% Man Ho Wong, University of Pittsburgh.
% -------------------------------------------------------------------------
% Input: - sortedData : Sorted recording data; 
%                        generated by importRecordings.m
%        - groupIndex : A table containing grouping info;
%                       can be generated with addGroup.m
%        - fileIndex : A table containing file info;
%                      can be imported from xlsx file by readIndex.m
%        - dv : String; dependent variable in sortedData to be summarized
% Output: - summary : A table containing the following statistics
%           - n_recordings (number of recordings)
%           - n_animals (number of recordings)
%           - mean
%           - median
%           - SD (standard deviation)
%           - CV (coefficient of variance)
%           - SEM (standard error of the mean)

%%

summary = table;

nGroups = height(groupIndex);
for g = 1:nGroups
    % Get data by group
    groupName = groupIndex.Properties.RowNames(g);
    filteredData = applyFilters(sortedData,groupIndex,fileIndex,groupName);
    % Statistics
    nRecordings = height(filteredData);
    nAnimals = length(unique(filteredData.mouseID));
    mean = groupsummary(filteredData.(dv),[],"mean");
    median = groupsummary(filteredData.(dv),[],"median");
    SD = groupsummary(filteredData.(dv),[],"std");
    CV = SD/mean;
    SEM = SD/sqrt(nRecordings);
    % Copy statistics to 'summary'
    summary{groupName,1:7} = {nRecordings,nAnimals,mean,median,SD,CV,SEM};
end
% Change 'summary' column names
statList = {'n_recordings','n_animals','mean','median','SD','CV','SEM'};
summary.Properties.VariableNames = statList;
fprintf('Done! The output contains the summary for the variable ''%s''.\n',dv);

end