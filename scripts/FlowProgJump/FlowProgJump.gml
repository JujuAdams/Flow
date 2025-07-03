// Feather disable all

/// N.B. This function is available to manually build programs using individual instructions. You
///      probably don't want to build programs manually. Instead, you should use `FlowGo()` or
///      `FlowCompile()`.
/// 
/// Sets a value to a target after the given number of frames. No interpolation is performed.
/// 
/// @param delayFrames
/// @param targetOrArray

function FlowProgJump(_delayFrames, _targetOrArray)
{
    static _system = __FlowSystem();
    
    _targetOrArray = __FlowEnsureArray(_targetOrArray);
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message($"FlowProgJump({_delayFrames}, {_targetOrArray})");
    }
}