// Feather disable all

/// @param function
/// @param argumentArray

function __FlowClassInstrFunction(_function, _argumentArray) constructor
{
    __function      = _function;
    __argumentArray = _argumentArray;
    
    
    
    static __Start = function(_age)
    {
        //Do nothing
    }
    
    static __Update = function(_container, _age)
    {
        method_call(__function, __argumentArray);
        return __FLOW_RETURN_COMPLETE;
    }
}