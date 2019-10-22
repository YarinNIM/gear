%% @author Yarin NIM <yarin.nim@gmail.com>
%% @copyright 2019 Yarin NIM
%% @version 0.1
%% @title This is for home of account
%% @doc Description about documentation

-module(account_home_controller).
-export([
    home_action/3,
    init_info_action/3,

    test_get_action/3,
    test_post_action/3
]).


%% @doc Render the home page of the account panel
home_action(Req, State, _) ->
    Res = resource:render_page(#{
        %header => <<"<div id=\"pnl-menu\"></div><div id=\"pnl-company\"></div>">>,
        js => [ 
            config:base_url("js/app.js", State),
            config:base_url("js/action.js", State)
        ]
    }, Req, State),
    {Res, Req, State}.


%% @doc Get the account information,
%% if the account select a company to access,
%% it will also returns the company information as well
init_info_action(Req, State, _) ->
    #{ account_id:= Aid} = State,
    Account = account_model:get_account(Aid),
    Res = #{
        error => false,
        account =>  Account#{permissions => permissions(State)},
        company => active_company(State)
    },

    {Res, Req, State}.

permissions(State) ->
    case company_account_model:account_permissions(State) of
        error -> #{};
        P -> P
    end.


%% @doc return the active company. The company which
%% the account is selected to work with.
active_company(State) ->
    case session:get(company_id, State) of
        undefined -> #{};
        Cid -> company_model:get_company(Cid)
    end.

test_get_action(Req, State, _) ->
    QS = cowboy_req:parse_qs(Req),
    io:format("Query String: ~p~n",[QS]),
    {QS, Req, State}.

test_post_action(Req, State, _) ->
    #{body_data:= Post}= State,
    io:format("Body: ~p~n",[Post]),
    {Post, Req, State}.
