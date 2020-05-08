%%%-------------------------------------------------------------------
%%% Created : 05. May 2020 20:06 น.
%%%-------------------------------------------------------------------
-module(cPol_mdc).

-include("cPol_db.hrl").
-include_lib("stdlib/include/qlc.hrl").
%% API
-export([get_dc/1, create_table/1,import_data/0,get_icd10/1, check_data/0, import_data_ax/0]).
-export_type([dc/0]).

-opaque dc() :: #cPol_dc{}.

-spec create_table([node()]) -> ok.
create_table(Nodes) ->
  {atomic, ok} = mnesia:create_table(cPol_dc,
    [{attributes, record_info(fields, cPol_dc)},
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
  %FileName="ax_5pfx.csv",
  %B="ax_5bx",
  FileName="mdc5_icd10.csv",
  FilePathName=string:join([FilePath, FileName], "/"),
  ForEachLine = fun(Line,Buffer)->
    [A,B|[]]=Line,
    Mgr="5",
    %io:format("Line: ~p~p~n",[A,B]),
    case get_icd10(A) of
        undefined->
          F = fun() ->
            mnesia:dirty_write(
              #cPol_dc{mdc=Mgr,code=A,key=B})
              end,
          ok = mnesia:activity(transaction, F);

      _ ->
        io:format("Old--------~p~n",[A]),
        ok
    end,
    Buffer
                end,
  case file:open(FilePathName,[read]) of
    {_,S} ->
      start_parsing(S,ForEachLine,[]);
    Error -> Error
  end.

import_data_ax()->
  FilePath="data/mdc/5",
  FileName="ax_5bx.csv",
  B="ax_5bx",
  FilePathName=string:join([FilePath, FileName], "/"),
  ForEachLine = fun(Line,Buffer)->
    [A|[]]=Line,
    %io:format("Line: ~p~p~n",[A,B]),
    case get_icd10(A) of
      undefined->
        F = fun() ->
          mnesia:dirty_write(
            #cPol_dc{code=A,ax=B})
            end,
        ok = mnesia:activity(transaction, F);

      Dc ->
        io:format("Old--------~p~n",[A]),
        F = fun() ->
          mnesia:dirty_write(
            Dc#cPol_dc{ax=B})
             end,
        ok = mnesia:activity(transaction, F)
    end,
    Buffer
                end,
  case file:open(FilePathName,[read]) of
    {_,S} ->
      start_parsing(S,ForEachLine,[]);
    Error -> Error
  end.

check_data()->
  FilePath="data/mdc/5",
  FileName="ax_5pdx.csv",
  %FileName="mdc5_icd9.csv",
  FilePathName=string:join([FilePath, FileName], "/"),
  ForEachLine = fun(Line,Buffer)->
    [A,B|[]]=Line,
    %io:format("Line: ~p~p~n",[A,B]),
    case get_icd10(A) of
      undefined->
        io:format("New--------~p~n",[A]);
      _ ->
        io:format("Old--------~p~n",[A]),
        ok
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

-spec get_icd10(binary()) -> dc() | undefined.
get_icd10(Code) ->
  F = fun() ->
    qlc:e(qlc:q(
      [X || X = #cPol_dc{code=C} <- mnesia:table(cPol_dc),
        string:equal(Code, C, true)]))
      end,
  case mnesia:activity(transaction, F) of
    [Dc] ->
      Dc;
    _ ->
      undefined
  end .