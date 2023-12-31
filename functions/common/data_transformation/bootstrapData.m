function resample = bootstrapData(data, nBoot, nResample, jitter)
%% Bootstrap an 1-column array of data and add simulated jitter(optional).
% Data points will be sampled from the input data randomly with
% replacement. Users have the option to add jitter (random z-score times
% the coefficient variance of each data point).
% -------------------------------------------------------------------------
% Input: - data : an one-column array of data points
%        - sd : standard deviation of input data
%        - nBoot : number of bootstrap runs
%        - nResample : number of data points to be sampled from input data
%        - jitter : add simulated jitter to resampled data points
% -------------------------------------------------------------------------
% Output: - resample : bootstrapped data
% -------------------------------------------------------------------------
% Example: bootstrap tau of the first recording in decayReport
% data = decayReport.events{1}.tau;
% 
% resample = bootstrapData(data, sd, 100, 500, true);

%%
has_negative = any(data<0);          % check if data has negative values
sd = std(data);                      % get S.D. of the data
resample = zeros(nResample, nBoot);  % Create an nResample-by-nBoot array
                                     %   to store bootstrapped data
for b= 1:nBoot
    % Random resampling
    resample(:,b) = randsample(data,nResample,1);
    % Simulate jitter if requested by user
    if jitter == true
        % Generate a list of z-scores for each datapoint to simulate jitter
        % jitter is z*(sd/mean)
        z = zeros(nResample,1);
        for i = 1:nResample
            % Adding negative jitter may generate negative values. Check if
            % data allows negative values. If yes, lower limit of z will
            % just be 95% CI boundary (-1.96); if not, it will be a value
            % that won't generate a -'ve jitter larger than the datapoint
            if has_negative
                z_LowLim = -1.96;
            else
                % jitter is z*(sd/mean), it should be greater than -mean
                z_LowLim = - resample(i,b)/(sd/resample(i,b));
            end
            % Generate a random z-score from normal distribution; repeat if
            % it falls outside 95% confidence interval (+/- 1.96) or
            % smaller than a value that generates negative datapoint
            z(i) = randn;
            while z(i) > 1.96 || z(i) < z_LowLim
                z(i) = randn;
            end
        end
        % Get coefficient of variance (SD normalized to each data point)
        cv = sd./resample(:,b);
        % Add jitter to bootstrapped data
        %   each data point's jitter = random z-score*cv of each data point
        resample(:,b) = resample(:,b) + z.*cv;
    end
end

%% Under development: using event S.D. to simulate jitter

% lowLim = decayReport.events{1}.('tau lowLim');
% upLim = decayReport.events{1}.('tau upLim');
% nObs = decayReport.events{1}.nObs;

% observation = [data, lowLim, upLim, nObs];  % empirical obsercations and their CIs
% nObserv = height(observation);   % number of observations
% 
% resample = zeros(nResample, nBoot);  % Create an nResample-by-nBoot array
%                                      %   to store bootstrapped data
% 
% % Run bootstrap:
% %   1. Generate a list of random integers (1 to nOBserv) w/ size of nObserv
% %      -> resamplingIdx
% %   2. Use resamplingIdx to get a random sample of the observation
% %      -> resample
% %   3. Add noise to resample if requested:
% 
% if jitter == true
%     for b= 1:nBoot
%         resamplingIdx = randi([1,nObserv],nResample,1);   
%         reLowLim = observation(resamplingIdx, 2);        
%         reUpLim  = observation(resamplingIdx, 3);
%         reNObs = observation(resamplingIdx, 4);
%         se = (reUpLim - reLowLim)/(2*1.96);
%         % sd = se.*sqrt(reNObs);
%         mu = (reUpLim + reLowLim)/2;
%         
%         z = zeros(nResample,1);
%         for i = 1:nResample
%             z(i) = randn;
%             while z(i) > 1.96 || z(i) < -1.96
%                 z(i) = randn;
%             end
%         end
%         resample(:,b) = mu + z.*se;
%     end
% else
%     for b= 1:nBoot
%         resamplingIdx = randi([1,nObserv],nResample,1);
%         resample(:,b) = observation(resamplingIdx, 1);
%     end
% end


end