function [sampled_idx] = sampling(symbol,sr)
sampled_idx = zeros(size(symbol));
tmp = repmat((symbol)',1,sr);

for i = 1:size(symbol,2)
    sampled_idx(sr*(i-1)+1:sr*i) = tmp(i,:);
end
