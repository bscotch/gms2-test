///@description Struct used to manage and execute all registered tests
function GMLTest_Manager() constructor {
	_tests = [];
	_failCount = 0;
	_disabledCount = 0;
	_testCount = 0;
	_seed = random_get_seed();
	_startTime=0;
	_on_conclude=undefined; // Callback function for when all tests have concluded.
	global.GMLTest_Manager_Context = self; //Exposes the manager's context to allow calling its functions from anywhere
	
	///@description Get the status string for whether there was a pass or a fail
	///@param {Bool} passed
	_get_status_string = function(passed){
		return passed ? "PASSED" : "FAILED";
	}
	
	/// @description Mixin function that adds the done function to tests
	/// @arg {Struct} test
	_mixin_done = function (test)  {
		test.done = method(
			{_test : test},
			function(err){
				if(!is_undefined(err)){
					_test._passed = false;
					global.GMLTest_Manager_Context._handleException(err);
				}
				_gmltest_log_status(global.GMLTest_Manager_Context._get_status_string(_test._passed), _test.get_name());
				global.GMLTest_Manager_Context._execute_test_at_index(_test._index+1);
			}
		);			
	}
	
	///@description Run a standard test
	///@param {Struct} test
	_run_test = function (test){
		var testName = test.get_name();
		_gmltest_log_status("RUN", testName);
		_testCount++;
		_mixin_done(test);
		try {
			if(test._is_async){
				test._fn(test.done); //_fn is async, so we should pass done as a callback to it
			}
			else{
				test._fn(); //_fn is sync, so we just call done afterwards
				test.done();
			}
		} catch (e){
			test.done(e) // catches error if _fn's excution failed
		}
	}

	///@description Run a fixture test
	///@param {Struct} test
	_run_fixture_test = function (test){
		var passed = true;
		var testName = test.get_name();
		_gmltest_log_status("RUN", testName);
		_testCount++;
		
		var harness = new test._harness();
		harness.setup();
		var fn = method(harness, test._fn);
		try {
			fn();
		} catch (e){
			passed = false;
			_handleException(e);
		}
		harness.tear_down();
		delete harness;
		
		var statusString = _get_status_string(passed);
		_gmltest_log_status(statusString, testName);
	}
	
	///@description Run a parameterized test
	///@param {Struct} test
	_run_parameter_test = function (test){
		for (var i = 0; i < array_length(test._array); i++){
			var passed = true;
			var testName = test.get_name() + "::" + string(i);
			_gmltest_log_status("RUN", testName);
			_testCount++;
			
			var harness = new test._harness();
			harness.setup();
			var fn = method(harness, test._fn);
			try {
				fn(test._array[i]);
			} catch (e){
				passed = false;
				_handleException(e);
			}
			harness.tear_down();
			delete harness;
				
			var statusString = _get_status_string(passed);
			_gmltest_log_status(statusString, testName);
		}
	}
	
	///@description Handles any exceptions thrown during the execution of the test
	///@param {Struct} e
	_handleException = function (e){
		_failCount++;
		show_debug_message(e.message);
		// If we threw an exception and it wasn't because an expect failed, we should log the callstack to the user
		if (!variable_struct_exists(e, "expectFailed")){
			_gmltest_log_callstack(e.stacktrace);
		}
	}
	
	///@description Execute the provided test struct
	///@param {Integer} test_index
	_execute_test_at_index = function (_test_index) {
		if(_test_index==array_length(_tests)){
			// Then we have completed all tests
			return _conclude_tests();
		}
		var test = _tests[_test_index];
		if (test._disabled){
			_disabledCount++;
			_gmltest_log_status("DISABLED", test.get_name());
			return _execute_test_at_index(_test_index+1);
		}
		
		if (test._harness == noone){		
			_run_test(test);
		}
		else if (test._array == noone){
			_run_fixture_test(test);
			_execute_test_at_index(_test_index+1);
		}
		else {
			_run_parameter_test(test);
			_execute_test_at_index(_test_index+1);
		}
	}
	
	///@description Execute all registered tests
	execute = function () {
		_startTime = current_time;
		_execute_test_at_index(0);
	}
	
	///@description Once all tests have passed, failed, or timed out, call this function.
	///@description This allows for async tests to also be run.
	_conclude_tests = function() {
		var endTime = current_time;
		var timeToRun = endTime - _startTime;
		
		show_debug_message("-------------------------");
		show_debug_message("RAN " + string(_testCount) + " TESTS IN " + string(timeToRun) + "MS.");
		if (_disabledCount > 0){
			show_debug_message("DISABLED TESTS: " + string(_disabledCount));
		}
		if (_failCount > 0){
			show_debug_message("FAILED TESTS: " + string(_failCount));
		}
		if(is_method(_on_conclude)){
			_on_conclude();
		}
	}
	
	///@description Adds a test to this manager
	///@param {Struct} test
	add_test = function(test){
		array_push(_tests, test);
		test._index = array_length(_tests)-1;
	}
}