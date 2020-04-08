%%%-------------------------------------------------------------------
%%% @author datawiz5
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Apr 2020 17:26 น.
%%%-------------------------------------------------------------------
-module(cPol_test).
-author("datawiz5").

%% API
-export([test1/0, parse/1]).

test1() ->
  T1=lists:sort(fun({KeyA,ValA}, {KeyB,ValB}) -> {ValA,KeyA} =< {ValB,KeyB} end, [{a,b},{b,a},{b,b}]),
  io:format("Test1: ~p~n",[length(T1)]),
  io:format("Test1: ~p~n",[T1]).

parse(FilePath)->
  ForEachLine = fun(Line,Buffer)-> io:format("Line: ~p~n",[Line]),Buffer end,
  case file:open(FilePath,[read]) of
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