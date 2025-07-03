// Feather disable all

/// @param scope

function __FlowClass(_scope) constructor
{
    static _system      = __FlowSystem();
    static _updateArray = _system.__updateArray;
    
    array_push(_updateArray, self);
    
    __scope = _scope;
    __age   = 0;
    __pause = false;
    __state = FLOW_PENDING;
    
    
    
    static __Update = function()
    {
        if (not __FlowScopeExists(__scope)) return true;
        if (__pause) return false;
        
        __age++;
        
        return false;
    }
    
    static __Skip = function()
    {
        //TODO - Set final values
        
        __state = FLOW_FINISHED;
        __scope = undefined;
    }
    
    static __Halt = function()
    {
        __state = FLOW_FINISHED;
        __scope = undefined;
    }
    
    static __BuildEnd = function()
    {
        
    }
}