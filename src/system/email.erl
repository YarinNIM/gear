-module(email).
-export([send/1, send_using_template/1]).

get_field(F, P) -> get_field(F, P, undefined).
get_field(F, P,D) ->
    case maps:find(F, P) of
        {ok, V} -> V;
        _ -> D 
    end.

content_type(Props) -> 
    %D = {<<"multipart">>, <<"mixed">>},
    D ={<<"text">>, <<"html; charset=\"UTF-8\"; format=\"flowed\"">>},
    %D ={<<"text">>, <<"html">>},
    get_field(content_type, Props, D).
    

send(Props) ->
    Config = get_config(Props),
    #{from := From_name} = Config,
    #{to := Tos} = Props,
    #{options := Op} = Config,
    #{subject := Subject} = Props,
    %#{callback := Cb } = Props,

    To = to_rep(Tos),

    Mime_body = mime_body(Props),

    Mime_att = mime_attachment(Props),

    From_email = proplists:get_value('username',Op),

    %{C, T} = case Mime_att of
    %   [] -> content_type(Props);
    %   _ -> {<<"multipart">>, <<"mixed">>}
    %end,

    [Sender |_ ] = To,
    Mime_e = [
        {<<"From">>, from_name(From_name, From_email)},
        {<<"To">>, to(Tos)},
        {<<"Subject">>, Subject}, 
        {<<"Reply-to">>, get_field(reply_to, Props, Sender)}
    ],

    Mime_email = case get_field(cc, Props, []) of
        [] -> Mime_e;
        Cc -> [{<<"Cc">>, Cc} | Mime_e]
    end,

    %%Dkim = dkim_options(),
    Email = {<<"multipart">>, <<"mixed">>, Mime_email,[],[Mime_body | Mime_att]},
    Encoded = mimemail:encode(Email),
    Gen_res = gen_smtp_client:send({From_email, To, Encoded}, Op, fun(Cb) ->
            io:format(' - Email callback [~p]...~n', [Cb])
        end),
    io:format(' - Sending email [~p] To ~p...~n',[Gen_res, To]).

to_rep(T) when is_binary(T) -> to_rep([T]);
to_rep(T) -> T.

to(T) when is_binary(T) -> to([T]);
to(Tos) -> 
    To  = lists:join(<<", ">>, Tos),
    erlang:iolist_to_binary(To).


from_name(N, E) -> 
    Nl = type:to_list(N),
    El = type:to_list(E),
    Nl++" <"++El++">".

get_config(Props) ->
    EN = case maps:find(email, Props) of
        error -> noreply;
        {ok, E} -> E
    end,
    config:email(EN).

mime_body(Props) ->
    {T,F}= content_type(Props),
    Content_type = <<T/binary,"/",F/binary>>,
    Body = get_field(body, Props, <<"Email body">>),
    {T, F,[
        {<<"Content-Type">>, Content_type},
        {<<"Content-Transfer-Encoding">>, <<"8bit">>},
        {<<"Content-Disposition">>, <<"inline">>}
    ],[],Body}.

mime_attachment(Props) ->
    Files = get_field(attachment, Props, []),
    [get_att(File) || File <- Files].

get_att(F) ->
    File = type:to_binary(F),
    Name = filename:basename(File),
    Content = case file:read_file(File) of
        {ok, C} -> C;
        {error, R} -> type:to_binary("Error in this attached file" ++ type:to_list(R))
    end,
    {T, Co,_} = cow_mimetypes:all(File),
    {T, Co,[
        {<<"Content-Type">>, <<T/binary,"/",Co/binary>>},
        {<<"Content-Transfer-Encoding">>, <<"base64">>}
    ],
    [
        {<<"disposition">>, <<"attachment">>},
        {<<"disposition-params">>, [{<<"filename">>, Name}, {<<"name">>, Name}]}
    ],Content}.

send_using_template(Props) ->
    Sub = get_field(subject, Props),
    E_layout = get_field(email_layout, Props, email_layout),
    E_layout_content = get_field(email_content_layout, Props, email_content_layout),

    Content_json = get_field(params, Props, #{}),
    Content_json_1 = Content_json#{sujbect => Sub},

    
    Content = template:render(E_layout_content, Content_json_1),
    Body = template:render(E_layout, #{subject => Sub, content => Content}),
    Email = Props#{content => Body},
    send(Email).
