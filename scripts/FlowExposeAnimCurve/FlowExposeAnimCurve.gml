// Feather disable all

/// @param name
/// @param animCurve

function FlowExposeAnimCurve(_name, _animCurve)
{
    static _animCurveMap = __FlowSystem().__animCurveMap;
    
    _animCurveMap[? _name] = _animCurve;
}