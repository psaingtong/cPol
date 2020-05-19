%%%-------------------------------------------------------------------
%%% Created : 09. Apr 2020 9:59 น.
%%%-------------------------------------------------------------------
-module(cPol_pcl).

-include("cPol_db.hrl").
-include_lib("stdlib/include/qlc.hrl").
%% API
-export([init/0, list_data/1, import_data/2, get_code/1, create_table/1,get_pdc/0,initcc/0,test/0]).
-export_type([dcl/0, dcl_ae/0, dcl_fj/0, dcl_ko/0, dcl_pz/0]).

-opaque dcl() :: #cPol_dcl_test{}.
-opaque dcl_ae() :: #cPol_dcl_ae{}.
-opaque dcl_fj() :: #cPol_dcl_fj{}.
-opaque dcl_ko() :: #cPol_dcl_ko{}.
-opaque dcl_pz() :: #cPol_dcl_pz{}.

init() ->
  %Data=[{"I213",2},{"E119",1},{"I10",1},{"N182",0},{"I092",1},{"K250",3},{"I209",0},{"A419",2},{"E875",1},{"E876",1}],
  Data=[{"I213",2},{"E119",1},{"I10",1},{"N182",0},{"I092",1},{"K250",3},{"I209",0},{"A419",2},{"E875",0},{"E876",1}],

  %Data=[{"K250",3},{"I213",2}],
  T1=lists:sort(
    fun({KeyA,ValA}, {KeyB,ValB}) ->
      {ValA,KeyA} >= {ValB,KeyB}
    end
    ,Data),

  F = fun ({_,0}) -> false ; (_) -> true end,
  T2=lists:filter(F, T1),
  %io:format("Test2: ~p~n",[T2]),
  T3=[{"K250",3},{"I213",2},{"A419",2},{"I10",1},{"I092",1},{"E876",1},{"E119",1}],
 % T3=[{"K250",3},{"I213",2},{"A419",2}],
  N0=[N || {N,_} <- T3],
  N1=[N || {_,N} <- T3],
  %io:format("Dc:Dcl ~p~p~n",[N0,N1]),
  S1 = lists:foldl(fun({A,B}, Sum) -> (B*math:pow(0.82,index_of({A,B}, T2)-1)) + Sum end, 0, T2),
  io:format("*-*-*- ~p~n",[S1]),
  T2.

initcc() ->
  A1=cPol_ipd:get_an("6300123"),
  %io:format("An Test--------~p~n",[A1]),
  Pdx = A1#cPol_ipd.pdx,
  Sdx=string:tokens(A1#cPol_ipd.sdx, ":"),
  %io:format("Pdx--------~p~n",[Pdx]),
  %io:format("Sdx--------~p~n",[Sdx]),
  Dx=[Pdx|Sdx],
  io:format("Dx--------~p~n",[Dx]),

  even_list33(Dx),

  ok.

even_list33([])-> [];
even_list33([H|T]) ->
  io:format("* ~p~n", [H]),
  MMM=[H]++even_list333(T),
  io:format("**--++===>: ~p~n", [MMM]).
  %even_list33(T).

even_list333([])-> [];
even_list333([H|T]) ->
  io:format("++: ~p~n", [H]),
  HHH=[H]++even_list333(T),
  HHH.

even_list11([])-> [];
even_list11([H|T]) ->
  LL=[H|T],
  io:format("**: ~p~n", [LL]),
  II=index_of(H, LL),
  io:format("~p: ~p~n", [II,H]),
  io:format("--: ~p~n", [T]),
  MMM=even_list22(T),
  io:format("**--++===>: ~p~n", [MMM]),
  %P = lists:foldl(fun(A) ->AA=index_of(A, H), io:format("****----~p~n",[AA]) end, 0, H),
  %PP = fun(A, AccIn) -> io:format("~p ", [A]), AccIn end,
  %PPP=lists:foldl(PP, 0, [1,2,3]),
  %P = lists:foldl(PP, 0, H),
  %io:format("Pcl--------- ~p~n",[P]),
  even_list11(T).

even_list22([])-> [];
even_list22([H|T]) ->
  io:format("**--++: ~p~n", [H]),
  HHH=[H]++even_list22(T),
  HHH.

-spec create_table([node()]) -> ok.
create_table(Nodes) ->
  {atomic, ok} = mnesia:create_table(cPol_dcl_test,
    [{attributes, record_info(fields, cPol_dcl_test)},
      {disc_copies, Nodes}]),
  {atomic, ok} = mnesia:create_table(cPol_dcl_ae,
    [{attributes, record_info(fields, cPol_dcl_ae)},
      {disc_copies, Nodes}]),
  {atomic, ok} = mnesia:create_table(cPol_dcl_fj,
    [{attributes, record_info(fields, cPol_dcl_fj)},
      {disc_copies, Nodes}]),
  {atomic, ok} = mnesia:create_table(cPol_dcl_ko,
    [{attributes, record_info(fields, cPol_dcl_ko)},
      {disc_copies, Nodes}]),
  {atomic, ok} = mnesia:create_table(cPol_dcl_pz,
    [{attributes, record_info(fields, cPol_dcl_pz)},
      {disc_copies, Nodes}]),
  ok.

list_data(FilePath)->
  ForEachLine = fun(Line,Buffer)->
    io:format("Line: ~p~n",[Line]),
    %[H|[]]=Line,
    %io:format("Line: ~p~n",[H]),
    Buffer
                end,
  case file:open(FilePath,[read]) of
    {_,S} ->
      cPol_util:start_parsing(S,ForEachLine,[]);
    Error -> Error
  end.

test()->
  FilePath="data/dcl/a",
  {ok,HH}=cPol_util:recursively_list_dir(FilePath),
  %io:format("DDDD: ~p~n",[HH]),
  even_list_cc(HH),

  ok.
even_list_cc([])-> [];
even_list_cc([H|T]) ->
  io:format("::: ~p~n", [H]),
  list_data(H),
  even_list_cc(T).


import_data(FilePath,FileName)->
  FilePathName=string:join([FilePath, FileName], "/"),
  ForEachLine = fun(Line,Buffer)->
    [H|[]]=Line,
    %io:format("Line: ~p~n",[H]),
    [A,B] = string:tokens(FileName, "."),
    [Scode,Dcl] = string:tokens(H, ":"),
    Mcode=string:join([A, Scode], ":"),

      case get_code(Mcode) of
        undefined ->
          F = fun() ->
          mnesia:dirty_write(
            #cPol_dcl_test{mcode=Mcode,scode=Scode,dcl=Dcl})
              end,
          ok = mnesia:activity(transaction, F);
         _ ->
           ok
      end,

    Buffer
                end,
  case file:open(FilePathName,[read]) of
    {_,S} ->
      cPol_util:start_parsing(S,ForEachLine,[]);
    Error -> Error
  end.

-spec get_code(binary()) -> dcl() | undefined.
get_code(Code) ->
  F = fun() ->
    qlc:e(qlc:q(
      [X || X = #cPol_dcl_test{mcode=C} <- mnesia:table(cPol_dcl_test),
        string:equal(Code, C, true)]))
      end,
  case mnesia:activity(transaction, F) of
    [Dcl] ->
      Dcl;
    _ ->
      undefined
  end .

get_pdc () ->
  %Pcl="5",
  %N1=[N || {_,N} <- K1],
  %%%
  %%%
  A1=cPol_ipd:get_an("6300123"),
  %io:format("An Test--------~p~n",[A1]),
  Pdx = A1#cPol_ipd.pdx,
  Sdx=string:tokens(A1#cPol_ipd.sdx, ":"),
  %io:format("Pdx--------~p~n",[Pdx]),
  %io:format("Sdx--------~p~n",[Sdx]),
  Dx=[Pdx|Sdx],
  io:format("Dx--------~p~n",[Dx]),
  Fdc="0553",
  Dcl_1=even_list(Fdc,Dx),
  io:format("--------~p~n",[Dcl_1]),
  %%%
  T1=lists:sort(
    fun({KeyA,ValA}, {KeyB,ValB}) ->
      {ValA,KeyA} >= {ValB,KeyB}
    end
    ,Dcl_1),

  F = fun ({_,0}) -> false ; (_) -> true end,
  T2=lists:filter(F, T1),
  io:format("Test2: ~p~n",[T2]),
  %%%
  P = lists:foldl(fun({A,B}, Sum) -> (B*math:pow(0.82,index_of({A,B}, T2)-1)) + Sum end, 0, T2),
  io:format("Pcl--------- ~p~n",[P]),
  P.

index_of(Item, List) -> index_of(Item, List, 1).
index_of(_, [], _)  -> not_found;
index_of(Item, [Item|_], Index) -> Index;
index_of(Item, [_|Tl], Index) -> index_of(Item, Tl, Index+1).

even_list(Fdc,[])-> [];
even_list(Fdc,[H|T]) ->
  Mcode=string:join([H,Fdc], ":"),
  HH=get_dcl(Mcode,H),
  %io:format("::: ~p~n", [HH]),
  HHH=HH++even_list(Fdc,T),
  [H|even_list(Fdc,T)],
  HHH.

get_dcl(Mcode,H) ->
  case get_code(Mcode) of
    undefined->
      DC=[{H,0}],
      DC;
    Dcl ->
      DC1=Dcl#cPol_dcl_test.dcl,
      DC=[{H,list_to_integer(DC1)}],
    DC
  end.