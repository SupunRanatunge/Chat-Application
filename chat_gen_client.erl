-module(chat_gen_client).
-behaviour(gen_server). 
-export([start_link/1]).
-export([init/1]).

-record(state, {fsm_Pid}).

%%% Client API
start_link(Name) ->  
    gen_server:start_link({local, clientServer}, ?MODULE, [Name], []).

init(Name) -> 
    % gen_server: call({global, chat_gen_server}, {enter, Name}).
    case gen_server:call({global, chat_gen_server}, {enter, Name}) of
    {ok, Fsm_Pid} ->
      {ok, #state{ fsm_Pid = Fsm_Pid}};
    {error, Reason} ->
      io:fwrite("terminating chat_gen_client Reason : ~p ~n", [Reason]),
      {stop, normal}
  end.

handle_call({ReceiverName, Message}, From, Clients) ->
  gen_fsm:send_event(fsm_Pid, {send, {ReceiverName, Message}}).
  {reply, message_is_sent_to_gen_fsm, Clients};
sendMessage(ReceiverName, Message) ->
  gen_server:call(clientServer, {send, {ReceiverName, Message}}).


 


% handle_call(depart, _From, Clients) ->
%     {X, _} = _From,

%     io:format("users~p~n", [Clients]),
%     NewClients = lists:keydelete(X, 1 , Clients),
%     {reply, user_is_unregistered , NewClients};


% handle_call({message_to, ReceiverName, Message}, _From, Clients) ->
    
%     case lists:keysearch(ReceiverName, 2, Clients) of
%         false ->
%             {reply, receiver_not_found, Clients};
            
%         {value, {Receiver_Pid, ReceiverName}} ->
%             sendMessage(Receiver_Pid, Message), 
%             {reply, message_is_sent, Clients}
            
        
%     end.

% sendMessage(Receiver_Pid, Message) ->
%     Receiver_Pid!Message.
                