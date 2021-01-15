///@description A mock up async function that allows callback and a way to track the async test id
///@param {Func} _callback
function async_function_example(_callback){
	var async_handle = instance_create_depth(0,0, 0, o_async_object);
	with async_handle{
		callback = _callback;
	}
	return async_handle;
}