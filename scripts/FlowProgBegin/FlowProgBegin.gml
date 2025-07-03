// Feather disable all

/// N.B. This function is available to manually build programs using individual instructions. You
///      probably don't want to build programs manually. Instead, you should use `FlowGo()` or
///      `FlowCompile()`.
/// 
/// Starts building a program. You must call `FlowProgEnd()` once you have finished building the
/// program. Programs may only be executed with `FlowGo()`.
/// 
/// @param [scope=self]

function FlowProgBegin(_scope)
{
    static _system = __FlowSystem();
    
    _system.__programCurrent = new __FlowClass(_scope);
    array_push(_system.__programStack, _system.__programCurrent);
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message("FlowProgBegin()");
    }
}