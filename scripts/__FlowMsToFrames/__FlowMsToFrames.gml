// Feather disable all

/// @param milliseconds

function __FlowMsToFrames(_ms)
{
    return ceil(_ms / FLOW_TARGET_FRAME_TIME);
}