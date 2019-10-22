-define(ROUTES, [
    {<<"">>, get, <<"admin_home@init">>, index},
    {<<"/">>, get, <<"admin_home@init">>, index},

    %% Static resource for application 
    %{<<"/resource.html">>, get, <<"admin_resource@index">>, <<"heaer is the param">>},
    {<<"/init_resource.html">>, get, <<"admin_home@init">>, resource},
    %{<<"/js_permission_keys.js">>, get, <<"admin_resource@permission_keys">>},

    %% Login page
    %{<<"/login.html">>, get, <<"admin_login@render">>},
    %{<<"/login.html">>, post, <<"admin_login@login">>},
    {<<"/logout.html">>, get, <<"admin_login@logout">>},

    %{<<"/admin_role.html">>, get, <<"admin_admin_role@init">>, {get_roles, ["admin_role.view"]}},
    {<<"/role_permission.html">>, get, <<"admin_role@init">>, {get_roles, ["system.role_view", "system.role_view"]}},
    {<<"/role_permission.html">>, post, <<"admin_role@init">>, {insert_role, ["system.role_modify"]}},
    {<<"/role_permission.html">>, put, <<"admin_role@init">>, {update_role,  ["system.role_modify"]}},
    {<<"/role_permission/[number].html">>, delete, <<"admin_role@init">>, {delete_role, ["system.role_modify"]}},
    %{<<"/role_permission.html">>, post, <<"admin_admin_role@init">>, {insert_role, ["system.role_modify"]}},

    %{<<"/admin_role.html">>, put, <<"admin_admin_role@init">>, {update_role, ["admin_role.update"]}},
    %{<<"/admin_role-[number].html">>, delete, <<"admin_admin_role@init">>, {delete_role, ["admin_role.delete"]}},

    {<<"/admin_account.html">>, get, <<"admin_account@get_accounts">>},
    {<<"/admin_account.html">>, post, <<"admin@handle">>, {admin_account, insert_account,["system.admin_account_modify"]}},
    {<<"/admin_account.html">>, put, <<"admin@handle">>, {admin_account, update_account, ["system.admin_account_modify"]}},
    {<<"/admin_account.html">>, delete, <<"admin@handle">>, {admin_account, delete_account, ["system.admin_account_modify"]}},

    %% Never user /account/
    %% as it's used by account_app to map the folder name
    %% where the account_app is accessed by /account/
    {<<"/account.html">>, post, <<"admin@handle">>, {account, insert_account, ["system.account_modify"]}},
    %{<<"/account.html">>, put, <<"admin_account@init">>, {update_account, ["system.account_modify"]}},
    {<<"/account.html">>, put, <<"admin@handle">>, {account, update_account, ["system.account_modify"]}},
    {<<"/account-field.html">>, put, <<"admin@handle">>, {account, update_field, ["system.account_modify"]}},
    %{<<"/account-search.html">>, post, <<"admin_account@init">>, {search_account,["system.account"]}},
    %{<<"/account-search.html">>, post, <<"account@search_account">>},

    %{<<"/company/get_companies.html">>, get, <<"admin_company@init">>, {get_companies, ["company.view"]}},
    {<<"/company.html">>, post, <<"admin@handle">>, {company, insert_company, ["company.modify"]}},
    {<<"/company.html">>, put, <<"admin@handle">>, {company, update_company, ["company.modify"]}},
    {<<"/company.html">>, delete, <<"admin@handle">>, {company, delete_company, ["company.modify"]}},

    {<<"/company/cover.html">>, post, <<"admin@handle">>, {company_cover, insert_cover,["company.modify"]}},
    {<<"/company/cover.html">>, put, <<"admin@handle">>, {company_cover, update_cover, ["company.modify"]}},
    {<<"/company/logo.html">>, post, <<"admin@handle">>, {company_cover, insert_logo, ["company.modify"]}},
    {<<"/company/logo.html">>, put, <<"admin@handle">>, {company_cover, update_logo, ["company.modify"]}},
    {<<"/company/contact.html">>, put, <<"admin@handle">>, {company, update_contact, ["company.modify"]}},

    {<<"/company/address.html">>, post, <<"admin@handle">>, {company_address, insert_address, ["company.modify"]}},
    {<<"/company/address.html">>, put, <<"admin@handle">>, {company_address, update_address, ["company.modify"]}},
    {<<"/company/address.html">>, delete, <<"admin@handle">>, {company_address, delete_address, ["company.modify"]}},
    {<<"/company/subcompany.html">>, post, <<"admin@handle">>, {company, insert_subcompany, ["company.modify"]}},
    {<<"/company/subcompany.html">>, delete, <<"admin@handle">>, {company, delete_subcompany, ["company.modify"]}},

    {<<"/company/contact_person.html">>, post, <<"admin@handle">>, {company_member, insert_contact_person,  [<<"company.contact_person">>]}},
    {<<"/company/contact_person.html">>, delete, <<"admin@handle">>, {company_member, delete_contact_person, [<<"company.contact_person">>]}},
    {<<"/company/contact_person.html">>, put, <<"admin@handle">>, {company_member, update_contact_person, [<<"company.contact_person">>]}},
    {<<"/company_account.html">>, post, <<"admin@handle">>, {company_member, insert_account, [<<"company.account">>]}},
    {<<"/company_account.html">>, delete, <<"admin@handle">>, {company_member, delete_account, [<<"company.account">>]}},
    {<<"/company_account.html">>, put, <<"admin@handle">>, {company_member, update_account, [<<"company.account">>]}},
    {<<"/company/sale_channel.html">>, post, <<"admin@handle">>, {company_sale_channel, insert_channel, [<<"company.sale_channel">>]}},
    {<<"/company/sale_channel.html">>, put, <<"admin@handle">>, {company_sale_channel, update_channel, [<<"company.sale_channel">>]}},
    {<<"/company/sale_channel.html">>, delete, <<"admin@handle">>, {company_sale_channel, delete_channel, [<<"company.sale_channel">>]}},

    {<<"/country.html">>, put, {admin, handle}, {country, update_country,[<<"system.resource_modify">>]}},

    %%
    %% Delivery Service
    %%
    {<<"/delivery/subscribers.html">>, get, {admin, handle}, {delivery_subscriber, get_subscribers, [<<"service.delivery_view">>]}},
    {<<"/delivery/none_subscribers.html">>, get, {admin, handle}, {delivery_subscriber, get_none_subscribers, [<<"service.delivery_view">>]}},
    {<<"/delivery/subscriber.html">>, post, {admin, handle}, {delivery_subscriber, insert_subscriber, [<<"service.delivery_modify">>]}},
    {<<"/delivery/subscriber.html">>, put, {admin, handle}, {delivery_subscriber, update_subscriber, [<<"service.delivery_modify">>]}},
    {<<"/delivery/subscriber.html">>, delete, {admin, handle}, {delivery_subscriber, delete_subscriber, [<<"service.delivery_modify">>]}},

    {<<"/delivery/service_charge.html">>, put, {admin, handle}, {delivery, service_charge, [<<"service.delivery_modify">>]}},
    {<<"/delivery/agents.html">>, get, {admin, handle}, {delivery_agent, get_agents, [<<"service.delivery_view">>]}},
    {<<"/delivery/none_agents.html">>, get, {admin, handle}, {delivery_agent, get_none_agents, [<<"service.delivery_view">>]}},
    {<<"/delivery/agent.html">>, post, {admin, handle}, {delivery_agent, insert_agent, [<<"service.delivery_modify">>]}},
    {<<"/delivery/agent.html">>, put, {admin, handle}, {delivery_agent, update_agent, [<<"service.delivery_modify">>]}},
    {<<"/delivery/agent.html">>, delete, {admin, handle}, {delivery_agent, delete_agent, [<<"service.delivery_modify">>]}},

    {<<"/delivery/orders.html">>, get, {admin, handle}, {admin_delivery_order, get_orders, [<<"service.delivery_view">>]}},
    {<<"/delivery/order.html">>, get , {admin, handle}, {admin_delivery_order, get_order, [<<"serivce.delivery_view">>]}},
    {<<"/delivery/order-[number].html">>, get , {admin, handle}, {admin_delivery_order, get_order, [<<"serivce.delivery_view">>]}},
    %% End delivery service

    {<<"/product_category.html">>, post, <<"admin@handle">>, {product_category, insert_category, [<<"catalog.product_category">>]}},
    {<<"/product_category.html">>, put, <<"admin@handle">>, {product_category, update_category, [<<"catalog.product_category">>]}},
    {<<"/product_category.html">>, delete, <<"admin@handle">>, {product_category, delete_category, [<<"catalog.product_category">>]}},
    {<<"/product_category/spec.html">>, post, <<"admin@handle">>, {product_category, insert_spec, [<<"catalog.product_category">>]}},
    {<<"/product_category/spec.html">>, delete, <<"admin@handle">>, {product_category, delete_spec, [<<"catalog.product_category">>]}},

    {<<"/product_sub_category.html">>, post, <<"admin@handle">>, {product_category, insert_sub_category, [<<"catalog.product_category">>]}},
    {<<"/product_sub_cateogry.html">>, delete, <<"admin@handle">>, {product_category, delete_sub_category, [<<"catalog.product_category">>]}},
    {<<"/product_sub_category.html">>, put, <<"admin@handle">>, {product_category, update_sub_category, [<<"catalog.product_category">>]}},
    {<<"/product_brand/logo.html">>, post, <<"admin@handle">>, {product_brand, upload_logo,[<<"catalog.product_brand">>]}},
    {<<"/product_brand/logo.html">>, put, <<"admin@handle">>, {product_brand, update_logo, [<<"catalog.product_brand">>]}},
    {<<"/product_brand.html">>, put, <<"admin@handle">>, {product_brand, update_brand, [<<"catalog.product_brand">>]}},
    {<<"/product_brand.html">>, delete, <<"admin@handle">>, {product_brand, delete_brand, [<<"catalog.product_brand">>]}},
    {<<"/product_spec.html">>, post, <<"admin@handle">>, {product_spec, insert_spec, [<<"catalog.product_spec">>]}},
    {<<"/product_spec.html">>, put, <<"admin@handle">>, {product_spec, update_spec, [<<"catalog.product_spec">>]}},
    {<<"/product_spec.html">>, delete, <<"admin@handle">>, {product_spec, delete_spec, [<<"catalog.product_spec">>]}},

    {<<"/vehicle_type.html">>, post, <<"admin@handle">>, {vehicle_type, insert_type, [<<"catalog.vehicle_type">>]}}, {<<"/vehicle_type.html">>, put, <<"admin@handle">>, {vehicle_type, update_type, [<<"catalog.vehicle_type">>]}},

    {<<"/product_model.html">>, post, <<"admin@handle">>, {product_model, insert_model, [<<"catalog.product_model">>]}},
    {<<"/product_model.html">>, put, <<"admin@handle">>, {product_model, update_model, [<<"catalog.product_model">>]}},
    {<<"/product_model.html">>, delete, <<"admin@handle">>, {product_model, delete_model, [<<"catalog.product_model">>]}},
    {<<"/product_model/move.html">>, put, <<"admin@handle">>, {product_model, move_model, [<<"catalog.product_model">>]}},

    %% Location Management, where to manage country/province and subordnates
    {<<"/province.html">>, put, {admin, handle}, {province, update_province, [<<"system.resource_modify">>]}},
    {<<"/district.html">>, post, {admin, handle}, {district, insert_district, [<<"system.resource_modify">>]}},
    {<<"/district.html">>, put, {admin, handle}, {district, edit_district, [<<"system.resource_modify">>]}},
    {<<"/district.html">>, delete, {admin, handle}, {district, delete_district, [<<"system.resource_modify">>]}},
    %{<<"/district/village.html">>, post, {admin, handle}, {district, insert_vilalge, [<<"system.resource_modify">>]}},
    {<<"/village.html">>, post, {admin, handle}, {village, insert_village, [<<"system.resource_modify">>]}},
    {<<"/village.html">>, put, {admin, handle}, {village, update_village, [<<"system.resource_modify">>]}},
    {<<"/village.html">>, delete, {admin, handle}, {village, delete_village, [<<"system.resource_modify">>]}},

    {<<"/vehicle.html">>, post, <<"admin@handle">>, {vehicle, insert_vehicle, [<<"catalog.vehicle_modify">>]}},
    {<<"/vehicle.html">>, put, <<"admin@handle">>, {vehicle, update_vehicle, [<<"catalog.vehicle_modify">>]}},
    {<<"/vehicle_model.html">>, post, <<"admin@handle">>, {vehicle_model, insert_model, [<<"catalog.vehicle_modify">>]}},
    {<<"/vehicle_model.html">>, put, <<"admin@handle">>, {vehicle_model, update_model, [<<"catalog.vehicle_modify">>]}},
    {<<"/vehicle_model.html">>, delete, <<"admin@handle">>, {vehicle_model, delete_model, [<<"catalog.vehicle_modify">>]}}
 ]).
