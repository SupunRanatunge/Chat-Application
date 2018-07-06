-module(chat_gen_fsm).
-export().
-behaviour(gen_fsm).

start_link(Name) ->
    gen_fsm:start_link({local, server}, ?MODULE, [Name], []).


    init(Args) ->
            Clients = proplists:get_value(clients, Args),
            Name = proplists:get_value(name, Args),
            ClientPid = proplists:get_value(client_pid, Args),
            {ok, connected, #state{clients = Clients, name = Name, client_pid = ClientPid}}.

connected({send, {ReceiverName, Message}}, Clients) ->
    case proplists:get_value(RecieverName, Clients) of
        undefined ->
            {error, no_client};
        HandlerPid ->
            gen_fsm:send_event(HandlerPid, {recieve, {SenderName, Message}})
        end,
    