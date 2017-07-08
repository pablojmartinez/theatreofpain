PLUGIN.name = "Show Bars"
PLUGIN.author = "Pablo J. Martínez"
PLUGIN.desc = "Allows to show the status bars using the key B."

if(CLIENT) then
local showingBars = false
    hook.Add( "Think", "ShowBars", function()
        if(input.IsKeyDown(KEY_B) and LocalPlayer():getNetVar("typing") == nil) then
            for i = 1, #nut.bar.list do
                local bar = nut.bar.list[i]
                bar.visible = true
            end
            showingBars = true
        elseif(showingBars == true) then
            for i = 1, #nut.bar.list do
                local bar = nut.bar.list[i]
                bar.visible = false
            end
            showingBars = false
        end
    end)
end