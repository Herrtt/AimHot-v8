--[[
	UI Lib by Herrtt,
	
	This is an actual mess at this point
--]]

local userinput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local newtweeninfo = TweenInfo.new
local mouse = game:GetService("Players").LocalPlayer:GetMouse()
 

local connections = {}
local function bindEvent(event, callback) -- Let me disconnect in peace
    local con = event:Connect(callback)
    table.insert(connections, con)
    return con
end 

local function tween(obj, properties, time, callback)
    local tween = TweenService:Create(obj, newtweeninfo(time), properties)
    if callback then pcall(function() tween.Completed:Connect(callback) end) end
    return tween:Play()
end
 
 
local function floor(n,c)
    return c * math.floor((n + c/2) / c)
end
 

local tweenstuff = {
    Enum.EasingDirection.Out,
    Enum.EasingStyle.Sine,
    .1,
    true,
}

 
local drag = {enabled = true}
do
    local renderstepped = game:GetService("RunService").RenderStepped
    local userinput = game:GetService("UserInputService")
   
    local dragging = false
    local mousedown = false
   
    function drag:add(frame)
       
        bindEvent(frame.InputBegan, function(key)
            if dragging then return end
            if key.UserInputType == Enum.UserInputType.MouseButton1 then
                mousedown = true
                dragging = true
                local offset = Vector2.new(mouse.X - frame.AbsolutePosition.X, mouse.Y - frame.AbsolutePosition.Y)
                while mousedown and drag.enabled do
                    local size = frame.Size
                    local anchorpoint = frame.AnchorPoint
                    local x =  mouse.X - offset.X + (size.X.Offset * anchorpoint.X)
                    local y = mouse.Y - offset.Y + (size.Y.Offset * anchorpoint.Y)
                    frame:TweenPosition(UDim2.new(0, x, 0, y), unpack(tweenstuff))
                    renderstepped:Wait()
                end
                dragging = false
            end
        end)
 
    end
   
    bindEvent(userinput.InputEnded, function(key)
        if key.UserInputType == Enum.UserInputType.MouseButton1 then
            mousedown = false
        end
    end)
 
end
 
 
--[[local Looks = { -- : TODO
    TextColor = Color3.new(1,1,1),
   
    Label = Color3.fromRGB(17, 17, 17),
    Toggle = Color3.fromRGB(17, 17, 17),
    Button = Color3.fromRGB(14, 14, 14) ,
   
    Rotate = Color3.fromRGB(17, 17, 17),
    Slider = Color3.fromRGB(17, 17, 17),
    Keybind = Color3.fromRGB(17,17,17),
    ColorPicker = Color3.fromRGB(17,17,17),
   
 
    Tab = Color3.fromRGB(20, 20, 20),
    Category = Color3.fromRGB(14, 14, 14),
    ToggleCategory = Color3.fromRGB(14, 14, 14),
}--]]
 
local ui = (script.Parent and script.Parent:FindFirstChild("ui")) or game:GetObjects("rbxassetid://4901175458")[1]
if not ui then return end

local parent
xpcall(function()
	parent = game:GetService("CoreGui")
	ui.Parent = parent
end, function()
	parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	ui.Parent = parent
end)

local templatesObj = ui:WaitForChild("Templates"):Clone()
ui:WaitForChild("Templates"):Destroy()
 
local templates = {
    Tab = templatesObj:WaitForChild("Tab");
    Toggle = templatesObj:WaitForChild("Toggle");
    Button = templatesObj:WaitForChild("Button");
    Keybind = templatesObj:WaitForChild("Keybind");
    Category = templatesObj:WaitForChild("Category");
    Label = templatesObj:WaitForChild("Label");
    Rotate = templatesObj:WaitForChild("Rotate");
    Slider = templatesObj:WaitForChild("Slider");
    ToggleCategory = templatesObj:WaitForChild("ToggleCategory");
}

local holder = ui:WaitForChild("Main")
 
local lib = {
	Object = ui,
    Container = holder,
    Existing = {},
    Visible = true,
    AwaitingKey = false,
	Keybind = "RightAlt"
}
 
function lib:End()
	for i,v in pairs(connections) do
		pcall(function()
			v:Disconnect()
		end)
		connections[i] = nil
	end
	connections = nil
	ui:Destroy()
	ui = nil
	lib = nil
end


 
local function openanimation(button, state)
    tween(button, {
        Rotation = state and 180 or 0
    }, .2)
    button.Text = state and "-" or "+"
end
 

local green = Color3.fromRGB(20, 255, 101)
local red = Color3.fromRGB(255, 146, 193)
local grey = Color3.fromRGB(192,192,192)
local white = Color3.fromRGB(255,250,250)

local function toggleanimation(button, state)
    button.Text = state and "on" or "off"
    tween(button, {
        TextColor3 = state and green or red,
    }, .2)
end
 
local function mouseanimation(button, state)
    tween(button, {--232,233,235, 220,220,220, 211,211,211
        TextColor3 = state and grey or white,
    }, .2)
end
 
local function hovereffect(button)
    bindEvent(button.MouseEnter, function()
        if lib.AwaitingKey then return end
        mouseanimation(button, true)
    end)
   	bindEvent(button.MouseLeave, function()
        if lib.AwaitingKey then return end
        mouseanimation(button, false)
    end)
end
 
local n = 0
function lib:AddTab(options)
    if (typeof(options) ~= "table") then
        return -- error()
    end
    setmetatable(options, {
        __index = function(Tab, Index)
            return
        end;
    })
 
    local self = {
        Type = "Tab",
        Open = options.Open or false,
        Visible = lib.Visible,
        Text = options.Text,
    }
    setmetatable(self, {
        __index = function(_, index)
            return lib[index]
        end;
    })
   
    self.Object = templates.Tab:Clone()
    self.Container = self.Object:WaitForChild("Container")
   
    local Open = self.Object:WaitForChild("Open")
    local TextObj = self.Object:WaitForChild("Body")
    local ListLayout = self.Container:WaitForChild("UIListLayout")
   
    TextObj.Text = self.Text:lower()
    self.Object.Parent = lib.Container
   
   
    bindEvent(ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        if self.Open then
            local Size = self.Container.Size
            local YSize = ListLayout.AbsoluteContentSize.Y
            self.Container.Size = UDim2.new(Size.X.Scale, Size.X.Offset, Size.Y.Scale, YSize == 0 and 10 or YSize)
        end
    end)
   
   
    local xpos = ((#lib.Container:GetChildren() - 1) * (self.Object.Size.X.Offset + 25)) + 50
    local ypos = 50
    local mypos = UDim2.new(0, xpos, 0, ypos)
    local tweening = false
    local function update()
 
        if self.Visible then
            tweening = true
            self.Object:TweenPosition(mypos,   
                Enum.EasingDirection.InOut,
                Enum.EasingStyle.Quad,
                .2,
                true,
                function(state)
                    if state == Enum.TweenStatus.Completed then
                        tweening = false
                    end
                end
            )
        else
            tweening = true
            self.Object:TweenPosition(UDim2.new(0,0,-1, -self.Container.Size.Y.Offset),    
                Enum.EasingDirection.InOut,
                Enum.EasingStyle.Quad,
                .2,
                true,
                function(state)
                    if state == Enum.TweenStatus.Completed then
                        tweening = false
                    end
                end
            )
        end
 
        if self.Open then
            local Size = self.Container.Size
            local YSize = ListLayout.AbsoluteContentSize.Y
            self.Container:TweenSize(UDim2.new(Size.X.Scale, Size.X.Offset, 0, YSize == 0 and 10 or YSize), unpack(tweenstuff))
        else
            local Size = self.Container.Size
            self.Container:TweenSize(UDim2.new(Size.X.Scale, Size.X.Offset, 0, 0), unpack(tweenstuff))
        end
    end
   
    bindEvent(Open.MouseButton1Click, function()
        if lib.AwaitingKey then return end
        self.Open = not self.Open
 
        openanimation(Open, self.Open)
        if self.Open then
            local Size = self.Container.Size
            local YSize = ListLayout.AbsoluteContentSize.Y
            self.Container:TweenSize(UDim2.new(Size.X.Scale, Size.X.Offset, Size.Y.Scale, YSize == 0 and 10 or YSize), unpack(tweenstuff))
        else
            local Size = self.Container.Size
            self.Container:TweenSize(UDim2.new(Size.X.Scale, Size.X.Offset, 0, 0), unpack(tweenstuff))
        end
    end)
    hovereffect(Open)
   
   
    function self:show()
        if self.Visible then
            return
        end
        self.Visible = true
        update()
    end
    function self:hide()
        if not self.Visible then
            return
        end
        self.Visible = false
        update()
    end
   
    bindEvent(self.Object:GetPropertyChangedSignal("Position"), function()
        if self.Visible and not tweening and drag.enabled then
            mypos = self.Object.Position   
        end
    end)
   
   
    update()
    table.insert(lib.Existing, self)
 
 
    drag:add(self.Object)
   
    return self
end
 
 
 
function lib:AddToggle(options, callback)
    if (self.Type ~= "Tab") and (self.Type ~= "Category") then
        return
    end
   
    local obj = templates.Toggle:Clone()
    n = n + 1
    obj.LayoutOrder = n
   
    local Button = obj:WaitForChild("Button")
    local Body = obj:WaitForChild("Body")
    local state = options.State or false
   
    Body.Text = options.Text:lower()
   
    bindEvent(Button.MouseButton1Click, function()
        if lib.AwaitingKey then return end     
        state = not state
        toggleanimation(Button, state)
        if callback then
            callback(state)
        end
    end)
   
    obj.Parent = self.Container
 
    toggleanimation(Button, state)
    return obj
end
 
function lib:AddLabel(options)
    if (self.Type ~= "Tab") and (self.Type ~= "Category") then
        return
    end
   
    local obj = templates.Label:Clone()
    obj.Body.Text = options.Text:lower()
    obj.Parent = self.Container
   
    return obj
end
 
function lib:AddButton(options, callback)
    if (self.Type ~= "Tab") and (self.Type ~= "Category") then
        return
    end
   
    local obj = templates.Button:Clone()
    obj.Button.Text = options.Text:lower()
    obj.Parent = self.Container
   
    n = n + 1
    obj.LayoutOrder = n
   
    bindEvent(obj.Button.MouseButton1Click, function()
        if lib.AwaitingKey then return end
        callback()
    end)
   
    hovereffect(obj.Button)
   
    return obj
end
 
function lib:AddKeybind(options, callback)
    if (self.Type ~= "Tab") and (self.Type ~= "Category") then
        return
    end
   
    local obj = templates.Keybind:Clone()
    obj.Body.Text = options.Text:lower()
    obj.Parent = self.Container
 
   
    n = n + 1
    obj.LayoutOrder = n
   
    local last = options.Current
    local function update(key)
        last = key
        tween(obj.Button, {
            TextColor3 = obj.BackgroundColor3,
        }, .1, function(a)
            if a == Enum.PlaybackState.Completed then
                obj.Button.Text = typeof(key) == "string" and key:lower() or key.Name:lower()
                mouseanimation(obj.Button, false)
            end        
        end)
    end
   
   
    local con
    local function disconnect()
        if con then
            con:Disconnect()
            con = nil
        end
    end
 
	local w = false
    bindEvent(obj.Button.MouseButton1Click, function()
        if lib.AwaitingKey or w then return end
        lib.AwaitingKey = true
       	w = true

        disconnect()
		obj.Button.Text = "..."
        mouseanimation(obj.Button, true)
		wait()
        con = userinput.InputBegan:Connect(function(key)
            local keyc = key.KeyCode == Enum.KeyCode.Unknown and key.UserInputType or key.KeyCode
            if keyc.Name ~= "Focus" and keyc.Name ~= "MouseMovement" and keyc.Name ~= "Focus" and keyc.Name ~= lib.Keybind then
 
                disconnect()
				
                lib.AwaitingKey = false
				wait()
				update(keyc)
				wait()
				w = false
				
                if callback then
                    callback(keyc)
                end
            --[[elseif keyc.Name == "Focus" then
                update(last)
                disconnect()
                lib.AwaitingKey = false
				wait()
				w = false--]]    
            end
        end)
    end)
   
   
    hovereffect(obj.Button)
       
       
    update(options.Current)
    return obj
end
 
 
 
 
function lib:AddRotate(options, whitelist, callback)
    if (self.Type ~= "Tab") and (self.Type ~= "Category") then
        return
    end
   
    local Values = whitelist
    if #Values == 0 then
        Values[1] = "empty"
    end
   
    local obj = templates.Rotate:Clone()
    obj.Body.Text = options.Text:lower()
    obj.Parent = self.Container
   
    n = n + 1
    obj.LayoutOrder = n
   
    local l = obj.Option.L
    local r = obj.Option.R
   
   
    local current = options.Current or 1
    obj.Option.Text = tostring(Values[current]):lower()
   
    local function change(v)
        current = current + v
        current = (current - 1) % (#Values) + 1
       
       
        local new = Values[current]
       
        if callback then callback(new) end
        tween(obj.Option, {
            TextColor3 = obj.BackgroundColor3,
        }, .1, function(a)
            if a == Enum.PlaybackState.Completed then
                obj.Option.Text = tostring(new):lower()
                mouseanimation(obj.Option, false)
            end
        end)
    end
    bindEvent(l.MouseButton1Click, function()
        if lib.AwaitingKey then return end
        change(-1)
    end)
    bindEvent(r.MouseButton1Click, function()
        if lib.AwaitingKey then return end
        change(1)
    end)
   
    hovereffect(l)
    hovereffect(r)
   
   
    return obj
end
 
 
function lib:AddSlider(options, range, callback)
    if (self.Type ~= "Tab") and (self.Type ~= "Category") then
        return -- error("Invalid type :(")
    end
   
    local a,b,c = range[1],range[2],range[3] or 1
    range = b - a
    local currentvalue = a
   
    local obj = templates.Slider:Clone()
    obj.Body.Text = (options.Text .. (" %s-%s"):format(a,b)):lower()
    obj.Parent = self.Container
   
    n = n + 1
    obj.LayoutOrder = n
   
    local back = obj.Back
    local front = back.Front
    local value = obj.Value
 
    local last = options.Current or a
   
   
    local function update(a1)
        local percent
        if not a1 then
            percent = math.clamp((mouse.X - back.AbsolutePosition.X) / back.AbsoluteSize.X, 0, 1)
        else
            percent = math.clamp((a1 - a) / (b - a), 0, 1)
        end
       
        local num = (a + (b - a) * percent)
        num = floor(num, c)
       
        value.Text = num
        value.PlaceholderText = num
 
        front:TweenSize(UDim2.new(percent, 0, front.Size.Y.Scale, front.Size.Y.Offset), unpack(tweenstuff))
       
        if callback and num ~= last then
            callback(num)
        end
        last = num
    end
   
	mouseanimation(value)
    bindEvent(value.FocusLost, function()
        local num = tonumber(value.Text)
        if not num then
            num = last
        end
   
        num = math.clamp(num, a, b)
		--update(num)

        local percent = math.clamp((num - a) / (b - a), 0, 1)
        num = (a + (b - a) * percent)
        num = floor(num, c)

        front:TweenSize(UDim2.new(percent, 0, front.Size.Y.Scale, front.Size.Y.Offset), unpack(tweenstuff) )
        value.Text = num
        value.PlaceholderText = num
       
       
        if callback and num ~= last then
            callback(num)
        end
        last = num
    end)
   
   
    local con0,con1,con2,con3
 
    local dragging = false
    local mousein = false
    local function disconnect()
        dragging = false
        if con0 then
            con0:Disconnect()
            con0 = nil
        end
        if con1 then
            con1:Disconnect()
            con1 = nil
        end
        if con2 then
            con2:Disconnect()
            con2 = nil
        end
        if con3 then
            con3:Disconnect()
            con3 = nil
        end
    end
   
    local function connect()
        if con3 then
            con3:Disconnect()
        end
        dragging = true
        con3 = userinput.InputChanged:Connect(function(key,gpe)
            if lib.AwaitingKey then return end
            if key.UserInputType == Enum.UserInputType.MouseMovement then
                update()
            end
        end)
    end
   
    bindEvent(back.MouseEnter, function()
 
        mousein = true
        if con0 then
            con0:Disconnect()
        end
        con0 = back.InputBegan:Connect(function(key, gpe)
            if lib.AwaitingKey then return end
            if key.UserInputType == Enum.UserInputType.MouseButton1 then
                update()
                connect()
            end
        end)
        if con1 then
            con1:Disconnect()
        end
        con1 = userinput.InputEnded:Connect(function(key, gpe)
            if key.UserInputType == Enum.UserInputType.MouseButton1 then
 
                if not mousein then
                    disconnect()
                elseif con3 then
                    con3:Disconnect()
                end
                dragging = false
            end
        end)
       
        if con2 then
            con2:Disconnect()
        end
        con2 = back.MouseLeave:Connect(function()
            mousein = false
            if not dragging then
                disconnect()
            end
        end)
    end)
   
   
    update(last)
    return obj
end
 
 
function lib:AddCategory(options)
    if (self.Type ~= "Tab") then
        return
    end
   
    local me = {
        Type = "Category",
        Open = options.Open or false,
        Text = options.Text,
    }
    setmetatable(me, {
        __index = function(_, index)
            return lib[index]
        end;
    })
   
    me.Object = templates.Category:Clone()
    me.Container = me.Object
   
    n = n + 1
    me.Object.LayoutOrder = n
   
    local Top = me.Object:WaitForChild("Top")
    local Open = Top:WaitForChild("Open")
    local TextObj = Top:WaitForChild("Body")
    local ListLayout = me.Container:WaitForChild("UIListLayout")
   
    TextObj.Text = me.Text:lower()
    me.Object.Parent = self.Container
   
    bindEvent(ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        if me.Open then
            local Size = me.Container.Size
            local YSize = ListLayout.AbsoluteContentSize.Y
            me.Container:TweenSize(UDim2.new(Size.X.Scale, Size.X.Offset, Size.Y.Scale, YSize), unpack(tweenstuff))
        end
    end)
   
    local function update()
        openanimation(Open, me.Open)
        if me.Open then
            local Size = me.Container.Size
            local YSize = ListLayout.AbsoluteContentSize.Y
            me.Container:TweenSize(UDim2.new(Size.X.Scale, Size.X.Offset, 0, YSize == Top.Size.Y.Offset and YSize + 10 or YSize), unpack(tweenstuff))
        else
            local Size = me.Container.Size
            me.Container:TweenSize(UDim2.new(Size.X.Scale, Size.X.Offset, Top.Size.Y.Scale, Top.Size.Y.Offset), unpack(tweenstuff))
        end
    end
    bindEvent(Open.MouseButton1Click, function()
        if lib.AwaitingKey then return end
        me.Open = not me.Open
        update()
    end)
    hovereffect(Open)
   
    update()
    return me
end
 
 
function lib:AddToggleCategory(options, callback)
    if (self.Type ~= "Tab") then
        return
    end
   
    local me = {
        Type = "Category",
        Open = options.Open or false,
        Text = options.Text,
    }
    setmetatable(me, {
        __index = function(_, index)
            return lib[index]
        end;
    })
   
    me.Object = templates.ToggleCategory:Clone()
    me.Container = me.Object
   
    n = n + 1
    me.Object.LayoutOrder = n
   
    local Top = me.Object:WaitForChild("Top")
    local Open = Top:WaitForChild("Open")
    local Button = Top:WaitForChild("Button")
    local ListLayout = me.Container:WaitForChild("UIListLayout")
   
    Button.Text = tostring(me.Text):lower()
    me.Object.Parent = self.Container
   
    bindEvent(ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        if me.Open then
            local Size = me.Container.Size
            local YSize = ListLayout.AbsoluteContentSize.Y
            me.Container:TweenSize(UDim2.new(Size.X.Scale, Size.X.Offset, Size.Y.Scale, YSize), unpack(tweenstuff))
        end
    end)
   
    local function update()
        openanimation(Open, me.Open)
        if me.Open then
            local Size = me.Container.Size
            local YSize = ListLayout.AbsoluteContentSize.Y
            me.Container:TweenSize(UDim2.new(Size.X.Scale, Size.X.Offset, 0, YSize == Top.Size.Y.Offset and YSize + 10 or YSize), unpack(tweenstuff))
        else
            local Size = me.Container.Size
            me.Container:TweenSize(UDim2.new(Size.X.Scale, Size.X.Offset, Top.Size.Y.Scale, Top.Size.Y.Offset), unpack(tweenstuff))
        end
    end
    bindEvent(Open.MouseButton1Click, function()
        if lib.AwaitingKey then return end
        me.Open = not me.Open
        update()
    end)
    hovereffect(Open)
   
    local state = options.State or false
    local function update2()
        tween(Button, {
            TextColor3 = state and green or red,
        }, .3)
       
    end
    bindEvent(Button.MouseButton1Click, function()
        if lib.AwaitingKey then return end
        state = not state
        update2()
        if callback then
            callback(state)
        end
    end)
       
       
    bindEvent(ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        if me.Open then
            local Size = me.Container.Size
            local YSize = ListLayout.AbsoluteContentSize.Y
            me.Container:TweenSize(UDim2.new(Size.X.Scale, Size.X.Offset, Size.Y.Scale, YSize), unpack(tweenstuff))
        end
    end)
   
    update2()
    update()
    return me
end


local function update()
	for i,v in pairs(lib.Existing) do
	    if lib.Visible then
	        v:show()
	    else
	        v:hide()
	    end
	end
end
function lib:show()
	lib.Visible = true
	drag.enabled = lib.Visible
	update()
end

function lib:hide()
	lib.Visible = false
	drag.enabled = lib.Visible
	update()
end

bindEvent(userinput.InputBegan, function(key, gpe)
    if gpe then return end
	if lib.AwaitingKey then return end
	
	if key.KeyCode.Name == lib.Keybind then
		lib.Visible = not lib.Visible
		if lib.Visible then
			lib:show()
		else
			lib:hide()
		end
    end
end)

return { lib }