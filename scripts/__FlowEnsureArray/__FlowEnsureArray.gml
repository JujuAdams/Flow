// Feather disable all

/// @param value

function __FlowEnsureArray(_value)
{
    return is_array(_value)? _value : [_value];
}