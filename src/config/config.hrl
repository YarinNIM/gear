-define(SYSTEM_SUP, system_sup).
-define(META, #{
    description => "Gear System, which one can implement another one.",
    vsn => "0.1"
}).

% @doc System configuration
%% ets: for RAM Database (ETS database)
%% dets: For database file using DETS storage
%% mnesia: Database session using mnesia database engine.
%% database: Default database session storage where your system using.
%% file: File session storage.

-type driver() :: ets | dets | mnesia | database | file.
-define(SESSION, #{
    driver => ets, %% RAM Database
    save_path => "/tmp/", % For file storage
    storage => gear_session,
    path =>  <<"/">>,
    key => <<"GSID">>,
    expire =>  180000000,
    domain => <<".">>
 }).


-define(P_DIR(K), code:priv_dir(gear) ++ "/" ++ K).

%% Server configuration
%% define port and protocol including server
%% certificatte and other options

-define(SERVER, #{
    protocol => https,
    config => [
        { port, 443},
        { certfile, ?P_DIR("ssl/server.crt")},
        { keyfile, ?P_DIR("ssl/server.key")} 
    ]
}).

% @doc The email configation
% You can configure many email address
-define(EMAILS, #{
    noreply => #{
        options => [
            {username, "admin@gear.com"}, %% User name
            {password, "secreate"}, %% Password
            {relay, "smtp.gear.com"}, %% SMPT Address
            {port, 587},
            {tls, always}
        ],
        from => "Noreply GEAR"
    }
}).

%%
%% @doc How the system request 
%% to access CORS to another host
-define(CORS, #{
    default => localhost,
    localhost => #{
        url => <<"http://localhost:8080">>,
        headers => #{
            cors_key => <<"cors-requeset-key">>,
            cors_hash =>  <<"where is the contetn of testing">>
        },
        optons => #{
            timeout => 166
        }
     }
}).



%% Define the module(s) that 
%% listen to events raised by event_dispatcher
-define(EVENT_LISTENER, #{
    event_handler_logger => #{
        vsn => "0.1",
        desc => "Handle event and rgisters the activities log.",
        db_pool => log
    }
    %logger_test => []
}).
