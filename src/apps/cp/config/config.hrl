-define(APP_CONFIG, #{
    vsn => <<"0.1">>,
    is_production => false,
    language => <<"en">>,
    encryption_key => <<"km3rg3@r_@pp11cat10n">>,
    auth_pages => [
        cp_home
    ],

    db_row_size => 20,

    login_page => <<"account/login.html?service=cp">>,
    cdn_url => <<"https://cdn.gear.loc/">>,
    static_url => <<"https://static.gear.loc/">>,
    profile_url => <<"{{ base_url }}pictures/profile/">>,
    cover_url => <<"{{ base_url }}pictures/profile_cover/">>,
    brand_url => <<"{{ base_url }}pictures/brand_logo/">>,
    product_picture => <<"{{ base_url }}pictures/product/">>,

    company_logo => <<"{{ base_url }}pictures/company_logo/">>,
    company_cover => <<"{{ base_url }}pictures/company_cover/">>
}).

-define(CSRF, #{
    enabled => true,
    expire => 60*30,
    token_name => <<"khmergear_csrf_key">>,
    regenerate => false,
    cookie_name => <<"khmergear_csrf_hash">>,
    except_urls => []
}).
