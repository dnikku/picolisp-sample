
# Server
(de start-server ()
   (task (port 12321)                     # Background server task
      (let? Sock (accept @)
         (unless (fork)                   # Handle request in child process
            (in Sock
               (while (rd)                # Handle requests
                  (out Sock
                     (pr (eval @)) ) ) )  # Evaluate and send reply
            (bye) )                       # Exit child process
         (close Sock) ) ) )               # Close socket in parent process


# Client
(de client ()
   (let? Sock (connect "localhost" 12321)
      (out Sock (pr '*Pid))               # Query PID from server
      (println 'PID (in Sock (rd)))       # Receive and print reply
      (out Sock (pr '(* 3 4)))            # Request some calculation
      (println 'Result (in Sock (rd)))    # Print result
      (close Sock) ) )                      # Close connection to server
