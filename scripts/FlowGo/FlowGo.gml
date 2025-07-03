// Feather disable all

/// @param programOrString
/// @param [paramArray]
/// @param [scope=self]

function FlowGo(_program, _paramArray = [], _scope = self)
{
    static _system = __FlowSystem();
    static _executionContext = _system.__executionContext;
    
    //If we've been given a string, compile it
    if (is_string(_program))
    {
        _program = FlowCompile(undefined, _program);
    }
    
    if (not __FlowScopeExists(_scope)) return;
    FlowSkip(_scope);
    
    //Pass the parameters into the execution context
    var _oldUsingGo = _system.__usingGo;
    var _oldParamArray = _executionContext.__paramArray;
    
    _system.__usingGo = true;
    _executionContext.__paramArray = __FlowEnsureArray(_paramArray);
    
    //Now execute the program and store the returned Flow struct
    _scope[$ FLOW_CONTAINER] = _program(_scope);
    
    _system.__usingGo = _oldUsingGo;
    _executionContext.__paramArray = _oldParamArray;
}