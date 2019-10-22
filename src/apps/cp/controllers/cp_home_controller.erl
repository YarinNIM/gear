-module(cp_home_controller).
-behaviour(cp_behaviour).
-export([
    init_action/3, permission_keys_action/3,
    index_action/3, init_resource_action/3, select_company_action/3,
    resource_action/3
]).

init_action(Req, State, P) -> 
    cp_behaviour:handle(Req, State, P, ?MODULE).

index_action(Req, State, _) ->
    Res = resource:render_page(#{}, Req, State),
    {Res, Req, State}.

init_resource_action(Req, State, _) ->
    #{ session_id := Sid} = State,
    Aid = session:get(account_id, Sid),
    Cid = session:get(company_id, Sid),
    Res = #{
        company => company_model:get_company(Cid, true),
        account => #{
          id => Aid,
          permissions => company_account_model:account_permissions(Cid, Aid)
        }
    },

    {Res, Req, State}.

permission_keys_action(Req, State, _ )->
    Keys = gear_permission_key:company(),
    Html = template:render(permission_keys, #{
        permission => jsx:decode(jsx:encode(Keys))
    }),
    {Html, Req, State}.


select_company_action(Req, State, [Cid]) ->
    #{session_id:= Sid} = State,
    Aid = session:get(account_id, Sid),
    Res = case company_account_model:account_permissions(Cid, Aid) of
        {error, Msg}-> {halt, Msg};
        _ -> 
            session:set(company_id, Cid, Sid),
            {redirect, config:parent_url(State)}
    end,
    {Res, Req, State}.

resource_action(Req, State, _ ) ->
    Res = gear_resource:get_resource(Req),
    {Res, Req, State}.
