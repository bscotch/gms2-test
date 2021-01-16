///@description A custom fixture that tests MyObject
function MyFixture() : GMLTest_Harness() constructor {
	
	instance = noone;
	
	function setup(){
		// Before we execute the test let's create the instance we will be testing
		// This way we don't have to duplicate code everywhere to do our tests
		instance = instance_create_depth(0,0,0, MyObject);
		show_debug_message("Harness setup");
	}
	
	function tear_down(){
		// After we are done testing let's clean up and destroy the instance to keep things clean
		instance_destroy(instance);	
		show_debug_message("Harness tear down");
	}
	
}

///@description Fixture test showing basic usage
test_f(MyFixture, "NotVisibleByDefault", function(){
	/// The function has access to the variables declared in MyFixture
	gmltest_expect_eq("hello", instance.name);
});

test_f(MyFixture, "Harness Async Test 1", function(_done){
	/// The function has access to the variables declared in MyFixture
	var callback = method({done: _done}, function(res){show_debug_message(res); done()})
	async_function_example(callback);
}, true);

///@description Standard async test showing basic usage with pass result
test_f(MyFixture, "Harness Async Test 2", function(_done){
	var callback = method(
		{done: _done},
		function(res){
			show_debug_message(res);
			try{
				show_error("Harness FAKE ERROR",false);
			}
			catch(err){
				done(err);
			}
		}
	);
	async_function_example(callback);
}, true)

///@description Disabled fixture test showing basic usage
xtest_f(MyFixture, "NameIsHelloByDefault", function(){
	gmltest_expect_eq("hello", instance.name);
});