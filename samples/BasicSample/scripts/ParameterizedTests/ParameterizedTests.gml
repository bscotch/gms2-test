var param_array = [1, 2, -1, 0];
for (var i = 0; i < array_length(param_array); i++){
	var _param = param_array[i];
	///@description Parameterized test showing basic usage
	///             We don't need any custom setup so we will use the basic harness
	test_p(GMLTest_Harness, "IsNumericTest", _param, function(p){
		// The value of p is equal to 1, 2, -1, or 0
		// This function will be called each time for each value to test the values
		gmltest_expect_true(is_numeric(p));
	});

	test_p(GMLTest_Harness, "Async Parameterized 1", _param, function(p, _done){
		var callback = method({done: _done}, function(res){show_debug_message(res); done()})
		async_function_example(callback, p);
	}, true);

	test_p(GMLTest_Harness,  "Async Parameterized 2", _param, function(p, _done){
		var callback = method(
			{done: _done},
			function(res){
				show_debug_message(res);
				try{
					show_error("Parameterized FAKE ERROR",false);
				}
				catch(err){
					done(err);
				}
			}
		);
		async_function_example(callback, p);
	}, true);

	///@description Disabled parameterized test showing basic usage
	///             If this test was run this would cause a failure, but it won't because it is disabled
	xtest_p(GMLTest_Harness, "IsUndefinedTest",_param, function(p){
		gmltest_expect_eq(undefined, p);
	});
}