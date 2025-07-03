// Feather disable all

/// @param variableOrArray

function FlowProgTargetVars(_variableOrArray)
{
    static _system = __FlowSystem();
    
    _variableOrArray = __FlowEnsureArray(_variableOrArray);
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message($"FlowProgTargetVars({_variableOrArray})");
    }
}