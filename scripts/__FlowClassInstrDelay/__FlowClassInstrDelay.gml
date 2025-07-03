// Feather disable all

/// @param time

function __FlowClassInstrDelay(_time) constructor
{
    __time  = _time;
    __start = infinity;
    
    static __Start = function(_age)
    {
        __start = _age;
    }
    
    static __Update = function(_container, _age)
    {
        return (_age >= __start + __time)? __FLOW_RETURN_COMPLETE : __FLOW_RETURN_WAIT;
    }
}