function [obj] = mark_as_complete(obj, ind)

ts = get_training_stages(obj);

ts{ind, obj.is_complete_COL} = 1;
delete_current_sphandles(obj, ind);

obj.training_stages = ts;
