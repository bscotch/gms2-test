///@description Standard test showing basic usage
xtest("Basic Standard Test", function(){
	gmltest_expect_true(true);
});

///@description Standard disabled test showing basic usage
///             If this test was run this would cause a failure, but it won't because it is disabled
xtest("Basic Disabled Test", function(){
	gmltest_expect_true(false); 
});

///@description Standard async test showing basic usage with pass result
test_async("Basic Async Test 1", function(_done){
	//We have to pass the _async_test_id to the object's scope to track back through the other. scope
	var callback = method({done: _done}, function(res){show_debug_message(res); done()})
	async_function_example(callback);
})

///@description Standard async test showing basic usage with pass result
test_async("Basic Async Test 2", function(_done){
	//We have to pass the _async_test_id to the object's scope to track back through the other. scope
	var callback = method(
		{done: _done},
		function(res){
			show_debug_message(res);
			try{
				show_error("FAKE ERROR",false);
			}
			catch(err){
				done(err);
			}
		}
	);
	async_function_example(callback);
})

