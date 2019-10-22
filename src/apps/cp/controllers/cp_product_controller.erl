-module(cp_product_controller).
-export([ 
    get_products_action/3
]).

get_products_action(Req, State, _) ->
    #{ session_id:= Sid} = State,
    Cid = session:get(company_id, Sid),
    #{ q:= Q } = cowboy_req:match_qs([{q, [], <<>>}], Req),
    Q1 = string:trim(Q),
    Res = #{
        error => false,
        products => product_model:get_pos_products(#{ 
            title => {<<"%", Q1/binary, "%">>, ilike},
            company_id => Cid
        })
    },
    {Res, Req, State}.
