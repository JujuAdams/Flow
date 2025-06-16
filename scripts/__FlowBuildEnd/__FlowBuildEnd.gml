// Feather disable all

function __FlowBuildEnd()
{
    static _system = __FlowSystem();
    
    var _leavingContext = _system.__buildContext;
    if (array_length(_leavingContext.__timeArray) <= 1)
    {
        __FlowError("No keyframes created");
    }
    
    var _context = array_pop(_system.__buildContextArray);
    _system.__buildContext =_context;
    
    return _leavingContext;
}