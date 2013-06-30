function gensimdata_ddc(filename, npts, data_width, factor_n, factor_d)

%phase = pi/2;
%y = (sin(2*pi*0.001*(0:npts-1))/5+0.5) .* cos(2*pi*n/204*(0:npts-1) + phase*sin(2*pi*0.01*(0:npts-1)));
%y = cos(2*pi*n/204*(0:npts-1) + phase*sin(2*pi*0.001*(0:npts-1)));
%y = zeros(1,npts);
%y = cos(2*pi*n/204*(0:npts-1) + pi/90000*(0:npts-1));
%y = sin(2*pi*0.0001*(0:npts-1)) .* cos(2*pi*n/204*(0:npts-1));

y = cos(2*pi*factor_n/factor_d*(0:npts-1));
y_scaled = round(((2^(data_width-1))-1)*y);

% write to file
fid = fopen(filename, 'w');
try
  for i=1:npts
    fprintf(fid, '%d\n', y_scaled(i));
  end
end
fclose(fid);
