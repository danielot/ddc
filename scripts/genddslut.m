function genddslut(filename, func, nco_width, factor_n, factor_d, granularity)

nco_phase_width = nextpow2(factor_d*granularity);
npts = 2^nco_phase_width;

phase_ind = 0:(npts-1);
npts = length(phase_ind);

y = func(2*pi*factor_n/factor_d/granularity*phase_ind);
y_scaled = round(((2^(nco_width-1))-1)*y);

% prepare to write signed hex number
y_hex = zeros(size(y_scaled));
index_y_pos = find(y_scaled >= 0);
index_y_neg = find(y_scaled < 0);
y_hex(index_y_pos) = y_scaled(index_y_pos);
y_hex(index_y_neg) = bitcmp(abs(y_scaled(index_y_neg))-1,nco_width);

% write to file
fid = fopen(filename,'w');
try
  for i=1:npts
    fprintf(fid, '%X\n', y_hex(i));
  end
end
fclose(fid);
