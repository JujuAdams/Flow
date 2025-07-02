// Feather disable all

/// @param string

function __FlowCompile(_string)
{
    static _precacheMap = __FlowSystem().__precacheMap;
    
    var _program = _precacheMap[? _string];
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
    
    var _block = __FlowMethodize(_tokenArray);
    _precacheMap[? _string] = _block;
    
    return _block;
}