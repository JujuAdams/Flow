// Feather disable all

/// @param [scope=self]

function FlowGetFrames(_scope = self)
{
    if (not __FlowScopeExists(_scope)) return infinity;
    if (not struct_exists(_scope, FLOW_CONTAINER)) return infinity;
    return _scope[$ FLOW_CONTAINER].__frames;
}