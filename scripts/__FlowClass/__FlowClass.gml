// Feather disable all

/// @param scope

function __FlowClass(_scope) constructor
{
    static _system      = __FlowSystem();
    static _updateArray = _system.__updateArray;
    
    array_push(_updateArray, self);
    
    __scope = _scope;
    __age   = -1;
    __pause = false;
    __state = FLOW_PENDING;
    
    __instruction      = 0;
    __instructionArray = [];
    __pendingArray     = [];
    
    __buildTargetDict    = {};
    __buildTargetMapping = [];
    
    
    
    static __Update = function()
    {
        if (not __FlowScopeExists(__scope)) return true;
        if (__pause) return false;
        
        __age++;
        
        //
        var _pending = false;
        var _i = 0;
        repeat(array_length(__pendingArray))
        {
            if (__pendingArray[_i].__Update(self, __age) == __FLOW_RETURN_PENDING)
            {
                _pending = true;
                ++_i;
            }
            else
            {
                array_delete(__pendingArray, _i, 1);
            }
        }
        
        if (_pending)
        {
            return false;
        }
        
        //
        var _length = array_length(__instructionArray);
        while(__instruction < _length)
        {
            var _instruction = __instructionArray[__instruction];
            _instruction.__Start(__age);
            
            var _result = _instruction.__Update(self, __age);
            if (_result == __FLOW_RETURN_WAIT)
            {
                break;
            }
            else if (_result == __FLOW_RETURN_PENDING)
            {
                array_push(__pendingArray, _instruction);
            }
            
            ++__instruction;
        }
        
        return (array_length(__pendingArray) <= 0);
    }
    
    static __Skip = function()
    {
        //TODO - Set final values
        
        __state = FLOW_FINISHED;
        __scope = undefined;
    }
    
    static __Halt = function()
    {
        __state = FLOW_FINISHED;
        __scope = undefined;
    }
    static __AddExecute = function(_function, _argumentArray)
    {
        array_push(__instructionArray, new __FlowClassInstrFunction(_function, _argumentArray));
    }
    
    static __ClearTargets = function()
    {
        __buildTargetDict    = {};
        __buildTargetMapping = [];
    }
    
    static __SetTarget = function(_variableArray, _isVector)
    {
        __buildTargetMapping = [];
        
        if (not _isVector)
        {
            var _i = 0;
            repeat(array_length(_variableArray))
            {
                var _variableName = _variableArray[_i];
                if (not variable_struct_exists(__buildTargetDict, _variableName))
                {
                    var _track = new __FlowClassInstrTarget(oMain.id, _variableName);
                    
                    array_push(__instructionArray, _track);
                    __buildTargetDict[$ _variableName] = _track;
                }
                
                array_push(__buildTargetMapping, _track);
                
                ++_i;
            }
        }
        else
        {
            var _variableName = string_join("&", _variableArray);
            if (not variable_struct_exists(__buildTargetDict, _variableName))
            {
                var _track = new __FlowClassInstrVector(oMain.id, _variableName);
                
                array_push(__instructionArray, _track);
                __buildTargetDict[$ _variableName] = _track;
            }
            
            array_push(__buildTargetMapping, _track);
        }
    }
    
    static __AddTween = function(_curve, _duration, _targetArray)
    {
        if (array_length(_targetArray) == 1)
        {
            var _i = 0;
            repeat(array_length(__buildTargetMapping))
            {
                __buildTargetMapping[_i].__AddTween(_curve, _duration, _targetArray[0]);
                ++_i;
            }
        }
        else
        {
            if (array_length(__buildTargetMapping) != array_length(_targetArray))
            {
                __FlowError(""); //TODO
            }
            
            var _i = 0;
            repeat(array_length(__buildTargetMapping))
            {
                __buildTargetMapping[_i].__AddTween(_curve, _duration, _targetArray[_i]);
                ++_i;
            }
        }
    }
    
    static __AddApproach = function(_speedArray, _targetArray)
    {
        if (array_length(_targetArray) == 1)
        {
            if (array_length(_speedArray) == 1)
            {
                var _i = 0;
                repeat(array_length(__buildTargetMapping))
                {
                    __buildTargetMapping[_i].__AddApproach(_speedArray[0], _targetArray[0]);
                    ++_i;
                }
            }
            else
            {
                if (array_length(__buildTargetMapping) != array_length(_speedArray))
                {
                    __FlowError(""); //TODO
                }
                
                var _i = 0;
                repeat(array_length(__buildTargetMapping))
                {
                    __buildTargetMapping[_i].__AddApproach(_speedArray[_i], _targetArray[0]);
                    ++_i;
                }
            }
        }
        else
        {
            if (array_length(__buildTargetMapping) != array_length(_targetArray))
            {
                __FlowError(""); //TODO
            }
            
            if (array_length(_speedArray) == 1)
            {
                var _i = 0;
                repeat(array_length(__buildTargetMapping))
                {
                    __buildTargetMapping[_i].___AddApproach(_speedArray[0], _targetArray[_i]);
                    ++_i;
                }
            }
            else
            {
                if (array_length(__buildTargetMapping) != array_length(_speedArray))
                {
                    __FlowError(""); //TODO
                }
                
                var _i = 0;
                repeat(array_length(__buildTargetMapping))
                {
                    __buildTargetMapping[_i].___AddApproach(_speedArray[_i], _targetArray[_i]);
                    ++_i;
                }
            }
        }
    }
    
    static __AddJump = function(_delay, _targetArray)
    {
        if (array_length(_targetArray) == 1)
        {
            var _i = 0;
            repeat(array_length(__buildTargetMapping))
            {
                __buildTargetMapping[_i].__AddJump(_delay, _targetArray[0]);
                ++_i;
            }
        }
        else
        {
            if (array_length(__buildTargetMapping) != array_length(_targetArray))
            {
                __FlowError(""); //TODO
            }
            
            var _i = 0;
            repeat(array_length(__buildTargetMapping))
            {
                __buildTargetMapping[_i].__AddJump(_delay, _targetArray[_i]);
                ++_i;
            }
        }
    }
}