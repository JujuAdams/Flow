// Feather disable all

/// N.B. This function is available to manually build programs using individual instructions. You
///      probably don't want to build programs manually. Instead, you should use `FlowGo()` or
///      `FlowCompile()`.
/// 
/// Executes a function using the given arguments. The time of execution is determined by the clock
/// time, as set by `FlowProgSetTime()` or `FlowProgAwaitAll()` etc.
/// 
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