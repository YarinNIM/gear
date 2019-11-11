-define(COM, fun(URL)-> <<"/company/", URL/binary>> end).
-define(ROUTES, [
    %% Public
    {<<"/test.html">>, get, {account_home, test_get}},
    {<<"/test.html">>, post, {account_home, test_post}},

    {<<"/">>, get, {account_home, home}},
    {<<"/init_info.html">>, get, {account_home, init_info}},
    {<<"/account.html">>, get, {account, active_account}},
    {<<"/account.html">>, put, {account, update_account}},
    {<<"/companies.html">>, get, {account_company, companies}},
    {<<"/js_permission_keys.js">>, get, {resource, permission_keys}},

    %% Authentication
    {<<"/login.html">>, get, {account_login, render}},
    {<<"/login.html">>, post, {account_login, login}},
    {<<"/logout.html">>, get, {account, logout}},
    {<<"/password.html">>, put, {account, change_pwd}},


    {<<"/register.html">>, get, { account_register, render}},
    {<<"/register.html">>, post, { account_register, register}},
    {<<"/register/resend_verification.html">>, post, { account_register, resend_verification}},
    {<<"/verify-[number]-[string]-[string].html">>, get, { account_verify, verify}},
    {<<"/recover_pwd.html">>, post, { account_recover, recover_pwd}},
    {<<"/recover_pwd-[number]-[string]-[string].html">>, get, <<"account_recover@render_recover">>},
    {<<"/reset_password.html">>, post, { account_recover, reset_password}},

    {<<"/resource.html">>, get, {resource, get_resource}},

    %% For company
    {<<"/companies.html">>, get, {account_company, companies}},
    {<<"/select_company.html">>, get, {account_company, select_company}},

    %% Resource
    {<<"/addresses.html">>, get, {account_address, get_addresses}},
    {<<"/address.html">>, post, {account_address, insert_address}},
    {<<"/address.html">>, put, {account_address, update_address}},
    {<<"/address.html">>, delete, {account_address, delete_address}},

    {<<"/delivery_orders.html">>, get, {account_delivery_order, get_orders}},
    {<<"/delivery_order.html">>, get, {account_delivery_order, get_order}},

    %% This code block is for company access.
    %% The company access is to access the resource of the company.
    %% Only privilege account can access the company resource
    {?COM(<<"select.html">>), post, {account_company, select_company}},
    {?COM(<<"get_active.html">>), get, {account_company, get_active}}

 ]).
