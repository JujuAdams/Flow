// Feather disable all

function FlowGetPause()
{
    static _system = __FlowSystem();
    
    return _system.__pause;
}