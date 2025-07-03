// Feather disable all

/// N.B. This function is available to manually build programs using individual instructions. You
///      probably don't want to build programs manually. Instead, you should use `FlowGo()` or
///      `FlowCompile()`.
/// 
/// Sets the variables to target for subsequent tweening instructions. You may soecify one variable
/// or multiple variables in an array.
/// 
/// @param variableOrArray

function FlowProgTargetVars(_variableOrArray)
{
    static _system = __FlowSystem();
    
    _variableOrArray = __FlowEnsureArray(_variableOrArray);
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message($"FlowProgTargetVars({_variableOrArray})");
    }
    
    _system.__programCurrent.__SetTarget(_variableOrArray, false);
}