-module(chat_client).
-behaviour(gen_server).
-export([start_link/1]).
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-export([send_messge/2]).
-define(SERVER, ?MODULE).
-record(state, {handler_pid}).

start_link(Name) ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [{name, Name}], []).

init(Args) ->
  %%Name = proplists:get_value(name, Args),
  {value, {_, Name}} = lists:keysearch(name, 1, Args),
  io:fwrite("Name : ~p ~n", [Name]),
  case gen_server:call({global, chat_server}, {register, Name}) of
    {ok, HandlerPid} ->
      {ok, #state{ handler_pid = HandlerPid}};
    {error, Reason} ->
      io:fwrite("terminating chat_client Reason : ~p ~n", [Reason]),
      {stop, normal}
  end.

handle_call({join, Name}, _From, State) ->
  io:fwrite("~p Joined the Server ~n", [Name]),
  {reply, ok, State};

handle_call({send, {Name, Message}}, _From, State) ->
  HandlerPid = State#state.handler_pid,
  Reply = gen_fsm:send_event(HandlerPid, {send, {Name, Message}}),
  {reply, Reply, State};

handle_call({recieve, {Sender, Message}}, _From, State) ->
  io:fwrite("~p : ~p ~n", [Sender, Message]),
  {reply, ok, State};

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

send_messge(Name, Message) ->
  gen_server:call(?SERVER, {send, {Name, Message}}).