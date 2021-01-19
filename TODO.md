1. Allow the async test api to pass `context` as an argument to remove the boilerplate code of `done` binding
2. We must used combined context if we want to expose both the fixture context and the test context, as `method` binding can only point to 1 struct

```js
test_async("New buffer_load_async", function(_callback){
	buffer_load_async(1,my_string, 1, 1);
	with instance_create_depth(0,0,0, o_async){
		callback = _callback;
	}
},  function(argument_array){
	var status_code = argument_array[0];
	var search_result = argument_array[1];
	
	show_debug_message(my_string);
	gmltest_expect_eq(_async_load[?"content"], "string");  
}, {my_string: my_string}, {my_string:my_string});
```

