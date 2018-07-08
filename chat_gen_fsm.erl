-module(chat_gen_fsm).
-export([start_link/1, connected/2]).
-export([init/1]).
-behaviour(gen_fsm).

start_link() ->
    
    gen_fsm:start_link({local, chat_gen_fsm}, ?MODULE, [], []).


init(Args) ->
    Clients = proplists:get_value(clients, Args),
    Name = proplists:get_value(name, Args),
    ClientPid = proplists:get_value(client_pid, Args),
    {ok, connected, [Clients, Name, ClientPid]}.

connected({send, {ReceiverName, Message}}, Clients) ->
    case proplists:get_value(ReceiverName, Clients) of
        undefined ->
            {error, no_client};
        Rec_fsmPid ->
            gen_fsm:send_event(Rec_fsmPid, {receive, {SenderName, Message}})
        end,
        {next_state, connected, Clients};
    
connected({receive, {SenderName, Message}}, ClientPid) ->
    gen_server:call(ClientPid, {receive, {SenderName, Message}),
    {next_state, connected, Clients}.

terminate(_Reason, _StateName, _StateData) ->
    ok.
    