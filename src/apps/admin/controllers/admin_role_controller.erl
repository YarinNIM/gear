-module(admin_role_controller).
-behaviour(admin_behaviour).


-export([
    init_action/3,
    get_roles_action/3,
    insert_role_action/3, update_role_action/3, delete_role_action/3
]).

init_action(Req, State, P) ->  admin_behaviour:handle(Req, State, P, ?MODULE).

get_roles_action(Req, State, _) ->
    %#{status := Status} = cowboy_req:match_qs([{status, [], any}], Req),
    Res = #{
        admin_roles => role_permission_model:get_admin_roles(),
        company_roles => role_permission_model:get_company_roles()
    },

    {Res, Req, State}.

validate(Req, State) ->
    #{ body_data := Post } = State,
    Valid = validator:validate(#{
        name => {[required, {minlength, 5}], <<"Invalidate Name">>}
    }, Post),

    case Valid of
        {error, Msg} -> {error, Msg};
        Else -> 
            Perms = proplists:get_all_values(<<"permissions">>, Post),
            Id = proplists:get_value(<<"id">>, Post, 0),
            #{ is_admin := Admin_role} = cowboy_req:match_qs([{is_admin, [], <<"false">>}], Req),
            Else#{
                id => type:to_integer(Id),
                is_admin_role  => type:to_atom(Admin_role),
                permissions => [{Perm, true} || Perm <- Perms],
                status => type:to_boolean(proplists:get_value(<<"status">>, Post))
            }
    end.

%post_params(State) -> 
%   #{session_id := Sid, body_data := Post} = State,
%   Aid = session:get(account_id, Sid),
%   Pers = proplists:get_all_values(<<"permissions">>, Post),
%   Perms = [{Per, true} || Per <- Pers],
%   Name = proplists:get_value(<<"name">>, Post),
%   Status = proplists:get_value(<<"status">>, Post, false),
%   [Name, Perms, type:to_bool(Status), Aid].


insert_role_action(Req, State, _) ->
    Res = case validate(Req, State) of
        {error, Msg} -> #{error=> true, msg=>Msg, type=>form};
        Data -> 
            #{ account_id := Aid} = State,
            case admin_role_permission_model:insert_role(Data, Aid) of
                {error, Db} -> #{error => true, msg => Db, type => server};
                Id -> 
                    Role = role_permission_model:get_role(Id),
                    #{ error => false, role => Role}
            end
    end,
    {Res, Req, State}.

update_role_action(Req, State, _) ->
    Res = case validate(Req, State) of
        {error, Msg} -> #{ error => true, msg => Msg};
        Data -> 
            #{ account_id := Aid}= State,
            case admin_role_permission_model:update_role(Data, Aid) of
                {error , Db} -> #{error => true, msg => Db, type=> db};
                Id -> #{
                    error => false,
                    role => role_permission_model:get_role(Id)
                 }
            end
    end, 
    {Res, Req, State}.

delete_role_action(Req, State, [Id]) ->
    #{ account_id := Aid} = State,
    Res = case admin_role_permission_model:delete_role(Id, Aid) of
        {error, Db} -> #{ error=> true, msg => Db, type=> db};
        _ -> #{ error => false, id => Id}
    end,
    {Res, Req, State}.

