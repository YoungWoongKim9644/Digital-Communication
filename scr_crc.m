k = input('Enter the length of Msg Word');
n = input('Enter the length of Codeword');

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

%scrambling
msg  = Scrambler(info_bits,k);

 disp('msg_bits')
disp(msg)
G = cyclpoly(n,k,'max')
gx = poly2sym(G)
msg(1,end:end+(n-k)) = 0;

%parity bits generator
for idx = 1: size(msg,1)
    buffer = msg(idx,:);
    mx(idx) = poly2sym(buffer);
    [t,tmp_px] = gfdeconv(fliplr(msg(idx,:)),fliplr(G));
    
    while size(tmp_px) ~= n-k;
        tmp_px(end+1) = 0;
    end
    parity_bits(idx,1:size(tmp_px,2)) = fliplr(tmp_px);
end


msg = msg(:, 1: end -(n-k));
codeword = [parity_bits msg]
err = under_3bit_err_generator(8,n);

%receive
recv_bits = bitxor(codeword,err)

%syndrome
for idx = 1:size(recv_bits,1)
    [q,s] = gfdeconv(fliplr(recv_bits(idx,:)),fliplr(G));
    while size(s) ~= size(G)-1;
        s(end+1) = 0;
    end
    s = fliplr(s);
    disp('syndrome = ')
    disp(s)
    if isequal(s,[1 1 1 0])
        disp('1 activatied')
            recv_bits(idx,1) = recv_bits(idx,1) + 1;
            recv_bits(idx,1) = rem(recv_bits(idx,1),2);
    elseif  isequal(s,[0 1 1 1])   
        disp('2 activatied')
            recv_bits(idx,2) = recv_bits(idx,2) + 1;
            recv_bits(idx,2) = rem(recv_bits(idx,2),2);
    elseif  isequal(s,[1 1 0 1])     
        disp('3 activatied')
             recv_bits(idx,3) = recv_bits(idx,3) + 1;
            recv_bits(idx,3) = rem(recv_bits(idx,3),2);
    elseif  isequal(s,[1 0 0 0])  
        disp('4 activatied')
            recv_bits(idx,4) = recv_bits(idx,4) + 1;
            recv_bits(idx,4) = rem(recv_bits(idx,4),2);
    elseif  isequal(s,[0 1 0 0])     
        disp('5 activatied')
           recv_bits(idx,5) = recv_bits(idx,5) + 1;
            recv_bits(idx,5) = rem(recv_bits(idx,5),2);
    elseif  isequal(s,[0 0 1 0])   
        disp('6 activatied')
            recv_bits(idx,6) = recv_bits(idx,6) + 1;
            recv_bits(idx,6) = rem(recv_bits(idx,6),2);
    elseif  isequal(s,[0 0 0 1])    
        disp('7 activatied')
            recv_bits(idx,7) = recv_bits(idx,7) + 1;
            recv_bits(idx,7) = rem(recv_bits(idx,7),2);
    elseif  isequal(s,[0 0 1 1])   
        disp('8 activatied')
            recv_bits(idx,1) = recv_bits(idx,1) + 1;
            recv_bits(idx,1) = rem(recv_bits(idx,1),2);
             recv_bits(idx,3) = recv_bits(idx,3) + 1;
            recv_bits(idx,3) = rem(recv_bits(idx,3),2);
    elseif  isequal(s,[1 1 1 1])     
        disp('9 activatied')
         recv_bits(idx,2) = recv_bits(idx,2) + 1;
            recv_bits(idx,2) = rem(recv_bits(idx,2),2);     
        recv_bits(idx,4) = recv_bits(idx,4) + 1;
            recv_bits(idx,4) = rem(recv_bits(idx,4),2);
    elseif  isequal(s,[1 0 0 1])  
        disp('10 activatied')
            recv_bits(idx,3) = recv_bits(idx,3) + 1;
            recv_bits(idx,3) = rem(recv_bits(idx,3),2);
            recv_bits(idx,5) = recv_bits(idx,5) + 1;
            recv_bits(idx,5) = rem(recv_bits(idx,5),2);
    elseif  isequal(s,[1 0 1 0])     
        disp('11 activatied')
            recv_bits(idx,4) = recv_bits(idx,4) + 1;
            recv_bits(idx,4) = rem(recv_bits(idx,4),2);
            recv_bits(idx,6) = recv_bits(idx,6) + 1;
            recv_bits(idx,6) = rem(recv_bits(idx,6),2);
    elseif  isequal(s,[0 1 0 1])   
        disp('12 activatied')
            recv_bits(idx,5) = recv_bits(idx,5) + 1;
            recv_bits(idx,5) = rem(recv_bits(idx,5),2);
            recv_bits(idx,7) = recv_bits(idx,7) + 1;
            recv_bits(idx,7) = rem(recv_bits(idx,7),2);
    elseif  isequal(s,[1 1 0 0])    
        disp('13 activatied')
            recv_bits(idx,6) = recv_bits(idx,6) + 1;
            recv_bits(idx,6) = rem(recv_bits(idx,6),2);
            recv_bits(idx,1) = recv_bits(idx,1) + 1;
            recv_bits(idx,1) = rem(recv_bits(idx,1),2);
    elseif  isequal(s,[0 1 1 0])   
        disp('14 activatied')
            recv_bits(idx,7) = recv_bits(idx,7) + 1;
            recv_bits(idx,7) = rem(recv_bits(idx,7),2);
            recv_bits(idx,2) = recv_bits(idx,2) + 1;
            recv_bits(idx,2) = rem(recv_bits(idx,2),2);
    elseif  isequal(s,[1 0 1 1])    
        disp('15 activatied')
            recv_bits(idx,3) = recv_bits(idx,3) + 1;
            recv_bits(idx,3) = rem(recv_bits(idx,3),2);
             recv_bits(idx,6) = recv_bits(idx,6) + 1;
            recv_bits(idx,6) = rem(recv_bits(idx,6),2);
             recv_bits(idx,5) = recv_bits(idx,5) + 1;
            recv_bits(idx,5) = rem(recv_bits(idx,5),2);
    end
    
end

 recv_msg = recv_bits(:,[end-(k-1):end])   
 
disp('descrambled reg_output')
disp(Scrambler(recv_msg,k))
char(bin2dec(num2str(Scrambler(recv_msg,k))))