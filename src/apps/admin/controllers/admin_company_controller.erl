-module(admin_company_controller).
-behaviour(admin_behaviour).
-export([
    init_action/3
    %get_companies_action/3,
    %get_company_action/3,
    %initial_info_action/3,
    %insert_company_action/3, 
    %update_company_action/3,
    %upload_cover_action/3, 
    %upload_logo_action/3, 
    %get_covers_action/3, 
    %update_cover_action/3,
    %get_logos_action/3, 
    %update_logo_action/3,
    %update_contact_action/3,

    %search_for_child_action/3, 
    %insert_sub_company_action/3, 
    %delete_sub_company_action/3
]).

init_action(R, S, P) -> admin_behaviour:handle(R, S, P, ?MODULE).


%get_companies_action(Req, State, _ ) ->
%   Res = #{
%       companies => company_model:get_companies(#{})
%   },
%   {Res, Req, State}.

%%validate(Post) ->
%   case validator:validate(#{
%       name_en => {[required, {minlength, 3}], <<"Company name is required">>},
%       name_kh => {[required], <<"Please input name in Khmer">>},
%%      industry_type_id => {[integer, {min, 1}], <<"Industry type is required">>},
%%      company_type_id => {[integer, {min, 1}], <<"Company type is required">>}
%   }, Post) of
%       {error, Msg} -> {error, Msg};
%       Valid ->
%           Valid#{
%               id => type:to_integer(proplists:get_value(<<"id">>, Post, 0)),
%               desc_en => proplists:get_value(<<"desc">>, Post, <<"">>)
%           }
%   end.
        

%insert_company_action(Req, State, _) ->
%   #{ body_data := Post} = State,
%   Res = case validate(Post) of
%       {error, Msg} -> #{error =>true, msg => Msg, type=> form};
%       Com -> 
%               io:format('Compay: ~p~n',[Com]),
%           #{account_id := Aid} = State,
%           case admin_company_model:insert_company(Com, Aid) of
%               {error, Db} -> #{error => true, msg => Db, type=> server};
%               Cid -> 
%                   Inserted = company_model:get_company(Cid),
%                   #{error => false, company => Inserted}
%           end
%   end,
%   {Res, Req, State}.

%get_company_action(Req, State, [Id]) ->
%   Com = gear_company:get_detail(Id),
%   {Com, Req, State}.

%%update_company_action(Req, State, _) ->
%   #{ body_data := Post } = State,
%   Res = case validate(Post) of
%       {error, Msg} -> #{error => true, msg=> Msg, type=> form};
%       Com -> 
%           #{ account_id := Aid} = State,
%           case company_model:update(Com, Aid) of
%               {error, Db} -> #{error => true, msg => Db, type=>server};
%               _ -> 
%                   #{ id := Cid} = Com,
%                   Update = company_model:get_company(Cid),
%                   #{error => false, company => Update }
%           end
%   end,
%   {Res, Req, State}.

%save_cover(File) ->
%   #{tmp_name := Tmp_name } = File,
%%  FN = filename:basename(Tmp_name),
%   Des = config:path(profile_cover, FN),
%   io:format('Des: ~p~n',[Des]),
%   case file:rename(Tmp_name, Des) of
%       ok -> #{ error => false, url => FN};
%       {error, Error} -> #{error => true, msg => Error}
%   end.

%upload_cover_action(Req, State, _) ->
%   #{body_data:= Post} = State,
%   File = proplists:get_value(<<"file">>, Post),
%   #{file_size:=Fs} = File,
%   Res = case Fs > config:throttle(profile_cover) of
%       true -> #{error => true, msg=><<"Over limited filesize">>};
%       false -> 
%           #{tmp_name := Tmp_name } = File,
%           Fn = filename:basename(Tmp_name),
%           Cid = proplists:get_value(<<"company_id">>, Post),
%           #{account_id := Aid} = State,
%           case company_model:insert_cover(Fn, type:to_integer(Cid), Aid) of
%               {error, Db} -> #{error => true, msg => Db};
%               _ -> save_cover(File)
%           end
%   end,
%   {Res, Req, State}.

%%save_logo(State) ->
%   #{ body_data := Post} = State,
%   File = proplists:get_value(<<"file">>, Post),
%%  #{tmp_name := Tmp_name, file_size:= Size} = File,
%   case Size > config:throttle(profile) of
%       true -> {error, <<"Exceed max filesize">>};
%       _ ->
%           Fn = filename:basename(Tmp_name),
%           Des = config:path(profile, Fn),
%           file:rename(Tmp_name, Des),
%           #{ account_id := Aid} = State,
%           Cid = proplists:get_value(<<"company_id">>, Post),
%           case company_model:insert_logo(Fn, type:to_integer(Cid), Aid) of
%               {error, Db} -> { error, Db};
%               _ -> Fn
%           end
%   end.

%upload_logo_action(Req, State, _ ) ->
%   Res = case save_logo(State) of
%       {error, Msg} -> #{ error => true, msg => Msg};
%       Url -> #{ error => false, url => Url}
%   end,
%   {Res, Req, State}.

%get_covers_action(Req, State, [Cid]) ->
%   Res = #{
%       company_id => Cid,
%       files => company_model:get_covers(Cid)
%   },
%   {Res, Req, State}.

%update_cover_action(Req, State, _ ) ->
%   #{ body_data := Post, account_id := Aid} = State,
%   Cid = proplists:get_value(<<"company_id">>, Post),
%%  Pid = proplists:get_value(<<"cover_id">>, Post),
%   company_model:update_cover(type:to_integer(Pid), type:to_integer(Cid), Aid),
%   {#{ error => false, msg => msg}, Req, State}.

%get_logos_action(Req, State, [Cid]) ->
%   {#{ files => company_model:get_logos(Cid)}, Req, State}.

%%update_logo_action(Req, State, _) ->
%   #{ body_data:= Post, account_id := Aid} = State,
%   Cid = proplists:get_value(<<"company_id">>,Post),
%%  Lid = proplists:get_value(<<"logo_id">>, Post),
%   Res  =case company_model:update_logo(type:to_integer(Lid), type:to_integer(Cid), Aid) of
%       {error, Db} -> #{error => true, msg => Db};
%       _ -> #{error => false, msg => msg}
%   end,
%   {Res, Req, State}.

%update_contact_action(Req, State, _) ->
%   #{ body_data := Post, account_id := Aid} = State,
%   Cid = type:to_integer(proplists:get_value(<<"company_id">>, Post)),
%   Res = case admin_company_model:update_contact(Post, Cid, Aid) of
%%      {error, Db} -> #{ error => true, msg => Db};
%       _ -> #{
%%          contact => company_model:get_contact(Cid)
%        }
%   end, 
%   {Res, Req, State}.

%search_for_child_action(Req, State, _) ->
%   #{ company_id:= Cid, q:= Q} = cowboy_req:match_qs([{company_id, int}, {q, nonempty}], Req),
%
%   Res = #{
%    items => company_model:search_for_children(Cid, Q)
%   },
%   {Res, Req, State}.

%insert_sub_company_action(Req, State, _) ->
%   #{ body_data:= Post, account_id:= Aid} = State,
%   Cid = type:to_integer(proplists:get_value(<<"company_id">>, Post)),
%   Sub_id = type:to_integer(proplists:get_value(<<"sub_company_id">>, Post)),
%   Res = case admin_company_model:insert_sub_company(Cid, Sub_id, Aid) of
%       {error, Db} -> #{error=>true, msg => Db, type=>dabase};
%       _ -> 
%           Comp = company_model:get_company(Sub_id),
%           #{
%               error => false,
%               company => Comp
%%          }
%   end,
%   {Res, Req, State}.

%delete_sub_company_action(Req, State, _) ->
%   #{ id := Id} = cowboy_req:match_qs([{id, int}], Req),
%   #{account_id := Aid} = State,
%
%   Res = case admin_company_model:delete_sub_company(Id, Aid) of
%       {error, Db} -> #{ error => true, msg => Db, type => server};
%       _ -> #{ error => false, company_id => Id}
%   end,
%%  {Res, Req, State}.
