// Feather disable all

if (keyboard_check_pressed(vk_space))
{
    FlowGo(@"
    dx,dy = 200  >>  acTest 120fr = 0,100  >>  linear 100ms = 0
    await
    delay 30fr
    functionTest()
    ");
}