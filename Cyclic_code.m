

k = input('Enter the length of Msg Word');
n = input('Enter the length of Codeword');
m = input('Enter the Msg Word: ')
G = cyclpoly(n,k,'max')
gx = poly2sym(G)
m(1,end:end+(n-k)) = 0;

for idx = 1: size(m,1)
    buffer = m(idx,:);
    mx(idx) = poly2sym(buffer);
    [t,tmp_px] = gfdeconv(fliplr(m(idx,:)),fliplr(G));
    
    while size(tmp_px) ~= n-k;
        tmp_px(end+1) = 0;
    end
    px(idx,1:size(tmp_px,2)) = fliplr(tmp_px);
end
m = m(:, 1: end -(n-k));
C = [px m]
err = [0 0 0 0 0 0 0 
     0 1 0 1 0 1 0
     0 0 0 0 1 0 0
     1 0 0 1 1 0 0
     0 1 1 1 1 1 0
     0 1 0 0 1 1 1
     1 0 1 0 0 1 0
     0 0 1 0 1 1 0
    ]
R = bitxor(C,err)
for idx = 1:size(R,1)
    [q,s] = gfdeconv(fliplr(R(idx,:)),fliplr(G));
    while size(s) ~= size(G)-1;
        s(end+1) = 0;
    end
    s = fliplr(s);
    disp('syndrome = ')
    disp(s)
    if isequal(s,[1 1 1 0])
        disp('1 activatied')
            R(idx,1) = R(idx,1) + 1;
            R(idx,1) = rem(R(idx,1),2);
    elseif  isequal(s,[0 1 1 1])   
        disp('2 activatied')
            R(idx,2) = R(idx,2) + 1;
            R(idx,2) = rem(R(idx,2),2);
    elseif  isequal(s,[1 1 0 1])     
        disp('3 activatied')
             R(idx,3) = R(idx,3) + 1;
            R(idx,3) = rem(R(idx,3),2);
    elseif  isequal(s,[1 0 0 0])  
        disp('4 activatied')
            R(idx,4) = R(idx,4) + 1;
            R(idx,4) = rem(R(idx,4),2);
    elseif  isequal(s,[0 1 0 0])     
        disp('5 activatied')
           R(idx,5) = R(idx,5) + 1;
            R(idx,5) = rem(R(idx,5),2);
    elseif  isequal(s,[0 0 1 0])   
        disp('6 activatied')
            R(idx,6) = R(idx,6) + 1;
            R(idx,6) = rem(R(idx,6),2);
    elseif  isequal(s,[0 0 0 1])    
        disp('7 activatied')
            R(idx,7) = R(idx,7) + 1;
            R(idx,7) = rem(R(idx,7),2);
    elseif  isequal(s,[0 0 1 1])   
        disp('8 activatied')
            R(idx,1) = R(idx,1) + 1;
            R(idx,1) = rem(R(idx,1),2);
             R(idx,3) = R(idx,3) + 1;
            R(idx,3) = rem(R(idx,3),2);
    elseif  isequal(s,[1 1 1 1])     
        disp('9 activatied')
         R(idx,2) = R(idx,2) + 1;
            R(idx,2) = rem(R(idx,2),2);     
        R(idx,4) = R(idx,4) + 1;
            R(idx,4) = rem(R(idx,4),2);
    elseif  isequal(s,[1 0 0 1])  
        disp('10 activatied')
            R(idx,3) = R(idx,3) + 1;
            R(idx,3) = rem(R(idx,3),2);
            R(idx,5) = R(idx,5) + 1;
            R(idx,5) = rem(R(idx,5),2);
    elseif  isequal(s,[1 0 1 0])     
        disp('11 activatied')
            R(idx,4) = R(idx,4) + 1;
            R(idx,4) = rem(R(idx,4),2);
            R(idx,6) = R(idx,6) + 1;
            R(idx,6) = rem(R(idx,6),2);
    elseif  isequal(s,[0 1 0 1])   
        disp('12 activatied')
            R(idx,5) = R(idx,5) + 1;
            R(idx,5) = rem(R(idx,5),2);
            R(idx,7) = R(idx,7) + 1;
            R(idx,7) = rem(R(idx,7),2);
    elseif  isequal(s,[1 1 0 0])    
        disp('13 activatied')
            R(idx,6) = R(idx,6) + 1;
            R(idx,6) = rem(R(idx,6),2);
            R(idx,1) = R(idx,1) + 1;
            R(idx,1) = rem(R(idx,1),2);
    elseif  isequal(s,[0 1 1 0])   
        disp('14 activatied')
            R(idx,7) = R(idx,7) + 1;
            R(idx,7) = rem(R(idx,7),2);
            R(idx,2) = R(idx,2) + 1;
            R(idx,2) = rem(R(idx,2),2);
    elseif  isequal(s,[1 0 1 1])    
        disp('15 activatied')
            R(idx,3) = R(idx,3) + 1;
            R(idx,3) = rem(R(idx,3),2);
             R(idx,6) = R(idx,6) + 1;
            R(idx,6) = rem(R(idx,6),2);
             R(idx,5) = R(idx,5) + 1;
            R(idx,5) = rem(R(idx,5),2);
    end
    
end


 recvm = R(:,[end-(k-1):end])   