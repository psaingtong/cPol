%%%-------------------------------------------------------------------
%%% @author wt
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Apr 2020 13:03 น.
%%%-------------------------------------------------------------------
-module(cPol_uitl1).
-author("wt").

-export ([
  %%list
  create_list/1, fetch_list/2, test_list/1, parmap_create_list/1 , ins_list/3, parallel_list/1,
  para_fetch_list/2, pfetch_list/1,

  %%dict
  create_dict/1, fetch_dict/2, test_dict/1, parmap_create_dict/1 , ins_dict/3, parallel_dict/1,

  %queue
  create_q/1, fetch_q/2, test_q/1, parmap_create_q/1, ins_q/3, parallel_q/1,

  %set
  create_set/1, fetch_set/2, test_set/1, parmap_create_set/1 , ins_set/3, parallel_set/1,

  create/1, multi_create/0,
  pcreate/1, parallel_multi_create/0

  %test/1 , multi_test/0
]).

%%creation tests

%% For List
create_list(N) ->
  lists:foldl ( fun(X,Prev) -> Prev ++ [X] end, [] , lists:seq(1,N)).

test_list(N) ->
  {R1,List} = timer:tc(?MODULE, create_list, [N]),
  %%Set = lists:foldl(fun(X,Prev) -> sets:add_element(X,Prev) end,SET, lists:seq(1,N)),
  {R2,_} = timer:tc(?MODULE, fetch_list,[ N, List ]),
  {list,inserT,R1,fetchT,R2}.

%% For Dict
create_dict(N) ->
  lists:foldl( fun(X,Prev)-> dict:append([],X,Prev) end, dict:new(), lists:seq(1,N)).

test_dict(N) ->
  {R1,Dict} = timer:tc(?MODULE, create_dict, [N]),
  %%Set = lists:foldl(fun(X,Prev) -> sets:add_element(X,Prev) end,SET, lists:seq(1,N)),
  {R2,_} = timer:tc(?MODULE, fetch_dict,[ N, Dict ]),
  {dict,inserT,R1,fetchT,R2}.

%% For Queue
create_q(N) ->
  lists:foldl(fun(X,Prev) -> queue:in(X,Prev) end, queue:new() , lists:seq(1,N)).

test_q(N)->
  {R1,Q}  = timer:tc(?MODULE, create_q,[N]),
  %%Q = lists:foldl(fun(X,Prev) -> queue:in(X,Prev) end,Q0, lists:seq(1,N)),
  {R2,_} = timer:tc(?MODULE, fetch_q, [ N,Q ] ),
  {queue,inserT,R1,fetchT,R2}.

%% For Set
create_set(N) ->
  SET = sets:new(),
  lists:foldl(fun(X,Prev) -> sets:add_element(X,Prev) end,SET, lists:seq(1,N)).

test_set(N) ->
  {R1,Set} = timer:tc(?MODULE, create_set, [N]),
  %%Set = lists:foldl(fun(X,Prev) -> sets:add_element(X,Prev) end,SET, lists:seq(1,N)),
  {R2,_} = timer:tc(?MODULE, fetch_set,[ N, Set ]),
  {set,inserT,R1,fetchT,R2}.

create(N)->
  [   timer:tc(?MODULE, X , [N])  || X <- [ test_list, test_dict, test_q,test_set ] ].

xmulti_create()->
  [ ?MODULE:create(X) || X<- [10,100,1000,10000,100000] ].

multi_create() ->
  InputRange = [10,100,1000,10000,100000],
  lists:map(fun(X) ->
    ?MODULE:create(X)
            end,InputRange).

%%fetching midpoint tests
fetch_q(N,Q)->
  fetch_q(N,Q,100).

fetch_q(N,Q,Find) ->
  F = fun(I) -> queue:out_r(I) end,
  R = lists:foldl( fun(_X,{Bool,PrevQ} ) ->
    {{value, Ele},QQ} = F(PrevQ),
    Ret1 = case Ele of
             Temp when Temp =:= Find ->
               true;
             _ ->
               Bool
           end,
    Ret2 = QQ,

    {Ret1,Ret2}

                   end,{false,Q},
    lists:seq(1,N)),
  R.

fetch_set(N,Set) ->
  fetch_set(N,Set,100).

fetch_set(_N,Set,Find) ->
  Return = sets:is_element(Find,Set),
  Return.

fetch_list(N,List) ->
  fetch_list(N,List,500).

fetch_list(_N,List,Find) ->
  Ret = lists:foldl(fun(X,Prev) when X =:= Find -> true;
    (X, Prev) -> Prev
                    end,false,List),
  Ret.

fetch_dict(N,Dict) ->
  {ok,List} = dict:find([],Dict),
  fetch_dict(N,List,500).

fetch_dict(_N,List,Find) ->
  Ret = lists:foldl(fun(X,Prev) when X =:= Find -> true;
    (X, Prev) -> Prev
                    end,false,List),
  Ret.

%% parallel operation

%% Parallel Map for Queue
parallel_q(N) ->
  {R1,Set} = timer:tc(?MODULE, parmap_create_q, [N]),
  {parallel_q,pcreate,R1}.

parmap_create_q(N) ->

  PID = spawn(fun() ->
    ?MODULE:ins_q( queue:new(),0,N) end),
  [PID ! {self(),X} || X <- lists:seq(1,N) ],
  receive
    {ok, Q} ->
      %%io:format("~n Still insertin, Q till now ~p",[Q]),
      ok;
    {done, Q}  ->
      io:format("~n *******DONE*********~n ~p",[Q]);
    _E ->
      io:format("unexpected ~p",[_E])
  end.

ins_q(Q,Ctr, Max) ->
  receive
    {From, N} ->
      %%io:format("~n insert ~p, ctr ~p, Q ~p ~n",[N,Ctr,Q]),
      NewQ = queue:in( N, Q) ,
      case Ctr
      of Temp when Temp < Max ->
        From ! {ok, NewQ};
        _->
          From ! {done, NewQ}
      end,
      ?MODULE:ins_q(NewQ,Ctr+1, Max);
    _E ->
      io:format("unexpected ~p",[_E]),
      ?MODULE:ins_q(Q, Ctr, Max)
  end.

%% Parallel Map for set
parallel_set(N) ->
  {R1,Set} = timer:tc(?MODULE, parmap_create_set, [N]),
  {parallel_set,pcreate,R1}.

parmap_create_set(N) ->

  PID = spawn(fun() ->
    ?MODULE:ins_set( sets:new(),0,N) end),
  [PID ! {self(),X} || X <- lists:seq(1,N) ],
  receive
    {ok, Sets} ->
      %%io:format("~n Still insertin, Sets till now ~p",[Sets]),
      ok;
    {done, Sets}  ->
      io:format("~n *******DONE*********~n ~p",[Sets]);
    _E ->
      io:format("unexpected ~p",[_E])
  end.

ins_set(Sets,Ctr, Max) ->
  receive
    {From, N} ->
      %%io:format("~n insert ~p, ctr ~p, Sets ~p ~n",[N,Ctr,Sets]),
      NewSets = sets:add_element(N,Sets),

      case Ctr
      of Temp when Temp < Max ->
        From ! {ok, NewSets};
        _->
          From ! {done, NewSets}
      end,
      ?MODULE:ins_set(NewSets,Ctr+1, Max);
    _E ->
      io:format("unexpected ~p",[_E]),
      ?MODULE:ins_set(Sets, Ctr, Max)
  end.

%% Parallel Map for dict
parallel_dict(N) ->
  {R1,Set} = timer:tc(?MODULE, parmap_create_dict, [N]),
  {parallel_dict,pcreate,R1}.

parmap_create_dict(N) ->

  PID = spawn(fun() ->
    ?MODULE:ins_dict( dict:new(),0,N) end),
  [PID ! {self(),X} || X <- lists:seq(1,N) ],
  receive
    {ok, Dict} ->
      %%io:format("~n Still insertin, Sets till now ~p",[Dict]),
      ok;
    {done, Dict}  ->
      io:format("~n *******DONE*********~n ~p",[Dict]);
    _E ->
      io:format("unexpected ~p",[_E])
  end.

ins_dict(Dict,Ctr, Max) ->
  receive
    {From, N} ->
      %%io:format("~n insert ~p, ctr ~p, Dict ~p ~n",[N,Ctr,Dict]),
      NewDict = dict:append([],N,Dict),

      case Ctr
      of Temp when Temp < Max ->
        From ! {ok, NewDict};
        _->
          From ! {done, NewDict}
      end,
      ?MODULE:ins_dict(NewDict,Ctr+1, Max);
    _E ->
      io:format("unexpected ~p",[_E]),
      ?MODULE:ins_dict(Dict, Ctr, Max)
  end.

%% Parallel Map for list
parallel_list(N) ->
  {R1,List} = timer:tc(?MODULE, parmap_create_list, [N]),
  {R2,_} = timer:tc(?MODULE, para_fetch_list, [N,List]),
  {parallel_list,pCreate,R1,pFetch,R2}.

parmap_create_list(N) ->

  PID = spawn(fun() ->
    ?MODULE:ins_list( [],0,N) end),
  [PID ! {self(),X} || X <- lists:seq(1,N) ],
  receive
    {ok, List} ->
      %%io:format("~n Still insertin, List till now ~p",[List]),
      ok;
    {done, List}  ->
      io:format("~n *******DONE*********~n ~p",[List]);
    _E ->
      io:format("unexpected ~p",[_E])
  end.

ins_list(List,Ctr, Max) ->
  receive
    {From, N} ->
      %%io:format("~n insert ~p, ctr ~p, Sets ~p ~n",[N,Ctr,Dict]),
      NewList = List ++ [N] ,

      case Ctr
      of Temp when Temp < Max ->
        From ! {ok, NewList};
        _->
          From ! {done, NewList}
      end,
      ?MODULE:ins_list(NewList,Ctr+1, Max);
    _E ->
      io:format("unexpected ~p",[_E]),
      ?MODULE:ins_list(List, Ctr, Max)
  end.

para_fetch_list(List, FindN) ->
  Pid = spawn(fun() ->
    ?MODULE:pfetch_list(FindN) end),
  Self = self(),
  Now1 = now(),
  lists:map ( fun(X) ->
    Pid ! {Self, X},
    receive
      {true,Find} ->
        io:format("~n Found ~p ",[Find]),
        true;
      {false,Find}  ->
        %io:format("~n NOT FOUND ~p ",[Find]),
        false;
      _E ->
        io:format("para main unexpected ~p",[_E])
    after 4000 ->
      io:format("timerout ",[])

    end
              end, List ) ,
  Now2 = now(),
  timer:now_diff(Now2,Now1).

pfetch_list(Find) ->
  receive
    {From, CurrN} ->

      _Ret = case CurrN of
               Temp when Temp =:= Find ->
                 From ! {true,Find},
                 true;
               _ ->
                 From ! {false,Find},
                 false
             end,
      %%io:format("~n insert ~p, ctr ~p, Sets ~p ~n",[N,Ctr,Dict]),
      ?MODULE:pfetch_list(Find);
    _E ->
      io:format("pfetch unexpected ~p",[_E]),
      ?MODULE:pfetch_list(Find)
  end.

pcreate(N)->
  [   timer:tc(?MODULE, X , [N])  || X <- [ parallel_list ] ].

parallel_multi_create() ->
  InputRange = [10,100,1000,10000],
  lists:map(fun(X) ->
    ?MODULE:pcreate(X)
            end,InputRange).
