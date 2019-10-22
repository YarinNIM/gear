-module(cp_app).
-include("config/config.hrl").
-include("config/routes.hrl").
-include("config/meta_data.hrl").
-include("config/resource.hrl").
-include("../../config/routes.hrl").
-export([
    routes/0, config/0, csrf/0,
    meta_data/0, resource/0,
    get_ids/1, perform/4
]).

routes() -> ?SYS_ROUTES++?ROUTES.
config() -> ?APP_CONFIG.
csrf() -> ?CSRF.
meta_data() -> ?META_DATA.
resource() -> ?RESOURCE.

get_ids(State) ->
    #{session_id:= Sid, account_id:= Aid} = State,
    Cid = session:get(company_id, Sid),
    {Sid, Cid, Aid}.

perform(State, Perm, Db_fun, Bind_param) -> 
    {_, Cid, Aid} = get_ids(State),
    case db:call(fun_cp_validate_permission, [Cid, Aid, Perm]) of
        true -> db:call(Db_fun, Bind_param);
        Else -> Else
    end.
