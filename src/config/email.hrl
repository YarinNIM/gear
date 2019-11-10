-define(EMAILS, #{
    noreply => env:get(email_noreply, #{
        options => [
            {username, "admin@gear.com"},
            {password, "secret"},
            {relay, "smtp.gear.com"},
            {port, 587},
            {tls, always}
        ],
        from => "Noreply GEAR"
    })
}).
