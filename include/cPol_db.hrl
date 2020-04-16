%%%-------------------------------------------------------------------
%%% Created : 09. Apr 2020 9:18 น.
%%%-------------------------------------------------------------------
-author("wt").
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