%%%-------------------------------------------------------------------
%%% @author wt
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Apr 2020 10:21 น.
%%%-------------------------------------------------------------------
-module(cPol_db).
-author("wt").
-include("cPol_db.hrl").
%% API
-export_type([test1/0]).
-export([install/0, get_an/1]).

-opaque test1() :: #cPol_test1{}.

install() ->
  Nodes = [node()],
  ok = application:stop(mnesia),
  ok = mnesia:create_schema(Nodes),
  ok = application:start(mnesia),
  ok = create_test_table(Nodes).

-spec create_test_table([node()]) -> ok.
create_test_table(Nodes) ->
  {atomic, ok} = mnesia:create_table(cPol_test1,
    [{attributes, record_info(fields, cPol_test1)},
      {disc_copies, Nodes}]),
  An="6300123",
  Pdx="I213",
  Sdx1="E119",
  Sdx2="I10",
  Sdx3="N182",
  Sdx4="I092",
  Sdx5="K250",
  Sdx6="I209",
  Sdx7="A419",
  Sdx8="E875",
  Sdx9="E876",
  F = fun() ->
    mnesia:write(
      #cPol_test1{an=An, pdx=Pdx, sdx1=Sdx1, sdx2=Sdx2,
        sdx3=Sdx3,
        sdx4=Sdx4,sdx5=Sdx5,sdx6=Sdx6, sdx7=Sdx7,sdx8=Sdx8,sdx9=Sdx9})
      end,
  ok = mnesia:activity(transaction, F).

-spec get_an(binary()) -> test1() | undefined.
get_an(An) ->
  F = fun() ->
    mnesia:read({cPol_test1, An})
      end,
  case mnesia:activity(transaction, F) of
    [Test1] ->
      Test1;
    _ ->
      undefined
  end .