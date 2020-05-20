%%%-------------------------------------------------------------------
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

    %%init icd10
    %cPol_db:init_icd10(),

    %%A1-A4
    %cPol_db:update_icd10_das(),
    %cPol_db:update_icd10_un_pdx(),
    %cPol_db:update_icd10_age(),
    %cPol_db:update_icd10_sex(),
    %A=cPol_db:get_code("i213"),
    %io:format("D Test--------~p~n",[A]),
    %%%
    %cPol_ipd:init_sample(),

    %cPol_ipd:test(),
    %%%
    %An="6300123",

    %Drg=cPol_drg:get_drg(An),
    %io:format("DRG--------~p~n",[Drg]),
    %%%
    %%Mdc - init
    FilePathMdc="data/mdc/22",
    %cPol_mdc:init(FilePathMdc),

    %Icd10=cPol_mdc:get_icd10("22:9915:ax_22pex"),
    %io:format("Icd10--------~p~n",[Icd10]),
    %%%%%
    %cPol_icd10:check_pdx("c602"),

    %%%%
    cPol_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
