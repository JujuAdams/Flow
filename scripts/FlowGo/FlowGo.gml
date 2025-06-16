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
    _executionContext.__paramArray = _paramArray;
    
    __FlowBuildStart(_scope);
    __FlowCompile(_string)();
    var _built = __FlowBuildEnd();
    
    _executionContext.__paramArray = _oldParamArray;
    
    _scope[$ FLOW_CONTAINER] = _built;
}