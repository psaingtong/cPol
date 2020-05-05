%%%-------------------------------------------------------------------
%%% Created : 09. Apr 2020 9:18 น.
%%%-------------------------------------------------------------------

-record(cPol_icd10,
{ code :: binary(),
  memo :: binary(),
  mdc :: binary(),
  das :: binary(),
  un_pdx :: binary(),
  age :: binary(),
  sex :: binary()
}).

-record(cPol_mdc,
{ mdc :: binary(),
  icd10 :: binary(),
  pdc10 :: binary(),
  icd9 :: binary(),
  pdc9 :: binary(),
  ax_bx :: binary(),
  ax_pbx :: binary(),
  dd :: binary(),
  memo :: binary()
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