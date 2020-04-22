%%%-------------------------------------------------------------------
%%% Created : 22. Apr 2020 20:04 น.
%%%-------------------------------------------------------------------
-module(cPol_drg).


%% API
-export([check_pdx/1]).

check_pdx(Pdx) ->
  io:format("Pdx----->~p ~n",[Pdx]),
  if
    Pdx=:= "" -> io:format("No Pdx and error code1----->~n"),
      DRG="26509",DRG;
    true ->
      %% check from icd10
      DRG="26509",
      %% check unaccept pdx
      DRG="26519",
      io:format("Pdx= ~p~n",[Pdx])
  end,

  io:format("check Drg ~n").
