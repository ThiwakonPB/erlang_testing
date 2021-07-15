-module(test).
-export([init/3,start/2,cancel/1]).
-record(food,{server,name,brand}).


start(Name, Brand) ->
    spawn(?MODULE, init,[self(),Name,Brand]).

init(Server,Name, Brand) ->
    loop(#food{server = Server, name = Name,brand = Brand}).

loop(S = #food{server = Server}) ->
     Ref = erlang:monitor(process, Server),
    receive
        {Server, Ref, store} ->
            Server ! {Ref,ok}
    after 5000 ->
        ok
    end.
             
cancel(Pid) ->
%% Monitor in case the process is already dead
    Ref = erlang:monitor(process, Pid),
    Pid ! {self(), Ref, cancel},
    receive
        {Ref, ok} ->
            erlang:demonitor(Ref, [flush]),
            ok;
        {'DOWN', Ref, process, Pid, _Reason} ->
            ok
    end.

