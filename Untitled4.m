k = input('Enter the length of Msg Word');
n = input('Enter the length of Codeword');
P = input('Enter the Parity Matrix : ');
G = [P eye(k)]
m = input('Enter the Msg Word: ')
Codeword = XOR(m,G)
err = [ 0 0 0 0 0 0 
      1 0 1 0 1 0
      0 0 0 1 0 0
      0 0 1 1 0 0
      1 1 1 1 1 0
      1 0 0 1 1 1
      0 1 0 0 1 0
      0 1 0 1 1 0
    ]
R = bitxor(Codeword,err);

H = [eye(n-k) transpose(P)]

S = XOR(R,transpose(H))

for idx= 1:size(R,1)
    if isequal(S(idx,:),[1 0 1])
        disp('1 activatied')
            R(idx,6) = R(idx,6) + 1;
            R(idx,6) = rem(R(idx,6),2);
    elseif  isequal(S(idx,:),[0 1 1])   
        disp('2 activatied')
            R(idx,5) = R(idx,5) + 1;
            R(idx,5) = rem(R(idx,5),2);
    elseif  isequal(S(idx,:),[1 1 0])     
        disp('3 activatied')
             R(idx,4) = R(idx,4) + 1;
            R(idx,4) = rem(R(idx,4),2);
    elseif  isequal(S(idx,:),[0 0 1])  
        disp('4 activatied')
            R(idx,3) = R(idx,3) + 1;
            R(idx,3) = rem(R(idx,3),2);
    elseif  isequal(S(idx,:),[0 1 0])     
        disp('5 activatied')
           R(idx,2) = R(idx,2) + 1;
            R(idx,2) = rem(R(idx,2),2);
    elseif  isequal(S(idx,:),[1 0 0])   
        disp('6 activatied')
            R(idx,1) = R(idx,1) + 1;
            R(idx,1) = rem(R(idx,1),2);
    elseif  isequal(S(idx,:),[1 1 1])    
        disp('7 activatied')
            R(idx,2) = R(idx,2) + 1;
            R(idx,2) = rem(R(idx,2),2);
            R(idx,5) = R(idx,5) + 1;
            R(idx,5) = rem(R(idx,5),2);
    end
    
end

recvm = R(:,[end-(k-1):end])