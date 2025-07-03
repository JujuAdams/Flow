// Feather disable all

/// @param frames

function FlowProgDelay(_frames)
{
    static _system = __FlowSystem();
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message($"FlowProgDelay({_frames})");
    }
}