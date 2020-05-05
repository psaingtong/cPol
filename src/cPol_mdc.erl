%%%-------------------------------------------------------------------
%%% Created : 05. May 2020 20:06 น.
%%%-------------------------------------------------------------------
-module(cPol_mdc).

-include("cPol_db.hrl").
-include_lib("stdlib/include/qlc.hrl").
%% API
-export([get_dc/1, create_table/1,import_data/0]).
-export_type([mdc/0]).

-opaque mdc() :: #cPol_mdc{}.

-spec create_table([node()]) -> ok.
create_table(Nodes) ->
  {atomic, ok} = mnesia:create_table(cPol_mdc,
    [{attributes, record_info(fields, cPol_mdc)},
      {disc_copies, Nodes}]),
  ok.

get_dc(Mdc)->
  case Mdc of
      5->
        io:format("Mdc--------~p~n",[Mdc]),
        ok;
    _ -> undefined
  end.

import_data()->
  FilePath="data/mdc/5",
  FileName="mdc5_icd10.csv",
  Mdc1="5",
  FilePathName=string:join([FilePath, FileName], "/"),
  ForEachLine = fun(Line,Buffer)->
    [A,B|[]]=Line,
    io:format("Line: ~p~p~n",[A,B]),
    case get_icd10(Mdc1,A) of
        undefined->
          F = fun() ->
            mnesia:dirty_write(
              #cPol_mdc{mdc=Mdc1,icd10=A,pdc10=B})
              end,
          ok = mnesia:activity(transaction, F),
          io:format("********* ~p~p~n",[A,B]);

      Mdc ->io:format("***old key***~n")
    end,
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

-spec get_icd10(binary(),binary()) -> mdc() | undefined.
get_icd10(Mdc,Code) ->
  F = fun() ->
    qlc:e(qlc:q(
      [X || X = #cPol_mdc{mdc=M} <- mnesia:table(cPol_mdc),
        string:equal(Mdc, M, true)]))
      end,
  case mnesia:activity(transaction, F) of
    [Mdc] ->
      F1 = fun() ->
        qlc:e(qlc:q(
          [X || X = #cPol_mdc{icd10=C} <- mnesia:table(cPol_mdc),
            string:equal(Code, C, true)]))
          end,
      case mnesia:activity(transaction, F1) of
        [Mdc] ->
          Mdc;
        _ ->
          undefined
          end;
    _ ->
      undefined
  end .