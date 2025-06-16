// Feather disable all

/// @param [scope=self]

function FlowSkip(_scope = self)
{
    if (not __FlowScopeExists(_scope)) return;
    if (not struct_exists(_scope, FLOW_CONTAINER)) return;
    _scope[$ FLOW_CONTAINER].__Skip();
}