// Feather disable all

/// @param string
/// @param [paramArray]
/// @param [scope=self]

function FlowGo(_string, _paramArray = [], _scope = self)
{
    static _executionContext = __FlowSystem().__executionContext;
    
    if (not __FlowScopeExists(_scope)) return;
    FlowSkip(_scope);
   
    var _oldParamArray = _executionContext.__paramArray;
    _executionContext.__paramArray = __FlowEnsureArray(_paramArray);
    
    var _program = __FlowCompile(_string);
    _scope[$ FLOW_CONTAINER] = _program();
    
    _executionContext.__paramArray = _oldParamArray;
}