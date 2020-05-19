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
  FilePath="data/mdc/25",
  FileName="mdc25_icd10.csv",
  FilePathName=string:join([FilePath, FileName], "/"),
  ForEachLine = fun(Line,Buffer)->
    [A,B|[]]=Line,
    Mgr="25",
    Code=string:join([Mgr, A], ":"),
    %io:format("Line: ~p~p~n",[A,B]),
    case get_icd10(Code) of
        undefined->
          F = fun() ->
            mnesia:dirty_write(
              #cPol_dc{code=Code,mdc=Mgr,mcode=A,key=B})
              end,
          ok = mnesia:activity(transaction, F);

      _ ->
        io:format("Old--------~p~n",[Code])
    end,
    Buffer
                end,
  case file:open(FilePathName,[read]) of
    {_,S} ->
      cPol_util:start_parsing(S,ForEachLine,[]);
    Error -> Error
  end.

import_data_ax()->
  FilePath="data/mdc/25",
  FileName="ax_25dx.csv",
  B="ax_25dx",
  Mgr="25",
  FilePathName=string:join([FilePath, FileName], "/"),
  ForEachLine = fun(Line,Buffer)->
    [A|[]]=Line,
    Code0=string:join([Mgr, A], ":"),
    Ax="ax",
    Code=string:join([Code0, Ax], ":"),
    io:format("Line: ~p~n",[Code]),
    case get_icd10(Code) of
      undefined->
        F = fun() ->
          mnesia:dirty_write(
            #cPol_dc{code=Code,mdc=Mgr,mcode=A,ax=B})
            end,
        ok = mnesia:activity(transaction, F);

      Dc ->
        io:format("Old--------~p~n",[Code])
    end,
    Buffer
                end,
  case file:open(FilePathName,[read]) of
    {_,S} ->
      cPol_util:start_parsing(S,ForEachLine,[]);
    Error -> Error
  end.

check_data()->
  FilePath="data/mdc/0",
  FileName="ax0pex.csv",
  %FileName="mdc5_icd9.csv",
  Mgr="0",
  FilePathName=string:join([FilePath, FileName], "/"),
  ForEachLine = fun(Line,Buffer)->
    [A|[]]=Line,
    Code=string:join([Mgr, A], ":"),
    %Ax="ax",
    %Code1=string:join([Code, Ax], ":"),
    %io:format("Line: ~p~p~n",[A,B]),
    case get_icd10(Code) of
      undefined->
        io:format("New--------~p~n",[Code]);
      _ ->
        io:format("Old--------~p~n",[Code]),
        ok
    end,
    Buffer
                end,
  case file:open(FilePathName,[read]) of
    {_,S} ->
      cPol_util:start_parsing(S,ForEachLine,[]);
    Error -> Error
  end.

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