-module(erlesque_worker).
-export([start/2, magic/2, test_job/1]).
-export([parse_resque_job/1]).

start(Address, Queues) ->
    % Check that Queues is not empty
	case erldis:connect(Address) of
		{ok, Client} ->
			io:format("Connected to redis server ~s~n", [Address]),
			Job = get_job(Client, Queues, Queues),
			io:format("~s~n", [Job]);
		ignore ->
			io:format("Unable to connect to redis server ~s~n", [Address])
	end.

get_job(Client, [], All_queues) ->
	io:format("No jobs found, sleeping for 10 seconds~n", []),
	timer:sleep(10000),
	get_job(Client, All_queues, All_queues);
		
get_job(Client, [First_queue|Other_queues], All_queues) ->
	Queue = string:concat("resque:queue:", First_queue),
	io:format("Attempting lpop of ~s~n", [Queue]),
	case erldis:lpop(Client, Queue) of
		ok ->
			case erldis:get_all_results(Client) of
				[nil] ->
					get_job(Client, Other_queues, All_queues);
				[Item] -> Item
			end;
		_ -> {error}
	end.

% stubs	
working() ->
    {ok}.

workers() ->
    {ok}.

worker_exists(Worker_id) ->
    {ok}.

working_on(Job_id) ->
    {ok}.

queues() ->
    {ok}.

shutdown(Worker_id) ->
    {ok}.

pause(Worker_id) ->
    {ok}.

unpause(Worker_id) ->
    {ok}.

register_worker() ->
    {ok}.

unregister_worker() ->
    {ok}.

done_working() ->
    {ok}.

processed() ->
    {ok}.

started() ->
    {ok}.

state(Worker_id) ->
    {ok}.

log_message() ->
    {ok}.
% /stubs

magic(Job, Args) ->
	Fun_str = string:concat("fun(A) -> ", string:concat(Job, "(A) end.")),
	{ok, Tokens, _} = erl_scan:string(Fun_str),
	{ok, [Form]} = erl_parse:parse_exprs(Tokens),
	{value, Fun, _} = erl_eval:expr(Form, []),
	Fun(Args).
	
% Need to find an Erlang JSON parser
parse_resque_job(String) ->
	Data = string:tokens(String, "\"{}[],"),
	LessData = [X || X <- Data, X /= ":"],
	Job = lists:nth(2, LessData),
	Args = lists:nthtail(3, LessData),
	{Job, Args}.
	
test_job(Args) ->
	io:format("TEST JOB ~s~n", Args).
