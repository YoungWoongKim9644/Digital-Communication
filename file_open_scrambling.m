% 파일 열기 및 데이터 비트화 
fid = fopen('matfile.txt','r');
c = fread(fid, 10);
c = dec2bin(c,3);

info_bits = zeros(10,3);

for i= 1:10
    for j = 1:3
        if c(i,j) == '0'
            info_bits(i,j) = 0;
        elseif c(i,j) == '1'
            info_bits(i,j) = 1;
        end
    end
end
disp(info_bits)
% 레지스터 초기화 및 output 공간 생성
reg = zeros(2,18);
reg(:, 1:2:end) = 1;
output = zeros(50,8);

% 레지스터를 활용한 스크램블러 코드 만들기
for i = 1:size(info_bits,1)*size(info_bits,2)
    scr_code= reg(1,1)+reg(2,1);
    output(i) = mod(scr_code+info_bits(i),2);
    reg(1, 1:end-1) = reg(1, 2:end);
    reg(1,end) = mod(reg(1,1)+reg(1,8),2);
    
    reg(2, 1:end-1) = reg(2, 2:end);
    reg(2,end) = mod(reg(2,1)+reg(2,6)+reg(2,8)+reg(2,11),2);
    disp(reg(1,:))
end