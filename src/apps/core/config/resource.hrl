-define(BASE, "{{ base_url }}").
-define(LIB, ?BASE ++ "lib/").

-define(RESOURCE,#{
    vsn => <<"0.0.1">>,
    %% template => #{
    %%  meta_data => resource_meta_data,
    %%  resource => or_resource,
    %%  page => or_page
    %% },

    css => [ 
        ?LIB ++ "icon-theme.min.css",
        ?BASE ++ "css/style.css"
    ],

    js => #{
        preload => [
            ?LIB ++ "util.min.js",
            ?LIB ++ "lib.min.js",
            ?BASE ++ "js/app.js"
        ],

        init => [
            ?BASE ++ "locale/en/locale.js"
            %% ?LIB ++ "react-dom.development.js"
        ]
    }
}).
