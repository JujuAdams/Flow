// Feather disable all

if (keyboard_check_pressed(vk_space))
{
    FlowGo("functionTest(%0%); time 20fr; functionTest(%1%)", [20, 30]);
}