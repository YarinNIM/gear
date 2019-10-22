%% @doc Data configration allows your
%% to configure database, type of database
%% you're using, and how many database connection
%% you are connection and wich default database
%% connection is used when access the database resource.

%% The default database
-define(DB_DEFAULT_POOL, main).
-define(DB, #{
    main => #{
        driver => "postgres",
        host => "localhost",
        %host => "192.168.0.122",
        database => "database_name",
        user_name => "user_name",
        password => "password",
     
        size => 10,
        max_overflow => 20
    }
}).

%-define(DB_RECORD_SIZE, 20).
