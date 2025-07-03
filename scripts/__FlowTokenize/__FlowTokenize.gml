// Feather disable all

/// @param string

#macro __FLOW_TOKEN_STATE_NULL           -3
#macro __FLOW_TOKEN_STATE_BLOCK_COMMENT  -2
#macro __FLOW_TOKEN_STATE_LINE_COMMENT   -1
#macro __FLOW_TOKEN_STATE_UNKNOWN         0
#macro __FLOW_TOKEN_STATE_IDENTIFIER       1
#macro __FLOW_TOKEN_STATE_STRING          2
#macro __FLOW_TOKEN_STATE_NUMBER          3
#macro __FLOW_TOKEN_STATE_SYMBOL          4
#macro __FLOW_TOKEN_STATE_BREAK           5

#macro __FLOW_TOKEN_NULL       (__FLOW_DEBUG_TOKENIZER? "null " : -1)
#macro __FLOW_TOKEN_SYMBOL     (__FLOW_DEBUG_TOKENIZER? "sym  " :  0)
#macro __FLOW_TOKEN_BREAK      (__FLOW_DEBUG_TOKENIZER? "brk  " :  1)
#macro __FLOW_TOKEN_NUMBER     (__FLOW_DEBUG_TOKENIZER? "numb " :  2)
#macro __FLOW_TOKEN_STRING     (__FLOW_DEBUG_TOKENIZER? "strg " :  3)
#macro __FLOW_TOKEN_BOOL       (__FLOW_DEBUG_TOKENIZER? "bool " :  4)
#macro __FLOW_TOKEN_UNDEFINED  (__FLOW_DEBUG_TOKENIZER? "undf " :  5)
#macro __FLOW_TOKEN_IDENTIFIER (__FLOW_DEBUG_TOKENIZER? "ident" :  6)

#macro __FLOW_TOKENIZER_STRIDE  2

function __FlowTokenize(_string)
{
    static _buffer = buffer_create(1024, buffer_grow, 1);
    
    //This function defines a look-up table. The table will return the token state when encountering
    //the ASCII character *in isolation*. Characters such as `/` or `.` have special case handling to
    //handle different behaviours, such as comments or variable access.
    static _nextStateLookupArray = (function()
    {
        var _array = array_create(127, __FLOW_TOKEN_STATE_UNKNOWN);
        
        _array[@ ord("\n")] = __FLOW_TOKEN_STATE_BREAK;                                           // 10
        _array[@ ord("!" )] = __FLOW_TOKEN_STATE_SYMBOL;                                          // 33
        _array[@ ord("\"")] = __FLOW_TOKEN_STATE_STRING;                                          // 34
        for(var _i = ord("#"); _i <= ord("-"); _i++) _array[@ _i] = __FLOW_TOKEN_STATE_SYMBOL;    // 35 ->  45
        _array[@ ord("." )] = __FLOW_TOKEN_STATE_NUMBER;                                          // 46
        _array[@ ord("/" )] = __FLOW_TOKEN_STATE_SYMBOL;                                          // 47
        for(var _i = ord("0"); _i <= ord("9"); _i++) _array[@ _i] = __FLOW_TOKEN_STATE_NUMBER;    // 48 ->  57
        _array[@ ord(":" )] = __FLOW_TOKEN_STATE_SYMBOL;                                          // 58
        _array[@ ord(";" )] = __FLOW_TOKEN_STATE_BREAK;                                           // 59
        for(var _i = ord("<"); _i <= ord("@"); _i++) _array[@ _i] = __FLOW_TOKEN_STATE_SYMBOL;    // 60 ->  64
        for(var _i = ord("A"); _i <= ord("Z"); _i++) _array[@ _i] = __FLOW_TOKEN_STATE_IDENTIFIER; // 65 ->  90
        _array[@ ord("[" )] = __FLOW_TOKEN_STATE_SYMBOL;                                          // 91
        _array[@ ord("\\")] = __FLOW_TOKEN_STATE_SYMBOL;                                          // 92
        _array[@ ord("]" )] = __FLOW_TOKEN_STATE_SYMBOL;                                          // 93
        _array[@ ord("^" )] = __FLOW_TOKEN_STATE_SYMBOL;                                          // 94
        _array[@ ord("_" )] = __FLOW_TOKEN_STATE_IDENTIFIER;                                       // 95
        _array[@ ord("`" )] = __FLOW_TOKEN_STATE_SYMBOL;                                          // 96
        for(var _i = ord("a"); _i <= ord("z"); _i++) _array[@ _i] = __FLOW_TOKEN_STATE_IDENTIFIER; // 97 -> 122
        for(var _i = ord("{"); _i <= ord("~"); _i++) _array[@ _i] = __FLOW_TOKEN_STATE_SYMBOL;    //123 -> 126
        
        return _array;
    })();
    
    var _tokensArray = [];
    
    var _size = string_byte_length(_string) + 1;
    
    buffer_seek(_buffer, buffer_seek_start, 0);
    buffer_write(_buffer, buffer_string, _string);
    
    var _readStart   = 0;
    var _state       = __FLOW_TOKEN_STATE_UNKNOWN;
    var _nextState   = __FLOW_TOKEN_STATE_UNKNOWN;
    var _lastByte    = 0;
    var _new         = false;
    var _changeState = true;
    
    var _b = 0;
    repeat(_size)
    {
        var _byte = buffer_peek(_buffer, _b, buffer_u8);
        _nextState = (_byte == 0)? __FLOW_TOKEN_STATE_NULL : __FLOW_TOKEN_STATE_UNKNOWN;
        _changeState = true;
        _new = false;
        
        switch(_state)
        {
            case __FLOW_TOKEN_STATE_LINE_COMMENT:
                if (_lastByte == ord("\n")) //Newline
                {
                    _new = true;
                }
                else
                {
                    _nextState = __FLOW_TOKEN_STATE_LINE_COMMENT;
                }
            break;
            
            case __FLOW_TOKEN_STATE_BLOCK_COMMENT:
                if ((_lastByte == ord("/")) && (buffer_peek(_buffer, _b-2, buffer_u8) == ord("*"))) // */
                {
                    _new = true;
                }
                else
                {
                    _nextState = __FLOW_TOKEN_STATE_BLOCK_COMMENT;
                }
            break;
            
            case __FLOW_TOKEN_STATE_BREAK:
                array_push(_tokensArray,   __FLOW_TOKEN_BREAK, chr(_lastByte));
            break;
            
            case __FLOW_TOKEN_STATE_IDENTIFIER: //Variable / function
                if (_byte == ord("."))
                {
                    _nextState = __FLOW_TOKEN_STATE_SYMBOL;
                }
                else
                {
                    var _nextState = (_byte < 127)? _nextStateLookupArray[_byte] : __FLOW_TOKEN_STATE_UNKNOWN;
                    
                    //If we have letters before numbers then the numbers are considered part of the variable name
                    if (_nextState == __FLOW_TOKEN_STATE_NUMBER)
                    {
                        _nextState = __FLOW_TOKEN_STATE_IDENTIFIER;
                    }
                }
                
                if (_state != _nextState)
                {
                    //Pop the string and store it as a token
                    buffer_poke(_buffer, _b, buffer_u8, 0);
                    buffer_seek(_buffer, buffer_seek_start, _readStart);
                    var _read = buffer_read(_buffer, buffer_string);
                    buffer_poke(_buffer, _b, buffer_u8, _byte);
                    
                    //Convert friendly human-readable operators into symbolic operators
                    switch(_read)
                    {
                        case "new":       array_push(_tokensArray,   __FLOW_TOKEN_SYMBOL,     "new"    ); break;
                        case "mod":       array_push(_tokensArray,   __FLOW_TOKEN_SYMBOL,     "%"      ); break;
                        case "and":       array_push(_tokensArray,   __FLOW_TOKEN_SYMBOL,     "&&"     ); break;
                        case "or" :       array_push(_tokensArray,   __FLOW_TOKEN_SYMBOL,     "||"     ); break;
                        case "xor" :      array_push(_tokensArray,   __FLOW_TOKEN_SYMBOL,     "^^"     ); break;
                        case "not":       array_push(_tokensArray,   __FLOW_TOKEN_SYMBOL,     "!"      ); break;
                        case "true":      array_push(_tokensArray,   __FLOW_TOKEN_BOOL,       true     ); break;
                        case "false":     array_push(_tokensArray,   __FLOW_TOKEN_BOOL,       false    ); break;
                        case "undefined": array_push(_tokensArray,   __FLOW_TOKEN_UNDEFINED,  undefined); break;
                        default:          array_push(_tokensArray,   __FLOW_TOKEN_IDENTIFIER, _read    ); break;
                    }
                    
                    _new = true;
                }
            break;
            
            case __FLOW_TOKEN_STATE_STRING: //Quote-delimited String
                if ((_byte == 0) || ((_byte == 34) && (_lastByte != 92))) //null "
                {
                    _changeState = false;
                    
                    if (_readStart < _b - 1)
                    {
                        //Pop the string and store it as a token
                        buffer_poke(_buffer, _b, buffer_u8, 0);
                        buffer_seek(_buffer, buffer_seek_start, _readStart+1);
                        var _read = buffer_read(_buffer, buffer_string);
                        buffer_poke(_buffer, _b, buffer_u8, _byte);
                    }
                    else
                    {
                        //Zero length string
                        var _read = "";
                    }
                    
                    array_push(_tokensArray, __FLOW_TOKEN_STRING, _read);
                    _new = true;
                }
                else
                {
                    _nextState = __FLOW_TOKEN_STATE_STRING; //Quote-delimited String
                }
            break;
            
            case __FLOW_TOKEN_STATE_NUMBER: //Number
                if (_byte == 46) //.
                {
                    _nextState = __FLOW_TOKEN_STATE_NUMBER;
                }
                else if ((_byte >= 48) && (_byte <= 57)) //0 1 2 3 4 5 6 7 8 9
                {
                    _nextState = __FLOW_TOKEN_STATE_NUMBER;
                }
                
                if (_state != _nextState)
                {
                    //Pop the string, try it convert it to a number, and store it as a token
                    buffer_poke(_buffer, _b, buffer_u8, 0);
                    buffer_seek(_buffer, buffer_seek_start, _readStart);
                    var _read = buffer_read(_buffer, buffer_string);
                    buffer_poke(_buffer, _b, buffer_u8, _byte);
                    
                    try
                    {
                        _read = real(_read);
                    }
                    catch(_error)
                    {
                        show_debug_message(_error);
                        __FlowError($"Could not convert \"{_read}\" to a number");
                        break;
                    }
                    
                    array_push(_tokensArray,   __FLOW_TOKEN_NUMBER, _read);
                    
                    _new = true;
                }
            break;
            
            case __FLOW_TOKEN_STATE_SYMBOL:
                //We usually default to treating consecutive symbols are separate (consider `-(-2))`). The following
                //checks will combine glyphs together
                if (_byte == 61) //=
                {
                    if ((_lastByte == 33)  // !=
                    ||  (_lastByte == 42)  // *=
                    ||  (_lastByte == 43)  // +=
                    ||  (_lastByte == 45)  // -=
                    ||  (_lastByte == 47)  // /=
                    ||  (_lastByte == 60)  // <=
                    ||  (_lastByte == 61)  // ==
                    ||  (_lastByte == 62)) // >=
                    {
                        _nextState = __FLOW_TOKEN_STATE_SYMBOL;
                    }
                }
                else if ((_byte == 38) && (_lastByte == 38)) // &&
                {
                    _nextState = __FLOW_TOKEN_STATE_SYMBOL;
                }
                else if ((_byte == 43) && (_lastByte == 43)) // ++
                {
                    _nextState = __FLOW_TOKEN_STATE_SYMBOL;
                }
                else if ((_byte == 43) && (_lastByte == 43)) // --
                {
                    _nextState = __FLOW_TOKEN_STATE_SYMBOL;
                }
                else if ((_byte == 124) && (_lastByte == 124)) // ||
                {
                    _nextState = __FLOW_TOKEN_STATE_SYMBOL;
                }
                else if ((_byte == 60) && (_lastByte == 60)) // <<
                {
                    _nextState = __FLOW_TOKEN_STATE_SYMBOL;
                }
                else if ((_byte == 62) && (_lastByte == 62)) // >>
                {
                    _nextState = __FLOW_TOKEN_STATE_SYMBOL;
                }
                else if ((_byte == 94) && (_lastByte == 94)) // ^^
                {
                    _nextState = __FLOW_TOKEN_STATE_SYMBOL;
                }
                
                if (_state != _nextState)
                {
                    //Pop the string and store it as a token
                    buffer_poke(_buffer, _b, buffer_u8, 0);
                    buffer_seek(_buffer, buffer_seek_start, _readStart);
                    var _read = buffer_read(_buffer, buffer_string);
                    buffer_poke(_buffer, _b, buffer_u8, _byte);
                    
                    array_push(_tokensArray,   __FLOW_TOKEN_SYMBOL, _read);
                    
                    _new = true;
                }
            break;
        }
        
        if (_changeState && (_nextState == __FLOW_TOKEN_STATE_UNKNOWN))
        {
            if (_byte == 47) // /
            {
                var _nextByte = buffer_peek(_buffer, _b+1, buffer_u8);
                if (_nextByte == 47) // /
                {
                    _nextState = __FLOW_TOKEN_STATE_LINE_COMMENT;
                }
                else if (_nextByte == 42) // *
                {
                    _nextState = __FLOW_TOKEN_STATE_BLOCK_COMMENT;
                }
                else
                {
                    _nextState = __FLOW_TOKEN_STATE_SYMBOL;
                }
            }
            else if (_byte < 127)
            {
                _nextState = _nextStateLookupArray[_byte];
            }
        }
        
        if (_new || (_state != _nextState)) _readStart = _b;
        _state = _nextState;
        if (_state == __FLOW_TOKEN_STATE_NULL) break;
        _lastByte = _byte;
        
        ++_b;
    }
    
    array_push(_tokensArray, __FLOW_TOKEN_BREAK, undefined);
    array_push(_tokensArray, __FLOW_TOKEN_NULL, undefined);
    
    return _tokensArray;
}