-define(SYS_PATH, <<"gear/">>).
-define(STATIC_PATH, <<?SYS_PATH/binary, "static/">>).

 -define(APP, #{
    %% 
    core_app => #{
        domain => "[www.]gear.loc",
        sub_apps => [{account, account_app}],
        static => {
            <<?SYS_PATH/binary, "static/core">>,
            [<<"js">>]
        }
    },

    %% @doc This the main administrator panel
    %% which is accessible by only administrator account.
    admin_app => #{ },

    %% @doc This application is for company resource management
    %% where is accessed by only account belongs to the specific company.
    cp_app => #{},

    %% @doc Account application is used by general account.
    %% Account registered only one application and
    %% could be used all applications in the system.
    account_app => #{
        static => {
            <<?SYS_PATH/binary, "static/account">>,
            [<<"js">>]
        }
     }
 }).
