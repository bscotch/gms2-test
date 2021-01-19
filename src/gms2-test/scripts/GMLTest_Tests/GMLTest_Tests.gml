///@description Base struct that all harnesses should extend from
/// setup and tear_down only supports synchronous functions
function GMLTest_Harness() constructor {
	///@description the additional context that the test will use
	context = {}
	
	///@description Called before the execution of the test.
	///             Use this function to setup your fixtures and parameterized tests.
	setup = function(){
		// Override this function
	}
	
	///@description Called after the execution of the test.
	///             Use this function to clean up your fixtures and parameterized tests.
	tear_down = function(){
		// Override this function
	}
}

///@description Test struct used to hold the registered test data for later execution
function _GMLTest_Test() constructor {
	_name = "";
	_fn = undefined;
	_fn_context = noone;
	_harness = noone;
	_harness_instance = noone;
	_harness_context = noone;
	_disabled = false;
	_param = noone;
	_is_async = false;
	_passed = true;
	_index = -1;
	_err = noone;
	_resolution_fn = noone;
	_resolution_fn_context = noone;
	
	/// @description This function signals the conclusion of a test, logs the result, clean up the harness, and starts the next test
	/// @param {Error} [err] Error that caused the test to fail
	done = 	function(err){
		if(!is_undefined(err)){
			// Log the result as failure and handles the error
			_passed = false;
			_err= err;
			global.GMLTestManager._handleException(err);
		}
		_gmltest_log_status(global.GMLTestManager._get_status_string(_passed), get_name());

		if(_harness_instance != noone){
			// If any harness is instantiated, call tear_down and delete the instance.
			tear_down();
			delete _harness_instance;
		}
				
		// Execute the next test
		global.GMLTestManager._execute_test_at_index(_index+1);				
	}
	
	/// @description Returns the name of the test, plus the name of the harness if it has one
	function get_name(){
		var result = "";
		if (_harness != noone){
			var temp = new _harness();
			result = instanceof(temp) + "::";
			delete temp;
		}
		result += (_name+"::"+string(_index));
		return result;
	}
}

///@description Register a basic test with a name and a function to execute
///@param {String} name The name of the test to be logged to the console
///@param {Function} fn The function to be executed
///@param {Struct} [fn_context] The context to that the function needs
function test(name, fn){	
	_gmltest_create_manager();
	var temp = new _GMLTest_Test();
	temp._name = name;
	temp._fn = fn;
	temp._fn_context =  argument_count > 2 ? argument[2] : noone;
	global.GMLTestManager.add_test(temp);
	return temp;
}

///@description Disable a registered basic test that has a name and a function to execute
///@param {String} name The name of the test to be logged to the console
///@param {Function} fn The function to be executed
///@param {Struct} [fn_context] The context to that the function needs
function xtest(name, fn){	
	var _fn_context =  argument_count > 2 ? argument[2] : noone;
	var temp = test(name, fn, _fn_context);
	temp._disabled = true;
	return temp;
}

///@description Register a fixture test with a harness, name and a function to execute
///@param {Struct} harness The struct to use as the harness when the test executes
///@param {String} name The name of the test to be logged to the console
///@param {Function} fn The function to be executed
///@param {Struct} [fn_context] The context to that the function needs
function test_f(harness, name, fn){
	var _fn_context =  argument_count > 3 ? argument[3] : noone;
	var temp = test(name, fn, _fn_context);
	temp._harness = harness;
	return temp;
}

///@description Disable a registered fixture test that has a harness, name and a function to execute
///@param {Struct} harness The struct to use as the harness when the test executes
///@param {String} name The name of the test to be logged to the console
///@param {Function} fn The function to be executed
///@param {Struct} [fn_context] The context to that the function needs
function xtest_f(harness, name, fn){
	var _fn_context =  argument_count > 3 ? argument[3] : noone;
	var temp = test_f(harness, name, fn, _fn_context);
	temp._disabled = true;
	return temp;
}

///@description Register a parameterized test with a harness, name, parameter, and a function to execute
///@param {Struct} harness The struct to use as the harness when the test executes
///@param {String} name The name of the test to be logged to the console
///@param {*} param parameter to pass along to the inner function
///@param {Function} fn The function to be executed which takes one parameter
///@param {Struct} [fn_context] The context to that the function needs
function test_p(harness, name, param, fn) {
	var _fn_context =  argument_count > 4 ? argument[4] : noone;
	var temp = test_f(harness, name, fn, _fn_context);
	temp._param = param;
	return temp;
}

///@description Disable a registered parameterized test that has a harness, name, parameter, and a function to execute
///@param {Struct} harness The struct to use as the harness when the test executes
///@param {String} name The name of the test to be logged to the console
///@param {*} param parameter to pass along to the inner function
///@param {Function} fn The function to be executed which takes one parameter
///@param {Struct} [fn_context] The context to that the function needs
function xtest_p(harness, name, param, fn) {
	var _fn_context =  argument_count > 4 ? argument[4] : noone;
	var temp = test_p(harness, name, param, fn, _fn_context);
	temp._disabled = true;
	return temp;
}

///@description Register a basic async test with a name, a function, and a resolution function to execute
///@param {String} name The name of the test to be logged to the console
///@param {Function} fn The async function to be executed
///@param {Function} resolution_fn The function to be executed when the async function resolves
///@param {Struct} [fn_context] The context to that the function needs
///@param {Struct} [resolution_fn_context] The context to that the resolution function needs
function test_async(name, fn, resolution_fn){	
	_gmltest_create_manager();
	var temp = new _GMLTest_Test();
	temp._name = name;
	temp._fn = fn;
	temp._resolution_fn = resolution_fn;
	temp._is_async = true;
	temp._fn_context =  argument_count > 3 ? argument[3] : noone;
	temp._resolution_fn_context =  argument_count > 4 ? argument[4] : noone;
	global.GMLTestManager.add_test(temp);
	return temp;
}

///@description Disable a registered basic async test
///@param {String} name The name of the test to be logged to the console
///@param {Function} fn The async function to be executed
///@param {Function} resolution_fn The function to be executed when the async function resolves
///@param {Struct} [fn_context] The context to that the function needs
///@param {Struct} [resolution_fn_context] The context to that the resolution function needs
function xtest_async(name, fn, resolution_fn){	
	var _fn_context =  argument_count > 3 ? argument[3] : noone;
	var _resolution_fn_context =  argument_count > 4 ? argument[4] : noone;
	var temp = test_async(name, fn, resolution_fn, _fn_context, _resolution_fn_context);
	temp._disabled = true;
	return temp;
}

///@description Register a fixture async test with a harness, name and a function to execute
///@param {Struct} harness The struct to use as the harness when the test executes
///@param {String} name The name of the test to be logged to the console
///@param {Function} fn The async function to be executed
///@param {Function} resolution_fn The function to be executed when the async function resolves
///@param {Struct} [fn_context] The context to that the function needs
///@param {Struct} [resolution_fn_context] The context to that the resolution function needs
function test_f_async(harness, name, fn, resolution_fn){
	var _fn_context =  argument_count > 4 ? argument[4] : noone;
	var _resolution_fn_context =  argument_count > 5 ? argument[5] : noone;
	var temp = test_async(name, fn, resolution_fn, _fn_context, _resolution_fn_context);
	temp._harness = harness;
	return temp;
}

///@description Disable a registered fixture async test with a harness, name and a function to execute
///@param {Struct} harness The struct to use as the harness when the test executes
///@param {String} name The name of the test to be logged to the console
///@param {Function} fn The async function to be executed
///@param {Function} resolution_fn The function to be executed when the async function resolves
///@param {Struct} [fn_context] The context to that the function needs
///@param {Struct} [resolution_fn_context] The context to that the resolution function needs
function xtest_f_async(harness, name, fn, resolution_fn){
	var _fn_context =  argument_count > 4 ? argument[4] : noone;
	var _resolution_fn_context =  argument_count > 5 ? argument[5] : noone;
	var temp = test_f_async(harness, name, fn, resolution_fn, _fn_context, _resolution_fn_context);
	temp._disabled = true;
	return temp;
}

///@description Register a parameterized test with a harness, name, parameter, and a function to execute
///@param {Struct} harness The struct to use as the harness when the test executes
///@param {String} name The name of the test to be logged to the console
///@param {*} param parameter to pass along to the inner function
///@param {Function} fn The async function to be executed
///@param {Function} resolution_fn The function to be executed when the async function resolves
///@param {Struct} [fn_context] The context to that the function needs
///@param {Struct} [resolution_fn_context] The context to that the resolution function needs
function test_p_async(harness, name, param, fn, resolution_fn) {
	var _fn_context =  argument_count > 5 ? argument[5] : noone;
	var _resolution_fn_context =  argument_count > 6 ? argument[6] : noone;
	var temp = test_f_async(harness, name, fn, resolution_fn,  _fn_context, _resolution_fn_context);
	temp._param = param;
	return temp;
}

///@description Disable a register a parameterized test with a harness, name, parameter, and a function to execute
///@param {Struct} harness The struct to use as the harness when the test executes
///@param {String} name The name of the test to be logged to the console
///@param {*} param parameter to pass along to the inner function
///@param {Function} fn The async function to be executed
///@param {Function} resolution_fn The function to be executed when the async function resolves
///@param {Struct} [fn_context] The context to that the function needs
///@param {Struct} [resolution_fn_context] The context to that the resolution function needs
function xtest_p_async(harness, name, param, fn, resolution_fn) {
	var _fn_context =  argument_count > 5 ? argument[5] : noone;
	var _resolution_fn_context =  argument_count > 6 ? argument[6] : noone;
	var temp = test_p_async(harness, name, param, fn, resolution_fn,  _fn_context, _resolution_fn_context);
	temp._disabled = true;
	return temp;
}