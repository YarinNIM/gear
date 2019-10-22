-module(admin_company_member_controller).
-export([
    %init_action/3,
    %get_member_action/3
]).

%init_action(Req, State, P) -> admin_behaviour:handle(Req, State, P, ?MODULE).
%
%get_member_action(Req, State, _) ->
%   #{id:= Cid} = cowboy_req:match_qs([{id, int}], Req),
%   Res = #{
%     accounts => company_model:get_accounts(Cid),
%     contact_persons => company_model:get_contact_persons(Cid)
%   },
%   {Res, Req, State}.
