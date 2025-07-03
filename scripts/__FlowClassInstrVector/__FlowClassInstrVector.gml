// Feather disable all

/// @param variableName

function __FlowClassInstrVector(_scope, _variableName) constructor
{
    __scope        = _scope;
    __variableName = _variableName;
    
    __start = undefined;
    
    __moment = 0;
    __momentArray = [];
    
    
    
    static __Start = function(_age)
    {
        __start = _age;
    }
    
    static __Update = function(_container, _age)
    {
        if (__moment >= array_length(__momentArray))
        {
            return __FLOW_RETURN_COMPLETE;
        }
        
        var _result = true;
        while(_result)
        {
            if (__moment >= array_length(__momentArray))
            {
                return __FLOW_RETURN_COMPLETE;
            }
            
            _result = __momentArray[__moment](__scope, __variableName, _age);
            if (_result)
            {
                __start = _age;
                ++__moment;
                
                if (__moment >= array_length(__momentArray))
                {
                    return __FLOW_RETURN_COMPLETE;
                }
                
                __momentArray[__moment].__startValue = __scope[$ __variableName];
            }
        }
        
        return __FLOW_RETURN_PENDING;
    }
    
    static __AddTween = function(_curve, _duration, _target)
    {
        if (_curve == undefined)
        {
            array_push(__momentArray, method({
                __startValue: undefined,
                __duration:   _duration,
                __target:     _target,
            },
            function(_scope, _variableName, _age)
            {
                return lerp(__startValue, __target, clamp(_age / __duration, 0, 1));
            }));
        }
        else
        {
            array_push(__momentArray, method({
                __startValue: undefined,
                __channel:    animcurve_get_channel(_curve, 0),
                __duration:   _duration,
                __target:     _target,
            },
            function(_scope, _variableName, _age)
            {
                return lerp(__startValue, __target, animcurve_channel_evaluate(__channel, clamp(_age / __duration, 0, 1)));
            }));
        }
    }
    
    static __AddApproach = function(_speed, _target)
    {
        array_push(__momentArray, method({
            __speed:  _speed,
            __target: _target,
        },
        function(_scope, _variableName, _age)
        {
            var _delta = __target - _scope[$ _variableName];
            _scope[$ _variableName] += clamp(_delta, -__speed, __speed);
            return (abs(_delta) <= __speed);
        }));
    }
    
    static __AddJump = function(_delay, _target)
    {
        array_push(__momentArray, method({
            __delay:  _delay,
            __target: _target,
        },
        function(_scope, _variableName, _age)
        {
            if (_age >= __delay)
            {
                _scope[$ _variableName] = __delay;
                return true;
            }
            
            return false;
        }));
    }
}