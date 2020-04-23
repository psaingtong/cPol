%%%-------------------------------------------------------------------
%%% Created : 21. Apr 2020 7:58 น.
%%%-------------------------------------------------------------------
-module(cPol_ipd).

-include("cPol_db.hrl").
-include_lib("stdlib/include/qlc.hrl").
%% API
-export([create_table/1]).

-spec create_table([node()]) -> ok.
create_table(Nodes) ->
  {atomic, ok} = mnesia:create_table(cPol_ipd,
    [{attributes, record_info(fields, cPol_ipd)},
      {disc_copies, Nodes}]),
  ok.
