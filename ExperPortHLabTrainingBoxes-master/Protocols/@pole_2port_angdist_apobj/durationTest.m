
dur = zeros(9,1);
for ind = 303:311
    test = saved_history.RewardsSection_LastTrialEvents{ind}(:,3);
    dur(ind-302) = floor((test(end) - test(6))*310);
end
dur