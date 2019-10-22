-define(BASE, "{{ base_url }}").
-define(LIB, ?BASE ++ "lib/").

-define(RESOURCE,#{
    vsn => <<"0.0.1">>,

    template => #{
        meta_data => resource_meta_data,
        resource => resource,
        page => resource_page
    },

    css => [
        ?LIB ++ "bulma/css/bulma.min.css",
        ?LIB ++ "bulma/css/bulma.css.map",
        ?BASE ++ "css/font_play.css",
        ?BASE ++ "css/sys_style.css"
    ],

    js => #{
        preload => [
            ?LIB ++ "react/react.development.js",
            ?LIB ++ "fontawesome/all.min.js",
            ?LIB ++ "array.js",
            ?LIB ++ "redux/redux.min.js",
            ?LIB ++ "redux/react-redux.min.js",

            ?BASE++"js_permission_keys.js?key=admin",
            ?LIB ++ "date.js",
            ?LIB ++ "string.js",
            ?LIB ++ "number.js",
            ?LIB ++ "jquery-3.3.1.min.js"
        ],

        init => [
            ?LIB ++ "react-dom/react-dom.development.js",
            ?LIB ++ "ajax.js",
            ?BASE ++ "js/app.js"
        ]
    }
}).
