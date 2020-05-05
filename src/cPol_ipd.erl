%%%-------------------------------------------------------------------
%%% Created : 21. Apr 2020 7:58 น.
%%%-------------------------------------------------------------------
-module(cPol_ipd).

-include("cPol_db.hrl").
-include_lib("stdlib/include/qlc.hrl").
%% API
-export([create_table/1, init_sample/0, test/0, an/1, pdx/1, sdx/1, get_an/1, age/1, sex/1, update_an/1]).
-export_type([ipd/0]).

-opaque ipd() :: #cPol_ipd{}.

-spec create_table([node()]) -> ok.
create_table(Nodes) ->
  {atomic, ok} = mnesia:create_table(cPol_ipd,
    [{attributes, record_info(fields, cPol_ipd)},
      {disc_copies, Nodes}]),
  ok.

init_sample() ->
  An="6300123",
  Pdx="I213",
  Sdx="E119:I10:N182:E875:A419:I209",
  Age=35,
  Sex="M",
  case get_an(An) of
    undefined ->
      F = fun() ->
        mnesia:dirty_write(
          #cPol_ipd{an=An,pdx=Pdx,sdx=Sdx,age=Age,sex=Sex})
          end,
      ok = mnesia:activity(transaction, F);
    _ ->
      ok
  end.

update_an(An) ->
  case get_an(An) of
    undefined ->ok;
    Ipd ->
      F = fun() ->
        mnesia:write(
          Ipd#cPol_ipd{age=35,sex="M"})
          end,
      ok = mnesia:activity(transaction, F)
  end,
  ok.

test() ->
  An="6300123",
  A1=get_an(An),
  io:format("An Test--------~p~n",[A1]),
  An_db=an(A1),
  io:format("An DB--------~p~n",[An_db]),
  Pdx_db=pdx(A1),
  io:format("Pdx DB--------~p~n",[Pdx_db]),
  Sdx_db=sdx(A1),
  io:format("Sdx DB--------~p~n",[Sdx_db]),
  ok.


-spec get_an(binary()) -> ipd() | undefined.
get_an(An) ->
  F = fun() ->
    qlc:e(qlc:q(
      [X || X = #cPol_ipd{an=A} <- mnesia:table(cPol_ipd),
        string:equal(An, A, true)]))
      end,
  case mnesia:activity(transaction, F) of
    [Ipd] ->
      Ipd;
    _ ->
      undefined
  end .

-spec an(ipd()) -> binary().
an(Ipd) ->
  Ipd#cPol_ipd.an.
-spec pdx(ipd()) -> binary().
pdx(Ipd) ->
  Ipd#cPol_ipd.pdx.
-spec sdx(ipd()) -> binary().
sdx(Ipd) ->
  Ipd#cPol_ipd.sdx.
-spec age(ipd()) -> binary().
age(Ipd) ->
  Ipd#cPol_ipd.age.
-spec sex(ipd()) -> binary().
sex(Ipd) ->
  Ipd#cPol_ipd.sex.
