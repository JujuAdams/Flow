// Feather disable all

/// @param time

function __FlowClassInstrDelay(_time) constructor
{
    __time  = _time;
    __start = undefined;
    
    static __Update = function(_container, _age)
    {
        __start ??= _age;
        
        return (_age >= __start + __time)? __FLOW_RETURN_COMPLETE : __FLOW_RETURN_WAIT;
    }
}