%%%-------------------------------------------------------------------
%%% Created : 09. Apr 2020 10:21 น.
%%%-------------------------------------------------------------------
-module(cPol_db).

-include("cPol_db.hrl").
-include_lib("stdlib/include/qlc.hrl").
%% API

-export([install/0, init_icd10/0, import_data/2, get_code/1, update_icd10_un_pdx/0,update_icd10_das/0,
  update_icd10_age/0,update_icd10_sex/0]).
-export_type([icd10/0]).

-opaque icd10() :: #cPol_icd10{}.


install() ->
  Nodes = [node()],
  ok = application:stop(mnesia),

  ok = mnesia:create_schema(Nodes),
  ok = application:start(mnesia),
  cPol_icd10:create_table(Nodes),
  cPol_mdc:create_table(Nodes),
  cPol_ipd:create_table(Nodes).

init_icd10() ->
  FilePath="data/e",
  FileName="e_dxcode.csv",
  import_data(FilePath,FileName),
  ok.

import_data(FilePath,FileName)->
  FilePathName=string:join([FilePath, FileName], "/"),
  ForEachLine = fun(Line,Buffer)->
    [A,B|[]]=Line,
    io:format("Line: ~p~p~n",[A,B]),
    case get_code(A) of
      undefined ->F = fun() ->
        mnesia:dirty_write(
          #cPol_icd10{code=A,mdc=B})
                      end,
        ok = mnesia:activity(transaction, F);
      _ ->
        ok
    end,
    Buffer
                end,
  case file:open(FilePathName,[read]) of
    {_,S} ->
      start_parsing(S,ForEachLine,[]);
    Error -> Error
  end.

%%A2
update_icd10_un_pdx() ->
  FilePath="data/a",
  FileName="a2.csv",
  update_data_un_pdx(FilePath,FileName),
  ok.

update_data_un_pdx(FilePath,FileName)->
  FilePathName=string:join([FilePath, FileName], "/"),
  ForEachLine = fun(Line,Buffer)->
    [A|[]]=Line,
    %io:format("Line: ~p~n",[A]),
    case get_code(A) of
      undefined ->
        io:format("no data ***~n");
      Icd10 ->
        %io:format("update: ~p~n",[A]),

        F = fun() ->
          ok = mnesia:write(Icd10#cPol_icd10{un_pdx=A})
            end,
        mnesia:activity(transaction, F),
        ok
    end,
    Buffer
                end,
  case file:open(FilePathName,[read]) of
    {_,S} ->
      start_parsing(S,ForEachLine,[]);
    Error -> Error
  end.
%%A3
update_icd10_age() ->
  FilePath="data/a",
  FileName="a3.csv",
  update_data_age(FilePath,FileName),
  ok.

update_data_age(FilePath,FileName)->
  FilePathName=string:join([FilePath, FileName], "/"),
  ForEachLine = fun(Line,Buffer)->
    [A,B|[]]=Line,
    %io:format("Line: ~p~n",[A]),
    case get_code(A) of
      undefined ->
        io:format("no data ***~n");
      Icd10 ->
        %io:format("update: ~p~n",[A]),

        F = fun() ->
          ok = mnesia:write(Icd10#cPol_icd10{age=B})
            end,
        mnesia:activity(transaction, F),
        ok
    end,
    Buffer
                end,
  case file:open(FilePathName,[read]) of
    {_,S} ->
      start_parsing(S,ForEachLine,[]);
    Error -> Error
  end.
%%A4
update_icd10_sex() ->
  FilePath="data/a",
  FileName="a4.csv",
  update_data_sex(FilePath,FileName),
  ok.

update_data_sex(FilePath,FileName)->
  FilePathName=string:join([FilePath, FileName], "/"),
  ForEachLine = fun(Line,Buffer)->
    [A,B|[]]=Line,
    %io:format("Line: ~p~n",[A]),
    case get_code(A) of
      undefined ->
        io:format("no data ***~n");
      Icd10 ->
        %io:format("update: ~p~n",[A]),

        F = fun() ->
          ok = mnesia:write(Icd10#cPol_icd10{sex=B})
            end,
        mnesia:activity(transaction, F),
        ok
    end,
    Buffer
                end,
  case file:open(FilePathName,[read]) of
    {_,S} ->
      start_parsing(S,ForEachLine,[]);
    Error -> Error
  end.
%%das

update_icd10_das() ->
  FilePath="data/a",
  FileName="a1.csv",
  update_data(FilePath,FileName),
  ok.

update_data(FilePath,FileName)->
  FilePathName=string:join([FilePath, FileName], "/"),
  ForEachLine = fun(Line,Buffer)->
    [A,B,C,D|[]]=Line,
    S1=string:join([B,C], ":"),
    S2=string:join([S1,D], ":"),
    %io:format("Line: ~p~n",[A]),
    case get_code(A) of
      undefined ->
        io:format("no data ***~n");
      Icd10 ->
        %io:format("update: ~p~n",[A]),

        F = fun() ->
          ok = mnesia:write(Icd10#cPol_icd10{das=S2})
            end,
        mnesia:activity(transaction, F),
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

-spec get_code(binary()) -> icd10() | undefined.
get_code(Code) ->
  F = fun() ->
    qlc:e(qlc:q(
      [X || X = #cPol_icd10{code=C} <- mnesia:table(cPol_icd10),
        string:equal(Code, C, true)]))
      end,
  case mnesia:activity(transaction, F) of
    [Icd] ->
      Icd;
    _ ->
      undefined
  end .




