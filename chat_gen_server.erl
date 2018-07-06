-module(chat_gen_server).
-export([start_link/0, handle_call/3, init/1]).
-bahaviour(gen_server).


% -record(state, {clients}).


start_link() ->
    gen_server:start_link({global, chatServer}, ?MODULE, [], []).

init([]) -> {ok, []}.

handle_call({enter, Name}, _From, Clients) ->
    
    
    case lists:keymember(Name, 2, Clients) of
        true ->
            io:format("user is already in ~n"),
            {reply, user_is_already_in , Clients};
        
        false ->
            {ClientPid,_} = _From,
            io:format("users~p~n", [Clients]),
            case chat_gen_fsm: start_link(chat_gen_fsm, [{clients, Clients}, {name, Name}, {client_pid, ClientPid}],[] ) of
                {ok, fsm_Pid} ->
                    NewClients = [{fsm_Pid, Name}| Clients],
                    {reply, {ok, fsm_Pid}, NewClients};
                {error, Reason} ->
                    io:format("chat_gen_fsm is terminating ~p~n",[Reason]),
                    {stop, normal, Clients}

            end
            
            
    end.





    

 
