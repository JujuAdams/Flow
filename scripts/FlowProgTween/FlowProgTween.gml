// Feather disable all

/// @param curve
/// @param frames
/// @param valueOrArray

function FlowProgTween(_curve, _frames, _valueOrArray)
{
    static _system = __FlowSystem();
    
    _valueOrArray = __FlowEnsureArray(_valueOrArray);
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message($"FlowProgTween({_curve}, {_frames}, {_valueOrArray})");
    }
}