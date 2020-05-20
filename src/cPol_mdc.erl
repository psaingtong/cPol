%%%-------------------------------------------------------------------
%%% Created : 05. May 2020 20:06 น.
%%%-------------------------------------------------------------------
-module(cPol_mdc).

-include("cPol_db.hrl").
-include_lib("stdlib/include/qlc.hrl").
%% API
-export([init/1, get_dc/1, create_table/1, get_icd10/1]).
-export_type([dc/0]).

-opaque dc() :: #cPol_dc{}.

-spec create_table([node()]) -> ok.
create_table(Nodes) ->
  {atomic, ok} = mnesia:create_table(cPol_dc,
    [{attributes, record_info(fields, cPol_dc)},
      {disc_copies, Nodes}]),
  ok.

init(FilePath)->
  {ok,HH}=cPol_util:recursively_list_dir(FilePath),
  even_list_dc(FilePath,HH),
  ok.

even_list_dc(FilePath,[])-> [];
even_list_dc(FilePath,[H|T]) ->
  [A,_] = string:tokens(H, "."),
  [_,_,Mgr,F] = string:tokens(A, "/"),
  list_data(Mgr,F,H),
  even_list_dc(FilePath,T).

list_data(Mgr,F,FilePath)->
  ForEachLine = fun(Line,Buffer)->
    D1=string:slice(F,0,2),
    if
      D1=:="dd" ->ok ;
      true ->
        if
          D1=:="ax" ->
            get_data_ax(Mgr,F,FilePath);
          true ->
            [A,B] = string:tokens(F, "_"),
            if
              B=:="icd9" ->
                get_data_icd(Mgr,FilePath);
              true ->
                get_data_icd(Mgr,FilePath)
            end

        end
    end,
    Buffer
                end,
  case file:open(FilePath,[read]) of
    {_,S} ->
      cPol_util:start_parsing(S,ForEachLine,[]);
    Error -> Error
  end.


get_data_ax(Mgr,F,FilePath)->
  ForEachLine = fun(Line,Buffer)->
    [A|[]]=Line,
    %io:format("LineFFF: ~p~n",[F]),
    Code0=string:join([Mgr, A], ":"),
    Code=string:join([Code0, F], ":"),
    io:format("code===: ~p~n",[Code]),
    case get_icd10(Code) of
        undefined->
          mnesia:dirty_write(
            #cPol_dc{code=Code,mdc=Mgr,mcode=A,ax=F});
      _ ->ok
    end,
    Buffer
                end,
  case file:open(FilePath,[read]) of
    {_,S} ->
      cPol_util:start_parsing(S,ForEachLine,[]);
    Error -> Error
  end.
get_data_icd(Mgr,FilePath)->
  ForEachLine = fun(Line,Buffer)->
    [A,B|[]]=Line,
    %io:format("Line: ~p~p~n",[A,B]),
    Code=string:join([Mgr, A], ":"),
    io:format("code===: ~p~n",[Code]),
    case get_icd10(Code) of
      undefined->
        mnesia:dirty_write(
          #cPol_dc{code=Code,mdc=Mgr,mcode=A,key=B});
      _ ->ok
    end,
    Buffer
                end,
  case file:open(FilePath,[read]) of
    {_,S} ->
      cPol_util:start_parsing(S,ForEachLine,[]);
    Error -> Error
  end.

get_dc(Mdc)->
  case Mdc of
      5->
        io:format("Mdc--------~p~n",[Mdc]),
        ok;
    _ -> undefined
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