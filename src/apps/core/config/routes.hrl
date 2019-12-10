-define(ROUTES, [
    {<<"/">>, get, core_home }, 
    {<<"/test/123">>, get, {core_home, test}},
    {<<"/test/content/[number]">>, get, {core_home, test_bind}}
]).
