// Feather disable all

/// @param [name]
/// @param string

function FlowCompile(_name = undefined, _string)
{
    static _precacheMap = __FlowSystem().__precacheMap;
    
    var _program = _precacheMap[? _string] ?? _precacheMap[? _name];
    if (_program != undefined) return _program;
    
    var _tokenArray = __FlowTokenize(_string);
    
    if (__FLOW_DEBUG_TOKENIZER)
    {
        var _i = 0;
        repeat(array_length(_tokenArray) div 2)
        {
            show_debug_message($"{_tokenArray[_i]}    {string_replace_all(_tokenArray[_i+1], "\n", "\\n")}"); 
            _i += 2;
        }
    }
    
    var _program = __FlowMethodize(_tokenArray);
    _precacheMap[? _string] = _program;
    
    if (_name != undefined)
    {
        _precacheMap[? _name] = _program;
    }
    
    return _program;
}