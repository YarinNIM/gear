-module(admin_app).
-include("config/config.hrl").
-include("../../config/routes.hrl").
-include("config/routes.hrl").
-include("config/meta_data.hrl").
-include("config/resource.hrl").
-export([
    routes/0, config/0, csrf/0,
    meta_data/0, resource/0, jwt/0
]).

config() -> ?APP_CONFIG.
routes() -> ?SYS_ROUTES ++ ?ROUTES.
csrf() -> ?CSRF.
meta_data() -> ?META_DATA.
resource() -> ?RESOURCE.
jwt() -> ?JWT.

