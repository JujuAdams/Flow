// Feather disable all

/// @param variableOrArray

function FlowProgTargetVector(_variableOrArray)
{
    static _system = __FlowSystem();
    
    _variableOrArray = __FlowEnsureArray(_variableOrArray);
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message($"FlowProgTargetVector({_array})");
    }
}