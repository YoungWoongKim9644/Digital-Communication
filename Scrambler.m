function [reg_output] = Scrambler(info_bits,k)

% 레지스터 초기화 및 output 공간 생성
reg = zeros(2,18);
reg(:, 1:2:end) = 1;
reg_output = zeros(8,k);

% 레지스터를 활용한 스크램블러 코드 만들기
for i = 1:size(info_bits,1)*size(info_bits,2)
    scr_code= reg(1,1)+reg(2,1);
    reg_output(i) = mod(scr_code+info_bits(i),2);
    reg(1, 1:end-1) = reg(1, 2:end);
    reg(1,end) = mod(reg(1,1)+reg(1,8),2);
    
    reg(2, 1:end-1) = reg(2, 2:end);
    reg(2,end) = mod(reg(2,1)+reg(2,6)+reg(2,8)+reg(2,11),2);
end

end
