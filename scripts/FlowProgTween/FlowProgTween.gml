// Feather disable all

/// N.B. This function is available to manually build programs using individual instructions. You
///      probably don't want to build programs manually. Instead, you should use `FlowGo()` or
///      `FlowCompile()`.
/// 
/// Starts a tween from the variable's previous value to the target value. The tween will use the
/// given curve; if the `curve` parameter is set to `undefined` then the tween will linearly
/// interpolate to the target value.
/// 
/// N.B. By default, the time units for this function is measured in frames. If you choose to use
///      milliseconds then the millisecond value will be converted to frames using
///      `FLOW_TARGET_FRAME_TIME`.
/// 
/// @param [curve]
/// @param duration
/// @param targetOrArray
/// @param [useMilliseconds=false]

function FlowProgTween(_curve = undefined, _duration, _targetOrArray, _useMilliseconds = false)
{
    static _system = __FlowSystem();
    
    _duration = __FlowMsToFrames(_duration);
    
    _targetOrArray = __FlowEnsureArray(_targetOrArray);
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message($"FlowProgTween({_curve}, {_duration}, {_targetOrArray})");
    }
}