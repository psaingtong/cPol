%%%-------------------------------------------------------------------
%%% Created : 16. Apr 2020 19:48 น.
%%%-------------------------------------------------------------------
-module(cPol_icd10).


-include("cPol_db.hrl").
-include_lib("stdlib/include/qlc.hrl").

-export_type([icd10/0]).
-export([create_table/1, get_code/1, check_pdx/1, check_dx/1, code/1, mdc/1, das/1,un_pdx/1,age/1,sex/1]).

-opaque icd10() :: #cPol_icd10{}.

-spec create_table([node()]) -> ok.
create_table(Nodes) ->
  {atomic, ok} = mnesia:create_table(cPol_icd10,
    [{attributes, record_info(fields, cPol_icd10)},
      {disc_copies, Nodes}]),
  ok.
check_dx(Ipd) ->
  Cpdx=cPol_ipd:pdx(Ipd),
  %io:format("Pdx db--- ~p~n",[Cpdx]),
  case get_code(Cpdx) of
    undefined->
      ok;
    Icd10 ->
      %io:format("Cpdx--------~p~n",[Icd10]),
      %%A2
      case un_pdx(Icd10) of
        undefined->
          %%A3
          case age(Icd10) of
            undefined->
              %%A4
              case sex(Icd10) of
                undefined->code(Icd10);
                Sex ->
                  io:format("---code sex---~p~n",[Sex]),
                  io:format("---sex relate dx---~n"),
                  undefined
              end;

            Age ->
              %io:format("---code age---~p~n",[Age]),
              case dx_check_age(Age,cPol_ipd:age(Ipd)) of
                  undefined->
                    io:format("---age relate dx---~n"),
                    undefined;
                _ ->
                  code(Icd10)

              end

          end;
        _ ->
          io:format("---unaccept dx---~n"),
          undefined
      end
    %io:format("Cpdx--------~p~n",[Icd10]),
    %code(Icd10)
  end.

dx_check_age(Age,A1) ->
  if
    Age =:="PIF" ->
      if
         A1>1->
           %io:format("Pass Age------~n"),
           ok ;
        true -> undefined
      end;

    true -> undefined
  end.



check_pdx(Cpdx) ->
  io:format("Pdx db--- ~p~n",[Cpdx]),
  case get_code(Cpdx) of
    undefined->
    ok;
    Icd10 ->
      io:format("Cpdx--------~p~n",[Icd10]),
      %%A2
      case un_pdx(Icd10) of
        undefined->
          %%A3
          case age(Icd10) of
            undefined->
              %%A4
              case sex(Icd10) of
                undefined->code(Icd10);
                _ ->
                  io:format("---sex relate dx---~n"),
                  undefined
              end;

            _ ->
              io:format("---age relate dx---~n"),
              undefined
          end;
        _ ->
          io:format("---unaccept dx---~n"),
          undefined
      end
      %io:format("Cpdx--------~p~n",[Icd10]),
      %code(Icd10)
  end.

-spec get_code(binary()) -> icd10() | undefined.
get_code(Code) ->
  F = fun() ->
    qlc:e(qlc:q(
      [X || X = #cPol_icd10{code=C} <- mnesia:table(cPol_icd10),
        string:equal(Code, C, true)]))
      end,
  case mnesia:activity(transaction, F) of
    [Icd10] ->
      Icd10;
    _ ->
      undefined
  end .

-spec code(icd10()) -> binary().
code(Icd10) ->
  Icd10#cPol_icd10.code.
-spec mdc(icd10()) -> binary().
mdc(Icd10) ->
  Icd10#cPol_icd10.mdc.
-spec das(icd10()) -> binary().
das(Icd10) ->
  Icd10#cPol_icd10.das.
-spec un_pdx(icd10()) -> binary().
un_pdx(Icd10) ->
  Icd10#cPol_icd10.un_pdx.
-spec age(icd10()) -> binary().
age(Icd10) ->
  Icd10#cPol_icd10.age.
-spec sex(icd10()) -> binary().
sex(Icd10) ->
  Icd10#cPol_icd10.sex.