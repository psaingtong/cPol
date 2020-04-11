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
    cPol_test:test1(),

    %Test1=cPol_db:get_an("6300123"),
    %io:format("Test1333: ~p~n",[Test1]),
    Test2=cPol_db:get_code("X9424"),
    io:format("Test_icd10: ~p~n",[Test2]),
    %cPol_test:parse("/home/datawiz5/utth/icd_10_test2.csv"),
    %cPol_test:importcode("/home/datawiz5/utth/icd_10_test6.csv"),
    %cPol_test:parse("/home/datawiz5/utth/drg-dev2/e_dxcode1.csv"),
    cPol_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
