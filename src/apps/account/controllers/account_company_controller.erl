%% @author Yarin NIM <yarin.nim@gmail.com>
%% @copyright 2019 Yarin NIM
%% @version 0.1
%% @title Account
%% @doc Description about documentation

-module(account_company_controller).
-export([
    companies_action/3,
    select_company_action/3,
    get_active_action/3
]).

companies_action(Req, State, _) ->
    #{account_id:= Aid} = State,
    {#{
        error => false,
        companies => account_model:get_companies(Aid)
     }, Req, State}.


%% @doc Select a company to get access to
select_company_action(Req, State,  _) ->
    #{body_data:= Post, session_id:= Sid} = State,
    Aid = session:get(account_id, Sid),
    Cid = proplists:get_value(<<"company_id">>, Post),
    Res =  case company_account_model:get_permissions(Cid, Aid) of
        {error, Msg} -> {401, Msg};
        _Pers -> 
            session:set(company_id, type:to_integer(Cid), Sid),
            get_active(State)
    end,
    {Res, Req, State}.

get_active(State) ->
    #{ account_id:= Aid, session_id:= Sid} = State,
    Cid = session:get(company_id, Sid),
    #{
        error => false,
        company => company_model:get_company(Cid, true),
        account => #{
            id => Aid,
            permissions => company_account_model:get_permissions(Cid, Aid)
        }
    }.

%% @doc Return the active company information
get_active_action(Req, State, _) ->
    {get_active(State), Req, State}.

