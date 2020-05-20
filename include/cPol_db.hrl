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
  sex :: binary(),
  dcl :: binary(),
  cc :: binary()
}).

-record(cPol_dc,
{ code :: binary(),
  mcode :: binary(),
  mdc :: binary(),
  key :: binary(),
  ax :: binary(),
  memo :: binary()
}).


-record(cPol_dcl,
{ mcode :: binary(),
  scode :: binary(),
  dcl :: binary()
}).
-record(cPol_cc,
{ ccode :: binary(),
  un_code :: binary(),
  memo :: binary()
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