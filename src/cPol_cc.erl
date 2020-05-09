%%%-------------------------------------------------------------------
%%% Created : 09. May 2020 20:40 น.
%%%-------------------------------------------------------------------
-module(cPol_cc).
-include("cPol_db.hrl").
-include_lib("stdlib/include/qlc.hrl").
%% API
-export([create_table/1,import_data/0,get_code/1, get_value_in_range/1]).
-export_type([cc/0]).

-opaque cc() :: #cPol_cc{}.


-spec create_table([node()]) -> ok.
create_table(Nodes) ->
  {atomic, ok} = mnesia:create_table(cPol_cc,
    [{attributes, record_info(fields, cPol_cc)},
      {disc_copies, Nodes}]),
  ok.
-spec get_code(binary()) -> cc() | undefined.
get_code(Code) ->
  F = fun() ->
    qlc:e(qlc:q(
      [X || X = #cPol_cc{ccode=C} <- mnesia:table(cPol_cc),
        string:equal(Code, C, true)]))
      end,
  case mnesia:activity(transaction, F) of
    [Cc] ->
      Cc;
    _ ->
      undefined
  end .


import_data()->
  FilePath="data/cc",
  FileName="f2i.csv",
  FilePathName=string:join([FilePath, FileName], "/"),
  ForEachLine = fun(Line,Buffer)->
    [A,B|[]]=Line,
    %io:format("Line--: ~p~n",[Line]),
    io:format("~p--~p~n",[A,B]),
    HH=string:tokens(B, " "),
    io:format("~p--+-- ~p~n", [A,HH]),
    %case Line of
     % [[],[]]->io:format("-------------~n");
      %_->
       % even_list_cc(Line),
        %io:format("Line--: ~p~n",[Line]),
        %io:format("-------------~n")
    %end,


    Buffer
                end,
  case file:open(FilePathName,[read]) of
    {_,S} ->
      start_parsing(S,ForEachLine,[]);
    Error -> Error
  end.

even_list_cc([])-> [];
even_list_cc([H|T]) ->
  io:format("* ~p~n", [H]),
  %[A,[]]=T,
  %HH=string:tokens(A, " "),
  %io:format("-- ~p~n", [HH]),
  %even_list_cc([T]),
  io:format("** ~p~n", [T]).



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

get_value_in_range(S) ->
  SSS="I980-I989",
  HH=string:tokens(SSS, "-"),
  [A,B]=HH,
  A0=string:slice(A, 0,1),
  A1=string:slice(A, 1),
  B1=string:slice(B, 1),
  From=list_to_integer(A1),
  To=list_to_integer(B1),
  io:format("From: ~p --+--To: ~p~n", [From,To]),
  lists:foreach(
    fun(I) ->  AAA=A0++integer_to_list(I),io:format("~p~n", [AAA] ) end,
    lists:seq(From, To)
  ).
