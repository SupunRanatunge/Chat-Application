-module(chat_fsm).
-behaviour(gen_fsm).
-export([start_link/0]).
-export([init/1,
  connected/2,
  connected/3,
  handle_event/3,
  handle_sync_event/4,
  handle_info/3,
  terminate/3,
  code_change/4]).

-define(SERVER, ?MODULE).
-record(state, {clients, client_pid, name}).

start_link() ->
  gen_fsm:start_link({local, ?SERVER}, ?MODULE, [], []).

init(Args) ->
  Clients = proplists:get_value(clients, Args),
  Name = proplists:get_value(name, Args),
  ClientPid = proplists:get_value(client_pid, Args),
  {ok, connected, #state{clients = Clients, name = Name, client_pid = ClientPid}}.

connected(_Event, _From, State) ->
  {reply, ok, idle, State}.

connected({send, {RecieverName, Message}}, State) ->
	%%io:fwrite("Send ~p ~p ~n",[RecieverName, Message]),
  Clients = State#state.clients,
  SenderName = State#state.name,
  Reply =
  case proplists:get_value(RecieverName, Clients) of
    undefined ->
      {error, no_client};
    HandlerPid ->
      gen_fsm:send_event(HandlerPid, {recieve, {SenderName, Message}})
  end,
  {next_state, connected, State};

connected({recieve, {SenderName, Message}}, State) ->
%%io:fwrite("receive ~p ~p ~n",[SenderName, Message]),
  ClientPid = State#state.client_pid,
  Reply = gen_server:call(ClientPid, {recieve, {SenderName, Message}}),
 %%ClientPid !  {recieve, SenderName, Message},
  {next_state, connected, State};

connected(_Event,  State) ->
  Reply = ok,
  {next_state, connected, State}.

handle_event({join, {Name, Pid}}, StateName, State) ->
  Clients = lists:concat([State#state.clients, [{Name, Pid}]]),
  ClientPid = State#state.client_pid,
  case gen_server:call(ClientPid, {join, Name}) of
    ok ->
      NewState = State#state{ clients = Clients},
      %% send the handling client the info
      {next_state, StateName, NewState};
    _Error ->
      ClientName = State#state.name,
      io:fwrite("error connecting client ~p ~n", [ClientName]),
      {stop, normal, State}
  end;

handle_event(_Event, StateName, State) ->
  {next_state, StateName, State}.

handle_sync_event(_Event, _From, StateName, State) ->
  Reply = ok,
  {reply, Reply, StateName, State}.

handle_info(_Info, StateName, State) ->
  {next_state, StateName, State}.

terminate(_Reason, _StateName, _State) ->
  ok.

code_change(_OldVsn, StateName, State, _Extra) ->
  {ok, StateName, State}.