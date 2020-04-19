%%%-------------------------------------------------------------------
%%% Created : 09. Apr 2020 9:59 น.
%%%-------------------------------------------------------------------
-module(cPol_pcl).

-include("cPol_db.hrl").
-include_lib("stdlib/include/qlc.hrl").
%% API
-export([init/0, even_print/1, list_data/1, import_data/2, get_code/1, create_table/1]).
-export_type([dcl/0]).

-opaque dcl() :: #cPol_dcl_test{}.

init() ->
  Data=[{"I213",2},{"E119",1},{"I10",1},{"N182",0},{"I092",1},{"K250",3},{"I209",0},{"A419",2},{"E875",1},{"E876",1}],
  T1=lists:sort(
    fun({KeyA,ValA}, {KeyB,ValB}) ->
      {ValA,KeyA} >= {ValB,KeyB}
    end
    ,Data),

  F = fun ({_,0}) -> false ; (_) -> true end,
  T2=lists:filter(F, T1),
  io:format("Test2: ~p~n",[T2]),

  T2.


even_print([])-> [];
even_print([H|T]) ->
  %io:format("printing: ~p~n", [H]),
  {H1,H2}=H,
  io:format("key: ~p~n", [H1]),
  [H|even_print(T)].

even_print1([])-> [];
even_print1([H|T]) ->
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

-spec create_table([node()]) -> ok.
create_table(Nodes) ->
  {atomic, ok} = mnesia:create_table(cPol_dcl_test,
    [{attributes, record_info(fields, cPol_dcl_test)},
      {disc_copies, Nodes}]),
  ok.

list_data(FilePath)->
  ForEachLine = fun(Line,Buffer)->
    %io:format("Line: ~p~n",[Line]),
    [H|[]]=Line,

    io:format("Line: ~p~n",[H]),
    Buffer
                end,

  case file:open(FilePath,[read]) of
    {_,S} ->
      start_parsing(S,ForEachLine,[]);
    Error -> Error
  end.


import_data(FilePath,FileName)->
  FilePathName=string:join([FilePath, FileName], "/"),
  ForEachLine = fun(Line,Buffer)->
    %io:format("Line: ~p~n",[Line]),
    %io:format("FilePath: ~p~n",[FilePathName]),
    [H|[]]=Line,
    %io:format("Line: ~p~n",[H]),
    [A,B] = string:tokens(FileName, "."),
    io:format("mcode: ~p~n",[A]),
    [Scode,Dcl] = string:tokens(H, ":"),
    io:format("scode: ~p~n",[Scode]),
    io:format("dcl: ~p~n",[Dcl]),
    F = fun() ->
      mnesia:dirty_write(
        #cPol_dcl_test{mcode=A})
        end,
    ok = mnesia:activity(transaction, F),
    Buffer
                end,
  case file:open(FilePathName,[read]) of
    {_,S} ->
      start_parsing(S,ForEachLine,[]);
    Error -> Error
  end.

start_parsing(S,ForEachLine,Opaque)->
  Line = io:get_line(S,''),
  case Line of
    eof -> {ok,Opaque};
    "\n" -> start_parsing(S,ForEachLine,Opaque);
    "\r\n" -> start_parsing(S,ForEachLine,Opaque);
    _ ->
      NewOpaque = ForEachLine(scanner(clean(clean(Line,10),13)),Opaque),
      start_parsing(S,ForEachLine,NewOpaque)
  end.

scan(InitString,Char,[Head|Buffer]) when Head == Char ->
  {lists:reverse(InitString),Buffer};
scan(InitString,Char,[Head|Buffer]) when Head =/= Char ->
  scan([Head|InitString],Char,Buffer);
scan(X,_,Buffer) when Buffer == [] -> {done,lists:reverse(X)}.
scanner(Text)-> lists:reverse(traverse_text(Text,[])).

traverse_text(Text,Buff)->
  case scan("",$,,Text) of
    {done,SomeText}-> [SomeText|Buff];
    {Value,Rem}-> traverse_text(Rem,[Value|Buff])
  end.

clean(Text,Char)->
  string:strip(string:strip(Text,right,Char),left,Char).

-spec get_code(binary()) -> dcl() | undefined.
get_code(Code) ->
  F = fun() ->
    qlc:e(qlc:q(
      [X || X = #cPol_dcl_test{scode=C} <- mnesia:table(cPol_dcl_test),
        string:equal(Code, C, true)]))
      end,
  case mnesia:activity(transaction, F) of
    [Dcl] ->
      Dcl;
    _ ->
      undefined
  end .

