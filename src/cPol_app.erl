%%%-------------------------------------------------------------------
%% @doc cPol public API
%% @end
%%%-------------------------------------------------------------------

-module(cPol_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    cPol_test:test1(),
    cPol_test:parse("/home/datawiz5/utth/drg-dev2/e_dxcode1.csv"),
    cPol_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
