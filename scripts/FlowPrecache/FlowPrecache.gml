// Feather disable all

/// @param identifier
/// @param string

function FlowPrecache(_identifier, _string)
{
    static _precacheMap = __FlowSystem().__precacheMap;
    _precacheMap[? _identifier] = __FlowCompile(_string);
}