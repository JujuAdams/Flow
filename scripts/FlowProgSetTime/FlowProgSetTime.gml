// Feather disable all

/// @param frame

function FlowProgSetTime(_frame)
{
    static _system = __FlowSystem();
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message($"FlowProgSetTime({_frame})");
    }
}