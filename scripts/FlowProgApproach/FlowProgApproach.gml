// Feather disable all

/// N.B. This function is available to manually build programs using individual instructions. You
///      probably don't want to build programs manually. Instead, you should use `FlowGo()` or
///      `FlowCompile()`.
/// 
/// Linearly interpolates a value towards a target at the given speed per frame. The speed value
/// ignores the sign (negative or positive).
/// 
/// @param speedOrArray
/// @param targetOrArray

function FlowProgApproach(_speedOrArray, _targetOrArray)
{
    static _system = __FlowSystem();
    
    _speedOrArray  = __FlowEnsureArray(_speedOrArray);
    _targetOrArray = __FlowEnsureArray(_targetOrArray);
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message($"FlowProgApproach({_speedOrArray}, {_targetOrArray})");
    }
}