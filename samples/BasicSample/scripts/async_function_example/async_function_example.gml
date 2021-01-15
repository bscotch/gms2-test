// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function async_function_example(_callback_id, _callback){
	var async_handle = instance_create_depth(0,0, 0, o_async_object);
	with async_handle{
		callback_id = _callback_id;
		callback = _callback;
	}
	return async_handle;
}