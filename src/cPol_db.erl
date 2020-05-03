%%%-------------------------------------------------------------------
%%% Created : 09. Apr 2020 10:21 น.
%%%-------------------------------------------------------------------
-module(cPol_db).

-include("cPol_db.hrl").
-include_lib("stdlib/include/qlc.hrl").
%% API

-export([install/0]).



install() ->
  Nodes = [node()],
  ok = application:stop(mnesia),

  ok = mnesia:create_schema(Nodes),
  ok = application:start(mnesia),
  cPol_icd10:create_table(Nodes),
  %cPol_pcl:create_table(Nodes),
  cPol_ipd:create_table(Nodes).





