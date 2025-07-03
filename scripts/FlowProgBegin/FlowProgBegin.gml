// Feather disable all

function FlowProgBegin()
{
    static _system = __FlowSystem();
    
    _system.__programCurrent = new __FlowClassProgram();
    array_push(_system.__programStack, _system.__programCurrent);
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message("FlowProgBegin()");
    }
}