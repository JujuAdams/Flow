// Feather disable all

/// N.B. This function is available to manually build programs using individual instructions. You
///      probably don't want to build programs manually. Instead, you should use `FlowGo()` or
///      `FlowCompile()`.
/// 
/// Sets the variables to target for subsequent tweening instructions. This function will consider
/// the variables as a vector by bundling them together when calculating tweens.
/// 
/// @param variableOrArray

function FlowProgTargetVector(_variableOrArray)
{
    static _system = __FlowSystem();
    
    _variableOrArray = __FlowEnsureArray(_variableOrArray);
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message($"FlowProgTargetVector({_variableOrArray})");
    }
    
    _system.__programCurrent.__SetTarget(_variableOrArray, true);
}