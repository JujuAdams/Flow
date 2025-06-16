// Feather disable all

/// @param variableOrArray
/// @param value

function __FlowBuildTo(_variableOrArray, _value)
{
    static _system = __FlowSystem();
    with(_system.__buildContext)
    {
        if (not is_array(_variableOrArray))
        {
            with(__EnsureVariable(_variableOrArray))
            {
                __value = _value;
            }
        }
        else
        {
            var _i = 0;
            repeat(array_length(_variableOrArray))
            {
                with(__EnsureVariable(_variableOrArray[_i]))
                {
                    __value = _value;
                }
                
                ++_i;
            }
        }
    }
}