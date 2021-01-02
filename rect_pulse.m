info_bits=randi([0,1],1,200);
sym_idx = info_bits(1:2:end)*2 + info_bits(2:2:end);
stem(sym_idx);