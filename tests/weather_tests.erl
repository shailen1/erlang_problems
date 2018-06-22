-module(weather_tests).
-compile([export_all]).
-include_lib("eunit/include/eunit.hrl").

% The api module must simulate time spent in an API call.
% Don't remove the sleep!
api_test() ->
  {Time, _} = timer:tc(weather_api, get_weather, [foo]),
  ?assert(Time >= 500000).

forecast_test() ->
  {Time, Value} = timer:tc(weather, forecast, [["Chicago", "Sydney", "London", "San Antonio", "Antarctica"]]),
  % We got the right data
  ?assertEqual(["Windy", "Clear", "Rainy", "Hot", "Cold"], Value),
  % And it took less than 2 seconds
  ?assert(Time < 1 * 1000 * 1000).

forecast_consult_test() ->
  {ok, Terms} = file:consult("../src/weather.data"),
  {ok, IoD} = file:open("./output.data", [write]),
  
  [begin
      % write output file with data and results in JSON, profile it
      {Time, Value} = timer:tc(weather_api, render, Term),
      file:write(IoD, {Time, Value, Term)
   end || Term <- Terms]
  file:close(IoD).
