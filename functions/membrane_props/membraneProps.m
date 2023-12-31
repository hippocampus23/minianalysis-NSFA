function results = membraneProps(fname, transientDir, settings)
%% Compute a recording's passive membrane properties from capacitance transients.
%
% Man Ho Wong, University of Pittsburgh
% -------------------------------------------------------------------------
% File needed: capacitance transients (.txt)
%              - See instructions in ../../resources/prepare_data.md
%              - See examples in: ../../demo_data/transient_trace/
% -------------------------------------------------------------------------
% Input: - fname : file name of recording
%        - transientDir : directory of transient files (must end in '/')
%        - settings : a struct containing following fields
%          - settings.tp = test pulse size, mV
%          - settings.sFreq = sampling frequency, Hz
%          - settings.baseStartT : baseline start time, ms
%          - settings.baseEndT : baseline end time, ms
%          - settings.decayEndT : decay end time, ms
%          See comments in the code for more info.
% -------------------------------------------------------------------------
% Output: results : an array containing the following values:
%                   - series resistance
%                   - input resistance
%                   - time constant (tau)
%                   - membrane capacitance
%                   - r square of fitting

%% Load file

% Check if file exists
path = [transientDir '/' fname];

if ~available(path,'r')
    results = []; % return empty array for checking outside the function
    return
end

traces = readmatrix(path);  % read traces

%% Recording properties

tp = settings.tp;
sFreq = settings.sFreq;
baseStartT = settings.baseStartT;
baseEndT = settings.baseEndT;
decayEndT = settings.decayEndT;

baseStartPt = sFreq*baseStartT/1000 + 1;
baseEndPt = sFreq*baseEndT/1000;
decayEndPt = sFreq*decayEndT/1000;

%% Fitting preferences (optional)
% Fit decay to first order exponential function
% I = I_0*exp(-t/tau), where I_0 is initial current

opt = fitoptions('Method','NonlinearLeastSquares');
opt.Lower = [0,-10];          % Lower limits for I_0 and -1/tau
opt.Upper = [1000,0];         % Upper limits for I_0 and -1/tau
opt.StartPoint = [200,-0.5];  % Where algorithm starts to guess, optional

% reverse fitting startpoiont, lower and upper limits for I_0 if tp is -'ve
if tp < 0
    opt.Lower(1) = -opt.Upper(1);
    opt.Upper(1) = 0;
    opt.StartPoint(1) = -opt.StartPoint(1);
end

%% Zero each trace to its own baseline's mean value
baseMean = mean(traces(baseStartPt:baseEndPt,:),1);
traces = traces - baseMean;

%% Get the mean trace and its peak location

meanTrace = mean(traces,2);

% determine peak direction depending on tp
if tp < 0
    peakI = min(meanTrace);
else
    peakI = max(meanTrace);
end

peakIdx = find(meanTrace == peakI,1);
peakT = peakIdx/sFreq*1000;

%% fit mean trace and compute membrane properties

% Section of trace to fit, and corresponding time points
decayTrace = meanTrace(peakIdx:decayEndPt);
time(:,1) = 0:1/sFreq*1000:(decayEndT-peakT);

% Before fitting, zero decay phase to stable current at the end of decay
%   Use last 10 points of decay as stable I
stableI = mean(meanTrace(decayEndPt-9:decayEndPt)) - ...
          mean(meanTrace(baseStartPt:baseEndPt));
                                                     
decayTrace = decayTrace - stableI;                                        

% Fit decay to first order exponential function
% I = I_0*exp(-t/tau), where I_0 is initial current
[xfit gof] = fit(time, decayTrace, 'exp1', opt);

% Compute passive membrane properties
inputR = tp/stableI*1000;       % input resistance, MOhm
seriesR = tp/peakI*1000;        % series resistance, MOhm
tau = -1/xfit.b;                % decay time constant, ms
membraneC = tau/seriesR*1000;   % membrane capacitance, pF

results = [seriesR, inputR, tau, membraneC, gof.rsquare];

end