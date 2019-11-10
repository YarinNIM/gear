%%
%% @doc How the system request 
%% to access CORS to another host
-define(CORS, #{
    default => localhost,
    localhost => #{
        url => <<"http://localhost:8080">>,
        headers => #{
            cors_key => <<"cors-requeset-key">>,
            cors_hash =>  <<"where is the contetn of testing">>
        },
        optons => #{
            timeout => 166
        }
     }
}).
