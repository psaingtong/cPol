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
-export([init/0, even_print/1]).

init() ->
  Data=[{"I213",2},{"E119",1},{"I10",1},{"N182",0},{"I092",1},{"K250",3},{"I209",0},{"A419",2},{"E875",1},{"E876",1}],
  %Data=[{"I213",2},{"E119",1},{"I10",1},{"I092",1},{"K250",3},{"A419",2},{"E875",1},{"E876",1}],
  %io:format("Data: ~p~n",[Data]),
  T1=lists:sort(
    fun({KeyA,ValA}, {KeyB,ValB}) ->
      {ValA,KeyA} >= {ValB,KeyB}
    end
    ,Data),
  %io:format("Test1: ~p~n",[T1]),
  %T2=lists:sort(fun({_,ValA}) -> io:format("Test2*****: ~p~n",[ValA]) end,Data),
  %io:format("Test2: ~p~n",[T2]),
  T1.


even_print([])-> [];
even_print([H|T]) ->
  %io:format("printing: ~p~n", [H]),
  {H1,H2}=H,
  if
    H2>0 -> io:format("key: ~p~n", [H1]),
      even_print1(T);
    true -> undefine
  end,
  [H|even_print(T)].

even_print1([])-> [];
even_print1([H|T]) ->
  K250={"K250","K251","K252","K254","K255","K256","K260","K261","K262","K264","K265","K266","K270"
    ,"K271","K272","K273","K274","K275","K276","K277","K278","K279","K280","K281","K282","K283"
    ,"K284","K285","K286","K290","K292","K293"},
  E875=[{"D550","D551","D552","D553","D554","D555","D556","D557","D558","D559","E250","E291","E345","E875","E876"
    ,"G110","G111","G112","G113","G114","G115","G116","G117","G118","G119"
    ,"G710","G711","G712","G713","G714","G715","G716","G717","G718","G719"
  ,"N250","N251","N252","N253","N254","N255","N256","N257","N258","N259"
  ,"P590","P591","P592","P593","P594","P595","P596","P597","P598","P599"
  ,"Q796","Q874","R799"}],
  %io:format("printing: ~p~n", [H]),
  {H1,H2}=H,
  if
    H2>0 -> io:format("key111: ~p~n", [H1]),

      H3=lists:keyfind(H1, E875),
      io:format("key in list: ~p~n", [H3]);
    true -> undefine
  end,
  [H|even_print1(T)].

