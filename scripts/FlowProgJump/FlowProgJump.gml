// Feather disable all

/// @param delayFrames
/// @param targetOrArray

function FlowProgJump(_delayFrames, _targetOrArray)
{
    static _system = __FlowSystem();
    
    _targetOrArray = __FlowEnsureArray(_targetOrArray);
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message($"FlowProgJump({_delayFrames}, {_targetOrArray})");
    }
}