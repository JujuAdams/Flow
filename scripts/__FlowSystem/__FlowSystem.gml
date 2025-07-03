// Feather disable all

#macro __FLOW_DEBUG_TOKENIZER        false
#macro __FLOW_DEBUG_PROGRAM_BUILDER  false

function __FlowSystem()
{
    static _system = undefined;
    if (_system != undefined) return _system;
    
    _system = {};
    with(_system)
    {
        __precacheMap  = ds_map_create();
        __animCurveMap = ds_map_create();
        __functionMap  = ds_map_create();
        
        __programStack   = [];
        __programCurrent = undefined;
        
        __executionContext = {
            __paramArray: [],
        };
        
        __updateArray = [];
        
        time_source_start(time_source_create(time_source_global, 1, time_source_units_frames, function()
        {
            static _updateArray = __updateArray;
            
            var _i = 0;
            repeat(array_length(_updateArray))
            {
                if (_updateArray[_i].__Update())
                {
                    array_delete(_updateArray, _i, 1); 
                }
                else
                {
                    ++_i;
                }
            }
        },
        [], -1));
        
        if (GM_build_type == "run")
        {
            global.__Flow = self;
        }
    }
    
    return _system;
}