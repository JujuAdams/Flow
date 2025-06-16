// Feather disable all

/// @param name
/// @param function

function FlowExposeFunction(_name, _function)
{
    static _functionMap = __FlowSystem().__functionMap;
    
    _functionMap[? _name] = _function;
}