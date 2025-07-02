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
        
        ///////
        // Utility methods
        ///////
        
        //Returns if the current token type matches with a desired type. Additionally, if `_checkContent`
        //is not `undefined` then this function also requires content to literally match too.
        static __Check = function(_checkType, _checkContent = undefined)
        {
            return ((__currentType == _checkType) && ((_checkContent == undefined) || (__currentContent == _checkContent)));
        }
        
        //Returns if the next token type matches with a desired type. Additionally, if `_checkContent`
        //is not `undefined` then this function also requires content to literally match too.
        static __CheckNext = function(_checkType, _checkContent)
        {
            return ((__tokenArray[__index + __FLOW_TOKENIZER_STRIDE] == _checkType) && ((_checkContent == undefined) || (__tokenArray[__index+1 + __FLOW_TOKENIZER_STRIDE] == _checkContent)));
        }
        
        //Moves the read head to a particular index
        static __Jump = function(_index)
        {
            __currentType    = __tokenArray[_index];
            __currentContent = __tokenArray[_index+1];
            __index = _index;
        }
        
        //Moves the read head along one position and returns the *previous* value
        static __Consume = function()
        {
            var _content = __currentContent;
            __Jump(__index + __FLOW_TOKENIZER_STRIDE);
            return _content;
        }
        
        //Performs a test against the current data. If the check succeeds, the read head is moved along one
        //step and the method returns `true`. Otherwise, this method returns `false`.
        static __CheckAndConsume = function(_checkType, _checkContent)
        {
            if (__Check(_checkType, _checkContent))
            {
                __Consume();
                return true;
            }
            
            return false;
        }
        
        //Generally useful method that converts an atomic value (string, number, boolean, undefined) to a
        //function call.
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
        
        ///////
        // Builder methods
        ///////
        
        //The basic building block. "Blocks" contain multiple statements separated by newlines or
        //semicolons.
        static __Block = function()
        {
            var _statementArray = [];
            
            //Continue parsing until we hit a null (which should be the end of the tokens)
            while(not __Check(__FLOW_TOKEN_NULL))
            {
                //Consume BREAK tokens until we hit something interesting
                if (not __CheckAndConsume(__FLOW_TOKEN_BREAK))
                {
                    var _statement = __Statement();
                    
                    if (is_ptr(_statement))
                    {
                        __FlowError($"Unexpected token: type={__currentType} \"{__currentContent}\"");
                        break;
                    }
                    
                    array_push(_statementArray, _statement);
                    
                    //We expect a statement to always end in a break
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
        
        //Statements are "lines" of instructions. Lines can only start with certain tokens:
        // `time <expression>`
        // `delay <expression>`
        // `await` `await all` `await any`
        // `function(<arguments>)`
        // `<tween line>`
        static __Statement = function()
        {
            ////////
            // `time <expression>`
            ////////
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
                        //TODO
                    });
                }
                else
                {
                    return pointer_null;
                }
            }
            
            ////////
            // `delay <expression>`
            ////////
            if (__CheckAndConsume(__FLOW_TOKEN_IDENTIFIER, "delay"))
            {
                var _value = __Expression();
                if (not is_ptr(_value))
                {
                    return method({
                        __value: __EnsureFunc(_value),
                    },
                    function()
                    {
                        //TODO
                    });
                }
                else
                {
                    return pointer_null;
                }
            }
            
            ////////
            // `await ...`
            ////////
            if (__CheckAndConsume(__FLOW_TOKEN_IDENTIFIER, "await"))
            {
                if (__CheckAndConsume(__FLOW_TOKEN_BREAK) || __CheckAndConsume(__FLOW_TOKEN_IDENTIFIER, "all"))
                {
                    return method({
                        
                    },
                    function()
                    {
                        //TODO
                    });
                }
                else if (__CheckAndConsume(__FLOW_TOKEN_IDENTIFIER, "any"))
                {
                    return method({
                        
                    },
                    function()
                    {
                        //TODO
                    });
                }
                else
                {
                    return pointer_null;
                }
            }
            
            ///////
            // `function(<arguments>)`
            ///////
            var _result = __FunctionCall();
            if (not is_ptr(_result)) return _result;
            
            ///////
            // `<tween line>`
            ///////
            var _result = __TweenLine();
            if (not is_ptr(_result)) return _result;
            
            //Failed to parse the line
            return pointer_null;
        }
        
        //Tween lines take one of two forms:
        // `<variableOrTuple> >> <process> [>> <process>]
        // `<variableOrTuple> = <multiExpression> [>> <process>]
        static __TweenLine = function()
        {
            var _target = __VariableOrTuple();
            if (is_ptr(_target)) return pointer_null;
            
            if (__CheckAndConsume(__FLOW_TOKEN_STATE_SYMBOL, "="))
            {
                var _setValue = __Expression();
                if (is_ptr(_setValue)) return pointer_null;
            }
            else
            {
                var _setValue = undefined;
            }
            
            //Accept any number of following process definitions, at least until we reach a break token
            var _processArray = [];
            while(not __CheckAndConsume(__FLOW_TOKEN_STATE_BREAK))
            {
                if (not __CheckAndConsume(__FLOW_TOKEN_STATE_SYMBOL, ">>")) return pointer_null;
                
                var _process = __Process();
                if (is_ptr()) return pointer_null;
                
                array_push(_processArray, _process);
            }
            
            return method({
                __target:       __EnsureFunc(_target),
                __setValue:     __EnsureFunc(_setValue),
                __processArray: _processArray,
            },
            function()
            {
                //TODO
            });
        }
        
        //Multi-expressions are comma separated expressions
        // `x`
        // `x,y`
        // `x,y,z`
        // `x&y`
        static __VariableOrTuple = function()
        {
            if (not __Check(__FLOW_TOKEN_IDENTIFIER))
            {
                return pointer_null;
            }
            
            var _vector = false;
            var _array  = [__Consume()];
            
            if (__CheckAndConsume(__FLOW_TOKEN_STATE_SYMBOL, ","))
            {
                //Building a list of parallel tracks to tween
                do
                {
                    var _reference = __Reference();
                    if (not is_ptr(_reference)) return pointer_null;
                
                    array_push(_array, _reference);
                }
                until(not __CheckAndConsume(__FLOW_TOKEN_STATE_SYMBOL, ","));
            }
            else if (__CheckAndConsume(__FLOW_TOKEN_STATE_SYMBOL, "&"))
            {
                //Building a vector to tween
                _vector = true;
                
                do
                {
                    var _reference = __Reference();
                    if (not is_ptr(_reference)) return pointer_null;
                
                    array_push(_array, _reference);
                }
                until(not __CheckAndConsume(__FLOW_TOKEN_STATE_SYMBOL, "&"));
            }
            
            return method({
                __vector: _vector,
                __array:  _array,
            },
            function()
            {
                //TODO
            });
        }
        
        static __Reference = function()
        {
            if (__Check(__FLOW_TOKEN_IDENTIFIER))
            {
                return __Consume();
            }
            else
            {
                return pointer_null;
            }
        }
        
        //A "process" defines target values and a mechanism to get there. They must take one of the following forms;
        // `+<multiExpression> = <multiExpression>`  : speed-based interpolation (a.k.a. "approach")
        // `<duration> <curve> = <multiExpression>`  : curve interpolation
        // `<duration> = <multiExpression>`          : linear interpolation
        // `<curve> <duration> = <multiExpression>`  : curve interpolation (alternate mode)
        static __Process = function()
        {
            var _mechanism = undefined;
            
            //Try to fit `+<multiExpression>`
            if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, "+"))
            {
                var _multiExpression = __MultiExpression();
                if (not is_ptr(_multiExpression)) return pointer_null;
                
                _mechanism = method({
                    __multiExpression: _multiExpression,
                },
                function()
                {
                    //TODO
                });
            }
            else
            {
                //Try to fit `<curve> <duration>`
                var _curve = __AnimationCurve();
                if (not is_ptr(_curve))
                {
                    var _duration = __Duration();
                    if (is_ptr(_duration)) return pointer_null;
                }
                else
                {
                    //Try to fit one of `<duration> <curve>` or `<duration>`
                    var _duration = __Duration();
                    if (is_ptr(_duration)) return pointer_null;
                    
                    var _curve = __AnimationCurve();
                    if (is_ptr(_curve)) _curve = undefined; //Curve definition is optional
                }
                
                _mechanism = method({
                    __duration: _duration,
                    __curve: _curve,
                },
                function()
                {
                    //TODO
                });
            }
            
            //Now try to match `= <multiExpression>`
            if (not __CheckAndConsume(__FLOW_TOKEN_STATE_SYMBOL, "="))
            {
                return pointer_null;
            }
            
            var _target = __MultiExpression();
            if (is_ptr(_target)) return pointer_null;
            
            return method({
                __mechanism: _mechanism,
                __target:    _target,
            },
            function()
            {
                //TODO
            });
        }
        
        // `<expression>fr`
        // `<expression>ms`
        static __Duration = function()
        {
            var _expression = __Expression();
            if (is_ptr(_expression)) return pointer_null;
            
            if (__CheckAndConsume(__FLOW_TOKEN_STATE_IDENIFIER, "ms"))
            {
                var _milliseconds = false;
            }
            else if (__CheckAndConsume(__FLOW_TOKEN_STATE_IDENIFIER, "ms"))
            {
                var _milliseconds = true;
            }
            else
            {
                return pointer_null;
            }
            
            return method({
                __expression:   __EnsureFunc(_expression),
                __milliseconds: _milliseconds,
            },
            function()
            {
                //TODO
            });
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
        
        //Multi-expressions are comma separated expressions
        // `1`
        // `1,2`
        // `1,2,3`
        static __MultiExpression = function()
        {
            var _array = [];
            
            do
            {
                var _expression = __Expression();
                if (not is_ptr(_expression)) return pointer_null;
                
                array_push(_array, _expression);
            }
            until(not __CheckAndConsume(__FLOW_TOKEN_STATE_SYMBOL, ","));
            
            return method({
                __array: _array,
            },
            function()
            {
                //TODO
            });
        }
        
        static __Expression = function()
        {
            var _functionCall = __FunctionCall();
            if (not is_ptr(_functionCall)) return _functionCall;
            
            var _return = __AddSubtract();
            if (not is_ptr(_return)) return _return;
            
            return pointer_null;
        }
        
        static __AddSubtract = function()
        {
            var _left = __MultiplyDivide();
            
            while(true)
            {
                if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, "-"))
                {
                    var _right = __MultiplyDivide(); //TODO - Filter out invalid datatypes
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
                    var _right = __MultiplyDivide(); //TODO - Filter out invalid datatypes
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
        
        static __MultiplyDivide = function()
        {
            var _left = __NegateNegative();
            
            while(true)
            {
                if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, "/"))
                {
                    var _right = __NegateNegative(); //TODO - Filter out invalid datatypes
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
                    var _right = __NegateNegative(); //TODO - Filter out invalid datatypes
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
        
        static __NegateNegative = function()
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
            
            var _function = __FunctionCall();
            if (not is_ptr(_function)) return _function;
            
            return pointer_null;
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
        
        // `~function(<arguments>)`
        // `function(<arguments>)`
        static __FunctionCall = function()
        {
            var _startIndex = __index;
            
            var _dynamic = __CheckAndConsume(__FLOW_TOKEN_STATE_SYMBOL, "~");
            
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
                
                //If we aren't followed by a close bracket then we must have some arguments
                if (not __CheckAndConsume(__FLOW_TOKEN_SYMBOL, ")"))
                {
                    do
                    {
                        var _expression = __Expression();
                        if (not is_ptr(_expression)) return pointer_null;
                        
                        array_push(_argumentArray, _expression);
                    }
                    until(not __CheckAndConsume(__FLOW_TOKEN_STATE_SYMBOL, ","));
                    
                    if (not __CheckAndConsume(__FLOW_TOKEN_SYMBOL, ")"))
                    {
                        __FlowError("No matching closing ) for opening (");
                    }
                }
                
                return method({
                    __dynamic: _dynamic,
                    __function: _function,
                    __argumentArray: _argumentArray,
                },
                function()
                {
                    return method_call(__function, __argumentArray);
                });
            }
            
            __Jump(_startIndex);
            return pointer_null;
        }
    })(_tokenArray)).__blockMethod;
}