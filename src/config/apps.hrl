-define(SYS_PATH, "gear/").
-define(STATIC_PATH, ?SYS_PATH ++ "static/").

 -define(APP, #{
    %% @doc This the main administrator panel
    %% which is accessible by only administrator account.
    admin_app => #{
        domain => "admin.gear.loc",
        sub_apps => [ {ac, account_app} ],
        static => [
            {"/js/[...]", {dir, ?STATIC_PATH ++ "admin/js/"}},
            {"/locale/[...]", {dir, ?STATIC_PATH ++ "admin/locale/"}},
            {"/css/[...]", {dir, ?STATIC_PATH ++ "admin/css/"}},
            {"/lib/[...]", {dir, ?STATIC_PATH ++ "lib/"}},
            {"/images/[...]", {dir, ?STATIC_PATH ++ "admin/images/"}},
            {"/pictures/[...]", {dir, ?STATIC_PATH ++ "pictures/"}},
            {"/favicon.icon", {dir, ?STATIC_PATH ++ "cambohub/images/favicon.icon"}}
        ]
    },

    %% @doc This application is for company resource management
    %% where is accessed by only account belongs to the specific company.
    cp_app => #{
        domain => <<"cp.gear.loc">>,
        sub_apps => [
            { account, account_app},
            { fleet, fleet_app}
        ],
        static => [
            {"/js/[...]", {dir, ?STATIC_PATH ++ "cp/js/"}},
            {"/locale/[...]", {dir, ?STATIC_PATH ++ "locale/"}},
            {"/css/[...]", {dir, ?STATIC_PATH ++ "cp/css/"}},
            {"/lib/[...]", {dir, ?STATIC_PATH ++ "lib/"}},
            {"/images/[...]", {dir, ?STATIC_PATH ++ "cp/images/"}},
            {"/pictures/[...]", {dir, ?STATIC_PATH ++ "pictures/"}},
            {"/favicon.icon", {dir, ?STATIC_PATH ++ "cambohub/images/favicon.icon"}}
        ]
    },

    %% @doc Account application is used by general account.
    %% Account registered only one application and
    %% could be used all applications in the system.
    account_app => #{
        domain => <<"">>,
        sub_apps => [],
        static => [
            {"/js/[...]", {dir, ?STATIC_PATH ++ "account/js/"}},
            {"/locale/[...]", {dir, ?STATIC_PATH ++ "locale/"}},
            {"/css/[...]", {dir, ?STATIC_PATH ++ "account/css/"}},
            {"/lib/[...]", {dir, ?STATIC_PATH ++ "lib/"}},
            {"/images/[...]", {dir, ?STATIC_PATH ++ "account/images/"}},
            {"/favicon.icon", {dir, ?STATIC_PATH ++ "cambohub/images/favicon.icon"}}
        ]
    },

 }).
 
%For static applications
 -define(STATIC, #{}).
% -define(STATIC, #{
%   static_app => #{
%       domain => "static.gear.loc", %      dir_handler => gear_static_handler, %       path => "/var/www/gear/static/", %      extra => [
%           {allow_methods, <<"POST">>},
%           {allow_origins, <<"*">>},
%           {<<"Access-Control-Allow-Origin">>, <<"*">>}
%       ]
%    }
%}).
