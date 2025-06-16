// Feather disable all

/// @param string

#macro __FLOW_TOKEN_STATE_NULL           -3
#macro __FLOW_TOKEN_STATE_BLOCK_COMMENT  -2
#macro __FLOW_TOKEN_STATE_LINE_COMMENT   -1
#macro __FLOW_TOKEN_STATE_UNKNOWN         0
#macro __FLOW_TOKEN_STATE_WORD            1
#macro __FLOW_TOKEN_STATE_STRING          2
#macro __FLOW_TOKEN_STATE_NUMBER          3
#macro __FLOW_TOKEN_STATE_SYMBOL          4
#macro __FLOW_TOKEN_STATE_LINE_BREAK      5

#macro __FLOW_TOKEN_NULL       (__FLOW_DEBUG_TOKENIZER? "tkn_nul" : -1)
#macro __FLOW_TOKEN_SYMBOL     (__FLOW_DEBUG_TOKENIZER? "tkn_sym" :  0)
#macro __FLOW_TOKEN_LINE_BREAK (__FLOW_DEBUG_TOKENIZER? "tkn_lbr" :  1)
#macro __FLOW_TOKEN_NUMBER     (__FLOW_DEBUG_TOKENIZER? "tkn_num" :  2)
#macro __FLOW_TOKEN_STRING     (__FLOW_DEBUG_TOKENIZER? "tkn_str" :  3)
#macro __FLOW_TOKEN_BOOL       (__FLOW_DEBUG_TOKENIZER? "tkn_bol" :  4)
#macro __FLOW_TOKEN_UNDEFINED  (__FLOW_DEBUG_TOKENIZER? "tkn_und" :  5)
#macro __FLOW_TOKEN_IDENTIFIER (__FLOW_DEBUG_TOKENIZER? "tkn_idt" :  6)

#macro __FLOW_TOKENIZER_STRIDE  2

function __FlowTokenize(_string)
{
    static _buffer = buffer_create(1024, buffer_grow, 1);
    
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
            
            case __FLOW_TOKEN_STATE_LINE_BREAK:
                array_push(_tokensArray,   __FLOW_TOKEN_LINE_BREAK, chr(_lastByte));
            break;
            
            case __FLOW_TOKEN_STATE_WORD: //Vvariable / function
                if ((_byte == ord("\n")) || (_byte == ord(";")))
                {
                    _nextState = __FLOW_TOKEN_STATE_LINE_BREAK;
                }
                else if ((_byte == ord("\"")) || (_byte == ord("%")) || (_byte == ord("&")) || (_byte == ord(")"))
                     ||  (_byte == ord( "*")) || (_byte == ord("+")) || (_byte == ord(",")) || (_byte == ord("-"))
                     ||  (_byte == ord("."))  || (_byte == ord("/")) || (_byte == ord(":")) || (_byte == ord("(")) || (_byte == ord(")"))
                     ||  (_byte == ord("<"))  || (_byte == ord("=")) || (_byte == ord(">")) || (_byte == ord("?"))
                     ||  (_byte == ord("["))  || (_byte == ord("]")) || (_byte == ord("^")) || (_byte == ord("_"))
                     ||  (_byte == ord("{"))  || (_byte == ord("|")) || (_byte == ord("}")) || (_byte == ord("~")))
                {
                    _nextState = __FLOW_TOKEN_STATE_SYMBOL;
                }
                else if (_byte > 32) //Everything is permitted, except non-printable stuff
                {
                    _nextState = __FLOW_TOKEN_STATE_WORD;
                }
                
                if (_state != _nextState)
                {
                    //Just a normal keyboard/variable
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
                    _nextState = __FLOW_TOKEN_STATE_UNKNOWN;
                }
            break;
            
            case __FLOW_TOKEN_STATE_STRING: //Quote-delimited String
                if ((_byte == 0) || ((_byte == 34) && (_lastByte != 92))) //null "
                {
                    _changeState = false;
                    
                    if (_readStart < _b - 1)
                    {
                        buffer_poke(_buffer, _b, buffer_u8, 0);
                        buffer_seek(_buffer, buffer_seek_start, _readStart+1);
                        var _read = buffer_read(_buffer, buffer_string);
                        buffer_poke(_buffer, _b, buffer_u8, _byte);
                    }
                    else
                    {
                        var _read = "";
                    }
                    
                    array_push(_tokensArray,   __FLOW_TOKEN_STRING, _read);
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
                        __FlowError($"Could not convert \"{_read}\" to a number");
                        return undefined;
                    }
                    
                    array_push(_tokensArray,   __FLOW_TOKEN_NUMBER, _read);
                    
                    _new = true;
                }
            break;
            
            case __FLOW_TOKEN_STATE_SYMBOL: //Symbol
                if (_byte == 61) //=
                {
                    if ((_lastByte == 33)  // !=
                    ||  (_lastByte == 42)  // *=
                    ||  (_lastByte == 43)  // +=
                    ||  (_lastByte == 45)  // +=
                    ||  (_lastByte == 47)  // /=
                    ||  (_lastByte == 60)  // <=
                    ||  (_lastByte == 61)  // ==
                    ||  (_lastByte == 62)) // >=
                    {
                        _nextState = __FLOW_TOKEN_STATE_SYMBOL; //Symbol
                    }
                }
                else if ((_byte == 38) && (_lastByte == 38)) //&
                {
                    _nextState = __FLOW_TOKEN_STATE_SYMBOL; //Symbol
                }
                else if ((_byte == 124) && (_lastByte == 124)) //|
                {
                    _nextState = __FLOW_TOKEN_STATE_SYMBOL; //Symbol
                }
                
                if (_state != _nextState)
                {
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
            if (_byte == ord("\n"))
            {
                _nextState = __FLOW_TOKEN_STATE_LINE_BREAK;
            }
            if (_byte == 33) //!
            {
                _nextState = __FLOW_TOKEN_STATE_SYMBOL;
            }
            else if ((_byte == 34) && (_lastByte != 92)) //"
            {
                _nextState = __FLOW_TOKEN_STATE_STRING; //Quote-delimited String
            }
            else if ((_byte == 37) || (_byte == 38)) //% &
            {
                _nextState = __FLOW_TOKEN_STATE_SYMBOL;
            }
            else if ((_byte == 40) || (_byte == 41)) //( )
            {
                _nextState = __FLOW_TOKEN_STATE_SYMBOL;
            }
            else if ((_byte >= 42) && (_byte <= 46)) //* + , - .
            {
                _nextState = __FLOW_TOKEN_STATE_SYMBOL;
            }
            else if (_byte == 47) // /
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
            else if ((_byte >= 48) && (_byte <= 57)) //0 1 2 3 4 5 6 7 8 9
            {
                _nextState = __FLOW_TOKEN_STATE_NUMBER;
            }
            else if (_byte == 58) //:
            {
                _nextState = __FLOW_TOKEN_STATE_SYMBOL;
            }
            else if (_byte == 59) //;
            {
                _nextState = __FLOW_TOKEN_STATE_LINE_BREAK;
            }
            else if ((_byte >= 60) && (_byte <= 63))  //< = > ?
            {
                _nextState = __FLOW_TOKEN_STATE_SYMBOL;
            }
            else if ((_byte >= 65) && (_byte <= 90)) //a b c...x y z
            {
                _nextState = __FLOW_TOKEN_STATE_WORD;
            }
            else if (_byte == 91) //[
            {
                _nextState = __FLOW_TOKEN_STATE_SYMBOL;
            }
            else if (_byte == 93) //]
            {
                _nextState = __FLOW_TOKEN_STATE_SYMBOL;
            }
            else if (_byte == 94) //^
            {
                _nextState = __FLOW_TOKEN_STATE_SYMBOL;
            }
            else if (_byte == 95) //_
            {
                _nextState = __FLOW_TOKEN_STATE_WORD;
            }
            else if ((_byte >= 97) && (_byte <= 122)) //A B C...X Y Z
            {
                _nextState = __FLOW_TOKEN_STATE_WORD;
            }
            else if ((_byte >= 123) && (_byte <= 126)) // { | } ~
            {
                _nextState = __FLOW_TOKEN_STATE_SYMBOL;
            }
        }
        
        if (_new || (_state != _nextState)) _readStart = _b;
        _state = _nextState;
        if (_state == __FLOW_TOKEN_STATE_NULL) break;
        _lastByte = _byte;
        
        ++_b;
    }
    
    array_push(_tokensArray, __FLOW_TOKEN_LINE_BREAK, undefined);
    array_push(_tokensArray, __FLOW_TOKEN_NULL, undefined);
    
    return _tokensArray;
}