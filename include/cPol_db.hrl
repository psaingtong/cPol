%%%-------------------------------------------------------------------
%%% Created : 09. Apr 2020 9:18 น.
%%%-------------------------------------------------------------------

-record(cPol_test1,
{ an :: binary(),
  pdx :: binary(),
  sdx1 :: binary(),
  sdx2 :: binary(),
  sdx3 :: binary(),
  sdx4 :: binary(),
  sdx5 :: binary(),
  sdx6 :: binary(),
  sdx7 :: binary(),
  sdx8 :: binary(),
  sdx9 :: binary()
}).

-record(cPol_icd10,
{ code :: binary(),
  memo :: binary(),
  premcd :: binary()
}).

-record(cPol_dcl_ae,
{ mcode :: binary(),
  scode :: binary(),
  dcl :: binary()
}).

-record(cPol_dcl_fj,
{ mcode :: binary(),
  scode :: binary(),
  dcl :: binary()
}).

-record(cPol_dcl_ko,
{ mcode :: binary(),
  scode :: binary(),
  dcl :: binary()
}).

-record(cPol_dcl_pz,
{ mcode :: binary(),
  scode :: binary(),
  dcl :: binary()
}).

-record(cPol_dcl_test,
{ mcode :: binary(),
  scode :: binary(),
  dcl :: binary()
}).

-record(cPol_ipd,
{ an :: binary(),
  hn :: binary(),
  sex :: binary(),
  pdx :: binary(),
  sdx :: binary(),
  proc :: binary(),
  dob :: erlang:timestamp(),
  age :: binary(),
  admwt :: integer(),
  discht :: binary(),
  admdt :: erlang:timestamp(),
  dischdt :: erlang:timestamp(),
  lday :: integer(),
  los :: integer()
}).