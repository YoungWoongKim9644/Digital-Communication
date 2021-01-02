function [recv_bits] = sym2bit(demod)

recv_bits = zeros(1,size(demod,2)*2);
for i=1:size(demod,2)
    if demod(i) == 0
         recv_bits(2*(i-1)+1:2*i) = [0 0];
    elseif demod(i) == 1
        %disp("1");
         recv_bits(2*(i-1)+1:2*i) = [0 1];
    elseif demod(i) == 2
        %disp("2");
         recv_bits(2*(i-1)+1:2*i) = [1 0];
    elseif demod(i) == 3
        %disp("3");
         recv_bits(2*(i-1)+1:2*i) = [1 1]; 
    end
end