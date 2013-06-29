function genddslut(filename, func, nbits_data, nbits_phase, factor)

phase_ind = 0:((2^nbits_phase)-1);
npts = length(phase_ind);

dec = ((2^(nbits_data-1))-1)*func(2*pi/factor*phase_ind);
dec_rounded = round(dec);

dec_hex = zeros(size(dec_rounded));

index_dec_pos = find(dec_rounded >= 0);
index_dec_neg = find(dec_rounded < 0);

dec_hex(index_dec_pos) = dec_rounded(index_dec_pos);
dec_hex(index_dec_neg) = bitcmp(abs(dec_rounded(index_dec_neg)-1),nbits_data);

fid = fopen(filename,'w');
try
    for i=1:npts
        fprintf(fid, '%X\n', dec_hex(i));
    end
end
fclose(fid);
