%%%-------------------------------------------------------------------
%%% Created : 19. Apr 2020 20:24 น.
%%%-------------------------------------------------------------------
-module(cPol_util).

-type name() :: string() | atom() | binary().

%% API
-export([start_parsing/3, recursively_list_dir/1,
  recursively_list_dir/2]).

start_parsing(S,ForEachLine,Opaque)->
  Line = io:get_line(S,''),
  case Line of
    eof -> {ok,Opaque};
    "\n" -> start_parsing(S,ForEachLine,Opaque);
    "\r\n" -> start_parsing(S,ForEachLine,Opaque);
    _ ->
      NewOpaque = ForEachLine(scanner(clean(clean(Line,10),13)),Opaque),
      start_parsing(S,ForEachLine,NewOpaque)
  end.

scan(InitString,Char,[Head|Buffer]) when Head == Char ->
  {lists:reverse(InitString),Buffer};
scan(InitString,Char,[Head|Buffer]) when Head =/= Char ->
  scan([Head|InitString],Char,Buffer);
scan(X,_,Buffer) when Buffer == [] -> {done,lists:reverse(X)}.
scanner(Text)-> lists:reverse(traverse_text(Text,[])).

traverse_text(Text,Buff)->
  case scan("",$,,Text) of
    {done,SomeText}-> [SomeText|Buff];
    {Value,Rem}-> traverse_text(Rem,[Value|Buff])
  end.

clean(Text,Char)->
  string:strip(string:strip(Text,right,Char),left,Char).

-spec recursively_list_dir(Dir::name()) ->
  {ok, [string()]} | {error, atom()}.

recursively_list_dir(Dir) ->
  recursively_list_dir(Dir, false).

-spec recursively_list_dir(Dir::name(), FilesOnly::boolean()) ->
{ok, [string()]} | {error, atom()}.

recursively_list_dir(Dir, FilesOnly) ->
  case filelib:is_file(Dir) of
    true ->
      case filelib:is_dir(Dir) of
        true -> {ok, recursively_list_dir([Dir], FilesOnly, [])};
        false -> {error, enotdir}
      end;
    false -> {error, enoent}
  end.

recursively_list_dir([], _FilesOnly, Acc) -> Acc;
recursively_list_dir([Path|Paths], FilesOnly, Acc) ->
  recursively_list_dir(Paths, FilesOnly,
    case filelib:is_dir(Path) of
      false ->
        %io:format("D Test--------~p~n",[Acc]),
        [Path | Acc];
      true ->
        {ok, Listing} = file:list_dir(Path),
        %io:format("D Listing-+++++++++++++++-------~p~n",[Listing]),
        SubPaths = [filename:join(Path, Name) || Name <- Listing],
        recursively_list_dir(SubPaths, FilesOnly,
          case FilesOnly of
            true -> Acc;
            false -> Acc
            %false -> [Path | Acc]
          end)
    end).

even_list([])-> [];
even_list([H|T]) ->
  case string:find(H,":") of
    nomatch->
      %io:format("----------~n"),
      ok;
    _ -> io:format("Value:~p~n",[H])
  end,
  %io:format("Value: ~p~n", [H]),
  [H|even_list(T)].

