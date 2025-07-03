// Feather disable all

/// @param speedOrArray
/// @param targetOrArray

function FlowProgApproach(_speedOrArray, _targetOrArray)
{
    static _system = __FlowSystem();
    
    _speedOrArray  = __FlowEnsureArray(_speedOrArray);
    _targetOrArray = __FlowEnsureArray(_targetOrArray);
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message($"FlowProgApproach({_speedOrArray}, {_targetOrArray})");
    }
}