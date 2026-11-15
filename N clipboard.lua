
--[[
    N SCRIPTS | CLIPBOARD 1.0
    Windows XP Luna Blue
    Toggle: RightAlt
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local CONFIG = {
    ToggleKey = Enum.KeyCode.RightAlt,
    Width = 590,
    Height = 440,
    MaxHistory = 100
}

local History = {}
local Connections = {}
local Alive = true
local ScreenGui

local function connect(signal, callback)
    local c = signal:Connect(callback)
    table.insert(Connections, c)
    return c
end

local function clipboardGet()
    local fn = getclipboard or get_clipboard
    if not fn then return nil end

    local success, result = pcall(fn)
    if success and type(result) == "string" then
        return result
    end
    return nil
end

local function clipboardSet(value)
    local fn = setclipboard or toclipboard or set_clipboard
    if not fn then
        return false
    end

    return pcall(fn, value)
end

local function shutdown()
    if not Alive then return end
    Alive = false

    for _, c in ipairs(Connections) do
        pcall(function()
            c:Disconnect()
        end)
    end

    table.clear(Connections)

    if ScreenGui then
        ScreenGui:Destroy()
        ScreenGui = nil
    end
end

-- GUI

local Parent
pcall(function()
    if gethui then
        Parent = gethui()
    end
end)

Parent = Parent or game:GetService("CoreGui")

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NClipboard"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Parent

local Colors = {
    Blue = Color3.fromRGB(10, 83, 180),
    DarkBlue = Color3.fromRGB(0, 60, 140),
    LightBlue = Color3.fromRGB(236, 244, 255),
    White = Color3.fromRGB(255, 255, 255),
    Gray = Color3.fromRGB(225, 225, 225),
    Border = Color3.fromRGB(125, 125, 125),
    Text = Color3.fromRGB(25, 25, 25),
    Green = Color3.fromRGB(20, 125, 50),
    Red = Color3.fromRGB(180, 40, 40)
}

local function create(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function corner(obj, radius)
    create("UICorner", {
        CornerRadius = UDim.new(0, radius or 4)
    }, obj)
end

local function stroke(obj, color)
    create("UIStroke", {
        Color = color or Colors.Border,
        Thickness = 1
    }, obj)
end

local function button(parent, text, width, color)
    local b = create("TextButton", {
        Size = UDim2.new(0, width, 0, 27),
        BackgroundColor3 = color or Colors.Gray,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = Colors.Text,
        TextSize = 12,
        Font = Enum.Font.Arial,
        AutoButtonColor = true
    }, parent)

    corner(b, 3)
    stroke(b)
    return b
end

local Main = create("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(CONFIG.Width, CONFIG.Height),
    Position = UDim2.new(0.5, -CONFIG.Width/2, 0.5, -CONFIG.Height/2),
    BackgroundColor3 = Colors.LightBlue,
    BorderSizePixel = 0,
    Active = true
}, ScreenGui)

stroke(Main, Color3.fromRGB(60, 90, 150))

-- Title bar

local TitleBar = create("Frame", {
    Size = UDim2.new(1, -6, 0, 27),
    Position = UDim2.fromOffset(3, 3),
    BackgroundColor3 = Colors.Blue,
    BorderSizePixel = 0
}, Main)

local TitleGradient = create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 120, 220)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 50, 135))
    })
}, TitleBar)

local Title = create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(9, 0),
    Size = UDim2.new(1, -75, 1, 0),
    Text = "N Clipboard",
    TextColor3 = Colors.White,
    TextSize = 14,
    Font = Enum.Font.ArialBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, TitleBar)

local Close = create("TextButton", {
    Size = UDim2.fromOffset(21, 21),
    Position = UDim2.new(1, -24, 0, 3),
    BackgroundColor3 = Color3.fromRGB(205, 65, 65),
    Text = "X",
    TextColor3 = Colors.White,
    TextSize = 13,
    Font = Enum.Font.ArialBold,
    BorderSizePixel = 0
}, TitleBar)

corner(Close, 3)
stroke(Close, Color3.fromRGB(110, 30, 30))

-- Dragging

local dragging = false
local dragStart, startPos

connect(TitleBar.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

connect(UIS.InputChanged, function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

connect(UIS.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Header

local Header = create("TextLabel", {
    Position = UDim2.fromOffset(12, 38),
    Size = UDim2.new(1, -24, 0, 24),
    BackgroundTransparency = 1,
    Text = "Clipboard Manager",
    TextColor3 = Colors.Text,
    TextSize = 16,
    Font = Enum.Font.ArialBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, Main)

local Info = create("TextLabel", {
    Position = UDim2.fromOffset(12, 62),
    Size = UDim2.new(1, -24, 0, 18),
    BackgroundTransparency = 1,
    Text = "Manage your clipboard history.",
    TextColor3 = Color3.fromRGB(90, 90, 90),
    TextSize = 11,
    Font = Enum.Font.Arial,
    TextXAlignment = Enum.TextXAlignment.Left
}, Main)

-- Input

local Input = create("TextBox", {
    Position = UDim2.fromOffset(12, 88),
    Size = UDim2.new(1, -24, 0, 31),
    BackgroundColor3 = Colors.White,
    BorderSizePixel = 0,
    PlaceholderText = "Enter text to save...",
    PlaceholderColor3 = Color3.fromRGB(130, 130, 130),
    Text = "",
    TextColor3 = Colors.Text,
    TextSize = 12,
    Font = Enum.Font.Arial,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left
}, Main)

stroke(Input)

local AddButton = button(Main, "Add Text", 82)
AddButton.Position = UDim2.fromOffset(12, 127)

local ImportButton = button(Main, "Import Clipboard", 125)
ImportButton.Position = UDim2.fromOffset(102, 127)

local ClearButton = button(Main, "Clear History", 100)
ClearButton.Position = UDim2.new(1, -112, 0, 127)

-- Search

local Search = create("TextBox", {
    Position = UDim2.fromOffset(12, 164),
    Size = UDim2.new(1, -24, 0, 29),
    BackgroundColor3 = Colors.White,
    BorderSizePixel = 0,
    PlaceholderText = "Search history...",
    Text = "",
    TextColor3 = Colors.Text,
    TextSize = 12,
    Font = Enum.Font.Arial,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left
}, Main)

stroke(Search)

-- History container

local List = create("ScrollingFrame", {
    Position = UDim2.fromOffset(12, 202),
    Size = UDim2.new(1, -24, 1, -247),
    BackgroundColor3 = Colors.White,
    BorderSizePixel = 0,
    ScrollBarThickness = 6,
    ScrollBarImageColor3 = Colors.Blue,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y
}, Main)

stroke(List)

local Layout = create("UIListLayout", {
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder
}, List)

create("UIPadding", {
    PaddingTop = UDim.new(0, 6),
    PaddingBottom = UDim.new(0, 6),
    PaddingLeft = UDim.new(0, 6),
    PaddingRight = UDim.new(0, 6)
}, List)

local Count = create("TextLabel", {
    Position = UDim2.new(0, 12, 1, -35),
    Size = UDim2.new(1, -24, 0, 20),
    BackgroundTransparency = 1,
    Text = "0 items",
    TextColor3 = Color3.fromRGB(90, 90, 90),
    TextSize = 11,
    Font = Enum.Font.Arial,
    TextXAlignment = Enum.TextXAlignment.Left
}, Main)

-- History functions

local function addHistory(value)
    if type(value) ~= "string" or value == "" then
        return
    end

    -- Avoid duplicate consecutive entries
    if History[1] == value then
        return
    end

    table.insert(History, 1, value)

    while #History > CONFIG.MaxHistory do
        table.remove(History)
    end
end

local function refresh()
    for _, child in ipairs(List:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local query = Search.Text:lower()
    local visible = 0

    for index, value in ipairs(History) do
        if query == "" or value:lower():find(query, 1, true) then
            visible += 1

            local Row = create("Frame", {
                Size = UDim2.new(1, -2, 0, 58),
                BackgroundColor3 = Color3.fromRGB(244, 247, 252),
                BorderSizePixel = 0,
                LayoutOrder = index
            }, List)

            stroke(Row, Color3.fromRGB(205, 210, 220))

            local Preview = create("TextLabel", {
                Position = UDim2.fromOffset(8, 5),
                Size = UDim2.new(1, -145, 1, -10),
                BackgroundTransparency = 1,
                Text = value:gsub("\n", " "):sub(1, 110),
                TextColor3 = Colors.Text,
                TextSize = 11,
                Font = Enum.Font.Arial,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                TextWrapped = true
            }, Row)

            local Copy = button(Row, "Copy", 48, Color3.fromRGB(210, 230, 255))
            Copy.Position = UDim2.new(1, -105, 0.5, -13)

            local Delete = button(Row, "X", 30, Color3.fromRGB(255, 220, 220))
            Delete.Position = UDim2.new(1, -43, 0.5, -13)

            connect(Copy.MouseButton1Click, function()
                local success = clipboardSet(value)
                if success then
                    Info.Text = "Copied to clipboard!"
                    Info.TextColor3 = Colors.Green
                else
                    Info.Text = "Clipboard API unavailable."
                    Info.TextColor3 = Colors.Red
                end
            end)

            connect(Delete.MouseButton1Click, function()
                table.remove(History, index)
                refresh()
            end)
        end
    end

    Count.Text = #History .. " items | " .. visible .. " shown"
end

-- Buttons

connect(AddButton.MouseButton1Click, function()
    if Input.Text ~= "" then
        addHistory(Input.Text)
        Input.Text = ""
        Info.Text = "Text added to history."
        Info.TextColor3 = Colors.Green
        refresh()
    end
end)

connect(ImportButton.MouseButton1Click, function()
    local value = clipboardGet()

    if value and value ~= "" then
        addHistory(value)
        Info.Text = "Clipboard imported!"
        Info.TextColor3 = Colors.Green
        refresh()
    else
        Info.Text = "Could not read clipboard."
        Info.TextColor3 = Colors.Red
    end
end)

connect(ClearButton.MouseButton1Click, function()
    table.clear(History)
    Info.Text = "History cleared."
    Info.TextColor3 = Colors.Red
    refresh()
end)

connect(Search:GetPropertyChangedSignal("Text"), refresh)

connect(Input.FocusLost, function(enterPressed)
    if enterPressed and Input.Text ~= "" then
        addHistory(Input.Text)
        Input.Text = ""
        refresh()
    end
end)

connect(Close.MouseButton1Click, shutdown)

-- Keyboard

connect(UIS.InputBegan, function(input, processed)
    if processed then return end

    if input.KeyCode == CONFIG.ToggleKey then
        Main.Visible = not Main.Visible
    end
end)

-- Footer

local Footer = create("TextLabel", {
    Position = UDim2.new(1, -170, 1, -35),
    Size = UDim2.fromOffset(158, 20),
    BackgroundTransparency = 1,
    Text = "N Scripts | Clipboard 1.0",
    TextColor3 = Color3.fromRGB(100, 100, 100),
    TextSize = 10,
    Font = Enum.Font.Arial,
    TextXAlignment = Enum.TextXAlignment.Right
}, Main)

refresh()

-- Initial clipboard import
local initial = clipboardGet()
if initial and initial ~= "" then
    addHistory(initial)
    refresh()
end

-- Destroy GUI shortcut through button
local Destroy = button(Main, "Destroy GUI", 90, Color3.fromRGB(255, 220, 220))
Destroy.Position = UDim2.new(1, -112, 1, -62)

connect(Destroy.MouseButton1Click, shutdown)
