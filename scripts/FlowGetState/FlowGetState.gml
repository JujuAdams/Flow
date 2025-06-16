// Feather disable all

/// @param [scope=self]

function FlowGetState(_scope = self)
{
    if (not __FlowScopeExists(_scope)) return FLOW_DOESNT_EXIST;
    if (not struct_exists(_scope, FLOW_CONTAINER)) return FLOW_DOESNT_EXIST;
    return _scope[$ FLOW_CONTAINER].__state;
}