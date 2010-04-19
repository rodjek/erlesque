% timezone code from http://www.erlang.org/pipermail/erlang-questions/2006-December/024289.html
% modified to return the timezone as as string

-module(timezone).
-export([zone/0]).

zone() ->
    Time = erlang:universaltime(),
    LocalTime = calendar:universal_time_to_local_time(Time),
    DiffSecs = calendar:datetime_to_gregorian_seconds(LocalTime) -
calendar:datetime_to_gregorian_seconds(Time),
    zone((DiffSecs/3600)*100).

%% Ugly reformatting code to get times like +0000 and -1300

zone(Val) when Val < 0 ->
    binary_to_list(erlang:iolist_to_binary(io_lib:format("-~4..0w", [trunc(abs(Val))])));
zone(Val) when Val >= 0 ->
    binary_to_list(erlang:iolist_to_binary(io_lib:format("+~4..0w", [trunc(abs(Val))]))).
