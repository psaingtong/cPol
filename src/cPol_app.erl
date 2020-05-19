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
   %cPol_ipd:update_an(An),
    %Drg=cPol_drg:get_drg(An),
    %io:format("DRG--------~p~n",[Drg]),
    %%%
    %%Mdc - init
    %cPol_mdc:check_data(),
    %cPol_mdc:import_data(),
    %cPol_mdc:import_data_ax(),
    %Icd10=cPol_mdc:get_icd10("25:a812:ax"),
    %io:format("Icd10--------~p~n",[Icd10]),
    %%%%%
    %cPol_icd10:check_pdx("c602"),

    %cPol_pcl:get_pdc(),
    %cPol_pcl:initcc(),

    %%%%
    %cPol_cc:get_value_in_range(""),

    %cPol_cc:import_data(),

    %cPol_icd10:list_data("/home/datawiz5/utth/cc/p050.csv"),
    %cPol_icd10:import_code("/home/datawiz5/utth/ecode/e_dxcode6.csv"),
    %cPol_test:test1(),
    %Te1=cPol_db:get_an("6300123"),
    %io:format("D Test--------~p~n",[Te1]),


    %%%%
    %Data=cPol_pcl:init(),
    %FilePath="/home/datawiz5/utth/cc_app",
    %FileName="k250.csv",
    %FilePathName=string:join([FilePath, FileName], "/"),
    %io:format("D Test--------~p~n",[FilePathName]),

    %cPol_pcl:import_data(FilePath,FileName),

    %Te3=cPol_pcl:get_code("i10:0011"),
    %io:format("D Test--------~p~n",[Te3]),

    cPol_pcl:test(),

    cPol_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
