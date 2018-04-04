% [labels] = get_labels(sma)

% Written by Carlos Brody October 2006

function [labels] = get_labels(sma)
   
   labels = sma.state_name_list;
   
   u = find(cell2mat(labels(:,3)));
   labels(u,2) = num2cell(cell2mat(labels(u,2))+rows(sma.states));
   
   labels = labels(:,1:2);
   