function [realValue, refValue] = runtimeMetric(data, taskName)
    %% runtimeMetric
    % Inputs:
    % - data
    % - taskName
    % 
    % Outputs:
    % - value
    % - refValue
    realValue = data.runTime;
    refValue = realValue;
end

