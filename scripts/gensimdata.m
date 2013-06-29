function gensimdata(filename, npts, nbits_data, fs, fif, fimage, amplitude)

t = (0:npts-1)/fs;
y = sin(2*pi*fif*t) + sum(sin(repmat(2*pi*t, length(fimage), 1).*repmat(fimage', 1, npts)));

dec = round(((2^(nbits_data-1))-1)*repmat(amplitude',1,npts).*repmat(y,4,1));

dec = dec';

fid = fopen(filename,'w');
try
  for i=1:npts
      fprintf(fid, '%d %d %d %d\n', dec(i,:));
  end
end
fclose(fid);