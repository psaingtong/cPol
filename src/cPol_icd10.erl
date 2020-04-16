%%%-------------------------------------------------------------------
%%% Created : 16. Apr 2020 19:48 น.
%%%-------------------------------------------------------------------
-module(cPol_icd10).


-include("cPol_db.hrl").
-include_lib("stdlib/include/qlc.hrl").

-export_type([icd10/0]).
-export([create_table/1, get_code/1, import_code/1, list_data/1]).

-opaque icd10() :: #cPol_icd10{}.

-spec create_table([node()]) -> ok.
create_table(Nodes) ->
  {atomic, ok} = mnesia:create_table(cPol_icd10,
    [{attributes, record_info(fields, cPol_icd10)},
      {disc_copies, Nodes}]),
  ok.

-spec get_code(binary()) -> icd10() | undefined.
get_code(Code) ->
  F = fun() ->
    qlc:e(qlc:q(
      [X || X = #cPol_icd10{code=C} <- mnesia:table(cPol_icd10),
        string:equal(Code, C, true)]))
      end,
  case mnesia:activity(transaction, F) of
    [Icd10] ->
      Icd10;
    _ ->
      undefined
  end .

import_code(FilePath)->
  ForEachLine = fun(Line,Buffer)->
    %io:format("Line: ~p~n",[Line]),
    [H|L]=Line,
    F = fun() ->
      mnesia:dirty_write(
        #cPol_icd10{code=H})
        end,
    ok = mnesia:activity(transaction, F),
    Buffer
                end,

  case file:open(FilePath,[read]) of
    {_,S} ->
      start_parsing(S,ForEachLine,[]);
    Error -> Error
  end.

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