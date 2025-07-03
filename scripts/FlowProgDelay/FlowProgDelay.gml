// Feather disable all

/// N.B. This function is available to manually build programs using individual instructions. You
///      probably don't want to build programs manually. Instead, you should use `FlowGo()` or
///      `FlowCompile()`.
/// 
/// Increments the program's internal clock for the purposes of adding instructions.
/// 
/// N.B. By default, the time units for this function is measured in frames. If you choose to use
///      milliseconds then the millisecond value will be converted to frames using
///      `FLOW_TARGET_FRAME_TIME`.
/// 
/// @param delay
/// @param [useMilliseconds=false]

function FlowProgDelay(_delay, _useMilliseconds = false)
{
    static _system = __FlowSystem();
    
    if (_delay < 0)
    {
        __FlowError("Cannot use a negative delay");
    }
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message($"FlowProgDelay({_delay})");
    }
    
    if (_useMilliseconds)
    {
        _delay = __FlowMsToFrames(_delay);
    }
    
    _delay = ceil(_delay);
    
    if (_delay <= 0)
    {
        return;
    }
    
    with(_system.__programCurrent)
    {
        array_push(__instructionArray, new __FlowClassInstrDelay(_delay));
        __ClearTargets();
    }
}