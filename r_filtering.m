function [filterd_sym] = r_filtering(raised_cosine_filter,sym_idx)
%UNTITLED6 이 함수의 요약 설명 위치
%   자세한 설명 위치

filterd_sym = zeros(1,74)
tmps = zeros(1,74)
hold on
for i = 1: size(sym_idx,2)
    if i < 25
        tmps(1:24+i) =  sym_idx(i)*raised_cosine_filter(26-i:end)
        filterd_sym(1:24+i) = filterd_sym(1:24+i) + sym_idx(i)*raised_cosine_filter(26-i:end)
        plot(tmps(1:24+i))
    elseif i >= 25
        tmps(i-24:24+i) =  sym_idx(i)*raised_cosine_filter(1:end)
        filterd_sym(i-24:24+i) = filterd_sym(i-24:24+i) + sym_idx(i)*raised_cosine_filter(1:end)
        plot(tmps(i-24:24+i))
    end
end
filterd_sym = filterd_sym(1:48)
end

