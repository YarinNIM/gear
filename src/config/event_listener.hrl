-define(EVENT_LISTENER, #{
    event_handler_logger => #{
        vsn => "0.1",
        desc => "Handle event and rgisters the activities log.",
        db_pool => log
    }
    %logger_test => []
}).
