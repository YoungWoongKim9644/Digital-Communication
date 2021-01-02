function [tri_idx] = tripulse(sampled_idx,sr)
%UNTITLED2 이 함수의 요약 설명 위치
%   자세한 설명 위치

switch(sr)
    case 5
        tri = zeros(5);
        for i = 1:size(sampled_idx,2)/5
            tri = sampled_idx(5*(i-1)+1:5*i);
            tri(1) = 0;
            tri(5) = 0;
            tri(2) = tri(3)/2;
            tri(4) = tri(3)/2;
            sampled_idx(5*(i-1)+1:5*i) = tri;
        end
    case 7
        tri = zeros(7);
        for i = 1:size(sampled_idx,2)/7
        tri = sampled_idx(7*(i-1)+1:7*i);
        tri(1) = 0;
        tri(7) = 0;
        tri(3) = 2*tri(5)/3;
        tri(5) = 2*tri(3)/3;
        tri(2) = tri(5)/3;
        tri(6) = tri(3)/3;
        sampled_idx(7*(i-1)+1:7*i) = tri;
        end
end
tri_idx = sampled_idx;
