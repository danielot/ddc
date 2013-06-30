function genfiles

npts = 100000;
datain_width = 16;
nco_width = 24;
factor_n = 4;
factor_d = 17;
granularity = 240;

genddslut('../ise_proj/coslut.mem', @cos, nco_width, factor_n, factor_d, granularity);
genddslut('../ise_proj/sinlut.mem', @sin, nco_width, factor_n, factor_d, granularity);
gensimdata_ddc('../ise_proj/datain.txt', npts, datain_width, factor_n, factor_d)
