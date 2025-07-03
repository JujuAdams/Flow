// Feather disable all

/// @param function
/// @param argumentArray

function FlowProgExecute(_function, _argumentArray)
{
    static _system = __FlowSystem();
    
    _argumentArray = __FlowEnsureArray(_argumentArray);
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message($"FlowProgExecute({_function}, {_argumentArray})");
    }
}