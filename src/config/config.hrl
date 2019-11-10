-include("apps.hrl").
-include("crypt.hrl").
-include("database.hrl").
-include("event_listener.hrl").
-include("permission_keys.hrl").
-include("cors.hrl").
-include("email.hrl").


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


%% @doc Server configuration efine port and protocol including server
%% certificatte and other options
%% protocol: http | hhttps
-type protocol(): http | https.
-define(SERVER, #{
    protocol => env:get(protocol, http),
    config => env:get(protocol_config, [ {port, 80} ])
}).
