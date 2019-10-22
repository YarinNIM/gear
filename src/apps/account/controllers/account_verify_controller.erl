-module(account_verify_controller).
-export([
    verify_action/3
]).

verify_action(Req, State, Params) ->
    Res = case db:call(fun_account_verify, Params) of
        {error,_} -> {redirect, config:base_url(State)};
        _ ->  render(Req, State, <<"true">>)
    end,
    {Res, Req, State}.

render(Req, State, Valid) ->
    resource:render_page(#{
        js => [
            {index, config:base_url(<<"js/verify.js">>, State)},
            {local, config:locale_url(<<"verify">>, State)}
        ],
        on_script_loaded => [<<"_.Verify.init(",Valid/binary,");">>]
    }, Req, State).
