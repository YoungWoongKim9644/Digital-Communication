k = input('Enter the length of Msg Word');
n = input('Enter the length of Codeword');
raised_cosine_filter = rcosfir(0.5,[-3 3], 8 ,1,'sqrt')
QPSK_single_BER = zeros(1,20);
QPSK_multi_BER= zeros(1,20);
QAM_single_BER= zeros(1,20);
QAM_multi_BER= zeros(1,20);

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



%symbol mapping + err

%------------------------Q P S K -------------------------%
codeword = reshape(codeword',[1,96])
qpsk_sym_idx = zeros(1,length(codeword)/2)
for i = 1:2:length(codeword)
    if codeword(i) == 0 && codeword(i+1) == 0
       qpsk_sym_idx(round(i/2)) = cosd(45) + 1j*sind(45)
    end
    if codeword(i) == 0 && codeword(i+1) == 1
        qpsk_sym_idx(round(i/2)) = cosd(135) + 1j*sind(135)
    end
    if codeword(i) == 1 && codeword(i+1) == 0
        qpsk_sym_idx(round(i/2)) = cosd(225) + 1j*sind(225)
    end
    if codeword(i) == 1 && codeword(i+1) == 1
        qpsk_sym_idx(round(i/2)) = cosd(315) + 1j*sind(315)
    end
    
end
%------------------------Q P S K -------------------------%


%------------------------1 6 - Q A M -------------------------%

codeword = reshape(codeword',[1,96])
qam_sym_idx = zeros(1,length(codeword)/4)
for i = 1:4:length(codeword)
    tmp = codeword(i:i+3)
    if isequal(tmp, [0 0 0 0])
        qam_sym_idx(ceil(i/4)) =(sqrt(5)/5)*(-2) + 1j*(sqrt(5)/5)*(2) 
    end
    if isequal(tmp, [0 0 0 1])
        qam_sym_idx(ceil(i/4)) =(sqrt(5)/5)*(-1) + 1j*(sqrt(5)/5)*(2)
    end
    if isequal(tmp, [0 0 1 0])
        qam_sym_idx(ceil(i/4)) =(sqrt(5)/5)*(1) + 1j*(sqrt(5)/5)*(2)
    end
    if isequal(tmp, [0 0 1 1])
        qam_sym_idx(ceil(i/4)) =(sqrt(5)/5)*(2) + 1j*(sqrt(5)/5)*(2)
    end
    if isequal(tmp, [0 1 0 0])
        qam_sym_idx(ceil(i/4)) =(sqrt(5)/5)*(-2) + 1j*(sqrt(5)/5)*(1) 
    end
    if isequal(tmp, [0 1 0 1])
        qam_sym_idx(ceil(i/4)) =(sqrt(5)/5)*(-1) + 1j*(sqrt(5)/5)*(1)
    end
    if isequal(tmp, [0 1 1 0])
        qam_sym_idx(ceil(i/4)) =(sqrt(5)/5)*(1) + 1j*(sqrt(5)/5)*(1)
    end
    if isequal(tmp, [0 1 1 1])
        qam_sym_idx(ceil(i/4)) =(sqrt(5)/5)*(2) + 1j*(sqrt(5)/5)*(1)
    end
    if isequal(tmp, [1 0 0 0])
        qam_sym_idx(ceil(i/4)) =(sqrt(5)/5)*(-2) + 1j*(sqrt(5)/5)*(-1) 
    end
    if isequal(tmp, [1 0 0 1])
        qam_sym_idx(ceil(i/4)) =(sqrt(5)/5)*(-1) + 1j*(sqrt(5)/5)*(-1)
    end
    if isequal(tmp, [1 0 1 0])
        qam_sym_idx(ceil(i/4)) =(sqrt(5)/5)*(1) + 1j*(sqrt(5)/5)*(-1)
    end
    if isequal(tmp, [1 0 1 1])
        qam_sym_idx(ceil(i/4)) =(sqrt(5)/5)*(2) + 1j*(sqrt(5)/5)*(-1)
    end
    if isequal(tmp, [1 1 0 0])
        qam_sym_idx(ceil(i/4)) =(sqrt(5)/5)*(-2) + 1j*(sqrt(5)/5)*(-2) 
    end
    if isequal(tmp, [1 1 0 1])
        qam_sym_idx(ceil(i/4)) =(sqrt(5)/5)*(-1) + 1j*(sqrt(5)/5)*(-2)
    end
    if isequal(tmp, [1 1 1 0])
        qam_sym_idx(ceil(i/4)) =(sqrt(5)/5)*(1) + 1j*(sqrt(5)/5)*(-2)
    end
    if isequal(tmp, [1 1 1 1])
        qam_sym_idx(ceil(i/4)) =(sqrt(5)/5)*(2) + 1j*(sqrt(5)/5)*(-2)
    end
    
    
end

%------------------------1 6 - Q A M-------------------------%


QPSK_in_sym_idx(1:8:8*length(qpsk_sym_idx))=qpsk_sym_idx %over sampling
QAM_in_sym_idx(1:8:8*length(qam_sym_idx))=qam_sym_idx %over sampling

QPSK_filtered_sym = conv(QPSK_in_sym_idx, raised_cosine_filter)
QAM_filtered_sym = conv(QAM_in_sym_idx, raised_cosine_filter)


multi_ch = [1 0 0 0.5]

QPSK_ch_out = QPSK_filtered_sym
QPSK_mul_ch_out = conv(multi_ch,QPSK_filtered_sym)
QAM_ch_out = QAM_filtered_sym
QAM_mul_ch_out = conv(multi_ch,QAM_filtered_sym)

SNR_i  = (-100:10:100)

for i = 1:length(SNR_i)

    QPSK_single_noise = addGaussianNoise(QPSK_ch_out,SNR_i(i));
    QPSK_multi_noise = addGaussianNoise(QPSK_mul_ch_out,SNR_i(i));
    QAM_single_noise = addGaussianNoise(QAM_ch_out,SNR_i(i));
    QAM_multi_noise = addGaussianNoise(QAM_mul_ch_out,SNR_i(i));
    
%------------------receiver------------------------------


   QPSK_single_recv_sym = conv(QPSK_single_noise,raised_cosine_filter);
   QPSK_multi_recv_sym = conv(QPSK_multi_noise,raised_cosine_filter);
   QAM_single_recv_sym = conv(QAM_single_noise,raised_cosine_filter);
   QAM_multi_recv_sym = conv(QAM_multi_noise,raised_cosine_filter);
   
   
   %------------------delay 제거------------------------------
   QPSK_single_recv_sym = QPSK_single_recv_sym(49:8:end-48);
   QPSK_multi_recv_sym = QPSK_multi_recv_sym(49:8:end-48);
   QAM_single_recv_sym = QAM_single_recv_sym(49:8:end-48);
   QAM_multi_recv_sym = QAM_multi_recv_sym(49:8:end-48);
   
     %-------------------receiving sampling-----------------
    QPSK_single_sampled_sym = QPSK_single_recv_sym
    QPSK_multi_sampled_sym =QPSK_multi_recv_sym
    QAM_single_sampled_sym = QAM_single_recv_sym
    QAM_multi_sampled_sym =  QAM_multi_recv_sym
     

    %-------------------demodulation---------------------
    QPSK_single_rx_bit_out = zeros(1, length(QPSK_single_sampled_sym)*2);
    
    for i=1:length(QPSK_single_sampled_sym)
        if(rad2deg(angle(QPSK_single_sampled_sym(i))) >= 90)
            QPSK_single_rx_bit_out(2*i-1) = 1;
            QPSK_single_rx_bit_out(2*i) = 0;
        elseif(rad2deg(angle(QPSK_single_sampled_sym(i))) >= 0)
            QPSK_single_rx_bit_out(2*i-1) = 0;
            QPSK_single_rx_bit_out(2*i) = 0;
        elseif(rad2deg(angle(QPSK_single_sampled_sym(i))) >= -90)
            QPSK_single_rx_bit_out(2*i-1) = 0;
            QPSK_single_rx_bit_out(2*i) = 1;
        else
            QPSK_single_rx_bit_out(2*i-1) = 1;
            QPSK_single_rx_bit_out(2*i) = 1;
        end
    end
    
    
    QPSK_multi_rx_bit_out =zeros(1, length(QPSK_multi_sampled_sym)*2);
    
    for i=1:length(QPSK_multi_sampled_sym)
        if(rad2deg(angle(QPSK_multi_sampled_sym(i))) >= 90)
            QPSK_multi_rx_bit_out(2*i-1) = 1;
            QPSK_multi_rx_bit_out(2*i) = 0;
        elseif(rad2deg(angle(QPSK_multi_sampled_sym(i))) >= 0)
            QPSK_multi_rx_bit_out(2*i-1) = 0;
            QPSK_multi_rx_bit_out(2*i) = 0;
        elseif(rad2deg(angle(QPSK_multi_sampled_sym(i))) >= -90)
           QPSK_multi_rx_bit_out(2*i-1) = 0;
            QPSK_multi_rx_bit_out(2*i) = 1;
        else
            QPSK_multi_rx_bit_out(2*i-1) = 1;
            QPSK_multi_rx_bit_out(2*i) = 1;
        end
    end
    
    
    
    QAM_single_rx_bit_out = zeros(1, length(QAM_single_sampled_sym)*2);
    
         QAM_single_sampled_sym = QAM_single_sampled_sym * sqrt(10);
        rx_sym_dec = zeros(1, length(QAM_single_sampled_sym)*2);
        
        for i=1:length(QAM_single_sampled_sym)
            if(abs(QAM_single_sampled_sym(i)) >= (3*sqrt(2) + sqrt(10)) / 2)
                if(rad2deg(angle(QAM_single_sampled_sym(i))) >= 90)
                    rx_sym_dec(2*i-1) = 0;
                    rx_sym_dec(2*i) = 3;
                elseif(rad2deg(angle(QAM_single_sampled_sym(i))) >= 0)
                    rx_sym_dec(2*i-1) = 3;
                    rx_sym_dec(2*i) = 3;
                elseif(rad2deg(angle(QAM_single_sampled_sym(i))) >= -90)
                    rx_sym_dec(2*i-1) = 3;
                    rx_sym_dec(2*i) = 0;
                else
                    rx_sym_dec(2*i-1) = 0;
                    rx_sym_dec(2*i) = 0;
                end
            elseif(abs(QAM_single_sampled_sym(i)) >= (sqrt(10) + sqrt(2)) / 2)
                if(rad2deg(angle(QAM_single_sampled_sym(i))) >= 135)
                    rx_sym_dec(2*i-1) = 0;
                    rx_sym_dec(2*i) = 2;
                elseif(rad2deg(angle(QAM_single_sampled_sym(i))) >= 90)
                    rx_sym_dec(2*i-1) = 1;
                    rx_sym_dec(2*i) = 3;
                elseif(rad2deg(angle(QAM_single_sampled_sym(i))) >= 45)
                    rx_sym_dec(2*i-1) = 2;
                    rx_sym_dec(2*i) = 3;
                elseif(rad2deg(angle(QAM_single_sampled_sym(i))) >= 0)
                    rx_sym_dec(2*i-1) = 3;
                    rx_sym_dec(2*i) = 2;
                elseif(rad2deg(angle(QAM_single_sampled_sym(i))) >= -45)
                    rx_sym_dec(2*i-1) = 3;
                    rx_sym_dec(2*i) = 1;
                elseif(rad2deg(angle(QAM_single_sampled_sym(i))) >= -90)
                    rx_sym_dec(2*i-1) = 2;
                    rx_sym_dec(2*i) = 0;
                elseif(rad2deg(angle(QAM_single_sampled_sym(i))) >= -135)
                    rx_sym_dec(2*i-1) = 1;
                    rx_sym_dec(2*i) = 0;
                else
                    rx_sym_dec(2*i-1) = 0;
                    rx_sym_dec(2*i) = 1;
                end
            else
                if(rad2deg(angle(QAM_single_sampled_sym(i))) >= 90)
                    rx_sym_dec(2*i-1) = 1;
                    rx_sym_dec(2*i) = 2;
                elseif(rad2deg(angle(QAM_single_sampled_sym(i))) >= 0)
                    rx_sym_dec(2*i-1) = 2;
                    rx_sym_dec(2*i) = 2;
                elseif(rad2deg(angle(QAM_single_sampled_sym(i))) >= -90)
                    rx_sym_dec(2*i-1) = 2;
                    rx_sym_dec(2*i) = 1;
                else
                    rx_sym_dec(2*i-1) = 1;
                    rx_sym_dec(2*i) = 1;
                end
            end
        end
        QAM_single_rx_bit_out = de2bi(rx_sym_dec); % 2진수로 변경
    
    
    QAM_multi_rx_bit_out = zeros(1, length(QAM_multi_sampled_sym)*2);
    
        
         QAM_multi_sampled_sym = QAM_multi_sampled_sym * sqrt(10);
        multi_rx_sym_dec = zeros(1, length(QAM_multi_sampled_sym)*2);
        
        for i=1:length(QAM_multi_sampled_sym)
            if(abs(QAM_multi_sampled_sym(i)) >= (3*sqrt(2) + sqrt(10)) / 2)
                if(rad2deg(angle(QAM_multi_sampled_sym(i))) >= 90)
                    multi_rx_sym_dec(2*i-1) = 0;
                    multi_rx_sym_dec(2*i) = 3;
                elseif(rad2deg(angle(QAM_multi_sampled_sym(i))) >= 0)
                    multi_rx_sym_dec(2*i-1) = 3;
                    multi_rx_sym_dec(2*i) = 3;
                elseif(rad2deg(angle(QAM_multi_sampled_sym(i))) >= -90)
                    multi_rx_sym_dec(2*i-1) = 3;
                    multi_rx_sym_dec(2*i) = 0;
                else
                    multi_rx_sym_dec(2*i-1) = 0;
                    multi_rx_sym_dec(2*i) = 0;
                end
            elseif(abs(QAM_multi_sampled_sym(i)) >= (sqrt(10) + sqrt(2)) / 2)
                if(rad2deg(angle(QAM_multi_sampled_sym(i))) >= 135)
                    multi_rx_sym_dec(2*i-1) = 0;
                    multi_rx_sym_dec(2*i) = 2;
                elseif(rad2deg(angle(QAM_multi_sampled_sym(i))) >= 90)
                    multi_rx_sym_dec(2*i-1) = 1;
                    multi_rx_sym_dec(2*i) = 3;
                elseif(rad2deg(angle(QAM_multi_sampled_sym(i))) >= 45)
                    multi_rx_sym_dec(2*i-1) = 2;
                    multi_rx_sym_dec(2*i) = 3;
                elseif(rad2deg(angle(QAM_multi_sampled_sym(i))) >= 0)
                    multi_rx_sym_dec(2*i-1) = 3;
                    multi_rx_sym_dec(2*i) = 2;
                elseif(rad2deg(angle(QAM_multi_sampled_sym(i))) >= -45)
                    multi_rx_sym_dec(2*i-1) = 3;
                    multi_rx_sym_dec(2*i) = 1;
                elseif(rad2deg(angle(QAM_multi_sampled_sym(i))) >= -90)
                    multi_rx_sym_dec(2*i-1) = 2;
                    multi_rx_sym_dec(2*i) = 0;
                elseif(rad2deg(angle(QAM_multi_sampled_sym(i))) >= -135)
                    multi_rx_sym_dec(2*i-1) = 1;
                    multi_rx_sym_dec(2*i) = 0;
                else
                    multi_rx_sym_dec(2*i-1) = 0;
                    multi_rx_sym_dec(2*i) = 1;
                end
            else
                if(rad2deg(angle(QAM_multi_sampled_sym(i))) >= 90)
                    multi_rx_sym_dec(2*i-1) = 1;
                    multi_rx_sym_dec(2*i) = 2;
                elseif(rad2deg(angle(QAM_multi_sampled_sym(i))) >= 0)
                    multi_rx_sym_dec(2*i-1) = 2;
                    multi_rx_sym_dec(2*i) = 2;
                elseif(rad2deg(angle(QAM_multi_sampled_sym(i))) >= -90)
                    multi_rx_sym_dec(2*i-1) = 2;
                    multi_rx_sym_dec(2*i) = 1;
                else
                    multi_rx_sym_dec(2*i-1) = 1;
                    multi_rx_sym_dec(2*i) = 1;
                end
            end
        end
        QAM_multi_rx_bit_out = de2bi(multi_rx_sym_dec); % 2진수로 변경
     



QAM_single_rx_bit_out = reshape(QAM_single_rx_bit_out.', 1, []); % col vector로 변경
QAM_multi_rx_bit_out = reshape(QAM_multi_rx_bit_out.', 1, []); % col vector로 변경
QPSK_single_rx_bit_out = reshape(QPSK_single_rx_bit_out.', 1, []); % col vector로 변경
QPSK_multi_rx_bit_out = reshape(QPSK_multi_rx_bit_out.', 1, []); % col vector로 변경

QAM_single_rx_bit_out =  reshape(QAM_single_rx_bit_out, [8, 12]); % 처음 msg의 matrix 차원으로 변경 
QAM_multi_rx_bit_out = reshape(QAM_multi_rx_bit_out,[8, 12]); % 처음 msg의 matrix 차원으로 변경 
QPSK_single_rx_bit_out = reshape(QPSK_single_rx_bit_out,[8, 12]); % 처음 msg의 matrix 차원으로 변경 
QPSK_multi_rx_bit_out = reshape(QPSK_multi_rx_bit_out,[8, 12]); % 처음 msg의 matrix 차원으로 변경 



%demod = demodulation(tri_pulse_sym+err,5);
%QPSK_single_recv_bits = sym2bit(QPSK_single_sampled_sym);
%QPSK_multi_recv_bits = sym2bit(QPSK_multi_sampled_sym);
%QAM_single_recv_bits = sym2bit(QAM_single_sampled_sym);
%QAM_multi_recv_bits = sym2bit(QAM_multi_sampled_sym);

%QPSK_single_recv_bits = reshape(QPSK_single_recv_bits,[8,12]);
%QPSK_multi_recv_bits = reshape(QPSK_multi_recv_bits,[8,12]);
%QAM_single_recv_bits = reshape(QAM_single_recv_bits,[8,12]);
%QAM_multi_recv_bits = reshape(QAM_multi_recv_bits,[8,12]);



%syndrome
for idx = 1:size(QPSK_single_rx_bit_out,1)
    [q,s] = gfdeconv(fliplr(QPSK_single_rx_bit_out(idx,:)),fliplr(G));
    while size(s) ~= size(G)-1;
        s(end+1) = 0;
    end
    s = fliplr(s);
    disp('syndrome = ');
    disp(s);
    if isequal(s,[1 1 1 0])
        disp('1 activatied');
            QPSK_single_rx_bit_out(idx,1) = QPSK_single_rx_bit_out(idx,1) + 1;
            QPSK_single_rx_bit_out(idx,1) = rem(QPSK_single_rx_bit_out(idx,1),2);
    elseif  isequal(s,[0 1 1 1])   
        disp('2 activatied')
            QPSK_single_rx_bit_out(idx,2) = QPSK_single_rx_bit_out(idx,2) + 1;
            QPSK_single_rx_bit_out(idx,2) = rem(QPSK_single_rx_bit_out(idx,2),2);
    elseif  isequal(s,[1 1 0 1])     
        disp('3 activatied')
             QPSK_single_rx_bit_out(idx,3) = QPSK_single_rx_bit_out(idx,3) + 1;
            QPSK_single_rx_bit_out(idx,3) = rem(QPSK_single_rx_bit_out(idx,3),2);
    elseif  isequal(s,[1 0 0 0])  
        disp('4 activatied')
            QPSK_single_rx_bit_out(idx,4) = QPSK_single_rx_bit_out(idx,4) + 1;
            QPSK_single_rx_bit_out(idx,4) = rem(QPSK_single_rx_bit_out(idx,4),2);
    elseif  isequal(s,[0 1 0 0])     
        disp('5 activatied')
           QPSK_single_rx_bit_out(idx,5) = QPSK_single_rx_bit_out(idx,5) + 1;
            QPSK_single_rx_bit_out(idx,5) = rem(QPSK_single_rx_bit_out(idx,5),2);
    elseif  isequal(s,[0 0 1 0])   
        disp('6 activatied')
            QPSK_single_rx_bit_out(idx,6) = QPSK_single_rx_bit_out(idx,6) + 1;
            QPSK_single_rx_bit_out(idx,6) = rem(QPSK_single_rx_bit_out(idx,6),2);
    elseif  isequal(s,[0 0 0 1])    
        disp('7 activatied')
            QPSK_single_rx_bit_out(idx,7) = QPSK_single_rx_bit_out(idx,7) + 1;
            QPSK_single_rx_bit_out(idx,7) = rem(QPSK_single_rx_bit_out(idx,7),2);
    elseif  isequal(s,[0 0 1 1])   
        disp('8 activatied')
            QPSK_single_rx_bit_out(idx,1) = QPSK_single_rx_bit_out(idx,1) + 1;
            QPSK_single_rx_bit_out(idx,1) = rem(QPSK_single_rx_bit_out(idx,1),2);
             QPSK_single_rx_bit_out(idx,3) = QPSK_single_rx_bit_out(idx,3) + 1;
            QPSK_single_rx_bit_out(idx,3) = rem(QPSK_single_rx_bit_out(idx,3),2);
    elseif  isequal(s,[1 1 1 1])     
        disp('9 activatied')
         QPSK_single_rx_bit_out(idx,2) = QPSK_single_rx_bit_out(idx,2) + 1;
            QPSK_single_rx_bit_out(idx,2) = rem(QPSK_single_rx_bit_out(idx,2),2);     
        QPSK_single_rx_bit_out(idx,4) = QPSK_single_rx_bit_out(idx,4) + 1;
            QPSK_single_rx_bit_out(idx,4) = rem(QPSK_single_rx_bit_out(idx,4),2);
    elseif  isequal(s,[1 0 0 1])  
        disp('10 activatied')
            QPSK_single_rx_bit_out(idx,3) = QPSK_single_rx_bit_out(idx,3) + 1;
            QPSK_single_rx_bit_out(idx,3) = rem(QPSK_single_rx_bit_out(idx,3),2);
            QPSK_single_rx_bit_out(idx,5) = QPSK_single_rx_bit_out(idx,5) + 1;
            QPSK_single_rx_bit_out(idx,5) = rem(QPSK_single_rx_bit_out(idx,5),2);
    elseif  isequal(s,[1 0 1 0])     
        disp('11 activatied')
            QPSK_single_rx_bit_out(idx,4) = QPSK_single_rx_bit_out(idx,4) + 1;
            QPSK_single_rx_bit_out(idx,4) = rem(QPSK_single_rx_bit_out(idx,4),2);
            QPSK_single_rx_bit_out(idx,6) = QPSK_single_rx_bit_out(idx,6) + 1;
            QPSK_single_rx_bit_out(idx,6) = rem(QPSK_single_rx_bit_out(idx,6),2);
    elseif  isequal(s,[0 1 0 1])   
        disp('12 activatied')
            QPSK_single_rx_bit_out(idx,5) = QPSK_single_rx_bit_out(idx,5) + 1;
            QPSK_single_rx_bit_out(idx,5) = rem(QPSK_single_rx_bit_out(idx,5),2);
            QPSK_single_rx_bit_out(idx,7) = QPSK_single_rx_bit_out(idx,7) + 1;
            QPSK_single_rx_bit_out(idx,7) = rem(QPSK_single_rx_bit_out(idx,7),2);
    elseif  isequal(s,[1 1 0 0])    
        disp('13 activatied')
            QPSK_single_rx_bit_out(idx,6) = QPSK_single_rx_bit_out(idx,6) + 1;
            QPSK_single_rx_bit_out(idx,6) = rem(QPSK_single_rx_bit_out(idx,6),2);
            QPSK_single_rx_bit_out(idx,1) = QPSK_single_rx_bit_out(idx,1) + 1;
            QPSK_single_rx_bit_out(idx,1) = rem(QPSK_single_rx_bit_out(idx,1),2);
    elseif  isequal(s,[0 1 1 0])   
        disp('14 activatied')
            QPSK_single_rx_bit_out(idx,7) = QPSK_single_rx_bit_out(idx,7) + 1;
            QPSK_single_rx_bit_out(idx,7) = rem(QPSK_single_rx_bit_out(idx,7),2);
            QPSK_single_rx_bit_out(idx,2) = QPSK_single_rx_bit_out(idx,2) + 1;
            QPSK_single_rx_bit_out(idx,2) = rem(QPSK_single_rx_bit_out(idx,2),2);
    elseif  isequal(s,[1 0 1 1])    
        disp('15 activatied')
            QPSK_single_rx_bit_out(idx,3) = QPSK_single_rx_bit_out(idx,3) + 1;
            QPSK_single_rx_bit_out(idx,3) = rem(QPSK_single_rx_bit_out(idx,3),2);
             QPSK_single_rx_bit_out(idx,6) = QPSK_single_rx_bit_out(idx,6) + 1;
            QPSK_single_rx_bit_out(idx,6) = rem(QPSK_single_rx_bit_out(idx,6),2);
             QPSK_single_rx_bit_out(idx,5) = QPSK_single_rx_bit_out(idx,5) + 1;
            QPSK_single_rx_bit_out(idx,5) = rem(QPSK_single_rx_bit_out(idx,5),2);
    end
    
end
 QPSK_single_recv_msg = QPSK_single_rx_bit_out(:,[end-(k-1):end]);   
  
for idx = 1:size(QPSK_multi_rx_bit_out,1)
    [q,s] = gfdeconv(fliplr(QPSK_multi_rx_bit_out(idx,:)),fliplr(G));
    while size(s) ~= size(G)-1;
        s(end+1) = 0;
    end
    s = fliplr(s);
    disp('syndrome = ');
    disp(s);
    if isequal(s,[1 1 1 0])
        disp('1 activatied');
            QPSK_multi_rx_bit_out(idx,1) = QPSK_multi_rx_bit_out(idx,1) + 1;
            QPSK_multi_rx_bit_out(idx,1) = rem(QPSK_multi_rx_bit_out(idx,1),2);
    elseif  isequal(s,[0 1 1 1])   
        disp('2 activatied')
            QPSK_multi_rx_bit_out(idx,2) = QPSK_multi_rx_bit_out(idx,2) + 1;
            QPSK_multi_rx_bit_out(idx,2) = rem(QPSK_multi_rx_bit_out(idx,2),2);
    elseif  isequal(s,[1 1 0 1])     
        disp('3 activatied')
             QPSK_multi_rx_bit_out(idx,3) = QPSK_multi_rx_bit_out(idx,3) + 1;
            QPSK_multi_rx_bit_out(idx,3) = rem(QPSK_multi_rx_bit_out(idx,3),2);
    elseif  isequal(s,[1 0 0 0])  
        disp('4 activatied')
            QPSK_multi_rx_bit_out(idx,4) = QPSK_multi_rx_bit_out(idx,4) + 1;
            QPSK_multi_rx_bit_out(idx,4) = rem(QPSK_multi_rx_bit_out(idx,4),2);
    elseif  isequal(s,[0 1 0 0])     
        disp('5 activatied')
           QPSK_multi_rx_bit_out(idx,5) = QPSK_multi_rx_bit_out(idx,5) + 1;
            QPSK_multi_rx_bit_out(idx,5) = rem(QPSK_multi_rx_bit_out(idx,5),2);
    elseif  isequal(s,[0 0 1 0])   
        disp('6 activatied')
            QPSK_multi_rx_bit_out(idx,6) = QPSK_multi_rx_bit_out(idx,6) + 1;
            QPSK_multi_rx_bit_out(idx,6) = rem(QPSK_multi_rx_bit_out(idx,6),2);
    elseif  isequal(s,[0 0 0 1])    
        disp('7 activatied')
            QPSK_multi_rx_bit_out(idx,7) = QPSK_multi_rx_bit_out(idx,7) + 1;
            QPSK_multi_rx_bit_out(idx,7) = rem(QPSK_multi_rx_bit_out(idx,7),2);
    elseif  isequal(s,[0 0 1 1])   
        disp('8 activatied')
            QPSK_multi_rx_bit_out(idx,1) = QPSK_multi_rx_bit_out(idx,1) + 1;
            QPSK_multi_rx_bit_out(idx,1) = rem(QPSK_multi_rx_bit_out(idx,1),2);
             QPSK_multi_rx_bit_out(idx,3) = QPSK_multi_rx_bit_out(idx,3) + 1;
            QPSK_multi_rx_bit_out(idx,3) = rem(QPSK_multi_rx_bit_out(idx,3),2);
    elseif  isequal(s,[1 1 1 1])     
        disp('9 activatied')
         QPSK_multi_rx_bit_out(idx,2) = QPSK_multi_rx_bit_out(idx,2) + 1;
            QPSK_multi_rx_bit_out(idx,2) = rem(QPSK_multi_rx_bit_out(idx,2),2);     
        QPSK_multi_rx_bit_out(idx,4) = QPSK_multi_rx_bit_out(idx,4) + 1;
            QPSK_multi_rx_bit_out(idx,4) = rem(QPSK_multi_rx_bit_out(idx,4),2);
    elseif  isequal(s,[1 0 0 1])  
        disp('10 activatied')
            QPSK_multi_rx_bit_out(idx,3) = QPSK_multi_rx_bit_out(idx,3) + 1;
            QPSK_multi_rx_bit_out(idx,3) = rem(QPSK_multi_rx_bit_out(idx,3),2);
            QPSK_multi_rx_bit_out(idx,5) = QPSK_multi_rx_bit_out(idx,5) + 1;
            QPSK_multi_rx_bit_out(idx,5) = rem(QPSK_multi_rx_bit_out(idx,5),2);
    elseif  isequal(s,[1 0 1 0])     
        disp('11 activatied')
            QPSK_multi_rx_bit_out(idx,4) = QPSK_multi_rx_bit_out(idx,4) + 1;
            QPSK_multi_rx_bit_out(idx,4) = rem(QPSK_multi_rx_bit_out(idx,4),2);
            QPSK_multi_rx_bit_out(idx,6) = QPSK_multi_rx_bit_out(idx,6) + 1;
            QPSK_multi_rx_bit_out(idx,6) = rem(QPSK_multi_rx_bit_out(idx,6),2);
    elseif  isequal(s,[0 1 0 1])   
        disp('12 activatied')
            QPSK_multi_rx_bit_out(idx,5) = QPSK_multi_rx_bit_out(idx,5) + 1;
            QPSK_multi_rx_bit_out(idx,5) = rem(QPSK_multi_rx_bit_out(idx,5),2);
            QPSK_multi_rx_bit_out(idx,7) = QPSK_multi_rx_bit_out(idx,7) + 1;
            QPSK_multi_rx_bit_out(idx,7) = rem(QPSK_multi_rx_bit_out(idx,7),2);
    elseif  isequal(s,[1 1 0 0])    
        disp('13 activatied')
            QPSK_multi_rx_bit_out(idx,6) = QPSK_multi_rx_bit_out(idx,6) + 1;
            QPSK_multi_rx_bit_out(idx,6) = rem(QPSK_multi_rx_bit_out(idx,6),2);
            QPSK_multi_rx_bit_out(idx,1) = QPSK_multi_rx_bit_out(idx,1) + 1;
            QPSK_multi_rx_bit_out(idx,1) = rem(QPSK_multi_rx_bit_out(idx,1),2);
    elseif  isequal(s,[0 1 1 0])   
        disp('14 activatied')
            QPSK_multi_rx_bit_out(idx,7) = QPSK_multi_rx_bit_out(idx,7) + 1;
            QPSK_multi_rx_bit_out(idx,7) = rem(QPSK_multi_rx_bit_out(idx,7),2);
            QPSK_multi_rx_bit_out(idx,2) = QPSK_multi_rx_bit_out(idx,2) + 1;
            QPSK_multi_rx_bit_out(idx,2) = rem(QPSK_multi_rx_bit_out(idx,2),2);
    elseif  isequal(s,[1 0 1 1])    
        disp('15 activatied')
            QPSK_multi_rx_bit_out(idx,3) = QPSK_multi_rx_bit_out(idx,3) + 1;
            QPSK_multi_rx_bit_out(idx,3) = rem(QPSK_multi_rx_bit_out(idx,3),2);
             QPSK_multi_rx_bit_out(idx,6) = QPSK_multi_rx_bit_out(idx,6) + 1;
            QPSK_multi_rx_bit_out(idx,6) = rem(QPSK_multi_rx_bit_out(idx,6),2);
             QPSK_multi_rx_bit_out(idx,5) = QPSK_multi_rx_bit_out(idx,5) + 1;
            QPSK_multi_rx_bit_out(idx,5) = rem(QPSK_multi_rx_bit_out(idx,5),2);
    end
    
end
 QPSK_multi_recv_msg = QPSK_multi_rx_bit_out(:,[end-(k-1):end]);   

for idx = 1:size(QAM_single_rx_bit_out,1)
    [q,s] = gfdeconv(fliplr(QAM_single_rx_bit_out(idx,:)),fliplr(G));
    while size(s) ~= size(G)-1;
        s(end+1) = 0;
    end
    s = fliplr(s);
    disp('syndrome = ');
    disp(s);
    if isequal(s,[1 1 1 0])
        disp('1 activatied');
            QAM_single_rx_bit_out(idx,1) = QAM_single_rx_bit_out(idx,1) + 1;
            QAM_single_rx_bit_out(idx,1) = rem(QAM_single_rx_bit_out(idx,1),2);
    elseif  isequal(s,[0 1 1 1])   
        disp('2 activatied')
            QAM_single_rx_bit_out(idx,2) = QAM_single_rx_bit_out(idx,2) + 1;
            QAM_single_rx_bit_out(idx,2) = rem(QAM_single_rx_bit_out(idx,2),2);
    elseif  isequal(s,[1 1 0 1])     
        disp('3 activatied')
             QAM_single_rx_bit_out(idx,3) = QAM_single_rx_bit_out(idx,3) + 1;
            QAM_single_rx_bit_out(idx,3) = rem(QAM_single_rx_bit_out(idx,3),2);
    elseif  isequal(s,[1 0 0 0])  
        disp('4 activatied')
            QAM_single_rx_bit_out(idx,4) = QAM_single_rx_bit_out(idx,4) + 1;
            QAM_single_rx_bit_out(idx,4) = rem(QAM_single_rx_bit_out(idx,4),2);
    elseif  isequal(s,[0 1 0 0])     
        disp('5 activatied')
           QAM_single_rx_bit_out(idx,5) = QAM_single_rx_bit_out(idx,5) + 1;
            QAM_single_rx_bit_out(idx,5) = rem(QAM_single_rx_bit_out(idx,5),2);
    elseif  isequal(s,[0 0 1 0])   
        disp('6 activatied')
            QAM_single_rx_bit_out(idx,6) = QAM_single_rx_bit_out(idx,6) + 1;
            QAM_single_rx_bit_out(idx,6) = rem(QAM_single_rx_bit_out(idx,6),2);
    elseif  isequal(s,[0 0 0 1])    
        disp('7 activatied')
            QAM_single_rx_bit_out(idx,7) = QAM_single_rx_bit_out(idx,7) + 1;
            QAM_single_rx_bit_out(idx,7) = rem(QAM_single_rx_bit_out(idx,7),2);
    elseif  isequal(s,[0 0 1 1])   
        disp('8 activatied')
            QAM_single_rx_bit_out(idx,1) = QAM_single_rx_bit_out(idx,1) + 1;
            QAM_single_rx_bit_out(idx,1) = rem(QAM_single_rx_bit_out(idx,1),2);
             QAM_single_rx_bit_out(idx,3) = QAM_single_rx_bit_out(idx,3) + 1;
            QAM_single_rx_bit_out(idx,3) = rem(QAM_single_rx_bit_out(idx,3),2);
    elseif  isequal(s,[1 1 1 1])     
        disp('9 activatied')
         QAM_single_rx_bit_out(idx,2) = QAM_single_rx_bit_out(idx,2) + 1;
            QAM_single_rx_bit_out(idx,2) = rem(QAM_single_rx_bit_out(idx,2),2);     
        QAM_single_rx_bit_out(idx,4) = QAM_single_rx_bit_out(idx,4) + 1;
            QAM_single_rx_bit_out(idx,4) = rem(QAM_single_rx_bit_out(idx,4),2);
    elseif  isequal(s,[1 0 0 1])  
        disp('10 activatied')
            QAM_single_rx_bit_out(idx,3) = QAM_single_rx_bit_out(idx,3) + 1;
            QAM_single_rx_bit_out(idx,3) = rem(QAM_single_rx_bit_out(idx,3),2);
            QAM_single_rx_bit_out(idx,5) = QAM_single_rx_bit_out(idx,5) + 1;
            QAM_single_rx_bit_out(idx,5) = rem(QAM_single_rx_bit_out(idx,5),2);
    elseif  isequal(s,[1 0 1 0])     
        disp('11 activatied')
            QAM_single_rx_bit_out(idx,4) = QAM_single_rx_bit_out(idx,4) + 1;
            QAM_single_rx_bit_out(idx,4) = rem(QAM_single_rx_bit_out(idx,4),2);
            QAM_single_rx_bit_out(idx,6) = QAM_single_rx_bit_out(idx,6) + 1;
            QAM_single_rx_bit_out(idx,6) = rem(QAM_single_rx_bit_out(idx,6),2);
    elseif  isequal(s,[0 1 0 1])   
        disp('12 activatied')
            QAM_single_rx_bit_out(idx,5) = QAM_single_rx_bit_out(idx,5) + 1;
            QAM_single_rx_bit_out(idx,5) = rem(QAM_single_rx_bit_out(idx,5),2);
            QAM_single_rx_bit_out(idx,7) = QAM_single_rx_bit_out(idx,7) + 1;
            QAM_single_rx_bit_out(idx,7) = rem(QAM_single_rx_bit_out(idx,7),2);
    elseif  isequal(s,[1 1 0 0])    
        disp('13 activatied')
            QAM_single_rx_bit_out(idx,6) = QAM_single_rx_bit_out(idx,6) + 1;
            QAM_single_rx_bit_out(idx,6) = rem(QAM_single_rx_bit_out(idx,6),2);
            QAM_single_rx_bit_out(idx,1) = QAM_single_rx_bit_out(idx,1) + 1;
            QAM_single_rx_bit_out(idx,1) = rem(QAM_single_rx_bit_out(idx,1),2);
    elseif  isequal(s,[0 1 1 0])   
        disp('14 activatied')
            QAM_single_rx_bit_out(idx,7) = QAM_single_rx_bit_out(idx,7) + 1;
            QAM_single_rx_bit_out(idx,7) = rem(QAM_single_rx_bit_out(idx,7),2);
            QAM_single_rx_bit_out(idx,2) = QAM_single_rx_bit_out(idx,2) + 1;
            QAM_single_rx_bit_out(idx,2) = rem(QAM_single_rx_bit_out(idx,2),2);
    elseif  isequal(s,[1 0 1 1])    
        disp('15 activatied')
            QAM_single_rx_bit_out(idx,3) = QAM_single_rx_bit_out(idx,3) + 1;
            QAM_single_rx_bit_out(idx,3) = rem(QAM_single_rx_bit_out(idx,3),2);
             QAM_single_rx_bit_out(idx,6) = QAM_single_rx_bit_out(idx,6) + 1;
            QAM_single_rx_bit_out(idx,6) = rem(QAM_single_rx_bit_out(idx,6),2);
             QAM_single_rx_bit_out(idx,5) = QAM_single_rx_bit_out(idx,5) + 1;
            QAM_single_rx_bit_out(idx,5) = rem(QAM_single_rx_bit_out(idx,5),2);
    end
    
end
 QAM_single_recv_msg = QAM_single_rx_bit_out(:,[end-(k-1):end]);   

for idx = 1:size(QAM_multi_rx_bit_out,1)
    [q,s] = gfdeconv(fliplr(QAM_multi_rx_bit_out(idx,:)),fliplr(G));
    while size(s) ~= size(G)-1;
        s(end+1) = 0;
    end
    s = fliplr(s);
    disp('syndrome = ');
    disp(s);
    if isequal(s,[1 1 1 0])
        disp('1 activatied');
            QAM_multi_rx_bit_out(idx,1) = QAM_multi_rx_bit_out(idx,1) + 1;
            QAM_multi_rx_bit_out(idx,1) = rem(QAM_multi_rx_bit_out(idx,1),2);
    elseif  isequal(s,[0 1 1 1])   
        disp('2 activatied')
            QAM_multi_rx_bit_out(idx,2) = QAM_multi_rx_bit_out(idx,2) + 1;
            QAM_multi_rx_bit_out(idx,2) = rem(QAM_multi_rx_bit_out(idx,2),2);
    elseif  isequal(s,[1 1 0 1])     
        disp('3 activatied')
             QAM_multi_rx_bit_out(idx,3) = QAM_multi_rx_bit_out(idx,3) + 1;
            QAM_multi_rx_bit_out(idx,3) = rem(QAM_multi_rx_bit_out(idx,3),2);
    elseif  isequal(s,[1 0 0 0])  
        disp('4 activatied')
            QAM_multi_rx_bit_out(idx,4) = QAM_multi_rx_bit_out(idx,4) + 1;
            QAM_multi_rx_bit_out(idx,4) = rem(QAM_multi_rx_bit_out(idx,4),2);
    elseif  isequal(s,[0 1 0 0])     
        disp('5 activatied')
           QAM_multi_rx_bit_out(idx,5) = QAM_multi_rx_bit_out(idx,5) + 1;
            QAM_multi_rx_bit_out(idx,5) = rem(QAM_multi_rx_bit_out(idx,5),2);
    elseif  isequal(s,[0 0 1 0])   
        disp('6 activatied')
            QAM_multi_rx_bit_out(idx,6) = QAM_multi_rx_bit_out(idx,6) + 1;
            QAM_multi_rx_bit_out(idx,6) = rem(QAM_multi_rx_bit_out(idx,6),2);
    elseif  isequal(s,[0 0 0 1])    
        disp('7 activatied')
            QAM_multi_rx_bit_out(idx,7) = QAM_multi_rx_bit_out(idx,7) + 1;
            QAM_multi_rx_bit_out(idx,7) = rem(QAM_multi_rx_bit_out(idx,7),2);
    elseif  isequal(s,[0 0 1 1])   
        disp('8 activatied')
            QAM_multi_rx_bit_out(idx,1) = QAM_multi_rx_bit_out(idx,1) + 1;
            QAM_multi_rx_bit_out(idx,1) = rem(QAM_multi_rx_bit_out(idx,1),2);
             QAM_multi_rx_bit_out(idx,3) = QAM_multi_rx_bit_out(idx,3) + 1;
            QAM_multi_rx_bit_out(idx,3) = rem(QAM_multi_rx_bit_out(idx,3),2);
    elseif  isequal(s,[1 1 1 1])     
        disp('9 activatied')
         QAM_multi_rx_bit_out(idx,2) = QAM_multi_rx_bit_out(idx,2) + 1;
            QAM_multi_rx_bit_out(idx,2) = rem(QAM_multi_rx_bit_out(idx,2),2);     
        QAM_multi_rx_bit_out(idx,4) = QAM_multi_rx_bit_out(idx,4) + 1;
            QAM_multi_rx_bit_out(idx,4) = rem(QAM_multi_rx_bit_out(idx,4),2);
    elseif  isequal(s,[1 0 0 1])  
        disp('10 activatied')
            QAM_multi_rx_bit_out(idx,3) = QAM_multi_rx_bit_out(idx,3) + 1;
            QAM_multi_rx_bit_out(idx,3) = rem(QAM_multi_rx_bit_out(idx,3),2);
            QAM_multi_rx_bit_out(idx,5) = QAM_multi_rx_bit_out(idx,5) + 1;
            QAM_multi_rx_bit_out(idx,5) = rem(QAM_multi_rx_bit_out(idx,5),2);
    elseif  isequal(s,[1 0 1 0])     
        disp('11 activatied')
            QAM_multi_rx_bit_out(idx,4) = QAM_multi_rx_bit_out(idx,4) + 1;
            QAM_multi_rx_bit_out(idx,4) = rem(QAM_multi_rx_bit_out(idx,4),2);
            QAM_multi_rx_bit_out(idx,6) = QAM_multi_rx_bit_out(idx,6) + 1;
            QAM_multi_rx_bit_out(idx,6) = rem(QAM_multi_rx_bit_out(idx,6),2);
    elseif  isequal(s,[0 1 0 1])   
        disp('12 activatied')
            QAM_multi_rx_bit_out(idx,5) = QAM_multi_rx_bit_out(idx,5) + 1;
            QAM_multi_rx_bit_out(idx,5) = rem(QAM_multi_rx_bit_out(idx,5),2);
            QAM_multi_rx_bit_out(idx,7) = QAM_multi_rx_bit_out(idx,7) + 1;
            QAM_multi_rx_bit_out(idx,7) = rem(QAM_multi_rx_bit_out(idx,7),2);
    elseif  isequal(s,[1 1 0 0])    
        disp('13 activatied')
            QAM_multi_rx_bit_out(idx,6) = QAM_multi_rx_bit_out(idx,6) + 1;
            QAM_multi_rx_bit_out(idx,6) = rem(QAM_multi_rx_bit_out(idx,6),2);
            QAM_multi_rx_bit_out(idx,1) = QAM_multi_rx_bit_out(idx,1) + 1;
            QAM_multi_rx_bit_out(idx,1) = rem(QAM_multi_rx_bit_out(idx,1),2);
    elseif  isequal(s,[0 1 1 0])   
        disp('14 activatied')
            QAM_multi_rx_bit_out(idx,7) = QAM_multi_rx_bit_out(idx,7) + 1;
            QAM_multi_rx_bit_out(idx,7) = rem(QAM_multi_rx_bit_out(idx,7),2);
            QAM_multi_rx_bit_out(idx,2) = QAM_multi_rx_bit_out(idx,2) + 1;
            QAM_multi_rx_bit_out(idx,2) = rem(QAM_multi_rx_bit_out(idx,2),2);
    elseif  isequal(s,[1 0 1 1])    
        disp('15 activatied')
            QAM_multi_rx_bit_out(idx,3) = QAM_multi_rx_bit_out(idx,3) + 1;
            QAM_multi_rx_bit_out(idx,3) = rem(QAM_multi_rx_bit_out(idx,3),2);
             QAM_multi_rx_bit_out(idx,6) = QAM_multi_rx_bit_out(idx,6) + 1;
            QAM_multi_rx_bit_out(idx,6) = rem(QAM_multi_rx_bit_out(idx,6),2);
             QAM_multi_rx_bit_out(idx,5) = QAM_multi_rx_bit_out(idx,5) + 1;
            QAM_multi_rx_bit_out(idx,5) = rem(QAM_multi_rx_bit_out(idx,5),2);
    end
    
end
 QAM_multi_recv_msg = QAM_multi_rx_bit_out(:,[end-(k-1):end]);   


 QPSK_single_output_reg = Scrambler(QPSK_single_recv_msg,k);
 QPSK_multi_output_reg = Scrambler(QPSK_multi_recv_msg,k);
 QAM_single_output_reg = Scrambler(QAM_single_recv_msg,k);
 QAM_multi_output_reg = Scrambler(QAM_multi_recv_msg,k);
 
 QPSK_single_output = QPSK_single_output_reg;
 QPSK_multi_output = QPSK_multi_output_reg;
 QAM_single_output = QAM_single_output_reg;
 QAM_multi_output = QAM_multi_output_reg;
 
 
%disp('descrambled reg_output');
%disp(QPSK_single_output)
%disp(QPSK_multi_output)
%disp(QAM_single_output)
%disp(QAM_multi_output)

QPSK_single_BER(i) = biterr(msg,QPSK_single_output);
QPSK_multi_BER(i) = biterr(msg,QPSK_multi_output);
QAM_single_BER(i) = biterr(msg,QAM_single_output);
QAM_multi_BER(i) = biterr(msg,QAM_multi_output);

end 
