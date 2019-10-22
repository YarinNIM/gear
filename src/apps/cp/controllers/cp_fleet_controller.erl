-module(cp_fleet_controller).
-export([
    get_services_action/3
]).


get_services_action(Req, State, _) ->
    Res = #{
        error => false,
        services => 'fdafdasf'
    },
    {Res, Req, State}.
