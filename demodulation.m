function [demod] = demodulation(tri_pulse_sym,sr)

switch(sr)
    case 5
        tmp_arr = zeros(1,3);
        demod = zeros(1,size(tri_pulse_sym,2)/5);
        for i = 1:size(tri_pulse_sym,2)/5
            disp(tri_pulse_sym(5*(i-1)+1:5*i))
            tmp_arr = tri_pulse_sym(5*(i-1)+2:5*i-1);
            for j = 1:3
                if tmp_arr(j) >= 3
                    tmp_arr(j) = 3;
                end
            end
            tmp_arr = sort(tmp_arr);
            demod(i) = min(tmp_arr(1)*2,tmp_arr(2));
            
        end
    case 7
        tmp_arr = zeros(1,5);
        demod = zeros(1,size(tri_pulse_sym,2)/7);
        for i = 1:size(tri_pulse_sym,2)/7
            
            disp(tri_pulse_sym(5*(i-1)+1:5*i))
            tmp_arr = tri_pulse_sym(7*(i-1)+2:7*i-1);
            for j = 1:5
                if tmp_arr(j) >= 3
                    tmp_arr(j) = 3;
                end
            end
            tmp_arr = sort(tmp_arr);
            demod(i) = min(tmp_arr(1)*3,tmp_arr(2)*3/2,tmp_arr(3));
            
            end
end

end

