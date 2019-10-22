-define(ADMIN_PER, 
#{
    system => #{
        name => <<"System Setting">>,
        permission => #{
            account => <<"View Account">>,
            account_modify => <<"Modify Account">>,

            admin_account => <<"View admin account">>,
            admin_account_modify => <<"Modify admin account">>,

            role_view => <<"View account role">>,
            role_modify => <<"Modify account role">>,

            resource_view => <<"View system resource">>,
            resource_modify => <<"Modify system resource">>
        }
    },

    company => #{
        name =>  <<"Company Management">>,
        permission => #{
            view => <<"List Company">> ,
            sale_channel => <<"Manage Sale Channels">>,
            modify => <<"Manage Company Info.">> ,
            account => <<"Company Account">> ,
            contact_person => <<"Contact Person">>,
            resource => <<"Company Resource">>,
            job_ann => <<"Job Accouncement">>
        }
    },

    catalog => #{
        name => <<"Catalog/Fleet Management">>,
        permission => #{
            product_category => <<"Product Category">>,
            product_brand => <<"Manage Product Brands">>,
            product_spec => <<"Product Specifications">>,
            product_model => <<"Product Model">>,
            product_view => <<"View Product">>,
            product_modify => <<"Modify Product">>,
            vehicle_type => <<"Manage vehicle type">>,
            vehicle_view => <<"List Vehicles">>,
            vehicle_modify => <<"Manage Vehicles">>
        }
    },

    service => #{
        name => <<"Manage system services">>,
        permission => #{
            delivery_view => <<"Delivery Report">>,
            delivery_modify => <<"Delivery Management">>
        }
    }


}).

-define(COM_ROLE, 
#{
    admin => #{
        name => <<"Administrative Task">>,
        permission => #{
            customer => <<"View Customer">>,
            customer_modify => <<"Manage Customer">>,
            vehicle => <<"List of vehicle">>,
            vehicle_modify => <<"Manage Vehicle">>,
            invoice_view => <<"Invoice list Acess">>,
            invoice_modify => <<"Manage invoice">>
        }
    },

    company => #{
        name=> <<"Company Management">>,
        permission => #{
            view => <<"View Company">>,
            sale_channel => <<"Manage Sale Channels">>,
            modify => <<"Modify Company">>,
            resource_view => <<"View Company Resource">>,
            resource_modify => <<"Modify Company Resource">>,
            account => <<"Account Management">>,
            contact_person => <<"Contact Person">>
        }
    },

    service => #{
        name => <<"Access to Services">>,
        permission => #{
            fleet_pos => <<"Fleet POS">>,
            fleet_report => <<"Fleet Report">>,
            fleet_admin => <<"Fleet Manager">>
        }
    },

    catalog => #{
        name => <<"Catalog Management">>,
        permission => #{
            product_view => <<"View products">>,
            product_modify => <<"Modify Product">>
        }
    }

}).

