%%%-------------------------------------------------------------------
%%% Created : 19. Apr 2020 20:24 น.
%%%-------------------------------------------------------------------
-module(cPol_util).

-type name() :: string() | atom() | binary().

%% API
-export([recursively_list_dir/1,
  recursively_list_dir/2]).


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
        io:format("D Listing--------~p~n",[Listing]),
        SubPaths = [filename:join(Path, Name) || Name <- Listing],
        recursively_list_dir(SubPaths, FilesOnly,
          case FilesOnly of
            true -> Acc;
            false -> [Path | Acc]
          end)
    end).