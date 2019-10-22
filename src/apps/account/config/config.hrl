-define(APP_CONFIG, #{
    vsn => <<"0.1">>,
    is_production => false,
    language => <<"en">>,
    encryption_key => <<"km3rg3@r_@pp11cat10n">>,
    auth_pages => [account_home],

    db_row_size => 20,
    auth_method => basic,

    login_page => <<"login.html?key=account">>
    %cdn_url => <<"http://cdn.khmergear.loc/">>,
    %static_url => <<"http://static.khmergear.loc/">>,
    %profile_url => <<"{{ base_url }}pictures/profile/">>,
    %cover_url => <<"{{ base_url }}pictures/profile_cover/">>
}).

-define(CSRF, #{
    enabled => true, %% enable the CSRF
    secure => true, %% validate the clean data
    max_age => 1000 * 1000, %% how long session stored
    token_name => <<"khmergear_csrf_key">>, %% token name
    regenerate => false, %% If the key is automatically re-generated
    cookie_name => <<"khmergear_csrf_hash">>, %% cookie name
    except_urls => [] %% urls which are by passed the validation
}).

-define(AUTH, #{ }).

%% Support
%% HS256, HS384, HS512
%% RS256, RS384, RS512
%% ES256, ES384, ES512

-define(JWT, #{
    algorithm => sh256,
    type => jwt,
    secret_key => <<"khmergear_jwt_123#@!456^%$">>,
    max_age => 30 * 3600 * 24 * 360 %% The full year expiration
}).
