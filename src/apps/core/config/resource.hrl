-define(BASE, "{{ base_url }}").
-define(LIB, ?BASE ++ "lib/").

-define(RESOURCE,#{
    vsn => <<"0.0.1">>,
    %% template => #{
    %%  meta_data => resource_meta_data,
    %%  resource => or_resource,
    %%  page => or_page
    %% },

    css => [ ],

    js => #{
        preload => [ ],
        init => [ ]
    }
}).
