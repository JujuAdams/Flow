// Feather disable all

/// @param tokenArray

function __FlowMethodize(_tokenArray)
{
    return (new (function(_tokenArray) constructor
    {
        static _animCurveMap = __FlowSystem().__animCurveMap;
        static _functionMap  = __FlowSystem().__functionMap;
        
        __tokenArray     = _tokenArray;
        __index          = 0;
        __currentType    = __tokenArray[0];
        __currentContent = __tokenArray[1];
        
        __blockMethod = __Block();
        
        static __Check = function(_checkType, _checkContent)
        {
            return ((__currentType == _checkType) && ((_checkContent == undefined) || (__currentContent == _checkContent)));
        }
        
        static __CheckNext = function(_checkType, _checkContent)
        {
            return ((__tokenArray[__index + __FLOW_TOKENIZER_STRIDE] == _checkType) && ((_checkContent == undefined) || (__tokenArray[__index+1 + __FLOW_TOKENIZER_STRIDE] == _checkContent)));
        }
        
        static __Consume = function()
        {
            var _content = __currentContent;
            
            var _index = __index + __FLOW_TOKENIZER_STRIDE;
            __currentType    = __tokenArray[_index];
            __currentContent = __tokenArray[_index+1];
            __index = _index;
            
            return _content;
        }
        
        static __CheckAndConsume = function(_checkType, _checkContent)
        {
            if (__Check(_checkType, _checkContent))
            {
                __Consume();
                return true;
            }
            
            return false;
        }
        
        //Converts an atomic value to a function call
        static __EnsureFunc = function(_value)
        {
            if (not is_method(_value))
            {
                return method({ __value : _value }, function() { return __value });
            }
            else
            {
                return _value;
            }
        }
        
        static __Block = function()
        {
            var _statementArray = [];
            
            while(not __Check(__FLOW_TOKEN_NULL))
            {
                if (not __CheckAndConsume(__FLOW_TOKEN_BREAK))
                {
                    var _statement = __Statement();
                    
                    if (is_ptr(_statement))
                    {
                        __FlowError($"Unexpected token: type={__currentType} \"{__currentContent}\"");
                        break;
                    }
                    
                    array_push(_statementArray, _statement);
                    
                    if (not __CheckAndConsume(__FLOW_TOKEN_BREAK))
                    {
                        __FlowError($"Unexpected token: type={__currentType} \"{__currentContent}\"");
                    }
                }
            }
            
            return method({
                __statementArray: _statementArray,
            },
            function()
            {
                var _array = __statementArray;
                var _i = 0;
                repeat(array_length(_array))
                {
                    _array[_i]();
                    ++_i;
                }
            });
        }
        
        static __Statement = function()
        {
            if (__CheckAndConsume(__FLOW_TOKEN_IDENTIFIER, "time"))
            {
                var _value = __Expression();
                if (not is_ptr(_value))
                {
                    return method({
                        __value: __EnsureFunc(_value),
                    },
                    function()
                    {
                        __FlowBuildTime(__value());
                    });
                }
                else
                {
                    return pointer_null;
                }
            }
            
            var _functionCall = __FunctionCall();
            if (not is_ptr(_functionCall)) return _functionCall;
            
            var _left = __ReferenceOrArray();
            if (not is_ptr(_left))
            {
                ////////
                // Variable assignment
                ////////
                
                if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, "="))
                {
                    var _right = __Expression();
                    if (is_ptr(_right)) return pointer_null;
                    
                    return method({
                        __left: _left,
                        __right: __EnsureFunc(_right),
                    },
                    function()
                    {
                        __FlowBuildTo(__left, __right());
                    });
                }
                
                ////////
                // Curve assignment
                ////////
                
                if (__CheckAndConsume(__FLOW_TOKEN_IDENTIFIER, "curve"))
                {
                    var _right = __AnimationCurve();
                    if (is_ptr(_right)) return pointer_null;
                    
                    return method({
                        __left: _left,
                        __right: __EnsureFunc(_right),
                    },
                    function()
                    {
                        __FlowBuildCurve(__left, __right());
                    });
                }
                
                ////////
                // Speed assignment
                ////////
                
                if (__CheckAndConsume(__FLOW_TOKEN_IDENTIFIER, "speed"))
                {
                    var _right = __Expression();
                    if (is_ptr(_right)) return pointer_null;
                    
                    return method({
                        __left: _left,
                        __right: __EnsureFunc(_right),
                    },
                    function()
                    {
                        __FlowBuildSpeed(__left, __right());
                    });
                }
            }
            
            return pointer_null;
        }
        
        static __GetVariable = function()
        {
            var _result = __Reference();
            if (not is_string(_result)) return pointer_null;
            
            __FlowError("Cannot `get` variables");
            
            //return method({
            //    __name: _result, //TODO - Replace with pre-hashed name
            //},
            //function()
            //{
            //    static _executionContext = __FlowSystem().__executionContext;
            //    return _executionContext.__scope[$ __name];
            //});
        }
        
        static __AnimationCurve = function()
        {
            if (__Check(__FLOW_TOKEN_IDENTIFIER))
            {
                var _animCurve = __Consume();
                var _asset = _animCurveMap[? _animCurve];
                if (animcurve_exists(_asset))
                {
                    return _asset;
                }
                else
                {
                    __FlowError($"Anim curve \"{_animCurve}\" not recognized");
                }
            }
            
            return pointer_null;
        }
        
        static __Expression = function()
        {
            var _functionCall = __FunctionCall();
            if (not is_ptr(_functionCall)) return _functionCall;
            
            var _return = __Term();
            if (not is_ptr(_return)) return _return;
            
            return pointer_null;
        }
        
        static __Term = function()
        {
            var _left = __Factor();
            
            while(true)
            {
                if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, "-"))
                {
                    var _right = __Factor(); //TODO - Filter out invalid datatypes
                    if (is_ptr(_right)) return pointer_null;
                    
                    //Optimization - return a precalculated value if possible
                    if (is_numeric(_left) && is_numeric(_right))
                    {
                        return (_left - _right);
                    }
                    else
                    {
                        return method({
                            __left:  __EnsureFunc(_left),
                            __right: __EnsureFunc(_right),
                        },
                        function()
                        {
                            return (__left() - __right());
                        });
                    }
                }
                else if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, "+"))
                {
                    var _right = __Factor(); //TODO - Filter out invalid datatypes
                    if (is_ptr(_right)) return pointer_null;
                    
                    //Optimization - return a precalculated value if possible
                    if (is_numeric(_left) && is_numeric(_right))
                    {
                        _left = (_left + _right);
                    }
                    else
                    {
                        return method({
                            __left:  __EnsureFunc(_left),
                            __right: __EnsureFunc(_right),
                        },
                        function()
                        {
                            return (__left() + __right());
                        });
                    }
                }
                else
                {
                    break;
                }
            }
            
            return _left;
        }
        
        static __Factor = function()
        {
            var _left = __Unary();
            
            while(true)
            {
                if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, "/"))
                {
                    var _right = __Unary(); //TODO - Filter out invalid datatypes
                    if (is_ptr(_right)) return pointer_null;
                    
                    //Optimization - return a precalculated value if possible
                    if (is_numeric(_left) && is_numeric(_right))
                    {
                        _left = (_left / _right);
                    }
                    else
                    {
                        return method({
                            __left:  __EnsureFunc(_left),
                            __right: __EnsureFunc(_right),
                        },
                        function()
                        {
                            return (__left() / __right());
                        });
                    }
                }
                else if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, "*"))
                {
                    var _right = __Unary(); //TODO - Filter out invalid datatypes
                    if (is_ptr(_right)) return pointer_null;
                    
                    //Optimization - return a precalculated value if possible
                    if (is_numeric(_left) && is_numeric(_right))
                    {
                        _left = (_left * _right);
                    }
                    else
                    {
                        return method({
                            __left:  __EnsureFunc(_left),
                            __right: __EnsureFunc(_right),
                        },
                        function()
                        {
                            return (__left() * __right());
                        });
                    }
                }
                else
                {
                    break;
                }
            }
            
            return _left;
        }
        
        static __Unary = function()
        {
            if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, "!"))
            {
                var _right = __Primary(); //TODO - Filter out invalid datatypes
                if (is_ptr(_right)) return pointer_null;
                
                //Optimization - return a precalculated value if possible
                if (is_numeric(_right) || is_bool(_right))
                {
                    return (!_right);
                }
                else
                {
                    return method({
                        __func: __EnsureFunc(_right),
                    },
                    function()
                    {
                        return (not __func());
                    });
                }
            }
            
            if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, "-"))
            {
                var _right = __Primary(); //TODO - Filter out invalid datatypes
                if (is_ptr(_right)) return pointer_null;
                
                //Optimization - return a precalculated value if possible
                if (is_numeric(_right) || is_bool(_right))
                {
                    return (-_right);
                }
                else
                {
                    return method({
                        __func: __EnsureFunc(_right),
                    },
                    function()
                    {
                        return (-__func());
                    });
                }
            }
            
            return __Primary();
        }
        
        static __Primary = function()
        {
            if (__Check(__FLOW_TOKEN_BOOL))
            {
                return __Consume();
            }
            
            if (__Check(__FLOW_TOKEN_UNDEFINED))
            {
                return __Consume();
            }
            
            if (__Check(__FLOW_TOKEN_STRING))
            {
                return __Consume();
            }
            
            if (__Check(__FLOW_TOKEN_NUMBER))
            {
                return __Consume();
            }
            
            if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, "%"))
            {
                var _number = __Number();
                if (not is_numeric(_number)) return pointer_null;
                
                if (not __CheckAndConsume(__FLOW_TOKEN_SYMBOL, "%"))
                {
                    __FlowError("No matching closing % for opening %");
                }
                
                return method({
                    __paramIndex: _number,
                },
                function()
                {
                    static _executionContext = __FlowSystem().__executionContext;
                    return _executionContext.__paramArray[__paramIndex];
                });
            }
            
            if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, "("))
            {
                var _expression = __Expression();
                if (is_ptr(_expression)) return pointer_null;
                
                if (not __CheckAndConsume(__FLOW_TOKEN_SYMBOL, ")"))
                {
                    __FlowError("No close bracket for open bracket");
                }
                
                return _expression;
            }
            
            return __GetVariable();
        }
        
        static __Number = function()
        {
            if (__Check(__FLOW_TOKEN_NUMBER))
            {
                return __Consume();
            }
            else
            {
                return pointer_null;
            }
        }
        
        static __ReferenceOrArray = function()
        {
            var _return = __Reference();
            if (is_ptr(_return)) return pointer_null;
            
            if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, ","))
            {
                var _new = __Reference();
                if (is_ptr(_new)) __FlowError("Expected reference after comma");
                
                _return = [_return, _new];
                
                while(__CheckAndConsume(__FLOW_TOKEN_SYMBOL, ","))
                {
                    var _new = __Reference();
                    if (is_ptr(_new)) __FlowError("Expected reference after comma");
                    
                    array_push(_return, _new);
                }
            }
            
            return _return;
        }
        
        static __FunctionCall = function()
        {
            if (__Check(__FLOW_TOKEN_IDENTIFIER) && __CheckNext(__FLOW_TOKEN_SYMBOL, "("))
            {
                var _functionName = __Consume();
                
                var _function = _functionMap[? _functionName];
                if (_function == undefined)
                {
                    __FlowError($"Function \"{_functionName}\" not recognized");
                }
                
                __Consume();
                
                var _argumentArray = [];
                
                //TODO - Arguments
                
                if (not __CheckAndConsume(__FLOW_TOKEN_SYMBOL, ")"))
                {
                    __FlowError("No matching closing ) for opening (");
                }
                
                return method({
                    __function: _function,
                    __argumentArray: _argumentArray,
                },
                function()
                {
                    return method_call(__function, __argumentArray);
                });
            }
            
            return pointer_null;
        }
        
        static __Reference = function()
        {
            if (__Check(__FLOW_TOKEN_IDENTIFIER))
            {
                var _result = __Consume();
                
                //Don't permit function execution
                if (__Check(__FLOW_TOKEN_SYMBOL, "("))
                {
                    return pointer_null;
                }
                
                return _result;
            }
            
            return pointer_null;
        }
        
    })(_tokenArray)).__blockMethod;
}