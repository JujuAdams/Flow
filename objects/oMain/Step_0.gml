// Feather disable all

if (keyboard_check_pressed(vk_space))
{
    FlowGo(@"
    dx = 0
    dy = functionTest()
    time 100
    dx = %0%
    dy = 0
    ");
    
    //FlowGo(@"
    //dx,dy = 0
    //dx,dy curve linear
    //functionTest()
    //time 10
    //dx,dy = 200
    //dx,dy curve acTest
    //time 40
    //time 60
    //dx,dy = 0");
}