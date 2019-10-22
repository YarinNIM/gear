-module(cp_company_controller).
-export([
    init_action/3,
    % update_action/3, 
    %update_contact_action/3,
    %update_address_action/3, 
    %delete_address_action/3, 
    %insert_address_action/3,
    insert_subcompany_action/3, 
    delete_subcompany_action/3
    %update_cover_action/3, 
    %insert_cover_action/3
]).

init_action(Req, State, Params) -> cp_behaviour:handle(Req, State, Params, ?MODULE).

%update_action(Req, State, _) ->
%   Res = case gear_company:validate_data(State) of
%       {error, Msg} -> #{error=>true, msg=>Msg, type=>server};
%   %   Com -> 
%%          {_, Cid, Aid} = gear_company:get_ids(State),
%           case db:call(fun_cp_company_update, [jsx:encode(Com), Cid, Aid, <<"company.modify">>]) of
%               {error, Db} -> #{error => true, msg => Db, type=> server};
%               Cid -> #{
%%                  error => false,
%%                  company => company_model:get_company(Cid)
%               }
%           end
%   end,
%   {Res, Req, State}.

%update_contact_action(Req, State, _) ->
%   #{ body_data := Post} = State,
%%  {_, Cid, Aid} = gear_company:get_ids(State),
%%% Res = case db:call(fun_cp_company_contact_update,[jsx:encode(Post), Cid, Aid, <<"company.modify">>]) of
%       {error, Db} -> #{error => true, msg => Db};
%       _ -> #{
%         error => false,
%         contact => company_model:get_contact(Cid)
%       }
%   end,
%   {Res, Req, State}.

%insert_address_action(Req, State, _)->
%   #{ body_data:= Post} = State,
%   {_, Cid, Aid} = cp_app:get_ids(State),
%   Res = gear_company_address:insert(Cid, Post, Aid),
%   {Res, Req, State}.

%update_address_action(Req, State, _ ) ->
%   #{body_data:= Post} = State,
%   Res = gear_company_address:update(Post),
%   {Res, Req, State}.

%delete_address_action(Req, State, _) ->
%   #{cid := Cid, id:= Id} = cowboy_req:match_qs([{cid, int}, {id, int}], Req),
%   Res = gear_company_address:delete(Cid, Id),
%   {Res, Req, State}.
%
insert_subcompany_action(Req, State, _) ->
    #{ body_data:=Post} = State,
    {_, Parent_id, _} = cp_app:get_ids(State),
    Id = proplists:get_value(<<"sub_company_id">>, Post),
    Res = gear_company_subcompany:insert(type:to_integer(Id), Parent_id),
    {Res, Req, State}.

delete_subcompany_action(Req, State, _) ->
    {_, Cid, _} = cp_app:get_ids(State),
    #{id := Id} = cowboy_req:match_qs([{id, int}], Req),
    Res = gear_company_subcompany:delete(Cid, Id),
    {Res, Req, State}.

%insert_cover_action(Req, State, _) ->
%   #{ body_data := Post} = State,
%   {_, Cid, Aid} = cp_app:get_ids(State),
%   Res = gear_company:insert_cover(Cid, Post, Aid),
%   {Res, Req, State}.


%update_cover_action(Req, State, _) ->
%   {_, Cid, _} = cp_app:get_ids(State),
%   #{ body_data := Post} = State,
%   Pid = proplists:get_value(<<"cover_id">>,Post),
%   Res = gear_company:update_cover(Cid, type:to_integer(Pid)),
%%  {Res, Req, State}.
