// Feather disable all

/// @param programOrString
/// @param [paramArray]
/// @param [scope=self]

function FlowGo(_program, _paramArray = [], _scope = self)
{
    static _executionContext = __FlowSystem().__executionContext;
    
    //If we've been given a string, compile it
    if (is_string(_program))
    {
        _program = FlowCompile(undefined, _program);
    }
    
    if (not __FlowScopeExists(_scope)) return;
    FlowSkip(_scope);
    
    //Pass the parameters into the execution context
    var _oldParamArray = _executionContext.__paramArray;
    _executionContext.__paramArray = __FlowEnsureArray(_paramArray);
    
    //Now execute the program and store the returned Flow struct
    _scope[$ FLOW_CONTAINER] = _program(_scope);
    
    _executionContext.__paramArray = _oldParamArray;
}