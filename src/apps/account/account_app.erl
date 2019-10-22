-module(account_app).
-include("config/config.hrl").
-include("config/routes.hrl").
-include("config/meta_data.hrl").
-include("config/resource.hrl").
-export([
    routes/0, config/0, csrf/0,
    meta_data/0, resource/0, jwt/0
]).

routes() -> ?ROUTES.
config() -> ?APP_CONFIG.
csrf() -> ?CSRF.
meta_data() -> ?META_DATA.
resource() -> ?RESOURCE.
jwt() -> ?JWT.
