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
    %Te1=cPol_db:get_an("6300123"),
    %io:format("D Test--------~p~n",[Te1]),
    Data=cPol_pcl:init(),
    %cPol_test:parse("/home/wt/wt-dev/github-dev/cc_a_test1.csv"),
    %Data=[{"I213",2},{"E119",1},{"I10",1},{"N182",0},{"I092",1},{"K250",3},{"I209",0},{"A419",2},{"E875",1},{"E876",1}],
    cPol_pcl:even_print(Data),
    cPol_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
