function [err] = under_3bit_err_generator(column,row)
%UNTITLED4 이 함수의 요약 설명 위치
%   자세한 설명 위치
    rng(10);
    err = zeros(column,row);
for i = 1:column
   one_num = randi([0,3],1);
   % one_num = 0;
    for idx = 1:one_num
        one_position = randi([1,row],1);
        err(i,one_position) = 1;
    end
end

end
