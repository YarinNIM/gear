-define(ROUTES, [
    {<<"/">>, #{ 
         get => core_home,
         post => {core_home, post, #{}},
         put => {core_home, put, #{action => put}},
         delete => {cor_home, delete, #{action => delete}}
    }},

    {<<"/home-net-good">>, #{
         get => core_home
    }},

    {<<"/test/:param_a[/:param_b]">>, #{
        get => {core_home, test_get}
    }},

    {<<"/test/123">>, #{
         put => {core_home, test}
    }}
]).
