// Feather disable all

/// @param variableOrArray
/// @param value

function __FlowBuildCurve(_variableOrArray, _value)
{
    static _system = __FlowSystem();
    with(_system.__buildContext)
    {
        if (not is_array(_variableOrArray))
        {
            with(__EnsureVariable(_variableOrArray))
            {
                __curve = _value;
            }
        }
        else
        {
            var _i = 0;
            repeat(array_length(_variableOrArray))
            {
                with(__EnsureVariable(_variableOrArray[_i]))
                {
                    __curve = _value;
                }
                
                ++_i;
            }
        }
    }
}