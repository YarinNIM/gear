-module(test_gen).
-export([
    send_mail/0
]).

send_mail() ->
    gen_smtp_client:send({"whatever@test.com", ["andrew@hijacked.us"],
 "Subject: testing\r\nFrom: Andrew Thompson <andrew@hijacked.us>\r\nTo: Some Dude <foo@bar.com>\r\n\r\nThis is the email body"},
  [{relay, "smtp.mailtrap.io"}, {username, "2a477f14917f6e"}, {password, "096b9521baa98e"}]).
