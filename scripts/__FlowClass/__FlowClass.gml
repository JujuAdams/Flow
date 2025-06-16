// Feather disable all

/// @param scope

function __FlowClass(_scope) constructor
{
    __scope = _scope;
    
    __state  = FLOW_PENDING;
    __frames = 0;
    
    __variableArray     = [];
    __variableTrackDict = {};
    __timeArray         = [0];
    __timeIndex         = 0;
    
    array_push(__FlowSystem().__updateArray, self);
    
    
    
    static __EnsureVariable = function(_variableName)
    {
        var _trackStruct = __variableTrackDict[$ _variableName];
        if (_trackStruct == undefined)
        {
            _trackStruct = {};
            
            _trackStruct[$ "0"] = {
                __value: __scope[$ _variableName] ?? 0,
                __curve: __FlowCurveLinear,
            };
            
            array_push(__variableArray, _variableName);
            __variableTrackDict[$ _variableName] = _trackStruct;
        }
        
        var _buildTime = array_last(__timeArray);
        var _timeStruct = _trackStruct[$ _buildTime];
        if (_timeStruct == undefined)
        {
            _timeStruct = variable_clone(_trackStruct[$ __timeArray[array_length(__timeArray)-2]]);
            _trackStruct[$ _buildTime] = _timeStruct;
        }
        
        return _timeStruct;
    }
    
    static __NewTime = function(_value)
    {
        if (_value < array_last(__timeArray))
        {
            __FlowError("Cannot create keyframe at an earlier time");
        }
        else if (_value == array_last(__timeArray))
        {
            return;
        }
        
        array_push(__timeArray, _value);
        
        var _i = 0;
        repeat(array_length(__variableArray))
        {
            __EnsureVariable(__variableArray[_i]);
            ++_i;
        }
    }
    
    static __Update = function()
    {
        if (not __FlowScopeExists(__scope)) return true;
        
        ++__frames;
        
        var _timeNext = __timeArray[__timeIndex+1];
        if (_timeNext == __frames)
        {
            ++__timeIndex;
            
            if (__timeIndex >= array_length(__timeArray)-1)
            {
                __Skip();
                return true;
            }
            
            _timeNext = __timeArray[__timeIndex+1];
        }
        
        var _timePrev = __timeArray[__timeIndex];
        
        var _t = (__frames - _timePrev) / (_timeNext - _timePrev);
        
        var _i = 0;
        repeat(array_length(__variableArray))
        {
            var _variableName = __variableArray[_i];
            var _trackStruct = __variableTrackDict[$ _variableName];
            
            var _keyframePrev = _trackStruct[$ _timePrev];
            var _keyframeNext = _trackStruct[$ _timeNext];
            
            var _curve = _keyframePrev.__curve
            var _from  = _keyframePrev.__value;
            var _to    = _keyframeNext.__value;
            
            var _q = animcurve_channel_evaluate(animcurve_get_channel(_curve, 0), _t);
            __scope[$ _variableName] = lerp(_from, _to, _q);
            
            ++_i;
        }
        
        return false;
    }
    
    static __Skip = function()
    {
        //TODO - Set final values
        
        __state = FLOW_FINISHED;
        __scope = undefined;
    }
    
    static __Stop = function()
    {
        __state = FLOW_FINISHED;
        __scope = undefined;
    }
}