frf = 500;
npts = 10000;
nbits_data = 16;

n = 204;
h = 864;

fs = n/h*frf;
%idx = 0:floor(n/2);
idx = 48;

for i=1:length(idx)
    fif = idx(i)/n*fs;
    gensimdata(sprintf('datain_%0.2fHz.txt', fif), npts, nbits_data, fs, fif, 0, [1 1 1 1]);
end