-module(json).
-compile(export_all).



-spec render(tuple()) -> string().

render(T) ->
	io:format("~s~n",[tuple_to_json_string(T)]).


-spec tuple_to_json_string(tuple()) -> string().

tuple_to_json_string(T) ->
	"{"++tuple_to_json(T)++"}".

-spec tuple_to_json(tuple()) -> string().

tuple_to_json(T) ->

 	E = element(1,T),
	case is_tuple(E) of
		true -> J1 = tuple_to_json(E),
				T2 = list_to_tuple(tl(tuple_to_list(T))),
				case size(T2) of
					0 -> J1;
					_ -> J1 ++ "," ++ tuple_to_json(T2)
				end;
		false -> 
			case is_atom(E) of
				true -> case E of 
							true -> J1 = "true:";
							false -> J1 = "false:";
							null -> J1 = "null:";
							_ -> 	J1 = "\"" ++ atom_to_list(E) ++"\":"
						end;

				_ -> case char_list(E) of
										true -> J1 = "\"" ++ E ++"\":";
										false -> case is_binary(E) of
													true -> J1 = "\"" ++ binary_to_list(E) ++"\":";
													false -> J1 = "[" ++ json_array(E) ++ "]:"
												end
									 end
		 	end,
		 	E2 = element(2,T),
		 	case is_tuple(E2) of
		 		true -> J2 = "{"++ tuple_to_json(E2) ++ "}",
		 				T2 = list_to_tuple(tl(tl(tuple_to_list(T)))),
						case size(T2) of
							0 -> J1 ++ J2;
							_ -> J1 ++ J2 ++ "," ++ tuple_to_json(T2)
						end;
		 		false ->
		 			case is_number(E2) of
		 				true -> case is_integer(E2) of
		 							true -> J2 = integer_to_list(E2) ;
		 							false -> J2 = float_to_list(E2,[{decimals, 10}, compact])
		 						end;
		 				false ->
		 					case is_atom(E2) of
								true -> case E2 of 
											true -> J1 = "true:";
											false -> J1 = "false:";
											null -> J1 = "null:";
											_ -> 	J1 = "\"" ++ atom_to_list(E2) ++"\":"
										end;
								_ -> case char_list(E2) of
										true -> J2 = "\"" ++ E2 ++"\"";
										false -> case is_binary(E2) of
													true -> J2 = "\"" ++ binary_to_list(E2) ++"\"";
													false -> J2 = "[" ++ json_array(E2) ++ "]"
												end
									 end
							end
					end,
					T2 = list_to_tuple(tl(tl(tuple_to_list(T)))),
					case size(T2) of
						0 -> J1++J2;
						_ -> J1 ++ J2 ++ "," ++ tuple_to_json(T2)
					end
		 	end
	end.
	
json_array([E|T]) ->
case is_tuple(E) of
		true -> J1 = tuple_to_json(E),
				case length(T) of
					0 -> J1;
					_ -> J1 ++ "," ++ json_array(T)
				end;
		false -> 
		 			case is_number(E) of
		 				true -> case is_integer(E) of
		 							true -> J1 = integer_to_list(E) ;
		 							false -> J1 = float_to_list(E,[{decimals, 10}, compact])
		 						end;
		 				false ->
		 					case is_atom(E) of
								true -> case E of 
										true -> J1 = "true:";
										false -> J1 = "false:";
										null -> J1 = "null:";
										_ -> 	J1 = "\"" ++ atom_to_list(E) ++"\":"
										end;
								_ -> case char_list(E) of
										true -> J1 = "\"" ++ E ++"\"";
										false -> case is_binary(E) of
													true -> J2 = "\"" ++ binary_to_list(E) ++"\"";
													false -> J1 = "[" ++ json_array(E) ++ "]"
												end
									 end
							end
					end
	end.


	

char_list([C|Cs]) when is_integer(C), C >= 0, C < 16#D800;
       is_integer(C), C > 16#DFFF, C < 16#FFFE;
       is_integer(C), C > 16#FFFF, C =< 16#10FFFF ->
    char_list(Cs);
char_list([]) -> true;
char_list(_) -> false.
