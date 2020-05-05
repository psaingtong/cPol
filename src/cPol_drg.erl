%%%-------------------------------------------------------------------
%%% Created : 22. Apr 2020 20:04 น.
%%%-------------------------------------------------------------------
-module(cPol_drg).


%% API
-export([check_pdx/1, get_drg/1]).

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

get_drg(An) ->
  A1=cPol_ipd:get_an(An),
  %io:format("An Test--------~p~n",[A1]),
  Pdx_db=cPol_ipd:pdx(A1),
  io:format("Pdx DB--------~p~n",[Pdx_db]),
  io:format("AN===> ~p~n",[An]).

