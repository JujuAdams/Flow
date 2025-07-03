// Feather disable all

function FlowProgEnd()
{
    static _system = __FlowSystem();
    
    _system.__programCurrent.__BuildEnd();
    _system.__programCurrent = array_pop(_system.__programStack);
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message("FlowProgEnd()");
    }
}