%%%-------------------------------------------------------------------
%%% Created : 16. Apr 2020 19:48 น.
%%%-------------------------------------------------------------------
-module(cPol_icd10).


-include("cPol_db.hrl").
-include_lib("stdlib/include/qlc.hrl").

-export_type([icd10/0]).
-export([create_table/1, get_code/1]).

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