-define(APP_CONFIG, #{
    vsn => <<"0.1">>,
    is_production => false,
    language => <<"en">>,
    encryption_key => <<"km3rg3@r_@pp11cat10n">>,
    auth_pages => [ admin_home ],

    db_row_size => 20,

    login_page => <<"ac/login.html?service=admin">>,
    cdn_url => <<"https://cdn.gear.loc/">>,
    static_url => <<"http://static.gear.loc/">>,
    brand_url => <<"{{ base_url }}pictures/brand_logo/">>,
    company_logo => <<"{{ base_url }}pictures/company_logo/">>,
    company_cover => <<"{{ base_url }}pictures/company_cover/">>
}).

-define(CSRF, #{
    enabled => true,
    expire => 60*30,
    token_name => <<"khmergear_csrf_key">>,
    regenerate => false,
    cookie_name => <<"khmergear_csrf_hash">>,
    except_urls => [], secure=> true,
    domain => <<"admin.gear.loc">>, path => <<".">>
}).

-define(JWT, #{
    token => <<"khmergear_jwt">>,
    method => hs256,
    expire =>  360 * 24 * 360
}).
