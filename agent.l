
(setq *Server-Port 12321)
(setq *Server-Sock NIL)


# Server
(de _run-client-task (Sock Adr)
   (in Sock
      (if (rd)
         (let (Req @)
            (_log "[server] (Client Ip @1 Sock @2) (Req . @3)" Adr Sock @)
            (out Sock (pr (eval Req))) )
         (_log "[server] (Client Ip @1 Sock @2) closed." Adr Sock)
         (task Sock)           #unregister client handler
         (close Sock) ) ) )

(de start-server ()
   (if *Server-Sock
      (_log "[server] (Server Sock @1) already listen!" *Server-Sock)
      (prog1
         (_log "[server] (Server Port @1) starting..." *Server-Port)
         (let? Server (port *Server-Port)
            (setq *Server-Sock Server)
            (task Server
               (when (accept @)
                  (task @        # start background task client handler
                     Adr *Adr
                     (_run-client-task @ Adr) ) ) ) )
         (_log "[server] (Server Sock @1) listen..." *Server-Sock) ) ) )

(de stop-server ()
   (ifn *Server-Sock
      (_log "[server] (Server) not running")
      (task *Server-Sock)  # unregister server sock
      (close *Server-Sock)
      (_log "[server] (Server Sock @1) stopped." *Server-Sock)
      (setq *Server-Sock NIL) ) )


# Client
(de client ()
   (let? Sock (connect "localhost" *Server-Port)
      (_log "[client] (Client Sock @1) connected to Server." Sock)
      (out Sock (pr '*Pid))
      (task Sock
         (println 'Reply 'PID (in @ (rd)))
         (task @)
         (close @)
         (_log "[client] (Client Sock @1) closed." Sock) ) ) )

(de client2 ()
   (let? Sock (connect "localhost" *Server-Port)
      (_log "[client2] (Client2 Sock @1) connected to Server." Sock)

      # start first task
      (out Sock (pr '*Pid))
      (task Sock
         Sock Sock  # capture socket
         (println 'Reply2 'PID (in Sock (rd)))
         (task Sock)

         # start second task
         (out Sock (pr '(+ 12 23)))
         (task Sock
            Sock Sock # capture socket
            (println 'Reply2 'PLUS (in Sock (rd)))
            (task Sock)
            (close Sock)
            (_log "[client2] (Client Sock @1) closed." Sock) ) ) ) )



# Debug
(de _debug ()
   (trace 'start-server)
   (trace 'client) )

(de _log (F . @)
   (prinl (tim$ (time) T) " DD - " (apply text (rest) F))
   nil )
