%% @author Yarin NIM <yarin.nim@gmail.com>
%% @copyright 2019 Yarin NIM
%% @version 0.1
%% @title Page Controller
%% @doc  This controler is to render 
%% all non-dynamic page. It is used for static
%% page such as ABOUT US, CONTACT US....

-module(cam_page_controller).
-export([
    contact_us_action/3,
    about_us_action/3
]).

%% Render the contact us page
contact_us_action(Req, State, _) ->
    Res = resource:render_page(#{
        js => [
            {contact, config:base_url("js/contact_us.js", State)},
            {contact_locale, config:locale_url('contact', State)}
        ],
        on_script_loaded => [<<"_.initContact();">>]
    }, Req, State),
    {Res, Req, State}.


%% @doc This to render the ABOUT US page.
about_us_action(Req, State, _) ->
    Res = resource:render_page( #{
        content => template:render(cam_about_us, #{
            img_about => config:base_url("images/about_us.jpg", State),
            img_vs => config:base_url("images/vision_mission.png", State)
        }),
        meta_data => #{
          title => <<"fdasfdasf">>
        }
    }, Req, State),

    {Res, Req, State}.

