-module(chat_server).
-behaviour(gen_server).
-export([start_link/0]).
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).
-record(state, {clients}).

start_link() ->
  gen_server:start_link({global, ?SERVER}, ?MODULE, [], []).

init([]) ->
  {ok, #state{ clients = []}}.

handle_call({register, Name}, From, State) ->
  {ClientPid, _Tag} =  From,
  Clients = State#state.clients,
  case gen_fsm:start_link(chat_fsm, [{clients, Clients}, {name, Name}, {client_pid, ClientPid}], []) of
    {ok, Pid} ->
      NewState = State#state{ clients = lists:concat([Clients, [{Name, Pid}]])},
      lists:foreach(fun({_UserName, UserPid}) -> gen_fsm:send_all_state_event(UserPid, {join, {Name, Pid}}) end, Clients),
      {reply, {ok, Pid}, NewState};
    {error, Reason} ->
      io:fwrite("gen_fsm start_link fail Reason : ~p ~n", [Reason]),
      {stop, normal, State}
  end;

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast(_Request, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.