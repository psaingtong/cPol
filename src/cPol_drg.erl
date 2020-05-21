%%%-------------------------------------------------------------------
%%% Created : 22. Apr 2020 20:04 น.
%%%-------------------------------------------------------------------
-module(cPol_drg).


%% API
-export([get_drg/1]).


get_drg(An) ->
  A1=cPol_ipd:get_an(An),
  %io:format("An Test--------~p~n",[A1]),
  %Vpdx=cPol_icd10:check_dx(A1),
  %io:format("Pdx=~p~n",[Vpdx]),
  case cPol_icd10:check_dx(A1) of
    undefined->Drg="26519",Drg;
    Icd10 ->get_drg_1(A1,Icd10)
  end.
get_drg_1(A1,Icd10) ->
  Pdx=cPol_ipd:pdx(A1),
  %io:format("Pdx=~p~n",[Pdx]),
  Sdx=cPol_ipd:sdx(A1),
  %io:format("Sdx=~p~n",[Sdx]),
  S1=re:split(Sdx,"[:]",[{return,list}]),
  %io:format("Sdx1=~p~n",[S1]),
  D2=cPol_icd10:even_list_dx(S1),
  io:format("Sdx-D2 ::: ~p~n", [D2]),
  [A|B]=D2,
  DA=[Pdx|[A]],
  %io:format("DA ::: ~p~n", [DA]),
  %%find primary Dx
  Mpdx=dagger_as(DA),
  io:format("PDX ::: ~p~n", [Mpdx]),
  if
    Mpdx=:=Pdx -> Tdx=[Pdx|[A]]++B,
      Tdx;
    true -> Tdx=[A|[Pdx]]++B,
      Tdx
  end,
  %%find MDC of main dx
  Mdc=cPol_icd10:mdc(cPol_icd10:get_code(Mpdx)),
  %io:format("MDC ::: ~p~n", [Mdc]),
  cPol_mdc:get_dc(Mdc,Tdx),

  ok.

dagger_as(DA) ->
  [A,B|[]] = DA,
  %io:format("D=~p-A=~p~n", [A,B]),
  Icd1=cPol_icd10:get_code(A),
  %io:format("D1::: ~p~n", [Icd1]),
  D11=cPol_icd10:das(Icd1),
  %io:format("D11::: ~p~n", [D11]),
  case cPol_icd10:das(Icd1) of
      undefined->A;
    As ->
      if
        As=:=B ->B ;
        true -> A
      end
  end.
