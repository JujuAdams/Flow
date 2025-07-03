// Feather disable all

/// N.B. This function is available to manually build programs using individual instructions. You
///      probably don't want to build programs manually. Instead, you should use `FlowGo()` or
///      `FlowCompile()`.
/// 
/// Increments the program's internal clock for the purposes of adding instructions. Any
/// instructions that follow `FlowProgSetTime()` will use the clock time as its basis.
/// 
/// N.B. By default, the time units for this function is measured in frames. If you choose to use
///      milliseconds then the millisecond value will be converted to frames using
///      `FLOW_TARGET_FRAME_TIME`.
/// 
/// @param time
/// @param [useMilliseconds=false]

function FlowProgDelay(_time, _useMilliseconds = false)
{
    static _system = __FlowSystem();
    
    if (_useMilliseconds)
    {
        _time = __FlowMsToFrames(_time);
    }
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message($"FlowProgDelay({_time})");
    }
}