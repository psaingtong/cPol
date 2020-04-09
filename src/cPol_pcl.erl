%%%-------------------------------------------------------------------
%%% @author wt
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Apr 2020 9:59 น.
%%%-------------------------------------------------------------------
-module(cPol_pcl).
-author("wt").

%% API
-export([init/0]).

init() ->
  %Data=[{"I213",2},{"E119",1},{"I10",1},{"N182",0},{"I092",1},{"K250",3},{"I209",0},{"A419",2},{"E875",1},{"E876",1}],
  Data=[{"I213",2},{"E119",1},{"I10",1},{"I092",1},{"K250",3},{"A419",2},{"E875",1},{"E876",1}],
  %io:format("Data: ~p~n",[Data]),
  T1=lists:sort(
    fun({KeyA,ValA}, {KeyB,ValB}) ->
      {ValA,KeyA} >= {ValB,KeyB}
    end
    ,Data),
  io:format("Test1: ~p~n",[T1]),
  %T2=lists:sort(fun({_,ValA}) -> io:format("Test2*****: ~p~n",[ValA]) end,Data),
  %io:format("Test2: ~p~n",[T2]),
  ok.
