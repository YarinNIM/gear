-module(event_dispatcher_server).
-behaviour(gen_server).
-record(state, {manager, handler, arg}).
-export([
    start_link/1,
    init/1,
    handle_call/3, handle_cast/2,
    handle_info/2
]).

start_link(Props) -> 
    gen_server:start_link({local, ?MODULE}, ?MODULE, Props, []).

init({EvntMng, Handler, Arg}) ->
    add_handler(EvntMng, Handler, Arg),
    {ok, #state{manager = EvntMng, handler = Handler, arg = Arg}}.

handle_call(_M, _F, S) -> {noreply, S}.
handle_cast(_M, S) -> {ok, S}.

handle_info({gen_event_EXIT, Handler, normal}, #state{handler=Handler} = State) ->
    io:format('Exit normal...~n'),
    {stop, normal, State};
handle_info({gen_event_EXIT, Handler, shutdown}, #state{handler=Handler} = State) ->
    io:format('Exit shutdown..~n'),
    {stop, normal, State};
handle_info({gen_event_EXIT, Handler, _Reason},
    #state{manager=Event, handler=Handler, arg=Arg} = State) ->
    add_handler(Event, Handler, Arg),
    {noreply, State}.

add_handler(Mng, Handler, Arg) -> gen_event:add_sup_handler(Mng, Handler, Arg).
