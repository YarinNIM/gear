-define(EMAILS, #{
    noreply => env:get(email_noreply, #{
        options => [
            {username, "2a477f14917f6e"},
            {password, "096b9521baa98e"},
            {relay, "smtp.mailtrap.io"},
            {port, 2525},
            {tls, always}
        ],
        from => "Noreply GEAR"
    })
}).
