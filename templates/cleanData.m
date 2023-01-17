function data = cleanData(data)
% Custom function to clean data; takes 'data' in the workspace (generated
% by prepData.m) as input.

%% Convert age to age group

p17 = find(data.age>=17 & data.age<=18);
p22 = find(data.age>=22 & data.age<=23);
p53 = find(data.age>=53);

data.age = num2cell(data.age);
data.age(p17) = {'P17-18'};
data.age(p22) = {'P22-23'};
data.age(p53) = {'>= P53'};
data.age = categorical(data.age);

clearvars("p17","p22","p53");

%% Remove unwanted recordings

% Remove unwanted conditions
dropConditions = {'msew' 'handled-ctrl' 'challenged-ctrl' 'challenged-lbn'};
data = data(~ismember(data.condition, dropConditions),:);
data.condition = removecats(data.condition);  % remove unused categories

% Remove P22-23
data = data(data.age~="P22-23",:);
data.age = removecats(data.age);   % remove unused categories

% Remove unmarked cells
data = data(data.cellType~="unmarked" & data.cellType~="tdtN",:);
data.cellType = removecats(data.cellType);   % remove unused categories

%% Recalculate bad readings of input resistance due to unstable recording
% - The corrected readings below were calculated from first 5 transient
%   traces instead of all traces:
%   In membraneProps.m, replace 'meanTrace = mean(traces,2)' with:
%   meanTrace = mean(traces(:,1:5),2);  

% input R was negative (-21726 MOhm)
data.inputR(data.fileName=="MW220124b_01.txt") = 561.8056;

% input R was a lot higher than other recordings (6745 MOhm)
data.inputR(data.fileName=="MW220125_02.txt") = 2.2424e+03;