///@description Standard test showing basic usage
xtest("Basic Standard Test", function(){
	gmltest_expect_true(true);
});

///@description Standard disabled test showing basic usage
///             If this test was run this would cause a failure, but it won't because it is disabled
xtest("Basic Disabled Test", function(){
	gmltest_expect_true(false); 
});

async_test("Basic Async Test", function(_async_test_id){
	async_function_example(_async_test_id, function(res){
		show_debug_message(res);
		async_test_done(other.callback_id);
	});
})

async_test("Basic Async Test 2", function(_async_test_id){
	async_function_example(_async_test_id, function(res){
		show_debug_message(res);
		async_test_done(other.callback_id);
	});
})