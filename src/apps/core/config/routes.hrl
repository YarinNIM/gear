-define(ROUTES, [
    {<<"/">>, #{ 
         get => core_home,
         post => {core_home, post, #{}}
    }},

    {<<"/test">>, #{
        get => {core_home, test_get}
    }},

    {<<"/test/123">>, #{
         put => {core_home, test}
    }}
]).
