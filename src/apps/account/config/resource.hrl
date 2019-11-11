-define(RESOURCE, #{
    vsn => <<"0.0.1">>,
    template => #{
        meta_data => resource_meta_data,
        resource => resource,
        page => resource_page
    },

    css => [],
    js => #{
        preload => [],
        init => []
    }
}).
