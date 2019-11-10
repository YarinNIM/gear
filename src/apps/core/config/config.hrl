-type env():: development | testing | production | atom().
-define(APP_CONFIG, #{
    vsn => <<"0.1">>,
    env => development,
    % is_production => false,
    language => <<"en">>,
    encryption_key => <<"km3rg3@r_@pp11cat10nf0r0nl1n3R#5T@UR@NT">>,
    auth_pages => [],

    login_page => <<"../account/login.html?ref_app=cambohub">>,
    brand_url => <<"{{ base_url }}picture/brand_logo/">>,
    product_picture => <<"{{ base_url }}picture/product/">>,
    account_picture => <<"{{ base_url }}picture/account/">>,
    company_logo => <<"{{ base_url }}picture/company_logo/">>
}).

-define(CSRF, #{
    enabled => true,
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

