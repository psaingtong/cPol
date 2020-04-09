%%%-------------------------------------------------------------------
%% @doc cPol public API
%% @end
%%%-------------------------------------------------------------------

-module(cPol_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    case mnesia:system_info(use_dir) of
        true ->
            ok;
        false ->
            cPol_db:install()
    end,
    %cPol_test:test1(),
    Te1=cPol_db:get_an("6300123"),
    %io:format("D Test--------~p~n",[Te1]),
    cPol_pcl:init(),
    %cPol_test:parse("/home/wt/wt-dev/github-dev/cc_a_test1.csv"),
    cPol_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
