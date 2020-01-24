-type env():: development | testing | production | atom().
-define(APP_CONFIG, #{
    vsn => <<"0.1">>,
    env => development,
    % is_production => false,
    language => <<"en">>,
    encryption_key => <<"km3rg3@r_@pp11cat10nf0r0nl1n3R#5T@UR@NT">>,
    auth_pages => []
}).

-define(CSRF, #{
    enabled => false,
    expires => 1,
    max_age => 3600 * 24 * 30,
    token_name => <<"gear_csrf_key">>,
    regenerate => false,
    cookie_name => <<"gear_csrf_token">>,
    except_urls => [],
    path => <<"/">>,
    secure => true,
    http_only => true
    %$ domain => <<"/">>, 
}).

