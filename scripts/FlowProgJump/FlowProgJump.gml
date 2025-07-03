// Feather disable all

/// N.B. This function is available to manually build programs using individual instructions. You
///      probably don't want to build programs manually. Instead, you should use `FlowGo()` or
///      `FlowCompile()`.
/// 
/// Sets a value to a target after the given number of frames. No interpolation is performed.
/// 
/// @param delay
/// @param targetOrArray
/// @param [useMilliseconds=false]

function FlowProgJump(_delay, _targetOrArray, _useMilliseconds = false)
{
    static _system = __FlowSystem();
    
    if (_useMilliseconds)
    {
        _delay = __FlowMsToFrames(_delay);
    }
    
    _delay = ceil(_delay);
    
    _targetOrArray = __FlowEnsureArray(_targetOrArray);
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message($"FlowProgJump({_delay}, {_targetOrArray})");
    }
    
    _system.__programCurrent.__AddJump(_delay, _targetOrArray);
}