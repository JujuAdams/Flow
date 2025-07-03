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
            function(_scope)
            {
                static _system = __FlowSystem();
                
                if (not _system.__usingGo)
                {
                    __FlowError("Must only execute Flow programs using `FlowGo()`");
                }
                
                FlowProgBegin(_scope);
                
                var _array = __statementArray;
                var _i = 0;
                repeat(array_length(_array))
                {
                    _array[_i]();
                    ++_i;
                }
                
                return FlowProgEnd();
            });
        }
        
        //Statements are "lines" of instructions. Lines can only start with certain tokens:
        // `time <duration>`
        // `delay <duration>`
        // `await` `await all` `await any`
        // `function(<arguments>)`
        // `<tween line>`
        static __Statement = function()
        {
            ////////
            // `time <duration>`
            ////////
            if (__CheckAndConsume(__FLOW_TOKEN_IDENTIFIER, "time"))
            {
                var _value = __Duration();
                if (not is_ptr(_value))
                {
                    return method({
                        __value: __EnsureFunc(_value),
                    },
                    function()
                    {
                        FlowProgSetTime(__value());
                    });
                }
                else
                {
                    return pointer_null;
                }
            }
            
            ////////
            // `delay <duration>`
            ////////
            if (__CheckAndConsume(__FLOW_TOKEN_IDENTIFIER, "delay"))
            {
                var _value = __Duration();
                if (not is_ptr(_value))
                {
                    return method({
                        __value: __EnsureFunc(_value),
                    },
                    function()
                    {
                        FlowProgDelay(__value());
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
                    return function()
                    {
                        FlowProgAwaitAll();
                    };
                }
                else if (__CheckAndConsume(__FLOW_TOKEN_IDENTIFIER, "any"))
                {
                    return function()
                    {
                        FlowProgAwaitAny();
                    };
                }
                else
                {
                    return pointer_null;
                }
            }
            
            ///////
            // `function(<arguments>)`
            ///////
            var _result = __Function(true);
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
            
            if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, "="))
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
            while(not __Check(__FLOW_TOKEN_BREAK))
            {
                if (not __CheckAndConsume(__FLOW_TOKEN_SYMBOL, ">>")) return pointer_null;
                
                var _process = __Process();
                if (is_ptr(_process)) return pointer_null;
                
                array_push(_processArray, _process);
            }
            
            return method({
                __target:       __EnsureFunc(_target),
                __setValue:     __EnsureFunc(_setValue),
                __processArray: _processArray,
            },
            function()
            {
                __target();
                
                if (__setValue != undefined)
                {
                    FlowProgJump(0, __setValue());
                }
                
                var _array = __processArray;
                var _i = 0;
                repeat(array_length(_array))
                {
                    _array[_i]();
                    ++_i;
                }
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
            
            var _array = [__EnsureFunc(__Consume())];
            
            if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, "&"))
            {
                //Building a vector to tween
                
                do
                {
                    var _reference = __Reference();
                    if (is_ptr(_reference)) return pointer_null;
                    
                    array_push(_array, __EnsureFunc(_reference));
                }
                until(not __CheckAndConsume(__FLOW_TOKEN_SYMBOL, "&"));
                
                return method({
                    __array:  _array,
                    __length: array_length(_array),
                },
                function()
                {
                    var _array = array_create(__length, 0);
                    
                    var _i = 0;
                    repeat(__length)
                    {
                        _array[@ _i] = __array[_i]();
                        ++_i;
                    }
                    
                    FlowProgTargetVector(_array);
                });
            }
            else
            {
                if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, ","))
                {
                    //Building a list of parallel tracks to tween
                    do
                    {
                        var _reference = __Reference();
                        if (is_ptr(_reference)) return pointer_null;
                        
                        array_push(_array, __EnsureFunc(_reference));
                    }
                    until(not __CheckAndConsume(__FLOW_TOKEN_SYMBOL, ","));
                }
                
                return method({
                    __array:  _array,
                    __length: array_length(_array),
                },
                function()
                {
                    var _array = array_create(__length, 0);
                    
                    var _i = 0;
                    repeat(__length)
                    {
                        _array[@ _i] = __array[_i]();
                        ++_i;
                    }
                    
                    FlowProgTargetVars(_array);
                });
            }
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
            //Try to fit `+<multiExpression>` first
            if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, "+"))
            {
                var _approachSpeed = __MultiExpression();
                if (is_ptr(_approachSpeed)) return pointer_null;
            }
            else
            {
                var _approachSpeed = undefined;
                
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
            }
            
            //Now try to match `= <multiExpression>`
            if (not __CheckAndConsume(__FLOW_TOKEN_SYMBOL, "="))
            {
                return pointer_null;
            }
            
            var _target = __MultiExpression();
            if (is_ptr(_target)) return pointer_null;
            
            if (_approachSpeed != undefined)
            {
                return method({
                    __approachSpeed: __EnsureFunc(_approachSpeed),
                    __target:        __EnsureFunc(_target),
                },
                function()
                {
                    FlowProgApproach(__approachSpeed(), __target());
                });
            }
            else
            {
                return method({
                    __curve:    __EnsureFunc(_curve),
                    __duration: __EnsureFunc(_duration),
                    __target:   __EnsureFunc(_target),
                },
                function()
                {
                    FlowProgTween(__curve(), __duration(), __target());
                });
            }
        }
        
        // `<expression>fr`
        // `<expression>ms`
        static __Duration = function()
        {
            var _expression = __Expression();
            if (is_ptr(_expression)) return pointer_null;
            
            if (__CheckAndConsume(__FLOW_TOKEN_IDENTIFIER, "fr"))
            {
                return method({
                    __value: __EnsureFunc(_expression),
                },
                function()
                {
                    return __value();
                });
            }
            else if (__CheckAndConsume(__FLOW_TOKEN_IDENTIFIER, "ms"))
            {
                return method({
                    __value: __EnsureFunc(_expression),
                },
                function()
                {
                    return ceil(__value() / FLOW_TARGET_FRAME_TIME);
                });
            }
            else
            {
                return pointer_null;
            }
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
                if (is_ptr(_expression)) return pointer_null;
                
                array_push(_array, __EnsureFunc(_expression));
            }
            until(not __CheckAndConsume(__FLOW_TOKEN_SYMBOL, ","));
            
            return method({
                __array: _array,
                __length: array_length(_array),
            },
            function()
            {
                var _array = array_create(__length, 0);
                
                var _i = 0;
                repeat(__length)
                {
                    _array[@ _i] = __array[_i]();
                    ++_i;
                }
                
                return _array;
            });
        }
        
        static __Expression = function()
        {
            var _return = __AddSubtract();
            if (not is_ptr(_return)) return _return;
            
            return pointer_null;
        }
        
        //Addition and subtraction operators
        static __AddSubtract = function()
        {
            var _left = __MultiplyDivide();
            
            while(true)
            {
                if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, "-"))
                {
                    var _right = __MultiplyDivide(); //TODO - Filter out invalid datatypes
                    if (is_ptr(_right)) return pointer_null;
                    
                    return method({
                        __left:  __EnsureFunc(_left),
                        __right: __EnsureFunc(_right),
                    },
                    function()
                    {
                        return (__left() - __right());
                    });
                }
                else if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, "+"))
                {
                    var _right = __MultiplyDivide(); //TODO - Filter out invalid datatypes
                    if (is_ptr(_right)) return pointer_null;
                    
                    return method({
                        __left:  __EnsureFunc(_left),
                        __right: __EnsureFunc(_right),
                    },
                    function()
                    {
                        return (__left() + __right());
                    });
                }
                else
                {
                    break;
                }
            }
            
            return _left;
        }
        
        //Multiplication and division operators
        static __MultiplyDivide = function()
        {
            var _left = __NegateNegative();
            
            while(true)
            {
                if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, "/"))
                {
                    var _right = __NegateNegative(); //TODO - Filter out invalid datatypes
                    if (is_ptr(_right)) return pointer_null;
                    
                    return method({
                        __left:  __EnsureFunc(_left),
                        __right: __EnsureFunc(_right),
                    },
                    function()
                    {
                        return (__left() / __right());
                    });
                }
                else if (__CheckAndConsume(__FLOW_TOKEN_SYMBOL, "*"))
                {
                    var _right = __NegateNegative(); //TODO - Filter out invalid datatypes
                    if (is_ptr(_right)) return pointer_null;
                    
                    return method({
                        __left:  __EnsureFunc(_left),
                        __right: __EnsureFunc(_right),
                    },
                    function()
                    {
                        return (__left() * __right());
                    });
                }
                else
                {
                    break;
                }
            }
            
            return _left;
        }
        
        //Unary operators
        // `!x`
        // `-x`
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
            var _functionCall = __Function(false);
            if (not is_ptr(_functionCall)) return _functionCall;
            
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
                if (is_ptr(_number)) return pointer_null;
                
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
                    
                    var _paramArray = _executionContext.__paramArray;
                    
                    if (__paramIndex >= array_length(_paramArray))
                    {
                        __FlowError($"No parameter passed for index {__paramIndex}");
                    }
                    
                    return _paramArray[__paramIndex];
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
            
            var _function = __Function(false);
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
        
        // `function(<arguments>)`
        static __Function = function(_defer)
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
                
                //If we aren't followed by a close bracket then we must have some arguments
                if (not __CheckAndConsume(__FLOW_TOKEN_SYMBOL, ")"))
                {
                    do
                    {
                        var _expression = __Expression();
                        if (is_ptr(_expression)) return pointer_null;
                        
                        array_push(_argumentArray, _expression);
                    }
                    until(not __CheckAndConsume(__FLOW_TOKEN_SYMBOL, ","));
                    
                    if (not __CheckAndConsume(__FLOW_TOKEN_SYMBOL, ")"))
                    {
                        __FlowError("No matching closing ) for opening (");
                    }
                }
                
                if (_defer)
                {
                    return method({
                        __function:      _function,
                        __argumentArray: _argumentArray,
                        __argumentCount: array_length(_argumentArray),
                    },
                    function()
                    {
                        var _array = array_create(__argumentCount, 0);
                        
                        var _i = 0;
                        repeat(__argumentCount)
                        {
                            _array[@ _i] = __argumentArray[_i]();
                            ++_i;
                        }
                        
                        FlowProgExecute(__function, _array);
                    });
                }
                else
                {
                    return method({
                        __function:      _function,
                        __argumentArray: _argumentArray,
                        __argumentCount: array_length(_argumentArray),
                    },
                    function()
                    {
                        var _array = array_create(__argumentCount, 0);
                        
                        var _i = 0;
                        repeat(__argumentCount)
                        {
                            _array[@ _i] = __argumentArray[_i]();
                            ++_i;
                        }
                        
                        return method_call(__function, _array);
                    });
                }
            }
            
            return pointer_null;
        }
        
    })(_tokenArray)).__blockMethod;
}