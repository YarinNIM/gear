-module(admin_home_controller).
-behaviour(admin_behaviour).
-export([
    init_action/3,
    index_action/3, resource_action/3
]).

init_action(Req, State, P) -> admin_behaviour:handle(Req, State, P, ?MODULE).

index_action(Req, State, _) ->
    io:format('State: ~p~n',[config:app_config(State)]),
    Res = resource:render_page(#{}, Req, State),
    {Res, Req, State}.

resource_action(Req, State, _) ->
    #{ session_id := Sid} = State,
    Aid = session:get(account_id, Sid),

    Ac = admin_account_model:get_account(Aid),
    Res = #{
        admin_permission_key => resource_controller:permission_keys(<<"admin">>), %%gear_permission_key:admin(),
        account => Ac
    },
    {Res, Req, State}.


