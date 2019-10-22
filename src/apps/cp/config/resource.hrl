-define(BASE, "{{ base_url }}").
-define(LIB, ?BASE ++ "lib/").

-define(RESOURCE,#{
    vsn => <<"0.0.2">>,
    template => #{
        meta_data => resource_meta_data,
        resource => resource,
        page => resource_page
    },

    css => [ 
        ?LIB ++ "bulma/css/bulma.min.css",
        ?BASE ++ "css/invoice.css",
        ?BASE ++ "css/font_play.css",
        ?BASE ++ "css/cp.css",
        ?BASE ++ "css/sys_style.css"
    ],

    js => #{
        preload => [
            ?LIB ++ "react/react.production.min.js",
            ?LIB ++ "fontawesome/all.js",
            ?LIB ++ "array.js",
            ?LIB ++ "redux/redux.min.js",
            ?LIB ++ "redux/react-redux.min.js",
            ?LIB ++ "react_crop.js",

            ?BASE++"js_permission_keys.js?key=company",
            ?LIB ++ "date.js",
            ?LIB ++ "string.js",
            ?LIB ++ "number.js",
            ?LIB ++ "jquery-3.3.1.min.js"
        ],

        init => [
            ?LIB ++ "react-dom/react-dom.production.min.js",
            ?LIB ++ "ajax.js",
            ?BASE ++ "js/app.js"
        ]
    }
}).
