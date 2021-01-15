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
async_test("Basic Async Test", function(_async_test_id){
	//We have to pass the _async_test_id to the object's scope to track back through the other. scope
	async_function_example(_async_test_id, function(res){
		show_debug_message(res);
		async_test_done(other._async_test_id, true);
	});
})

///@description Standard async test showing basic usage with failed result
async_test("Basic Async Test 2", function(_async_test_id){
	async_function_example(_async_test_id, function(res){
		show_debug_message(res);
		async_test_done(other._async_test_id, false);
	});
})