-define(BASE, "{{ base_ur l}}").
-define(LIB, "{{ base_url }}lib/").

-define(RESOURCE,#{
    vsn => <<"0.0.1">>,

    template => #{
        meta_data => resource_meta_data,
        resource => resource,
        page => resource_page
    },

    css => [ 
        ?LIB ++ "bulma/css/bulma.min.css",
        "{{ base_url }}css/account_style.css"
    ],

    js => #{
        preload => [ 
            ?LIB ++ "react/react.development.js",
            ?LIB ++ "fontawesome/all.js",
            ?LIB ++ "redux/redux.min.js",
            ?LIB ++ "redux/react-redux.min.js",
            ?LIB ++ "date.js",
            ?LIB ++ "jquery-3.3.1.min.js",
            "{{ base_url }}js_permission_keys.js?key=company"
        ],

        init => [
            ?LIB ++"react-dom/react-dom.development.js",
            ?LIB ++ "ajax.js"
        ]
    }
}).
