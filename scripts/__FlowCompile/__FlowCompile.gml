// Feather disable all

/// @param string

function __FlowCompile(_string)
{
    static _precacheMap = __FlowSystem().__precacheMap;
    
    var _program = _precacheMap[? _string];
    if (_program != undefined) return _program;
    
    var _tokenArray = __FlowTokenize(_string);
    var _block = __FlowMethodize(_tokenArray);
    _precacheMap[? _string] = _block;
    
    return _block;
}