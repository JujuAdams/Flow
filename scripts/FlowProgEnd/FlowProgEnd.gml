// Feather disable all

/// N.B. This function is available to manually build programs using individual instructions. You
///      probably don't want to build programs manually. Instead, you should use `FlowGo()` or
///      `FlowCompile()`.
/// 
/// Finishes building the program and returns a handle that can be used to refer to the program.
/// You must only execute the program by using this handle with `FlowGo()`.

function FlowProgEnd()
{
    static _system = __FlowSystem();
    
    var _program = _system.__programCurrent;
    _program.__buildTargetDict = undefined;
    
    _system.__programCurrent = array_pop(_system.__programStack);
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message("FlowProgEnd()");
    }
    
    return _program;
}