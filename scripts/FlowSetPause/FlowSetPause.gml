// Feather disable all

/// @param state

function FlowSetPause(_state)
{
    static _system = __FlowSystem();
    
    _system.__pause = _state;
}