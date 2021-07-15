-module(evserver).
-compile(export_all).
-record(state,{events,items}).

                  

start() ->
    register(?MODULE, Pid=spawn(?MODULE, init, [])),
    Pid.
 
start_link() ->
    register(?MODULE, Pid=spawn_link(?MODULE, init, [])), 
    Pid.
 
terminate() ->
    ?MODULE ! shutdown.

init() ->
    loop(#state{events = orddict:new(), items= orddict:new()}).

loop(S = #state{}) ->
    receive
        {Pid, MsgRef, {store, Items}} ->
            Ref = erlang:monitor(process,Items),
            Newitems = orddict:store(Ref, Items, S#state.items),
            Pid ! {MsgRef, ok},
            loop(S#state{items = Newitems})
    end.

% loop(S=#state{}) ->
%     receive
%         {Pid, MsgRef, {subscribe, Client}} ->
%             Ref = erlang:monitor(process, Client),
%             NewClients = orddict:store(Ref, Client, S#state.clients),
%             Pid ! {MsgRef, ok},
%             loop(S#state{clients=NewClients})
%     end.


item(Pid) ->
    Ref = erlang:monitor(process, whereis(?MODULE)),
    ?MODULE ! {self(), Ref, {ste, Pid}},
    receive
        {Ref, ok} ->
            {ok, Ref};
        {'DOWN', Ref, process, _Pid, Reason} ->
            {error, Reason}
    after 5000 ->
        {error, timeout}
    end.