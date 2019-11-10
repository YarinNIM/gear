-define(ROUTES, [
    {<<"">>, get, {cam_home, index} },
    {<<"/">>, get, {cam_home, index} },

    {<<"/about-us.html">>, get, {cam_page, about_us}},
    {<<"/contact-us.html">>, get, {cam_page, contact_us}},

    {<<"/properties.html">>, get, {cam_properties, index}},
    {<<"/properties-[number].html">>, get, {cam_properties, detail}}
]).
