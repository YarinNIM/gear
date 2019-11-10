%% @author Yarin NIM <yarin.nim@gmail.com>
%% @copyright 2019 Yarin NIM
%% @version 0.1
%% @title Properties Controller
%% @doc This controller is to response 
%% the properties list to client

-module(cam_properties_controller).
-export([
    index_action/3,
    detail_action/3
]).

index_action(Req, State, _) ->
    #{is_ajax:= Is_ajax} = State,
    Res = case Is_ajax of
        false -> render(Req, State);
        true -> get_properties(Req, State)
    end,
    {Res, Req, State}.


get_properties(_Req, _State) ->
    #{error => false, products => []}.

render(Req, State) ->
    resource:render_page(#{
        js => [
            config:base_url("js/product.js", State),
            config:locale_url("product", State)
        ],
        on_script_loaded => [ <<"_.initProducts()">> ]
    }, Req, State).

meta_data(_Product, State) ->
    #{ current_uri:= Cur} = State,
    #{
        title => <<"Heres iteh title">>,
        description => <<"Heres ithe description">>,
        image=> config:base_url("images/test.jpg", State),
        url=> iolist_to_binary(Cur)
    }.

detail_action(Req, State, Params) ->
    #{ is_ajax:= Ajax} = State,
    Res = case Ajax of
        false -> render_detail(Req, State, Params);
        true -> #{ error => false}
    end,
    {Res, Req, State}.

render_detail(Req, State, _P) ->
    resource:render_page(#{
        js => [ config:base_url("js/product_detail.js", State) ],
        on_script_loaded => [<<"_.initProductDetail()">>],
        meta_data => meta_data(#{}, State)
    }, Req, State).
