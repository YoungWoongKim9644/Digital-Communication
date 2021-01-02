k = input('Enter the length of Msg Word');
n = input('Enter the length of Codeword');
P = input('Enter the Parity Matrix : ');
G = [P eye(k)]


% 파일 열기 및 데이터 비트화 
fid = fopen('matfile.txt','r');
c = fread(fid, 8,'uint8=>char')
c = dec2bin(c,k);

info_bits = zeros(8,k);

% str2bin transform
for i= 1:8
    for j = 1:k
        if c(i,j) == '0'
            info_bits(i,j) = 0;
        elseif c(i,j) == '1'
            info_bits(i,j) = 1;
        end
    end
end
disp('info_bits')
disp(info_bits)

msg_bits  = Scrambler(info_bits,k);

 disp('msg_bits')
disp(msg_bits)


codeword = XOR(msg_bits,G)
sym_idx = codeword(1:2:end)*2 + codeword(2:2:end);
sampled_sym = sampling(sym_idx,5);
tri_pulse_sym = tripulse(sampled_sym,5);

err = randerr(1,size(tri_pulse_sym,2),82);


% seed matching을 위한 작업
%err = under_3bit_err_generator(8,n+1);
%err(:,1) = [];


demod = demodulation(tri_pulse_sym+err,5);
recv_bits = sym2bit(demod);
recv_bits = reshape(recv_bits,[8,11]);
%receive
%recv_bits = bitxor(codeword,err)
%recv_bits = tri_pulse_sym + randi([0,1],
H = [eye(n-k) transpose(P)]
S = XOR(recv_bits,transpose(H))

%syndrome cases
for idx= 1:size(recv_bits,1)
    if isequal(S(idx,:),[1 0 1])
        disp('1 activatied')
            recv_bits(idx,6) = recv_bits(idx,6) + 1;
            recv_bits(idx,6) = rem(recv_bits(idx,6),2);
    elseif  isequal(S(idx,:),[0 1 1])   
        disp('2 activatied')
            recv_bits(idx,5) = recv_bits(idx,5) + 1;
            recv_bits(idx,5) = rem(recv_bits(idx,5),2);
    elseif  isequal(S(idx,:),[1 1 0])     
        disp('3 activatied')
             recv_bits(idx,4) = recv_bits(idx,4) + 1;
            recv_bits(idx,4) = rem(recv_bits(idx,4),2);
    elseif  isequal(S(idx,:),[0 0 1])  
        disp('4 activatied')
            recv_bits(idx,3) = recv_bits(idx,3) + 1;
            recv_bits(idx,3) = rem(recv_bits(idx,3),2);
    elseif  isequal(S(idx,:),[0 1 0])     
        disp('5 activatied')
           recv_bits(idx,2) = recv_bits(idx,2) + 1;
            recv_bits(idx,2) = rem(recv_bits(idx,2),2);
    elseif  isequal(S(idx,:),[1 0 0])   
        disp('6 activatied')
            recv_bits(idx,1) = recv_bits(idx,1) + 1;
            recv_bits(idx,1) = rem(recv_bits(idx,1),2);
    elseif  isequal(S(idx,:),[1 1 1])    
        disp('7 activatied')
            recv_bits(idx,2) = recv_bits(idx,2) + 1;
            recv_bits(idx,2) = rem(recv_bits(idx,2),2);
            recv_bits(idx,5) = recv_bits(idx,5) + 1;
            recv_bits(idx,5) = rem(recv_bits(idx,5),2);
    end
    
end

recv_msg = recv_bits(:,[end-(k-1):end])
disp('descrambled reg_output')
disp(Scrambler(recv_msg,k))
char(bin2dec(num2str(Scrambler(recv_msg,k))))