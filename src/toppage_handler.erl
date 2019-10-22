%% @author Yarin NIM, <yarin.nim@gmail.com>
%% @version 0.1
%%

-module(toppage_handler).
-define(SERVER, #{ }).
-export([init/2, allowed_methods/2, terminate/3, is_authorized/2,
    content_types_accepted/2, delete_completed/2, delete_resource/2,
    content_types_provided/2, resource_exists/2,
    forbidden/2, valid_content_headers/2,
    get_referer/1, get_referer/2
]).

-export([handle_controller/2, handle_head/2, handle_body/2, handle_multipart/2]).
-export([moved_temporarily/2]).
-export([page_404/3]).
-define(VAL(K, L), proplists:get_value(K, L)).
-define(VAL(K, L, D), proplists:get_value(K, L, D)).

is_ajax(Req) ->
    case cowboy_req:header(<<"x-requested-with">>, Req, false) of
        false -> case cowboy_req:header('ajax-request', Req, false) of
            false -> false;
            _ -> true end;
        _ -> true
    end.

app_res(M, App_opts) -> 
    App = proplists:get_value(app, App_opts),
    App:M().

get_referer(Req) -> get_referer(Req, <<>>).
get_referer(Req, Def) ->
    case cowboy_req:header(<<"referer">>, Req) of
        undefined -> Def;
        Ref -> Ref
    end.


init(Req, Opts) ->
    io:format('~n=============INIT REQUEST============~n'),
    {SID, Req1} = session:get_session(Req),
    pg2:join(?VAL(app, Opts), self()),
    rand:seed(exs64),

    App_name = proplists:get_value(app, Opts),
    io:format(" - App name [~p]...~n",[App_name]),

    App_conf = app_res(config, Opts),

    Lang = case session:get(lang, SID) of
        undefined -> 
            #{language := L} = app_res(config, Opts),
            session:set(lang, L, SID),
            L;
        Lan -> Lan
    end,

    Conf = maps:remove(login_page, maps:remove(auth_pages, App_conf)),
    BaseURL = base_url(Req, Opts),

    Referer = case session:get(referer, SID) of
        undefined -> case cowboy_req:header(<<"referer">>, Req) of
            undefined -> BaseURL;
            Ref -> Ref
            end;
        Ref_s -> 
            session:delete(referer, SID),
            Ref_s
    end,

    State0 = case session:get(has_login, SID) of
        true -> #{
            has_login => true,
            account_id => session:get(account_id, SID)
         };
        _ -> #{ has_login => false}
    end,


    State = State0#{
        session_id => SID,
        is_ajax => is_ajax(Req1),
        lang => Lang,
        referer => Referer,
        current_uri => cowboy_req:uri(Req),
        path => cowboy_req:path(Req),
        config => Conf#{
            base_url => BaseURL,
            parent_url => parent_url(Req, Opts)
        },
        app => Opts
    },

    {cowboy_rest, Req1, State}.


base_url(R, Opts) ->
    %io:format('R: ~p~n=======~n~p~n',[R, Opts]),
    Pref = case proplists:get_value(prefix, Opts) of
        undefined -> <<"">>;
        Pre -> type:to_binary(Pre ++ "/")
    end,
    H = cowboy_req:host(R),
    S = cowboy_req:scheme(R),
    <<S/binary, "://", H/binary,"/", Pref/binary>>.

parent_url(R, Opts) ->
    Base = base_url(R, Opts),
    case proplists:get_value(prefix, Opts) of
        undefined -> Base;
        Pre -> 
            Pref = type:to_binary(Pre),
            Re = re:replace(Base, <<Pref/binary, "/$">>, <<"">>),
            iolist_to_binary(Re)
    end.




% Default allowed methods
% HEAD, GET, POST, PATCH, PUT, DELETE and OPTIONS._
allowed_methods(Req, State)-> {[<<"GET">>,<<"POST">>,<<"PUT">>,<<"DELETE">>],Req, State}.

% Calling router:resource_exists called twice, 
% should manage to make it called only once.
is_authorized(Req, State) -> 
    #{ app := App_opts } = State,
    App_config = app_res(config, App_opts),

    #{session_id := SID } = State,

    {Auth, Req1, StateRes} = case router:resource_exists(Req, App_opts) of
        {C, A, P, E} -> 
            Controller = binary_to_atom(iolist_to_binary(re:replace(atom_to_binary(C, latin1), <<"_controller">>, <<"">>, [global])), latin1),
            State1 = State#{handler => {C, A, P}, extra_param => E},
            #{auth_pages := Auth_pages } = App_config,

            %% Check if the conntroller is in Authentication configure
            %% Which required login to access resource
            case lists:member(Controller, Auth_pages) of
                true -> 
                    case session:get(has_login, SID) of
                        false -> redirect_to_login(Req, State1);
                        undefined -> redirect_to_login(Req, State1);
                        _ -> {true, Req, State1}
                    end;
                _ -> {true, Req, State1}
            end;
        Error ->
            State_e = State#{handler => Error},
            {true, Req, State_e}
    end,

    io:format(' - Checking authorization..~p~n',[Auth]),


    %{Auth1, Req2, State2} = security:validate_jwt(Auth, Req1, StateRes),
    %io:format(" - Validating JWT: ~p...~n",[Auth1]),
    %{Auth1, Req2, State2}.

    {Auth, Req1, StateRes}.

redirect_to_login(Req, State) -> 
    #{ app := App } = State,
    App_conf = app_res(config, App),
    %#{login_page := LP } = ?APP_CONFIG,
    #{login_page := LP } = App_conf,
    case LP of
        undefined ->
            {{false, <<"Unauthorized">>}, Req, State};
        URL -> 
            Uri = iolist_to_binary(cowboy_req:uri(Req)),
            #{session_id := Sid} = State,
            session:set(referer, Uri, Sid),
            URL_r = config:base_url(URL, State),
            Ref = get_referer(Req),
            URL_r1 = <<URL_r/binary,"&ref=", Ref/binary>>,
            io:format(' - Redirecting to login page... [~p]~n',[URL_r1]),
            Req_r = cowboy_req:reply(303, #{<<"location">> => URL_r1}, <<"login page">>, Req),
            {stop, Req_r, URL_r}
    end.

forbidden(Req, State) ->
    io:format(' - Checking fobidden...~n'),
    {false, Req, State}.

valid_content_headers(Req, State) ->
    io:format(' - Validate Content Header...~n'),
    {true, Req, State}.

resource_exists(Req, State)->
    #{handler := Handler}   = State,
    case Handler of
        {_, _, _} -> 
            io:format(' - Resource exists ~n'),
            {true, Req, State};
        E ->
            #{ app := App_opts } = State,
            Path = router:request_url(Req, App_opts),
            io:format(' - Resource exists error: ~p, ~p~n',[E, Path]),
            page_404(Req, State, E)
    end.
    
content_types_provided(Req, State)->
    case cowboy_req:parse_header(<<"content-type">>, Req) of
        undefined -> io:format(' - Content type provided...~n');
        {C, P, _} -> io:format(' - Content type provided ~p, ~p...~n',[C, P]) 
    end,
    Handler = [
        {{<<"text">>,<<"html">>, '*'}, handle_head},
        {{<<"application">>,<<"json">>, '*'}, handle_head},
        {{<<"text">>,<<"plain">>,'*'}, handle_head}],
    {Handler, Req, State}.


content_types_accepted(Req, State) ->
    Handler = [
        {{<<"text">>,<<"html">>, '*'}, handle_body},
        {{<<"application">>,<<"json">>, '*'}, handle_body},
        {{<<"application">>,<<"x-www-form-urlencoded">>, '*'}, handle_body},
        {{<<"multipart">>, <<"form-data">>, '*'}, handle_multipart},
        {{<<"text">>, <<"plain">>, '*'}, handle_body}],
    {Handler, Req, State}.

delete_resource(Req, State) ->
    io:format(' - Handling delete method...~n'),
    handle_body(Req, State).

delete_completed(Req, State) ->
    io:format(' - Deleted completed...~n'),
    {true, Req, State}.

media_type(Req) -> 
    #{media_type := M} = Req,
    M.

escape(Content, Req, State) ->
    Res = case media_type(Req) of
        {<<"text">>, <<"html">>, _} -> Content;
        {<<"text">>, <<"plain">>, _} -> Content;
        {<<"text">>, <<"javascript">>, _} -> Content;
        {<<"application">>, <<"json">>, _} -> try jsx:encode(Content) catch _:_ -> #{response => Content} end 
    end,
    Req1 = session:touch(Req),
    {Res, Req1, State}.

handle_controller(Req, State) ->
    #{handler := Handler} = State,
    case Handler of 
        {C,A,P}-> 
            io:format(' - Handle: ~p:~p(~p)~n',[C,A,P]),
            C:A(Req, State, P);
        E -> 
            Req_e = cowboy_req:reply(404, #{<<"msg">> => E}, Req),
            {E, Req_e, State}
    end.

%% @doc Force to download a file
%% even the browser support to open the file type
%% but it still get content to download

download(File, Req, State) when is_binary(File) ->
    Name = uid:get_id(),
    FName = <<"gear_file_", Name/binary>>,
    download({File, FName}, Req, State);
download({_File, _Name}, Req, State) ->
    {true, Req, State}.

handle(Content, Req, State) ->
    case Content of
        {redirect, URL} ->
            io:format(' - Redirecting to: ~p~n', [URL]),
            Req_r = cowboy_req:reply(302, #{<<"location">> => URL}, <<"">>, Req),
            {stop, Req_r, URL}; 

        {redirect_303, URL}  ->
            io:format(' - Redirecting 303 to: ~p~n', [URL]),
            Req_r = cowboy_req:reply(303, #{<<"location">> => URL}, <<"">>, Req),
            {stop, Req_r, URL}; 

        {crush, Msg} ->
            io:format(' - Sending crush to browser [~p]...~n', [Msg]),
            Req_c = cowboy_req:reply(500, ?SERVER#{<<"crush-msg">> => Msg}, Req),
            {stop, Req_c, State};
        {halt, Msg} ->
            io:format(' - Halting the request [~p]....~n',[Msg]),
            Req_h = cowboy_req:reply(500, ?SERVER#{<<"halt-msg">> => Msg}, Req),
            {stop, Req_h, State};
        {csrf, Msg} ->
            io:format(' - Terminating CSRF...~n'),
            Req_csrf = cowboy_req:reply(401, ?SERVER#{<<"csrf">> => Msg},Req),
            {stop, Req_csrf, State};
        {404, Msg_404} ->
            Req_404 = cowboy_req:reply(404, #{<<"msg">> => Msg_404}, Req),
            {stop, Req_404, State};
        unauthorized ->
            io:format(' - Sending unauthorized crush...~n'),
            Req_a = cowboy_req:reply(401, ?SERVER#{<<"auth">> => <<"false">>, <<"auth-msg">> => <<"Unauthorized visitor">>}, Req),
            {stop, Req_a, State};
        {file, File} ->
            io:format(' - Sending file content to client~n'),
            Ct = file_info:mimetype(File),
            {ok, Data} = file:read_file(File),
            Req_1 = cowboy_req:reply(200, #{ <<"content-type">> => Ct }, Data, Req),
            {stop, Req_1, State};
        {download, File} -> download(File, Req, State);
        _  ->
            case cowboy_req:method(Req) of
                <<"GET">> -> escape(Content, Req, State);
                <<"HEAD">> -> escape(Content, Req, State);
                %<<"DELETE">> -> escape(Content, Req, State);
                _ ->
                    {Content1, Req_ok, State_ok} = escape(Content, Req, State),
                    Req_ok1 = cowboy_req:set_resp_body(Content1, Req_ok),
                    Req_ok2 = session:touch(Req_ok1),
                    {true, Req_ok2, State_ok }
            end
    end.

handle_head(R, S) -> 
    #{app := App} = S,
    Csrf = app_res(csrf, App),
    io:format(' - Handling HEAD...~n', []),
    {Token, Req} = security:generate(R, Csrf),
    State = S#{token => Token},
    {Content, Req1, State1} = handle_controller(Req, State),
    handle(Content, Req1, State1).

handle_body(Request, TS) ->
    #{ app := App } = TS,
    Csrf = app_res(csrf, App),
    io:format(' - Handling body request...~n'),
    {Body_data, Req} = get_body_data(Request),
    State = TS#{body_data => Body_data},

    {Content, R, S} = case security:validate(Req, State, Csrf) of
        ok -> handle_controller(Req, State);
        _ -> {{csrf, <<"Forbidden for CSRF">>}, Req, State}
    end,

    {Token, Req1} = security:generate(R, Csrf),
    State1 = S#{token => Token},
    handle(Content, Req1, State1).

get_body_data(Req) ->
    {Post, Req2} = case cowboy_req:read_urlencoded_body(Req) of
        {ok, Post_s, Req1} -> {Post_s, Req1};
        _ -> {[], Req}
    end,
    Body_data = [{K, string:trim(V)} || {K, V} <- Post],
    {Body_data, Req2}.

handle_multipart(Req, State) -> 
    #{ app := App } = State,
    Csrf = app_res(csrf, App),
    io:format(' - Handling Multipart request...~n'),
    {Data, Req1} = stream_multipart(Req, State, []),
    State1 = State#{body_data => Data},
    {Content, Reqr, Stater} = case security:validate(Req1, State1, Csrf) of
        ok -> handle_controller(Req1, State1);
        _ -> {{csrf, <<"Forbiden for CSRF">>},Req1, State1}
    end,
    handle(Content, Reqr, Stater).


stream_multipart(Req, State, Post) ->
    case cowboy_req:read_part(Req) of
        {ok, Headers, Req1} -> 
            {Data, Req3} = case cow_multipart:form_data(Headers) of
                {data, Field} -> 
                    {Value, Req2} = stream_body(Req1, <<"">>),
                    {{Field, Value}, Req2};
                File_info ->
                    {FContent, ReqF} = stream_body(Req1, <<"">>),
                    {add_file(FContent, File_info), ReqF}
            end, 
            Post1 = [ Data | Post],
            stream_multipart(Req3, State, Post1);
        {done, Req1} -> {Post, Req1}
    end.

stream_body(Req,Acc) ->
    case cowboy_req:read_part_body(Req) of
        {more, Data, Req1} -> stream_body(Req1, <<Acc/binary, Data/binary>>);
        {ok,Data, Req1} -> {<<Acc/binary, Data/binary>>, Req1}
    end.

add_file(Content, Info) ->
    {file, Field, Name, Minetype } = Info,
    Ext = type:to_list(filename:extension(Name)),
    Ran = erlang:system_time(),
    File_name = "gear_file_"++type:to_list(Ran) ++ Ext,
    Tmp_name = type:to_binary("/tmp/"++ File_name),
    Fs = file:write_file(Tmp_name, Content),
    
    File = #{
        name => Name,
        tmp_name => type:to_binary(File_name),
        tmp_path => Tmp_name,
        file_state => Fs,
        file_size => type:to_integer(filelib:file_size(Tmp_name) / 1024),
        extension => type:to_binary(Ext),
        mimetype => Minetype
    },
    {Field, File}.

moved_temporarily(Req, State) ->
    io:format(' - Moved temporarily...~n'),
    {true, Req, State}.

terminate(Reason, _Req, _State) -> 
    io:format(' - Terminate :[~p]~n=============END REQUEST=============~n',[Reason]),
    ok.

page_404(Req, State, Error) ->
    %Res = case request:media_type(Req) of
    Res = case media_type(Req) of
        {<<"text">>,<<"html">>, []} -> <<"URL Not found">>;
        {<<"application">>,<<"json">>, []} ->
            Info = [
                {<<"error">>, 404},
                {<<"msg">>, Error}
            ],
            jsx:encode(Info)
    end,
    Req_404 = cowboy_req:reply(404, #{<<"msg">> => Res}, Req),
    Req1 = cowboy_req:set_resp_body(Res, Req_404),
    {stop, Req1, State}.