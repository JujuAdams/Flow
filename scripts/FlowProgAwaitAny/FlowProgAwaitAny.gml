// Feather disable all

/// N.B. This function is available to manually build programs using individual instructions. You
///      probably don't want to build programs manually. Instead, you should use `FlowGo()` or
///      `FlowCompile()`.
/// 
/// Tells Flow to wait at this instruction until any tween has finished. This function will only
/// consider tweens created since the last `await` instruction (or the start of the program).

function FlowProgAwaitAny()
{
    static _system = __FlowSystem();
    
    if (__FLOW_DEBUG_PROGRAM_BUILDER)
    {
        show_debug_message("FlowProgAwaitAny()");
    }
}