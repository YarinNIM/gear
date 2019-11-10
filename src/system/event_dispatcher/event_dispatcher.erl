%%%-------------------------------------------------------------------
%% @doc event_server public API
%% @end
%%%-------------------------------------------------------------------

-module(event_dispatcher).
-behaviour(supervisor).
-define(SUP, event_dispatcher_sup).
-include("events.hrl").
-define(EVENT, ?MODULE).

%% Application callbacks
-export([start/0, start_link/0, init/1]).
-export([
    event_manager/0,
    dispatch/1, dispatch/2,
    handlers/0,  children/0
]).

%%====================================================================
%% API
%%====================================================================
start() -> start_link().
start_link() -> supervisor:start_link({local, ?SUP}, ?MODULE, []).

event_manager() -> [#{
    id => ?MODULE,
    start => {gen_event, start_link, [{local, ?EVENT}]},
    restart => permanent,
    shutdown => 5000,
    type => worker,
    modules => [dynamic]
}].



init([]) ->
    io:format('init...~n'),
    Events = maps:to_list(config:event_listener()),
    Pool_specs = lists:map(fun({Handler,Arg}) ->
        #{
            id => Handler,
            start => {event_dispatcher_server, start_link, [{?EVENT, Handler, Arg}]},
            restart => permanent,
            shutdown => 2000,
            type => worker,
            modules => [event_dispatcher_server]
        }
    end, Events),
    Specs = event_manager() ++ Pool_specs,
    {ok, {{one_for_one, 10, 10}, Specs}}.
    
dispatch(E) -> dispatch(E, #{}).
dispatch(E, D) -> 
    case lists:member(E, ?EVENTS) of
        true ->
            try
                io:format(" - Raising an event [~p]...~n", [E]),
                gen_event:notify(?EVENT, {E, D})
            catch
                Class:Reason ->
                    io:format('Error: ~p:~p~n',[Class, Reason])
            end;
        _ ->
            io:format(" - Event [~p] does not exist...~n",[E])
    end.

handlers() -> gen_event:which_handlers(?EVENT).

children() -> supervisor:which_children(?SUP).

%%--------------------------------------------------------------------
%stop(_State) ->
%   ok.

%%====================================================================
%% Internal functions
%%====================================================================
