-module(db_worker).
-behaviour(gen_server).
-export([start_link/1]).

%% gen_server callbacks
-export([
    init/1, handle_call/3, 
    handle_cast/2, handle_info/2, 
    terminate/2, code_change/3,
    get_squery/3
]).
-define(SERVER, ?MODULE).
-define(V(K, L), proplists:get_value(K, L)).
-define(V(K, L, D) , proplists:get_value(K, L, D)).
-record(state, {connection, statement}).

start_link(Args) ->
    gen_server:start_link(?MODULE, Args, []).

init(Args) ->
    #{host := Host} = Args,
    #{database := DB} = Args,
    #{user_name := UName} = Args,
    #{password := Pwd} = Args,

    Connection = case epgsql:connect(Host, UName, Pwd, [{database, DB}]) of
        {ok, Con} -> Con;
        Msg -> io:format(' - Error in connection to database:~n~p~n~n   
            Host: ~p~n   
            User: ~p~n   
            Pwd: ~p~n   
            DB: ~p~n===========~n', [Msg, Host, UName, Pwd, DB])
    end,
    {ok, #state{connection=Connection, statement=#{}}}.

get_squery(Con, Q, Params) -> 
    case epgsql:equery(Con, Q, Params) of
        %% For update statement
        {ok, Count} -> 
            {ok, Count}; % on update

        %% for Select statement
        {ok, Cols, R1} ->
            {ok, add_column_names(Cols, R1)}; 

        %% for insert statement
        {ok, _, Cols, R2} -> 
            {ok, add_column_names(Cols, R2)};

        %% Error database
        {error, R3} -> 
            {error, R3} % on error
    end.

% cast({_, Col, numeric, _, _}) ->

%% @doc Add the list with column name
-spec add_column_names(Columns::list(), Rows::list()) -> Row_detail::list().
add_column_names(Cols, Rows) ->
    Fieldname = [{element(2, C), element(3, C)} || C <- Cols],
    [add_column_name(tuple_to_list(Row), Fieldname) || Row <- Rows].

add_column_name(Cols, Rows) -> add_column_name(Cols, Rows, #{}).
add_column_name(_, [], Map) -> Map;
add_column_name([null | Tr],[_ | Tf], Map) -> add_column_name(Tr,Tf, Map);
add_column_name([Hr | Tr],[{Fn, Type} | Tf], Map) -> 
    %%io:format('Type: ~p~nValue: ~p~n',[Type, Hr]),
    Hr1 = case Type of
        date -> {Hr, {0,0,0}};
        numeric -> erlang:binary_to_float(Hr);
        {unknown_oid, 1700} -> type:to_float(Hr);
        jsonb -> jsx:decode(Hr, [return_maps]);
        {unknown_oid, 3802} -> jsx:decode(Hr, [return_maps, {labels, attempt_atom}]);
        _ -> Hr
    end,
    Map1 = Map#{ type:to_atom(Fn) => Hr1},
    add_column_name(Tr, Tf, Map1).



status({Status, Res}) ->
    case Status of
        error -> 
            {_, _, _Et, _Ec, Emsg, _Ed} = Res,
            %Error = #{ error => true, msg => Emsg,
            %   code => Ec, type => Et,
            %   detail => Ed
            %},
            {error, Emsg};
        _ -> Res
    end.

column_info(Table, Con) -> 
    Sql = <<"select column_name, data_type, udt_name from information_schema.columns 
        where table_name = $1">>,
    {ok, Rows} = get_squery(Con, Sql, [Table]),
    Res = lists:foldr(fun(Row, Map) ->
        #{ column_name:= Name,
           data_type := Type,
           udt_name := Udt} = Row,
        Map#{ Name => {Type, Udt}}
    end, #{}, Rows),
    epgsql:sync(Con),
    Res.

handle_call({column_info, Table}, _, State = #state{connection = Con}) ->
    Res = column_info(Table,Con),
    {reply, Res, State};

%% @doc Handles query request
handle_call({equery, Query, Params}, _From, State = #state{connection=Con}) ->
    Res = get_squery(Con, Query, Params),
    epgsql:sync(Con),
    {reply, status(Res), State};

%% @doc Handle query and return single row
handle_call({query_row, Q, P}, _F, State = #state{connection = Con}) ->
    Res = case status(get_squery(Con, Q, P)) of
        [] -> false;
        [Row | _] -> Row;
        Else -> Else
    end,
    epgsql:sync(Con),
    {reply, Res, State};

%% @doc Handles in query builder format
handle_call({insert, Table, Data, Rd}, _, State = #state{connection = Con}) ->
    Col_info = column_info(Table, Con),
    {Query, Params} = db_query_builder:insert(Table, Data, Col_info),
    Ren = type:to_binary(Rd),
    Sql = case Ren of
        <<"undefined">> -> Query;
        _ -> <<Query/binary, " returning ", Ren/binary>>
    end,
    Res = get_squery(Con, Sql, Params),
    epgsql:sync(Con),
    {reply, status(Res), State};

%% @doc Handles database function call
handle_call({call, _Fun, _Params}, _F, State = #state{connection = _Con}) ->
    {reply, ok, State}.


handle_cast({execute, Sql, Param}, State = #state{connection = Con}) ->
    io:format(' - Execute db statement asyn...~n'),
    epgsql:equery(Con, Sql,Param),
    {noreply, State};
handle_cast({call, Fun, Params}, State= #state{connection = Con}) ->
    io:format(' - Call db function asyn...~n'),
    F_nam = type:to_binary(Fun),
    Binds = db_query_builder:params_to_binded(Params),
    Sql = <<"select * from ",F_nam/binary, "(", Binds/binary, ");">>,
    epgsql:equery(Con, Sql, Params),
    {noreply, State};
handle_cast(_Msg, State) ->
    io:format(' - Handling cast...~n'),
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, #state{connection = Conn}) ->
    ok = epgsql:close(Conn),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% @doc Converts list of parameters to 
%% binded number associated with parameters

