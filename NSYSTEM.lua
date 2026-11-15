--==================================================
--   N SYSTEM  |  Admin Panel + Aimbot + ESP
--   100% LocalScript (StarterPlayerScripts)
--==================================================

local P   = game:GetService("Players")
local U   = game:GetService("UserInputService")
local R   = game:GetService("RunService")
local T   = game:GetService("TweenService")
local L   = game:GetService("Lighting")
local TS  = game:GetService("TeleportService")
local VU  = game:GetService("VirtualUser")
local St  = game:GetService("Stats")
local TCS = game:GetService("TextChatService")
local HS  = game:GetService("HttpService")
local RS  = game:GetService("ReplicatedStorage")
local CAS = game:GetService("ContextActionService")

local LP  = P.LocalPlayer
local Cam = workspace.CurrentCamera

--==================== CONFIG DO DONO ====================
-- Só quem edita este arquivo muda isso. Nada deste bloco é editável pela UI.
local OWNER = {
    System = {
        Name        = "N SYSTEM",             -- nome mostrado na barra e na tela de key
        Version     = "V2",                   -- versão mostrada na barra e nas configurações
        Creator     = "Nunk",                 -- mostrado em Configurações > Geral
        PanelKey    = Enum.KeyCode.Home,      -- tecla que abre/fecha o painel (pode remapear depois pela UI)
        PanicKey    = nil,                    -- tecla padrão do botão de pânico; nil = sem tecla, defina pela aba KEYBINDS
        DefaultTheme = "Roxo",                -- um dos nomes em Presets (ver mais abaixo)
        DefaultSize  = "M",                   -- "S", "M" ou "L" (ver CFG.Sizes)
    },

    KeySystem = {
        Enabled       = true,                 -- false = painel abre direto, sem pedir key
        CaseSensitive = true,
        MaxAttempts   = 3,                    -- tentativas erradas antes de bloquear/kickar
        KickOnFail    = true,                 -- true = kicka ao estourar tentativas
        KickMessage   = "Muitas tentativas de key.",
        Title         = "N SYSTEM",
        Subtitle      = "Digite sua key para continuar",
        GetKeyLink    = "https://discord.gg/d58HVqzCEM", -- "" = sem botão de copiar link

        -- Cada key agora é uma tabela, não só um texto:
        --   Key      = o texto da key (obrigatório)
        --   Level    = "normal" ou "admin"
        --   Expires  = nil (permanente) ou um timestamp Unix (DateTime.Now().UnixTimestamp + segundos)
        --   Nicks    = (só faz sentido em keys "admin") lista de nicks/UserIds liberados a usar
        --              essa key específica; lista vazia ou ausente = qualquer um com a key certa
        Keys = {
            {Key = "NS-6LRc-8bfm-3Mey-UgqE", Level = "normal", Expires = nil},
            {Key = "NS-ADM1-6dMQ-k7X3-Lzgr", Level = "admin",  Expires = nil, Nicks = {}},
        },

        NormalHiddenTabs = {"SCRIPTS"}, -- abas que quem usa key NORMAL não vê (admin sempre vê tudo)
    },

    -- Blacklist: nick ou UserId (número ou texto) nunca consegue nem ver a tela de key.
    -- Whitelist: nick ou UserId entra DIRETO, sem pedir key, com o nível indicado.
    Access = {
        Blacklist = { -- {Who = "nick ou userid", Reason = "opcional"}
            -- {Who = "JogadorChato123"},
        },
        Whitelist = { -- {Who = "nick ou userid", Level = "admin" ou "normal"}
            -- {Who = "SeuAmigo", Level = "admin"},
        },
    },

    -- Presets de skybox: cada um precisa do ID de uma IMAGE (não Decal) do Roblox.
    -- Para achar um: Creator Store > Images > procure "skybox" > abra o asset >
    -- copie o número da URL. Cole aqui como Id = 123456 (só o número já funciona).
    -- O mesmo ID é usado nas 6 faces (igual o botão manual da aba VISUAL já fazia).
    SkyboxPresets = {
        -- {Name = "Nome do preset", Id = 123456789},
    },

    Credits = {
        Discord = "https://discord.gg/d58HVqzCEM",
        People = {
            {Name = "Nunk", Role = "Criador"},
        },
    },

    Executor = {
        Enabled = true,                                -- false = aba SCRIPTS não aparece
        Scripts = {
            -- Url     = baixa e executa via loadstring(game:HttpGet(url))
            -- Code    = executa o texto direto
            -- AutoRun = true executa sozinho quando o painel carrega
            {Name = "Infinite Yield", Url = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"},
            {Name = "XVC HUB",        Url = "https://pastebin.com/raw/Piw5bqGq"},
            {Name = "N Player Info",  Url = "https://raw.githubusercontent.com/nEsseltialsByNoel/script/refs/heads/main/N%20player%20inspector.lua"},
            {Name = "N Clipboard",    Url = "https://raw.githubusercontent.com/nEsseltialsByNoel/script/refs/heads/main/N%20clipboard.lua"},
            {Name = "UGC Emotes",     Url = "https://haxhell.com/api/raw/universal-script-emoteanimation-script-ugc"},
            {Name = "Voadora(Lag Danger)",  Url = "https://scriptblox.com/raw/Universal-Script-Fe-dropkick-(kickgui)-r15-229511"},
            {Name = "Hitbox Expander",      Url = "https://pastefy.app/G0km0LOW/raw"},
        },
    },
}

--==================== CONFIG / TEMA ====================
local CFG = {
    FlySpd = 55, FlyVSpd = 55, FlyMode = "Câmera", FollowD = 5, SpinSpd = 12, ScaryDur = 1.5,
    OrbitR = 8, OrbitSpd = 2, ScaryDelay = 3, FreecamSpd = 60, ZoomMax = 100000, XrayRad = 50, XrayInt = 0.4,
    SprintSpd = 28, ClimbSpd = 28, MaxFall = 60, NoclipMode = "Paredes", NoclipExtra = 0, SpamDelay = 3,
    FlingPower = 9000, FlingSpin = 1200,
    Sizes = { S = Vector2.new(560, 360), M = Vector2.new(780, 460), L = Vector2.new(960, 580) },
}
local BAR = 46

local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
local Theme = {
    Main = rgb(14, 10, 20), Element = rgb(38, 24, 56), Accent = rgb(145, 65, 220),
    Text = rgb(245, 235, 255), Sub = rgb(165, 150, 180),
    Good = rgb(61, 220, 151), Bad = rgb(220, 61, 110),
    Transp = 0.12, Radius = 10,
}
local function panelC() return Theme.Main:Lerp(Color3.new(1, 1, 1), 0.04) end
local Presets = {
    Roxo     = {Accent = rgb(145, 65, 220), Main = rgb(14, 10, 20), Element = rgb(38, 24, 56)},
    Azul     = {Accent = rgb(60, 120, 255), Main = rgb(9, 12, 22),  Element = rgb(22, 32, 58)},
    Verde    = {Accent = rgb(40, 200, 120), Main = rgb(9, 16, 13),  Element = rgb(20, 44, 34)},
    Vermelho = {Accent = rgb(225, 60, 80),  Main = rgb(18, 9, 11),  Element = rgb(48, 22, 28)},
    Ciano    = {Accent = rgb(40, 200, 220), Main = rgb(8, 14, 18),  Element = rgb(20, 40, 50)},
    Rosa     = {Accent = rgb(240, 90, 170), Main = rgb(18, 9, 15),  Element = rgb(52, 22, 42)},
}
local PresetNames = {"Roxo", "Azul", "Verde", "Vermelho", "Ciano", "Rosa"}
do
    local defT = OWNER.System and Presets[OWNER.System.DefaultTheme]
    if defT then for k, v in pairs(defT) do Theme[k] = v end end
end
local Settings = {KeepOnRespawn = false, Toasts = true, MaxToasts = 5, Compact = false,
    FloatBtn = (U.TouchEnabled and not U.KeyboardEnabled)}

--==================== ESTADO ====================
local BindsEnabled = true
local panelOpen = true
local savedPos = nil
local origSky = nil
local Aimbot = { Enabled = false, FOV = 150, Smooth = 0.3, TeamCheck = true,
    VisibleCheck = false, HoldMode = false, Part = "Head", MaxDist = 1000,
    Prediction = 0, Sticky = true, Origin = "Centro" }

local Sel, SelLbl = nil, nil
local En = { Fly=false, Noclip=false, Spin=false, View=false, Follow=false,
    Freecam=false, Xray=false, Spectate=false, BlurActive=false }
local Cn, OrigCol, FlyObj, FlyH = {}, {}, {}, nil
local Extras, MS, MR = {}, {}, {}
local H, UI, Applied, Fn, Feat = {}, {}, {}, {}, {}
local TGT  = {"Follow", "Orbit", "HeadSit", "Shake"}
local CAMM = {"View", "Freecam", "Spectate"}
local togglePanel, applyCompact, cfgExport, cfgImport

--==================== HELPERS ====================
local function C(n, c)
    if Cn[n] then Cn[n]:Disconnect() end
    Cn[n] = c
end
local function D(n)
    if Cn[n] then
        pcall(function() Cn[n]:Disconnect() end)
        Cn[n] = nil
    end
end
local function ch()  return LP.Character end
local function rt(c) return c and c:FindFirstChild("HumanoidRootPart") end
local function hm(c) return c and c:FindFirstChildOfClass("Humanoid") end
local function srt() return Sel and rt(Sel.Character) end
local function EX(s, r) table.insert(Extras, {stop = s, reset = r}) end
local function stopT(except)
    for _, n in ipairs(TGT) do
        if n ~= except and (Cn[n] or MR[n]) then
            D(n)
            if MS[n] then pcall(MS[n]) end
            if MR[n] then pcall(MR[n]) end
        end
    end
end
local function stopC(except)
    for _, n in ipairs(CAMM) do
        if n ~= except and (Cn[n] or MR[n]) then
            D(n)
            if MR[n] then pcall(MR[n]) end
        end
    end
end
local function hex(c)
    return string.format("#%02x%02x%02x", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end
local function new(cls, props, parent)
    local i = Instance.new(cls)
    for k, v in pairs(props) do i[k] = v end
    i.Parent = parent
    return i
end

-- sistema de tema
local Upd = {}
local function themed(fn) pcall(fn) Upd[#Upd + 1] = fn return fn end
local function applyTheme() for _, f in ipairs(Upd) do pcall(f) end end
local function rcorner(i, off)
    local c = new("UICorner", {}, i)
    themed(function() c.CornerRadius = UDim.new(0, math.max(0, Theme.Radius + off)) end)
    return c
end
local function rstroke(i, tr, th)
    local s = new("UIStroke", {Transparency = tr or 0.55, Thickness = th or 1}, i)
    themed(function() s.Color = Theme.Accent end)
    return s
end

--==================== GUIs ====================
local PG = LP:WaitForChild("PlayerGui")

--==================== KEY SYSTEM ====================
local function nowStamp()
    local ok, t = pcall(function() return DateTime.now().UnixTimestamp end)
    return ok and t or os.time()
end

local Access = "admin" -- vira "normal" ou "admin" conforme a key/whitelist usada
do
    local K = OWNER.KeySystem
    local AC = OWNER.Access or {}
    local myNick, myId = LP.Name, tostring(LP.UserId)

    local function matchesWho(list)
        for _, entry in ipairs(list or {}) do
            local who = tostring(entry.Who or entry)
            if who == myNick or who == myId then return entry end
        end
        return nil
    end

    -- blacklist: barra de cara, sem nem mostrar a tela de key
    if matchesWho(AC.Blacklist) then
        LP:Kick("Você não tem permissão para usar este sistema.")
        while true do task.wait(1) end
    end

    -- whitelist: entra direto, sem pedir key
    local wl = matchesWho(AC.Whitelist)
    if wl then
        Access = wl.Level or "admin"
    elseif K and K.Enabled then
        local function norm(s)
            s = tostring(s)
            if not K.CaseSensitive then s = string.lower(s) end
            return s
        end
        local lookup = {}
        for _, k in ipairs(K.Keys or {}) do lookup[norm(k.Key)] = k end

        local max = K.MaxAttempts or 5
        local hasLink = K.GetKeyLink and K.GetKeyLink ~= ""

        local kg = new("ScreenGui", {Name = "N_KEY", ResetOnSpawn = false, DisplayOrder = 500, IgnoreGuiInset = true}, PG)
        local dim = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.4, BorderSizePixel = 0, Active = true}, kg)
        local card = new("Frame", {Size = UDim2.fromOffset(340, hasLink and 240 or 200), AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = Theme.Main, BorderSizePixel = 0}, dim)
        new("UICorner", {CornerRadius = UDim.new(0, 12)}, card)
        new("UIStroke", {Color = Theme.Accent, Transparency = 0.3, Thickness = 1.5}, card)

        new("TextLabel", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1,
            Text = "◈  " .. (K.Title or OWNER.System.Name or "N SYSTEM"),
            TextColor3 = Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 18}, card)
        new("TextLabel", {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 38), BackgroundTransparency = 1,
            Text = K.Subtitle or "Digite sua key", TextColor3 = Theme.Sub, Font = Enum.Font.Gotham, TextSize = 12}, card)

        local box = new("TextBox", {Size = UDim2.new(1, -40, 0, 36), Position = UDim2.new(0, 20, 0, 70),
            PlaceholderText = "Sua key...", PlaceholderColor3 = Theme.Sub, Text = "", TextColor3 = Theme.Text,
            Font = Enum.Font.GothamMedium, TextSize = 13, ClearTextOnFocus = false, BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0}, card)
        new("UICorner", {CornerRadius = UDim.new(0, 8)}, box)

        local verify = new("TextButton", {Size = UDim2.new(1, -40, 0, 36), Position = UDim2.new(0, 20, 0, 116),
            Text = "VERIFICAR", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false,
            BackgroundColor3 = Theme.Accent, BorderSizePixel = 0}, card)
        new("UICorner", {CornerRadius = UDim.new(0, 8)}, verify)

        local status = new("TextLabel", {Size = UDim2.new(1, -40, 0, 20), Position = UDim2.new(0, 20, 0, 160),
            BackgroundTransparency = 1, Text = "", TextColor3 = Theme.Bad, Font = Enum.Font.GothamMedium, TextSize = 11,
            TextWrapped = true}, card)

        if hasLink then
            local link = new("TextButton", {Size = UDim2.new(1, -40, 0, 30), Position = UDim2.new(0, 20, 0, 190),
                Text = "COPIAR LINK PARA PEGAR A KEY", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 11,
                AutoButtonColor = false, BackgroundColor3 = Theme.Element, BorderSizePixel = 0}, card)
            new("UICorner", {CornerRadius = UDim.new(0, 8)}, link)
            link.MouseButton1Click:Connect(function()
                local ok = pcall(function() setclipboard(K.GetKeyLink) end)
                status.TextColor3 = Theme.Sub
                status.Text = ok and "Link copiado!" or K.GetKeyLink
            end)
        end

        local passed, tries, locked = false, 0, false
        local function check()
            if locked or passed then return end
            local typed = norm(box.Text:gsub("^%s+", ""):gsub("%s+$", ""))
            local entry = lookup[typed]
            local fail

            if not entry then
                fail = "Key inválida"
            elseif entry.Expires and nowStamp() > entry.Expires then
                fail = "Key expirada"
            elseif entry.Level == "admin" and entry.Nicks and #entry.Nicks > 0
                and not (table.find(entry.Nicks, myNick) or table.find(entry.Nicks, myId)) then
                fail = "Essa key não é liberada pra você"
            end

            if not fail then
                Access = entry.Level or "normal"
                passed = true
                status.TextColor3 = Theme.Good
                status.Text = "Key válida!"
                task.wait(0.4)
                kg:Destroy()
                return
            end

            tries += 1
            status.TextColor3 = Theme.Bad
            status.Text = string.format("%s (%d/%d)", fail, tries, max)
            if tries >= max then
                if K.KickOnFail then
                    LP:Kick(K.KickMessage or "Muitas tentativas de key.")
                    return
                end
                locked = true
                for s = 10, 1, -1 do
                    if passed then return end
                    status.Text = "Bloqueado por " .. s .. "s"
                    task.wait(1)
                end
                locked, tries = false, 0
                status.Text = ""
            end
        end
        verify.MouseButton1Click:Connect(check)
        box.FocusLost:Connect(function(enter) if enter then check() end end)

        while not passed do task.wait(0.1) end
    end
end

local function mkGui(name, order, inset)
    return new("ScreenGui", {Name = name, ResetOnSpawn = false, DisplayOrder = order,
        IgnoreGuiInset = inset or false}, PG)
end
local Gui    = mkGui("N_SYSTEM", 20)
local OvGui  = mkGui("N_OVERLAYS", 50)
local TGui   = mkGui("N_TOASTS", 100, true)
local FovGui = mkGui("N_AIM_FOV", 5, true)
local TipGui = mkGui("N_TIP", 150, true)
local FloatGui = mkGui("N_FLOAT", 200, true)

local panelBlur = new("BlurEffect", {Name = "N_PanelBlur", Size = 12, Enabled = false}, L)

--==================== JANELA ====================
local DefSize = CFG.Sizes[OWNER.System and OWNER.System.DefaultSize] or CFG.Sizes.M
local Win = new("Frame", {Name = "Win", BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.fromOffset(DefSize.X, DefSize.Y + BAR),
    Position = UDim2.new(0.5, -DefSize.X / 2, 0.5, -(DefSize.Y + BAR) / 2)}, Gui)
local WinScale = new("UIScale", {Scale = 1}, Win)

local Bar = new("Frame", {Size = UDim2.new(1, 0, 0, 38), BorderSizePixel = 0}, Win)
rcorner(Bar, 2)
rstroke(Bar, 0.3, 1.2)
themed(function() Bar.BackgroundColor3 = Theme.Main Bar.BackgroundTransparency = Theme.Transp end)

local function barLabel(txt, x, w, size, bold)
    return new("TextLabel", {Size = UDim2.fromOffset(w, 38), Position = x, BackgroundTransparency = 1,
        Text = txt, Font = bold and Enum.Font.GothamBold or Enum.Font.GothamMedium, TextSize = size,
        TextXAlignment = Enum.TextXAlignment.Left}, Bar)
end
do
    local logo = barLabel("◈", UDim2.fromOffset(12, 0), 20, 20, true)
    local name = barLabel(OWNER.System and OWNER.System.Name or "N SYSTEM", UDim2.fromOffset(36, 0), 100, 15, true)
    local ver  = barLabel(OWNER.System and OWNER.System.Version or "", UDim2.fromOffset(112, 1), 34, 9, true)
    themed(function() logo.TextColor3 = Theme.Accent name.TextColor3 = Theme.Text ver.TextColor3 = Theme.Accent end)
end
local Badge = new("TextLabel", {Size = UDim2.fromOffset(84, 22), Position = UDim2.fromOffset(150, 8),
    Text = "● 0 ativos", Font = Enum.Font.GothamBold, TextSize = 10, BorderSizePixel = 0}, Bar)
rcorner(Badge, -4)
themed(function() Badge.BackgroundColor3 = Theme.Element Badge.BackgroundTransparency = 0.2 end)

local fpsL  = new("TextLabel", {Size = UDim2.fromOffset(62, 38), Position = UDim2.new(1, -316, 0, 0), BackgroundTransparency = 1,
    Text = "-- FPS", Font = Enum.Font.GothamMedium, TextSize = 11}, Bar)
local timeL = new("TextLabel", {Size = UDim2.fromOffset(70, 38), Position = UDim2.new(1, -252, 0, 0), BackgroundTransparency = 1,
    Text = os.date("%H:%M:%S"), Font = Enum.Font.GothamMedium, TextSize = 11}, Bar)
local pingL = new("TextLabel", {Size = UDim2.fromOffset(62, 38), Position = UDim2.new(1, -180, 0, 0), BackgroundTransparency = 1,
    Text = "-- ms", Font = Enum.Font.GothamMedium, TextSize = 11}, Bar)
themed(function() fpsL.TextColor3 = Theme.Sub timeL.TextColor3 = Theme.Sub pingL.TextColor3 = Theme.Sub end)

local function topBtn(txt, x)
    local b = new("TextButton", {Size = UDim2.fromOffset(32, 26), Position = UDim2.new(1, x, 0, 6),
        Text = txt, Font = Enum.Font.GothamBold, TextSize = 14, AutoButtonColor = false, BorderSizePixel = 0}, Bar)
    rcorner(b, -4)
    themed(function() b.BackgroundColor3 = Theme.Element b.TextColor3 = Theme.Text end)
    return b
end
local SizeBtn  = topBtn("≡", -112)
local MinBtn   = topBtn("-", -76)
local CloseBtn = topBtn("X", -40)

local Body = new("Frame", {Position = UDim2.fromOffset(0, BAR), Size = UDim2.new(1, 0, 1, -BAR),
    BorderSizePixel = 0, ClipsDescendants = true}, Win)
rcorner(Body, 2)
rstroke(Body, 0.3, 1.2)
themed(function() Body.BackgroundColor3 = Theme.Main Body.BackgroundTransparency = Theme.Transp end)

local RzH = new("TextButton", {Size = UDim2.fromOffset(16, 16), Position = UDim2.new(1, -20, 1, -20),
    Text = "◢", Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, BackgroundTransparency = 0.5,
    BorderSizePixel = 0, ZIndex = 10}, Body)
rcorner(RzH, -6)
themed(function() RzH.BackgroundColor3 = Theme.Accent RzH.TextColor3 = Theme.Text end)

do
    local drag, ds, sp = false, nil, nil
    Bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true ds = i.Position sp = Win.Position
        end
    end)
    local rz, rs, ri = false, nil, nil
    RzH.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            rz = true rs = i.Position ri = Vector2.new(Win.AbsoluteSize.X, Win.AbsoluteSize.Y)
        end
    end)
    U.InputChanged:Connect(function(i)
        local mv = i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
        if drag and mv then
            local d = i.Position - ds
            Win.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
        if rz and mv then
            local d = (i.Position - rs) / WinScale.Scale
            Win.Size = UDim2.fromOffset(math.clamp(ri.X / WinScale.Scale + d.X, 560, 1000),
                math.clamp(ri.Y / WinScale.Scale + d.Y, 360 + BAR, 760))
        end
    end)
    U.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false rz = false
        end
    end)
end

local Content = new("Frame", {Position = UDim2.fromOffset(10, 10), Size = UDim2.new(1, -20, 1, -20), BackgroundTransparency = 1}, Body)
local Side = new("Frame", {Size = UDim2.new(0, 150, 1, 0), BorderSizePixel = 0}, Content)
rcorner(Side, -2)
themed(function() Side.BackgroundColor3 = panelC() Side.BackgroundTransparency = 0.1 end)
local PageArea = new("Frame", {Position = UDim2.fromOffset(158, 0), Size = UDim2.new(1, -158, 1, -26), BorderSizePixel = 0}, Content)
rcorner(PageArea, -2)
themed(function() PageArea.BackgroundColor3 = panelC() PageArea.BackgroundTransparency = 0.1 end)
local Status = new("TextLabel", {Position = UDim2.new(0, 158, 1, -22), Size = UDim2.new(1, -158, 0, 22),
    BackgroundTransparency = 1, Text = "  ◎ Nenhum jogador selecionado", Font = Enum.Font.GothamMedium,
    TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}, Content)
themed(function() Status.TextColor3 = Theme.Sub end)

local SearchBox = new("TextBox", {Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 0, 26),
    PlaceholderText = "Buscar opção...", Text = "", Font = Enum.Font.Gotham, TextSize = 11, ClearTextOnFocus = false,
    BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left}, Side)
new("UIPadding", {PaddingLeft = UDim.new(0, 8)}, SearchBox)
rcorner(SearchBox, -4)
themed(function() SearchBox.BackgroundColor3 = Theme.Element SearchBox.BackgroundTransparency = 0.2
    SearchBox.TextColor3 = Theme.Text SearchBox.PlaceholderColor3 = Theme.Sub end)

local TabList = new("ScrollingFrame", {Position = UDim2.fromOffset(6, 38), Size = UDim2.new(1, -12, 1, -102),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0,
    AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new()}, Side)
new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, TabList)

do
    local card = new("Frame", {Position = UDim2.new(0, 6, 1, -58), Size = UDim2.new(1, -12, 0, 52), BorderSizePixel = 0}, Side)
    rcorner(card, -3)
    themed(function() card.BackgroundColor3 = Theme.Element card.BackgroundTransparency = 0.3 end)
    local av = new("ImageLabel", {Size = UDim2.fromOffset(36, 36), Position = UDim2.fromOffset(4, 8), BackgroundTransparency = 0.4,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=60&h=60", BorderSizePixel = 0}, card)
    new("UICorner", {CornerRadius = UDim.new(1, 0)}, av)
    local n1 = new("TextLabel", {Size = UDim2.new(1, -52, 0, 18), Position = UDim2.fromOffset(46, 8), BackgroundTransparency = 1,
        Text = LP.DisplayName, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd}, card)
    local n2 = new("TextLabel", {Size = UDim2.new(1, -52, 0, 14), Position = UDim2.fromOffset(46, 26), BackgroundTransparency = 1,
        Text = "@" .. LP.Name, Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd}, card)
    UI.cardLabels = {n1, n2}
    themed(function() n1.TextColor3 = Theme.Text n2.TextColor3 = Theme.Sub end)
end

local Pages, TabBtns, curTab = {}, {}, nil
local function createPage(name)
    local p = new("ScrollingFrame", {Name = name, Size = UDim2.new(1, -12, 1, -12), Position = UDim2.fromOffset(6, 6),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
        AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Visible = false}, PageArea)
    themed(function() p.ScrollBarImageColor3 = Theme.Accent end)
    new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, p)
    Pages[name] = p
    return p
end
local function refTabs()
    for n, b in pairs(TabBtns) do
        local a = (n == curTab)
        b.BackgroundColor3 = a and Theme.Accent or Theme.Element
        b.BackgroundTransparency = a and 0.1 or 0.55
        b.TextColor3 = Theme.Text
    end
end
themed(refTabs)
local function switchPage(name)
    curTab = name
    for k, v in pairs(Pages) do v.Visible = (k == name) end
    local p = Pages[name]
    if p then
        p.Position = UDim2.fromOffset(6, 20)
        T:Create(p, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(6, 6)}):Play()
    end
    refTabs()
end
local TabIcons = {PLAYER = "●", MOVEMENT = "▲", TROLL = "◆", VISUAL = "☀", ESP = "◉", AIMBOT = "◎",
    OVERLAYS = "▤", FAVORITOS = "★", THEME = "◐", SETTINGS = "⚙", KEYBINDS = "⌨", SCRIPTS = "❯"}
local tabOrder = 0
local function tab(name)
    tabOrder += 1
    local b = new("TextButton", {Size = UDim2.new(1, 0, 0, 30), LayoutOrder = tabOrder,
        Text = (TabIcons[name] or "●") .. "   " .. name, Font = Enum.Font.GothamBold, TextSize = 11,
        AutoButtonColor = false, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0}, TabList)
    rcorner(b, -4)
    new("UIPadding", {PaddingLeft = UDim.new(0, 10)}, b)
    b.MouseButton1Click:Connect(function() SearchBox.Text = "" switchPage(name) end)
    TabBtns[name] = b
    return createPage(name)
end

applyCompact = function()
    local on = Settings.Compact
    local w = on and 46 or 150
    Side.Size = UDim2.new(0, w, 1, 0)
    PageArea.Position = UDim2.fromOffset(w + 8, 0)
    PageArea.Size = UDim2.new(1, -(w + 8), 1, -26)
    Status.Position = UDim2.new(0, w + 8, 1, -22)
    Status.Size = UDim2.new(1, -(w + 8), 0, 22)
    SearchBox.Visible = not on
    TabList.Position = UDim2.fromOffset(6, on and 6 or 38)
    TabList.Size = UDim2.new(1, -12, 1, on and -70 or -102)
    for n, b in pairs(TabBtns) do
        b.Text = on and (TabIcons[n] or "●") or ((TabIcons[n] or "●") .. "   " .. n)
        b.TextXAlignment = on and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
    end
    for _, l in ipairs(UI.cardLabels) do l.Visible = not on end
end

--==================== TOAST ====================
local TH = new("Frame", {Size = UDim2.fromOffset(300, 400), Position = UDim2.new(1, -320, 1, -420), BackgroundTransparency = 1}, TGui)
new("UIListLayout", {Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Bottom, SortOrder = Enum.SortOrder.LayoutOrder}, TH)
local toastCount, toastList = 0, {}
local function toast(txt, col)
    if not Settings.Toasts then return end
    toastCount += 1
    local t = new("TextLabel", {Size = UDim2.fromOffset(280, 34), BackgroundColor3 = panelC(), BackgroundTransparency = 1,
        Text = "  " .. txt, TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = toastCount}, TH)
    new("UICorner", {CornerRadius = UDim.new(0, 8)}, t)
    local s = new("UIStroke", {Color = col or Theme.Accent, Transparency = 1}, t)
    table.insert(toastList, t)
    for i = #toastList, 1, -1 do
        if not toastList[i].Parent then table.remove(toastList, i) end
    end
    while #toastList > Settings.MaxToasts do
        local o = table.remove(toastList, 1)
        if o and o.Parent then o:Destroy() end
    end
    T:Create(t, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    T:Create(s, TweenInfo.new(0.2), {Transparency = 0.3}):Play()
    task.delay(2.2, function()
        if t.Parent then
            T:Create(t, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            T:Create(s, TweenInfo.new(0.3), {Transparency = 1}):Play()
            task.wait(0.35)
            if t.Parent then t:Destroy() end
        end
    end)
end

--==================== KEYBINDS (núcleo) ====================
local Binds, BindOrder, BindUI = {}, {}, {}
local capId, capConn = nil, nil

local function keyName(k)
    local m = {LeftControl = "LCtrl", RightControl = "RCtrl", LeftShift = "LShift", RightShift = "RShift",
        LeftAlt = "LAlt", RightAlt = "RAlt", Backquote = "`", Return = "Enter"}
    local n = k.Name
    return m[n] or (#n > 7 and n:sub(1, 7) or n)
end
local function addBind(id, name, kind, fire, key)
    Binds[id] = {name = name, kind = kind, fire = fire, key = key, use = (kind == "always")}
    table.insert(BindOrder, id)
end
local function refreshBind(id)
    for _, f in ipairs(BindUI[id] or {}) do pcall(f) end
end
local function endCapture()
    if capConn then capConn:Disconnect() capConn = nil end
    local id = capId
    capId = nil
    if id then refreshBind(id) end
end
local function startCapture(id)
    endCapture()
    capId = id
    refreshBind(id)
    local my
    my = U.InputBegan:Connect(function(i, t)
        if t then return end
        if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
        local kc = i.KeyCode
        if kc == Enum.KeyCode.Unknown then return end
        local b = Binds[id]
        if kc == Enum.KeyCode.Escape then endCapture() return end
        if kc == Enum.KeyCode.Backspace then
            b.key = nil
            b.use = false
            toast("Bind removida: " .. b.name, Theme.Bad)
            endCapture()
            return
        end
        for oid, ob in pairs(Binds) do
            if oid ~= id and ob.key == kc then
                toast("Já usado em " .. ob.name, Theme.Bad)
                endCapture()
                return
            end
        end
        b.key = kc
        if b.kind == "toggle" or b.kind == "action" then b.use = true end
        toast(b.name .. ": [" .. kc.Name .. "]", Theme.Good)
        endCapture()
    end)
    capConn = my
    task.delay(6, function() if capConn == my then endCapture() end end)
end

local function bindWidgets(f, id, xr)
    local b = Binds[id]
    local kb = new("TextButton", {Size = UDim2.fromOffset(62, 20), Position = UDim2.new(1, xr - 62, 0.5, -10),
        Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 4}, f)
    rcorner(kb, -5)
    local chk
    if b.kind == "toggle" or b.kind == "action" then
        chk = new("TextButton", {Size = UDim2.fromOffset(18, 18), Position = UDim2.new(1, xr - 62 - 22, 0.5, -9),
            Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 4}, f)
        rcorner(chk, -6)
        rstroke(chk, 0.4, 1)
    end
    local function ref()
        local k = b.key
        kb.Text = (capId == id) and "..." or (k and keyName(k) or "BIND")
        kb.TextColor3 = Theme.Text
        kb.BackgroundColor3 = (capId == id) and Theme.Accent or Theme.Main:Lerp(Theme.Element, 0.7)
        kb.TextTransparency = (chk and not b.use) and 0.5 or 0
        if chk then chk.BackgroundColor3 = b.use and Theme.Accent or Theme.Main end
    end
    BindUI[id] = BindUI[id] or {}
    table.insert(BindUI[id], ref)
    themed(ref)
    kb.MouseButton1Click:Connect(function()
        if capId == id then endCapture() else startCapture(id) end
    end)
    if chk then
        chk.MouseButton1Click:Connect(function()
            if not b.key then toast("Defina uma tecla primeiro", Theme.Bad) return end
            b.use = not b.use
            refreshBind(id)
        end)
    end
end

--==================== COMPONENTES ====================
local Items, FavCount = {}, 0
local PageLO = setmetatable({}, {__mode = "k"})
local TipOf = setmetatable({}, {__mode = "k"})
local function LO(p) PageLO[p] = (PageLO[p] or 0) + 1 return PageLO[p] end

-- duas colunas: itens "compactos" (botões/toggles/cycles) ocupam metade da
-- largura cada, em pares, dentro de uma "linha" que é o item real do
-- UIListLayout da página. Itens full-width (seções, sliders, caixas de
-- texto...) chamam fullWidth(p) antes de se criar, o que fecha a linha atual.
local ColState = setmetatable({}, {__mode = "k"})
local function fullWidth(p) ColState[p] = nil end
local function cell(p, h)
    local st = ColState[p]
    if not st then
        local line = new("Frame", {Size = UDim2.new(1, -8, 0, h), BackgroundTransparency = 1, LayoutOrder = LO(p)}, p)
        st = {line = line, side = 1}
        ColState[p] = st
    end
    local f
    if st.side == 1 then
        f = new("Frame", {Size = UDim2.new(0.5, -3, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, st.line)
        st.side = 2
    else
        f = new("Frame", {Size = UDim2.new(0.5, -3, 1, 0), Position = UDim2.new(0.5, 3, 0, 0), BackgroundTransparency = 1}, st.line)
        ColState[p] = nil
    end
    return f
end

local Tips = {
    ["FLY"] = "Voa pelo mapa. WASD move, Espaço sobe, Ctrl desce. Modo e velocidades nos sliders abaixo.",
    ["NOCLIP"] = "Atravessa paredes. Modo 'Total' também atravessa o chão.",
    ["INFINITE JUMP"] = "Permite pular no ar quantas vezes quiser.",
    ["CLICK TP (Ctrl + clique)"] = "Segure Ctrl e clique no chão para teleportar até lá.",
    ["FREECAM"] = "Câmera livre: só a câmera se move, o personagem fica parado. WASD move, Espaço/Ctrl sobe/desce, Shift acelera, botão direito gira.",
    ["ZOOM INFINITO"] = "Remove o limite de zoom da câmera (scroll do mouse).",
    ["TRAVAR NO ALVO"] = "Mantém a mira no mesmo jogador até ele sair do FOV, evitando ficar trocando de alvo.",
    ["SPRINT AUTOMÁTICO"] = "Aumenta a velocidade só enquanto você está andando.",
    ["SPIDER (subir paredes)"] = "Sobe paredes quando você anda de frente para elas.",
    ["ANTI-QUEDA"] = "Limita a velocidade de queda para você não tomar dano.",
    ["GOTO SELECTED"] = "Teleporta você até o jogador selecionado.",
    ["SCARY - TP + RETURN"] = "Vai até o jogador selecionado e volta pra onde estava.",
    ["VIEW PLAYER"] = "Assiste a câmera do jogador selecionado.",
    ["FOLLOW PLAYER"] = "Fica atrás do jogador selecionado.",
    ["SPIN"] = "Gira o personagem sem parar.",
    ["FLING (sem alvo)"] = "Arremessa quem encostar em você. Precisa de colisão entre jogadores no jogo.",
    ["FLING (no alvo selecionado)"] = "Vai até o jogador selecionado e tenta arremessá-lo. Precisa de colisão entre jogadores.",
    ["PÂNICO (desliga tudo e esconde)"] = "Desliga todas as funções e esconde o painel na hora. Defina uma tecla nesta aba.",
    ["ORBIT PLAYER"] = "Orbita ao redor do jogador selecionado.",
    ["SENTAR NA CABEÇA"] = "Senta na cabeça do jogador selecionado.",
    ["TREMER PERTO"] = "Treme aleatoriamente perto do jogador selecionado.",
    ["LOOP SCARY"] = "Repete o Scary em loop no jogador selecionado.",
    ["SPAM JUMP"] = "Pula sem parar.",
    ["CHAT SPAM"] = "Envia a mensagem da caixa em loop, com o intervalo do slider.",
    ["ESP (MASTER)"] = "Liga o ESP. As opções abaixo escolhem o que aparece.",
    ["NOME DO TIME"] = "Mostra o nome do time do jogador junto com o resto do ESP.",
    ["ESCONDER MEU TIME"] = "Não mostra ESP em quem está no seu mesmo time.",
    ["ESP DE ITENS"] = "Mostra objetos/itens cujo nome contém o texto da caixa acima.",
    ["X-RAY (paredes)"] = "Deixa as paredes perto de você transparentes.",
    ["FULLBRIGHT"] = "Remove sombras e escuridão (só no seu client).",
    ["ANTI AFK"] = "Evita ser kickado por ficar parado.",
    ["AIMBOT"] = "Mira automaticamente no jogador mais perto do centro da tela.",
    ["TEAM CHECK"] = "Ignora jogadores do seu time.",
    ["VISIBLE CHECK"] = "Só mira em quem não está atrás de parede.",
    ["SEGURAR PARA MIRAR"] = "O aimbot só trabalha enquanto você segura a tecla ao lado.",
    ["SPECTATE MODE"] = "Assiste os jogadores um por um (use os botões de próximo/anterior).",
    ["SELECIONAR CLICANDO"] = "Clique em um jogador no jogo para selecioná-lo.",
    ["COPIAR ROUPA DO SELECIONADO (client)"] = "Copia roupa e acessórios do selecionado. Só você vê.",
    ["OVERLAY FPS / PING"] = "Janela flutuante com FPS e ping.",
    ["CHAT LOGGER"] = "Janela flutuante que registra o chat.",
    ["LISTA DE BINDS NA TELA"] = "Mostra suas binds ativas e o que está ligado.",
}

local function updateFavEmpty() if UI.favEmpty then UI.favEmpty.Visible = (FavCount == 0) end end
local function setFav(it, v)
    if it.fav == v then return end
    it.fav = v
    if v then
        FavCount += 1
        it.row.LayoutOrder = 1000 + FavCount
        it.row.Parent = Pages.FAVORITOS
    else
        FavCount -= 1
        it.row.LayoutOrder = it.lo
        it.row.Parent = it.page
    end
    if it.starRef then it.starRef() end
    updateFavEmpty()
end

local function regItem(f, text, p, tall)
    local it = {row = f, text = text, key = p.Name .. ":" .. text, page = p, lo = f.LayoutOrder, fav = false}
    table.insert(Items, it)
    local star = new("TextButton", {Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(4, tall and 6 or 9),
        BackgroundTransparency = 1, Text = "☆", Font = Enum.Font.GothamBold, TextSize = 13, ZIndex = 5}, f)
    it.starRef = function()
        star.Text = it.fav and "★" or "☆"
        star.TextColor3 = it.fav and Theme.Accent or Theme.Sub
    end
    themed(it.starRef)
    star.MouseButton1Click:Connect(function() setFav(it, not it.fav) end)
    if Tips[text] then TipOf[f] = Tips[text] end
    return it
end

local function row(p, h, compact)
    h = h or 34
    local f
    if compact then
        local wrapper = cell(p, h)
        f = new("Frame", {Size = UDim2.new(1, 0, 0, h), BorderSizePixel = 0, LayoutOrder = LO(p)}, wrapper)
    else
        fullWidth(p)
        f = new("Frame", {Size = UDim2.new(1, -8, 0, h), BorderSizePixel = 0, LayoutOrder = LO(p)}, p)
    end
    rcorner(f, -3)
    themed(function() f.BackgroundColor3 = Theme.Element f.BackgroundTransparency = 0.25 end)
    return f
end
local function rowLabel(f, text, rightReserve)
    local l = new("TextLabel", {Size = UDim2.new(1, -(24 + (rightReserve or 10)), 1, 0), Position = UDim2.fromOffset(24, 0),
        BackgroundTransparency = 1, Text = text, Font = Enum.Font.GothamMedium,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2}, f)
    themed(function() l.TextColor3 = Theme.Text end)
    return l
end

local function sec(p, txt)
    fullWidth(p)
    local f = new("Frame", {Size = UDim2.new(1, -8, 0, 24), BackgroundTransparency = 1, LayoutOrder = LO(p)}, p)
    local l = new("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = string.upper(txt),
        Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}, f)
    local line = new("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -2), BorderSizePixel = 0}, f)
    themed(function() l.TextColor3 = Theme.Accent line.BackgroundColor3 = Theme.Accent line.BackgroundTransparency = 0.65 end)
    return f
end
local function lbl(p, txt)
    fullWidth(p)
    local l = new("TextLabel", {Size = UDim2.new(1, -8, 0, 20), BackgroundTransparency = 1, Text = txt,
        Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        LayoutOrder = LO(p)}, p)
    themed(function() l.TextColor3 = Theme.Sub end)
    return l
end
local function tbox(p, ph)
    fullWidth(p)
    local b = new("TextBox", {Size = UDim2.new(1, -8, 0, 32), PlaceholderText = ph, Text = "", Font = Enum.Font.Gotham,
        TextSize = 11, ClearTextOnFocus = false, BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = LO(p)}, p)
    new("UIPadding", {PaddingLeft = UDim.new(0, 10)}, b)
    rcorner(b, -4)
    themed(function() b.BackgroundColor3 = Theme.Element b.BackgroundTransparency = 0.2
        b.TextColor3 = Theme.Text b.PlaceholderColor3 = Theme.Sub end)
    return b
end

local function btn(p, text, cb, id, defKey)
    local f = row(p, 34, true)
    local hit = new("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 1}, f)
    rowLabel(f, text, id and 116 or 10)
    regItem(f, text, p)
    if id then
        addBind(id, text, "action", cb, defKey)
        bindWidgets(f, id, -10)
    end
    hit.MouseEnter:Connect(function() T:Create(f, TweenInfo.new(0.1), {BackgroundTransparency = 0.05}):Play() end)
    hit.MouseLeave:Connect(function() T:Create(f, TweenInfo.new(0.1), {BackgroundTransparency = 0.25}):Play() end)
    hit.MouseButton1Click:Connect(function()
        f.BackgroundColor3 = Theme.Accent
        task.delay(0.08, function() f.BackgroundColor3 = Theme.Element end)
        if cb then cb() end
    end)
    return f
end

local function toggle(p, text, cb, opts)
    opts = opts or {}
    local f = row(p, 34, true)
    local on = false
    local hit = new("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 1}, f)
    rowLabel(f, text, opts.reserve or 54)
    regItem(f, text, p)
    local track = new("Frame", {Size = UDim2.fromOffset(38, 20), Position = UDim2.new(1, -48, 0.5, -10), BorderSizePixel = 0, ZIndex = 2}, f)
    rcorner(track, 99)
    local knob = new("Frame", {Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(3, 3),
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 3}, track)
    rcorner(knob, 99)
    local function trackCol() return on and Theme.Accent or Theme.Main:Lerp(Theme.Sub, 0.25) end
    themed(function() track.BackgroundColor3 = trackCol() end)
    local function set(v, silent)
        if v == on then return end
        on = v
        T:Create(knob, TweenInfo.new(0.12), {Position = on and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)}):Play()
        T:Create(track, TweenInfo.new(0.12), {BackgroundColor3 = trackCol()}):Play()
        if not silent then
            T:Create(f, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Accent}):Play()
            task.delay(0.14, function() T:Create(f, TweenInfo.new(0.25), {BackgroundColor3 = Theme.Element}):Play() end)
            cb(on)
        end
    end
    hit.MouseEnter:Connect(function() T:Create(f, TweenInfo.new(0.1), {BackgroundTransparency = 0.05}):Play() end)
    hit.MouseLeave:Connect(function() T:Create(f, TweenInfo.new(0.1), {BackgroundTransparency = 0.25}):Play() end)
    hit.MouseButton1Click:Connect(function() set(not on) end)
    if opts.def then set(true, true) end
    return {set = set, off = function() set(false) end, flip = function() set(not on) end,
        get = function() return on end, row = f}
end

local function feature(p, id, text, cb, defKey)
    local o = toggle(p, text, cb, {reserve = 150})
    H[id] = o.off
    Feat[id] = o
    addBind(id, text, "toggle", o.flip, defKey)
    bindWidgets(o.row, id, -54)
    return o
end

local activeSl = nil
U.InputChanged:Connect(function(i)
    if activeSl and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        activeSl(i.Position.X)
    end
end)
U.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        activeSl = nil
    end
end)
local function slider(p, text, mn, mx, def, step, cb, fmt)
    local f = row(p, 44)
    regItem(f, text, p, true)
    local lb = new("TextLabel", {Size = UDim2.new(1, -110, 0, 20), Position = UDim2.fromOffset(24, 4), BackgroundTransparency = 1,
        Text = text, Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd}, f)
    local vl = new("TextBox", {Size = UDim2.fromOffset(70, 20), Position = UDim2.new(1, -80, 0, 4), BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, Text = "",
        ClearTextOnFocus = true}, f)
    local hit = new("TextButton", {Size = UDim2.new(1, -24, 0, 18), Position = UDim2.fromOffset(12, 24),
        BackgroundTransparency = 1, Text = ""}, f)
    local bar = new("Frame", {Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0.5, -3), BorderSizePixel = 0}, hit)
    local fill = new("Frame", {Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0}, bar)
    local knob = new("Frame", {Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2}, bar)
    rcorner(bar, 99) rcorner(fill, 99) rcorner(knob, 99)
    themed(function() lb.TextColor3 = Theme.Text vl.TextColor3 = Theme.Accent
        bar.BackgroundColor3 = Theme.Main fill.BackgroundColor3 = Theme.Accent end)
    local val
    local function fmtv(v)
        if fmt then return fmt(v) end
        if step and step < 1 then return string.format("%.2f", v) end
        return string.format("%.0f", v)
    end
    local function set(v, silent)
        v = math.clamp(v, mn, mx)
        if step then v = math.floor(v / step + 0.5) * step end
        v = math.clamp(v, mn, mx)
        val = v
        local r = (mx == mn) and 0 or (v - mn) / (mx - mn)
        fill.Size = UDim2.new(r, 0, 1, 0)
        knob.Position = UDim2.new(r, -7, 0.5, -7)
        vl.Text = fmtv(v)
        if cb and not silent then cb(v) end
    end
    local function fromX(x)
        local w = bar.AbsoluteSize.X
        if w <= 0 then return end
        set(mn + math.clamp((x - bar.AbsolutePosition.X) / w, 0, 1) * (mx - mn))
    end
    hit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            activeSl = fromX
            fromX(i.Position.X)
        end
    end)
    vl.FocusLost:Connect(function()
        local n = tonumber(vl.Text)
        if n then set(n) else vl.Text = fmtv(val) end
    end)
    set(def, true)
    return {set = set, get = function() return val end}
end

local function cycle(p, text, opts, def, cb)
    local f = row(p, 34, true)
    rowLabel(f, text, 120)
    regItem(f, text, p)
    local idx = table.find(opts, def) or 1
    local b = new("TextButton", {Size = UDim2.fromOffset(100, 22), Position = UDim2.new(1, -110, 0.5, -11),
        Text = opts[idx], Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 3}, f)
    rcorner(b, -4)
    themed(function() b.BackgroundColor3 = Theme.Main:Lerp(Theme.Element, 0.7) b.TextColor3 = Theme.Accent end)
    b.MouseButton1Click:Connect(function()
        idx = idx % #opts + 1
        b.Text = opts[idx]
        cb(opts[idx])
    end)
    return {set = function(v) idx = table.find(opts, v) or idx b.Text = opts[idx] end}
end

--==================== TOOLTIP (poll) ====================
do
    local TipF = new("TextLabel", {AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 0.05, BorderSizePixel = 0, Font = Enum.Font.Gotham, TextSize = 11, TextWrapped = true,
        Visible = false, ZIndex = 10, TextXAlignment = Enum.TextXAlignment.Left}, TipGui)
    new("UISizeConstraint", {MaxSize = Vector2.new(260, 200)}, TipF)
    new("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6)}, TipF)
    new("UICorner", {CornerRadius = UDim.new(0, 6)}, TipF)
    rstroke(TipF, 0.3, 1)
    themed(function() TipF.BackgroundColor3 = panelC() TipF.TextColor3 = Theme.Text end)
    local acc, hoverText, hoverT = 0, nil, 0
    R.Heartbeat:Connect(function(dt)
        acc += dt
        if TipF.Visible then
            local m = U:GetMouseLocation()
            TipF.Position = UDim2.fromOffset(m.X + 14, m.Y + 12)
        end
        if acc < 0.12 then return end
        local step = acc
        acc = 0
        if not Win.Visible then TipF.Visible = false hoverText = nil return end
        local mo = LP:GetMouse()
        local found
        for _, o in ipairs(PG:GetGuiObjectsAtPosition(mo.X, mo.Y)) do
            local x = o
            while x and x ~= PG do
                if TipOf[x] then found = TipOf[x] break end
                x = x.Parent
            end
            if found then break end
        end
        if found and found == hoverText then
            hoverT += step
        else
            hoverText = found
            hoverT = 0
            TipF.Visible = false
        end
        if found and hoverT >= 0.4 and not TipF.Visible then
            TipF.Text = found
            TipF.Visible = true
        end
    end)
end

--==================== OVERLAYS ====================
local Ov = {}
local stackY = 0
local function mkOverlay(id, title, W, Hh)
    if Ov[id] then return Ov[id] end
    local f = new("Frame", {Size = UDim2.fromOffset(W, Hh), Position = UDim2.new(0, 16, 0, 60 + stackY),
        BorderSizePixel = 0, Visible = false}, OvGui)
    rcorner(f, -2)
    rstroke(f, 0.3, 1)
    themed(function() f.BackgroundColor3 = panelC() f.BackgroundTransparency = 0.1 end)
    local top = new("Frame", {Size = UDim2.new(1, 0, 0, 26), BorderSizePixel = 0}, f)
    rcorner(top, -2)
    themed(function() top.BackgroundColor3 = Theme.Element top.BackgroundTransparency = 0.2 end)
    local tl = new("TextLabel", {Size = UDim2.new(1, -30, 1, 0), Position = UDim2.fromOffset(8, 0), BackgroundTransparency = 1,
        Text = title, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}, top)
    themed(function() tl.TextColor3 = Theme.Text end)
    local cl = new("TextButton", {Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -24, 0, 3), BackgroundColor3 = Theme.Bad,
        BackgroundTransparency = 0.3, Text = "X", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 10,
        AutoButtonColor = false, BorderSizePixel = 0}, top)
    new("UICorner", {CornerRadius = UDim.new(0, 4)}, cl)
    local body = new("Frame", {Name = "Body", Size = UDim2.new(1, -8, 1, -34), Position = UDim2.fromOffset(4, 30), BackgroundTransparency = 1}, f)
    new("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, body)
    local dg, ds2, sp2 = false, nil, nil
    top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dg = true ds2 = i.Position sp2 = f.Position
        end
    end)
    U.InputChanged:Connect(function(i)
        if dg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds2
            f.Position = UDim2.new(sp2.X.Scale, sp2.X.Offset + d.X, sp2.Y.Scale, sp2.Y.Offset + d.Y)
        end
    end)
    U.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dg = false end
    end)
    local o = {Frame = f, Body = body, OnClose = nil}
    Ov[id] = o
    cl.MouseButton1Click:Connect(function()
        f.Visible = false
        if o.OnClose then o.OnClose() end
    end)
    stackY = stackY + Hh + 8
    return o
end

--==================== LÓGICA COMPARTILHADA (Fn) ====================
local function selectP(p)
    if p == LP then return end
    Sel = p
    if SelLbl then SelLbl.Text = "Selecionado: " .. p.Name end
    if UI.Nick then UI.Nick.Text = p.Name end
    toast("Selecionado: " .. p.Name)
end

local SpecIdx = 0
Fn.specList = function()
    local l = {}
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= LP and p.Character and hm(p.Character) then table.insert(l, p) end
    end
    return l
end
Fn.specCycle = function(dir)
    local l = Fn.specList()
    if #l == 0 then toast("Ninguém pra spectar", Theme.Bad) return end
    SpecIdx = ((SpecIdx - 1 + dir) % #l) + 1
    local p = l[SpecIdx]
    local h = p.Character and hm(p.Character)
    if h then
        Cam.CameraSubject = h
        Sel = p
        if SelLbl then SelLbl.Text = "Selecionado: " .. p.Name end
        toast("Spec: " .. p.Name)
    end
end

Fn.stopFly = function()
    En.Fly = false
    D("Fly")
    for _, o in ipairs(FlyObj) do
        if o and o.Parent then o:Destroy() end
    end
    table.clear(FlyObj)
    if FlyH and FlyH.Parent then
        FlyH.PlatformStand = false
        FlyH:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    FlyH = nil
end
Fn.startFly = function()
    local c = ch()
    local r, h = rt(c), hm(c)
    if not r or not h then
        if H.Fly then H.Fly() end
        return
    end
    Fn.stopFly()
    En.Fly = true
    FlyH = h
    h.PlatformStand = true
    local v = new("BodyVelocity", {MaxForce = Vector3.new(1e6, 1e6, 1e6), Velocity = Vector3.zero}, r)
    local g = new("BodyGyro", {MaxTorque = Vector3.new(1e6, 1e6, 1e6), P = 10000, CFrame = Cam.CFrame}, r)
    table.insert(FlyObj, v)
    table.insert(FlyObj, g)
    local throttle = 0
    C("Fly", R.RenderStepped:Connect(function(dt)
        if not r.Parent then
            if H.Fly then H.Fly() end
            return
        end
        local cf = Cam.CFrame
        local up = (U:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) - (U:IsKeyDown(Enum.KeyCode.LeftControl) and 1 or 0)
        local vert = Vector3.new(0, up * CFG.FlyVSpd, 0)
        local mv = Vector3.zero
        if U:IsKeyDown(Enum.KeyCode.W) then mv += cf.LookVector end
        if U:IsKeyDown(Enum.KeyCode.S) then mv -= cf.LookVector end
        if U:IsKeyDown(Enum.KeyCode.A) then mv -= cf.RightVector end
        if U:IsKeyDown(Enum.KeyCode.D) then mv += cf.RightVector end
        local mode = CFG.FlyMode
        if mode == "Avião" then
            local fwd = (U:IsKeyDown(Enum.KeyCode.W) and 1 or 0) - (U:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
            throttle = math.clamp(throttle + fwd * dt * 1.5, 0, 1)
            v.Velocity = cf.LookVector * CFG.FlySpd * throttle + vert
        elseif mode == "CFrame" then
            local hor = mv.Magnitude > 0 and mv.Unit * CFG.FlySpd or Vector3.zero
            v.Velocity = Vector3.zero
            r.CFrame = r.CFrame + (hor + vert) * dt
            r.AssemblyLinearVelocity = Vector3.zero
        else
            if mv.Magnitude == 0 and h.MoveDirection.Magnitude > 0 then mv = h.MoveDirection end
            local hor = mv.Magnitude > 0 and mv.Unit * CFG.FlySpd or Vector3.zero
            v.Velocity = hor + vert
        end
        g.CFrame = cf
    end))
end

Fn.restoreCol = function()
    D("Noclip")
    for part, orig in pairs(OrigCol) do
        if part and part.Parent then part.CanCollide = orig end
    end
    table.clear(OrigCol)
    if En.Noclip and CFG.NoclipMode == "Total" then
        local h = hm(ch())
        if h then h:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end
    En.Noclip = false
end

Fn.stopSpin = function()
    D("Spin")
    En.Spin = false
    local h = hm(ch())
    if h then h.AutoRotate = true end
end

--------- FLING (precisa de colisão entre jogadores ligada no jogo) ---------
-- Técnica: ancora seu HumanoidRootPart (ele some da física por um instante)
-- e "tremula" a posição dele bem rápido perto do alvo. Isso ainda empurra
-- forte quem está tocando, mas como você está ancorado, você NÃO vai junto,
-- não gira e não sai voando. Ao desligar, o Anchored volta ao valor original
-- na hora (retorno automático).
local FlingRoot, FlingOrigAnchored = nil, nil
Fn.stopFling = function()
    D("Fling")
    if FlingRoot and FlingRoot.Parent then
        pcall(function() FlingRoot.Anchored = FlingOrigAnchored end)
    end
    FlingRoot, FlingOrigAnchored = nil, nil
end

--------- FREECAM (só a câmera se move; personagem fica parado) ---------
local freeConns, freeControls = {}, nil
local function getControls()
    local ok, c = pcall(function()
        return require(LP:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 3)):GetControls()
    end)
    return ok and c or nil
end

Fn.stopFreecam = function()
    D("Freecam")
    for _, c in ipairs(freeConns) do pcall(function() c:Disconnect() end) end
    table.clear(freeConns)
    pcall(function() CAS:UnbindAction("N_FreecamSink") end)
    if freeControls then
        pcall(function() freeControls:Enable() end)
        freeControls = nil
    end
    local was = En.Freecam
    En.Freecam = false
    U.MouseBehavior = Enum.MouseBehavior.Default
    if was then
        Cam.CameraType = Enum.CameraType.Custom
        local h = hm(ch())
        if h then Cam.CameraSubject = h end
    end
end

Fn.startFreecam = function()
    Fn.stopFreecam()
    En.Freecam = true

    local pitch, yaw = Cam.CFrame:ToOrientation()
    local pos = Cam.CFrame.Position
    Cam.CameraType = Enum.CameraType.Scriptable

    -- trava o personagem: desliga os controles e engole as teclas de movimento
    freeControls = getControls()
    if freeControls then pcall(function() freeControls:Disable() end) end
    local K = Enum.KeyCode
    CAS:BindActionAtPriority("N_FreecamSink", function() return Enum.ContextActionResult.Sink end, false,
        Enum.ContextActionPriority.High.Value + 100,
        K.W, K.A, K.S, K.D, K.Space, K.LeftControl, K.LeftShift, K.Up, K.Down, K.Left, K.Right)

    local rmb = false
    table.insert(freeConns, U.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.UserInputType == Enum.UserInputType.MouseButton2 then
            rmb = true
            U.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
        end
    end))
    table.insert(freeConns, U.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton2 then
            rmb = false
            U.MouseBehavior = Enum.MouseBehavior.Default
        end
    end))
    table.insert(freeConns, U.InputChanged:Connect(function(i)
        if rmb and i.UserInputType == Enum.UserInputType.MouseMovement then
            yaw = yaw - i.Delta.X * 0.005
            pitch = math.clamp(pitch - i.Delta.Y * 0.005, -math.pi / 2 + 0.01, math.pi / 2 - 0.01)
        end
    end))

    C("Freecam", R.RenderStepped:Connect(function(dt)
        local rot = CFrame.fromEulerAnglesYXZ(pitch, yaw, 0)
        local cf = CFrame.new(pos) * rot
        local mv = Vector3.zero
        if U:IsKeyDown(K.W) then mv += cf.LookVector end
        if U:IsKeyDown(K.S) then mv -= cf.LookVector end
        if U:IsKeyDown(K.A) then mv -= cf.RightVector end
        if U:IsKeyDown(K.D) then mv += cf.RightVector end
        if U:IsKeyDown(K.Space) then mv += Vector3.yAxis end
        if U:IsKeyDown(K.LeftControl) then mv -= Vector3.yAxis end
        local boost = U:IsKeyDown(K.LeftShift) and 3 or 1
        if mv.Magnitude > 0 then pos = pos + mv.Unit * CFG.FreecamSpd * boost * dt end
        Cam.CFrame = CFrame.new(pos) * rot
    end))
end

local xrayParts, xrayTok = {}, 0
Fn.stopXray = function()
    xrayTok += 1
    En.Xray = false
    for p, o in pairs(xrayParts) do
        if p and p.Parent then p.LocalTransparencyModifier = o end
    end
    table.clear(xrayParts)
end
Fn.startXray = function()
    En.Xray = true
    xrayTok += 1
    local my = xrayTok
    task.spawn(function()
        while xrayTok == my do
            local r = rt(ch())
            if r then
                for _, p in ipairs(workspace:GetPartBoundsInRadius(r.Position, CFG.XrayRad)) do
                    if p:IsA("BasePart") and not p:IsDescendantOf(ch()) then
                        if xrayParts[p] == nil then xrayParts[p] = p.LocalTransparencyModifier end
                        p.LocalTransparencyModifier = 0.85
                    end
                end
            end
            task.wait(CFG.XrayInt)
        end
    end)
end

local savedL = nil
Fn.stopFB = function()
    D("FB")
    if savedL then
        for k, v in pairs(savedL) do L[k] = v end
        savedL = nil
    end
end

--==================== ABAS ====================
local Tabs = {}

Tabs.PLAYER = function(Pg)
    sec(Pg, "Seleção de jogador")
    UI.Nick = tbox(Pg, "Nick do jogador")
    SelLbl = lbl(Pg, "Selecionado: Nenhum")
    btn(Pg, "SELECIONAR PELO NICK", function()
        local q = string.lower(UI.Nick.Text)
        if q == "" then toast("Digite um nick", Theme.Bad) return end
        local partial
        for _, p in ipairs(P:GetPlayers()) do
            local n, d = string.lower(p.Name), string.lower(p.DisplayName)
            if n == q or d == q then selectP(p) return end
            if not partial and (n:sub(1, #q) == q or d:sub(1, #q) == q) then partial = p end
        end
        if partial then selectP(partial) else toast("Não encontrado", Theme.Bad) end
    end)
    feature(Pg, "ClickSel", "SELECIONAR CLICANDO", function(on)
        D("ClickSel")
        if on then
            C("ClickSel", U.InputBegan:Connect(function(i, t)
                if t then return end
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    local tg = LP:GetMouse().Target
                    local mdl = tg and tg:FindFirstAncestorOfClass("Model")
                    local p = mdl and P:GetPlayerFromCharacter(mdl)
                    if p and p ~= LP then selectP(p) end
                end
            end))
        end
    end)
    EX(function() D("ClickSel") end, H.ClickSel)

    sec(Pg, "Lista de jogadores")
    local Lst = new("ScrollingFrame", {Size = UDim2.new(1, -8, 0, 170), BorderSizePixel = 0, ScrollBarThickness = 3,
        AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), LayoutOrder = LO(Pg)}, Pg)
    rcorner(Lst, -4)
    themed(function() Lst.BackgroundColor3 = Theme.Main Lst.BackgroundTransparency = 0.3 Lst.ScrollBarImageColor3 = Theme.Accent end)
    new("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, Lst)
    local PRow, rowN = {}, 0
    local function recolor()
        for p, o in pairs(PRow) do
            o.b.BackgroundColor3 = (Sel == p) and Theme.Accent or Theme.Element
            o.n1.TextColor3 = Theme.Text
            o.n2.TextColor3 = Theme.Sub
        end
    end
    themed(recolor)
    local function addRow(p)
        if p == LP or PRow[p] then return end
        rowN += 1
        local b = new("TextButton", {Size = UDim2.new(1, -8, 0, 38), Text = "", AutoButtonColor = false,
            BorderSizePixel = 0, LayoutOrder = rowN}, Lst)
        new("UICorner", {CornerRadius = UDim.new(0, 6)}, b)
        local av = new("ImageLabel", {Size = UDim2.fromOffset(30, 30), Position = UDim2.fromOffset(4, 4), BackgroundTransparency = 0.5,
            Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=60&h=60", BorderSizePixel = 0}, b)
        new("UICorner", {CornerRadius = UDim.new(1, 0)}, av)
        local n1 = new("TextLabel", {Size = UDim2.new(1, -44, 0, 16), Position = UDim2.fromOffset(40, 3), BackgroundTransparency = 1,
            Text = p.DisplayName .. " (@" .. p.Name .. ")", Font = Enum.Font.GothamMedium, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, b)
        local n2 = new("TextLabel", {Size = UDim2.new(1, -44, 0, 14), Position = UDim2.fromOffset(40, 19), BackgroundTransparency = 1,
            Text = "...", Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left}, b)
        b.MouseButton1Click:Connect(function() selectP(p) recolor() end)
        PRow[p] = {b = b, n1 = n1, n2 = n2}
        recolor()
    end
    for _, p in ipairs(P:GetPlayers()) do addRow(p) end
    P.PlayerAdded:Connect(addRow)
    P.PlayerRemoving:Connect(function(p)
        if Sel == p then
            Sel = nil
            SelLbl.Text = "Selecionado: Nenhum"
        end
        local o = PRow[p]
        if o then o.b:Destroy() PRow[p] = nil end
    end)
    do
        local acc = 0
        R.Heartbeat:Connect(function(dt)
            acc += dt
            if acc < 1 then return end
            acc = 0
            local mr = rt(ch())
            for p, o in pairs(PRow) do
                local r = rt(p.Character)
                local d = (mr and r) and math.floor((mr.Position - r.Position).Magnitude) or 0
                o.n2.Text = (p.Team and p.Team.Name or "Sem time") .. "  ·  " .. d .. "m"
            end
            recolor()
        end)
    end

    sec(Pg, "Spectate")
    feature(Pg, "Spec", "SPECTATE MODE", function(on)
        En.Spectate = on
        if on then
            stopC("Spectate")
            if #Fn.specList() > 0 then
                SpecIdx = 0
                Fn.specCycle(1)
            end
        else
            D("Spectate")
            local h = hm(ch())
            if h then Cam.CameraSubject = h end
        end
    end)
    MR.Spectate = H.Spec
    EX(function() D("Spectate") end, H.Spec)
    btn(Pg, "SPEC PRÓXIMO", function() if En.Spectate then Fn.specCycle(1) end end, "SpecNext", Enum.KeyCode.Q)
    btn(Pg, "SPEC ANTERIOR", function() if En.Spectate then Fn.specCycle(-1) end end, "SpecPrev", Enum.KeyCode.E)
end

Tabs.MOVEMENT = function(Pg)
    sec(Pg, "Movimento")
    feature(Pg, "Fly", "FLY", function(on) if on then Fn.startFly() else Fn.stopFly() end end)
    feature(Pg, "Noclip", "NOCLIP", function(on)
        Fn.restoreCol()
        if on then
            En.Noclip = true
            C("Noclip", R.Stepped:Connect(function(_, dt)
                local c = ch()
                if not c then return end
                for _, part in ipairs(c:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if OrigCol[part] == nil then OrigCol[part] = part.CanCollide end
                        part.CanCollide = false
                    end
                end
                local r, h = rt(c), hm(c)
                if not r or not h then return end
                if CFG.NoclipMode == "Total" then
                    local up = (U:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) - (U:IsKeyDown(Enum.KeyCode.LeftControl) and 1 or 0)
                    h:ChangeState(Enum.HumanoidStateType.Physics)
                    r.AssemblyLinearVelocity = Vector3.zero
                    r.CFrame = r.CFrame + (h.MoveDirection * (h.WalkSpeed + CFG.NoclipExtra) + Vector3.new(0, up * 40, 0)) * dt
                elseif CFG.NoclipExtra > 0 and h.MoveDirection.Magnitude > 0 then
                    r.CFrame = r.CFrame + h.MoveDirection * CFG.NoclipExtra * dt
                end
            end))
        end
    end)
    feature(Pg, "InfJ", "INFINITE JUMP", function(on)
        D("InfJ")
        if on then
            C("InfJ", U.JumpRequest:Connect(function()
                local h = hm(ch())
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end))
        end
    end)
    EX(function() D("InfJ") end, H.InfJ)
    feature(Pg, "ClickTP", "CLICK TP (Ctrl + clique)", function(on)
        D("ClickTP")
        if on then
            C("ClickTP", U.InputBegan:Connect(function(i, t)
                if t then return end
                if i.UserInputType == Enum.UserInputType.MouseButton1 and U:IsKeyDown(Enum.KeyCode.LeftControl) then
                    local r = rt(ch())
                    local m = LP:GetMouse()
                    if r and m and m.Hit then r.CFrame = CFrame.new(m.Hit.Position + Vector3.new(0, 3, 0)) end
                end
            end))
        end
    end)
    EX(function() D("ClickTP") end, H.ClickTP)
    feature(Pg, "Free", "FREECAM", function(on)
        if on then
            stopC("Freecam")
            Fn.startFreecam()
        else
            Fn.stopFreecam()
        end
    end, Enum.KeyCode.F)
    MR.Freecam = H.Free
    EX(function() Fn.stopFreecam() end, H.Free)

    sec(Pg, "Extras de movimento")
    local sprintBase = nil
    feature(Pg, "Sprint", "SPRINT AUTOMÁTICO", function(on)
        D("Sprint")
        if sprintBase then
            local h = hm(ch())
            if h then h.WalkSpeed = sprintBase end
            sprintBase = nil
        end
        if on then
            local h0 = hm(ch())
            sprintBase = h0 and h0.WalkSpeed or 16
            C("Sprint", R.Heartbeat:Connect(function()
                local h = hm(ch())
                if h then h.WalkSpeed = (h.MoveDirection.Magnitude > 0) and CFG.SprintSpd or sprintBase end
            end))
        end
    end)
    EX(function() end, H.Sprint)

    feature(Pg, "Spider", "SPIDER (subir paredes)", function(on)
        D("Spider")
        if on then
            C("Spider", R.Heartbeat:Connect(function()
                local c = ch()
                local r, h = rt(c), hm(c)
                if not r or not h then return end
                local look = r.CFrame.LookVector
                local flat = Vector3.new(look.X, 0, look.Z)
                if flat.Magnitude < 0.01 then return end
                local rp = RaycastParams.new()
                rp.FilterType = Enum.RaycastFilterType.Exclude
                rp.FilterDescendantsInstances = {c}
                local hit = workspace:Raycast(r.Position, flat.Unit * 3, rp)
                if hit and (h.MoveDirection.Magnitude > 0 or U:IsKeyDown(Enum.KeyCode.W)) then
                    local v = r.AssemblyLinearVelocity
                    r.AssemblyLinearVelocity = Vector3.new(v.X, CFG.ClimbSpd, v.Z)
                end
            end))
        end
    end)
    EX(function() D("Spider") end, H.Spider)

    feature(Pg, "AntiFall", "ANTI-QUEDA", function(on)
        D("AntiFall")
        if on then
            C("AntiFall", R.Heartbeat:Connect(function()
                local r = rt(ch())
                if not r then return end
                local v = r.AssemblyLinearVelocity
                if v.Y < -CFG.MaxFall then r.AssemblyLinearVelocity = Vector3.new(v.X, -CFG.MaxFall, v.Z) end
            end))
        end
    end)
    EX(function() D("AntiFall") end, H.AntiFall)

    sec(Pg, "Velocidades e modos")
    cycle(Pg, "Modo do fly", {"Câmera", "CFrame", "Avião"}, CFG.FlyMode, function(v) CFG.FlyMode = v end)
    slider(Pg, "Fly speed", 10, 200, CFG.FlySpd, 1, function(v) CFG.FlySpd = v end)
    slider(Pg, "Fly velocidade vertical", 10, 200, CFG.FlyVSpd, 1, function(v) CFG.FlyVSpd = v end)
    slider(Pg, "Freecam speed", 10, 300, CFG.FreecamSpd, 1, function(v) CFG.FreecamSpd = v end)
    cycle(Pg, "Modo do noclip", {"Paredes", "Total"}, CFG.NoclipMode, function(v)
        CFG.NoclipMode = v
        if v ~= "Total" and En.Noclip then
            local h = hm(ch())
            if h then h:ChangeState(Enum.HumanoidStateType.GettingUp) end
        end
    end)
    slider(Pg, "Noclip velocidade extra", 0, 100, CFG.NoclipExtra, 1, function(v) CFG.NoclipExtra = v end)
    slider(Pg, "Sprint speed", 16, 150, CFG.SprintSpd, 1, function(v) CFG.SprintSpd = v end)
    slider(Pg, "Spider velocidade", 10, 120, CFG.ClimbSpd, 1, function(v) CFG.ClimbSpd = v end)
    slider(Pg, "Anti-queda (vel. máx.)", 10, 200, CFG.MaxFall, 1, function(v) CFG.MaxFall = v end)

    sec(Pg, "Player stats")
    local DefGrav = workspace.Gravity
    local sW = slider(Pg, "WalkSpeed", 0, 500, 16, 1, function(v)
        Applied.W = v
        local h = hm(ch())
        if h then h.WalkSpeed = v end
    end)
    local sJ = slider(Pg, "JumpPower", 0, 500, 50, 1, function(v)
        Applied.J = v
        local h = hm(ch())
        if h then h.UseJumpPower = true h.JumpPower = v end
    end)
    local sG = slider(Pg, "Gravidade", 0, 500, DefGrav, 1, function(v) workspace.Gravity = v end)
    btn(Pg, "RESET STATS", function()
        local h = hm(ch())
        if h then
            h.WalkSpeed = 16
            h.UseJumpPower = true
            h.JumpPower = 50
        end
        workspace.Gravity = DefGrav
        Applied.W, Applied.J = nil, nil
        sW.set(16, true) sJ.set(50, true) sG.set(DefGrav, true)
    end)
    EX(function() workspace.Gravity = DefGrav end)

    sec(Pg, "Waypoints")
    local wpName = tbox(Pg, "Nome do waypoint (opcional)")
    local WP = {}
    local wpList = new("ScrollingFrame", {Size = UDim2.new(1, -8, 0, 130), BorderSizePixel = 0, ScrollBarThickness = 3,
        AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), LayoutOrder = LO(Pg)}, Pg)
    rcorner(wpList, -4)
    themed(function() wpList.BackgroundColor3 = Theme.Main wpList.BackgroundTransparency = 0.3 wpList.ScrollBarImageColor3 = Theme.Accent end)
    new("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, wpList)
    local function rebuildWP()
        for _, c in ipairs(wpList:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        for i, w in ipairs(WP) do
            local f = new("Frame", {Size = UDim2.new(1, -8, 0, 28), BorderSizePixel = 0, LayoutOrder = i,
                BackgroundColor3 = Theme.Element}, wpList)
            new("UICorner", {CornerRadius = UDim.new(0, 6)}, f)
            new("TextLabel", {Size = UDim2.new(1, -90, 1, 0), Position = UDim2.fromOffset(8, 0), BackgroundTransparency = 1,
                Text = w.name, TextColor3 = Theme.Text, Font = Enum.Font.GothamMedium, TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, f)
            local go = new("TextButton", {Size = UDim2.fromOffset(34, 20), Position = UDim2.new(1, -78, 0.5, -10), Text = "TP",
                Font = Enum.Font.GothamBold, TextSize = 10, BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text,
                AutoButtonColor = false, BorderSizePixel = 0}, f)
            new("UICorner", {CornerRadius = UDim.new(0, 5)}, go)
            local del = new("TextButton", {Size = UDim2.fromOffset(34, 20), Position = UDim2.new(1, -40, 0.5, -10), Text = "X",
                Font = Enum.Font.GothamBold, TextSize = 10, BackgroundColor3 = Theme.Bad, TextColor3 = Theme.Text,
                AutoButtonColor = false, BorderSizePixel = 0}, f)
            new("UICorner", {CornerRadius = UDim.new(0, 5)}, del)
            go.MouseButton1Click:Connect(function()
                local r = rt(ch())
                if r then r.CFrame = w.cf end
            end)
            del.MouseButton1Click:Connect(function()
                table.remove(WP, i)
                rebuildWP()
            end)
        end
    end
    themed(rebuildWP)
    btn(Pg, "SALVAR WAYPOINT AQUI", function()
        local r = rt(ch())
        if not r then return end
        local n = wpName.Text ~= "" and wpName.Text or ("WP " .. (#WP + 1))
        table.insert(WP, {name = n, cf = r.CFrame})
        wpName.Text = ""
        rebuildWP()
        toast("Waypoint salvo: " .. n, Theme.Good)
    end)
end

Tabs.TROLL = function(Pg)
    sec(Pg, "Ações no jogador")
    btn(Pg, "GOTO SELECTED", function()
        local t, r = srt(), rt(ch())
        if t and r then r.CFrame = t.CFrame * CFrame.new(0, 0, 5) end
    end, "Goto")
    btn(Pg, "SCARY - TP + RETURN", function()
        local t = srt()
        local c = ch()
        local r = rt(c)
        if not t or not r then return end
        local o = r.CFrame
        r.CFrame = t.CFrame * CFrame.new(0, 0, 4)
        task.delay(CFG.ScaryDur, function()
            if LP.Character == c and r.Parent then r.CFrame = o end
        end)
    end, "Scary")

    feature(Pg, "View", "VIEW PLAYER", function(on)
        D("View")
        En.View = on
        if on then
            if not Sel then
                if H.View then H.View() end
                return
            end
            stopC("View")
            C("View", R.RenderStepped:Connect(function()
                local h = hm(Sel and Sel.Character)
                if h and Cam.CameraSubject ~= h then Cam.CameraSubject = h end
            end))
        else
            local h = hm(ch())
            if h then Cam.CameraSubject = h end
        end
    end)
    MR.View = H.View

    feature(Pg, "Follow", "FOLLOW PLAYER", function(on)
        D("Follow")
        En.Follow = on
        if on then
            stopT("Follow")
            C("Follow", R.Heartbeat:Connect(function()
                local t, r = srt(), rt(ch())
                if t and r then
                    r.CFrame = t.CFrame * CFrame.new(0, 0, CFG.FollowD)
                    r.AssemblyLinearVelocity = Vector3.zero
                end
            end))
        end
    end)
    MR.Follow = H.Follow

    feature(Pg, "Spin", "SPIN", function(on)
        En.Spin = on
        if on then
            local h = hm(ch())
            if h then h.AutoRotate = false end
            C("Spin", R.Heartbeat:Connect(function(dt)
                local r = rt(ch())
                if r then r.CFrame = r.CFrame * CFrame.Angles(0, CFG.SpinSpd * dt, 0) end
            end))
        else
            Fn.stopSpin()
        end
    end)
    MR.Spin = H.Spin

    sec(Pg, "Fling")
    -- Ancora o HRP e tremula a posição dele bem rápido perto do alvo (ou ao
    -- redor de você mesmo, sem alvo). Ancorado = você não vai junto, não gira
    -- e não sai voando; quem está tocando ainda recebe o empurrão forte.
    local function flingTick(targetFollow)
        local tick = 0
        return R.Heartbeat:Connect(function()
            local r = rt(ch())
            if not r then return end
            if FlingRoot ~= r then
                FlingOrigAnchored = r.Anchored
                FlingRoot = r
            end
            r.Anchored = true
            tick += 1
            local center, radius
            if targetFollow then
                local t = srt()
                if not t then return end
                center, radius = t.Position, 2 + CFG.FlingPower / 4000 -- fica colado nele
            else
                center, radius = r.Position, 4 + CFG.FlingPower / 2000 -- varre uma área maior ao redor de você
            end
            local ang = math.rad((tick * 149) % 360) -- gira rápido e sem repetir padrão óbvio
            local sign = (tick % 2 == 0) and 1 or -1  -- alterna o lado a cada frame = o "chicote" do fling
            local dir = Vector3.new(math.cos(ang), 0, math.sin(ang))
            local offset = dir * radius * sign + Vector3.new(0, radius * 0.35, 0)
            r.CFrame = CFrame.new(center + offset) * CFrame.Angles(0, math.rad((tick * CFG.FlingSpin) % 360), 0)
        end)
    end
    local function startFling(targetFollow)
        Fn.stopFling()
        local r = rt(ch())
        if not r then return end
        FlingOrigAnchored = r.Anchored
        FlingRoot = r
        C("Fling", flingTick(targetFollow))
    end
    feature(Pg, "Fling", "FLING (sem alvo)", function(on)
        if on then
            if H.FlingT then H.FlingT() end
            startFling(false)
        else
            Fn.stopFling()
        end
    end)
    feature(Pg, "FlingT", "FLING (no alvo selecionado)", function(on)
        if on then
            if H.Fling then H.Fling() end
            if not Sel then
                toast("Selecione um jogador", Theme.Bad)
                if H.FlingT then H.FlingT() end
                return
            end
            startFling(true)
        else
            Fn.stopFling()
        end
    end)
    EX(function() Fn.stopFling() end, H.Fling)
    lbl(Pg, "Precisa de colisão entre jogadores ligada no jogo. Em jogos com anti-fling, pode não funcionar.")

    sec(Pg, "Mais troll")
    feature(Pg, "Orbit", "ORBIT PLAYER", function(on)
        if not on then D("Orbit") return end
        if not Sel then
            if H.Orbit then H.Orbit() end
            return
        end
        stopT("Orbit")
        D("Orbit")
        local ang = 0
        C("Orbit", R.Heartbeat:Connect(function(dt)
            local t, r = srt(), rt(ch())
            if not t or not r then return end
            ang += dt * CFG.OrbitSpd
            local ctr = t.Position
            local pos = ctr + Vector3.new(math.cos(ang), 0, math.sin(ang)) * CFG.OrbitR
            r.CFrame = CFrame.lookAt(pos, Vector3.new(ctr.X, pos.Y, ctr.Z))
            r.AssemblyLinearVelocity = Vector3.zero
        end))
    end)
    MR.Orbit = H.Orbit

    MS.HeadSit = function()
        local h = hm(ch())
        if h then h.Sit = false end
    end
    feature(Pg, "HeadSit", "SENTAR NA CABEÇA", function(on)
        if not on then
            D("HeadSit")
            MS.HeadSit()
            return
        end
        if not Sel then
            if H.HeadSit then H.HeadSit() end
            return
        end
        stopT("HeadSit")
        D("HeadSit")
        C("HeadSit", R.Heartbeat:Connect(function()
            local tc = Sel and Sel.Character
            local hd = tc and tc:FindFirstChild("Head")
            local c = ch()
            local r, h = rt(c), hm(c)
            if hd and r then
                r.CFrame = hd.CFrame * CFrame.new(0, 2, 0)
                r.AssemblyLinearVelocity = Vector3.zero
                if h then h.Sit = true end
            end
        end))
    end)
    MR.HeadSit = H.HeadSit

    feature(Pg, "Shake", "TREMER PERTO", function(on)
        if not on then D("Shake") return end
        if not Sel then
            if H.Shake then H.Shake() end
            return
        end
        stopT("Shake")
        D("Shake")
        C("Shake", R.Heartbeat:Connect(function()
            local t, r = srt(), rt(ch())
            if not t or not r then return end
            r.CFrame = t.CFrame * CFrame.new(math.random(-30, 30) / 10, 0, math.random(-30, 30) / 10)
            r.AssemblyLinearVelocity = Vector3.zero
        end))
    end)
    MR.Shake = H.Shake

    local scaryTok = 0
    feature(Pg, "LoopScary", "LOOP SCARY", function(on)
        scaryTok += 1
        if not on then return end
        if not Sel then
            if H.LoopScary then H.LoopScary() end
            return
        end
        local my = scaryTok
        task.spawn(function()
            while scaryTok == my do
                local t = srt()
                local c = ch()
                local r = rt(c)
                if t and r then
                    local o = r.CFrame
                    r.CFrame = t.CFrame * CFrame.new(0, 0, 4)
                    task.wait(CFG.ScaryDur)
                    if LP.Character == c and r.Parent then r.CFrame = o end
                end
                task.wait(CFG.ScaryDelay)
            end
        end)
    end)
    EX(function() scaryTok += 1 end, H.LoopScary)

    feature(Pg, "SpamJ", "SPAM JUMP", function(on)
        D("SpamJ")
        if on then
            C("SpamJ", R.Heartbeat:Connect(function()
                local h = hm(ch())
                if h then h.Jump = true end
            end))
        end
    end)
    EX(function() D("SpamJ") end, H.SpamJ)

    btn(Pg, "LANÇAR PRO CÉU", function()
        local r = rt(ch())
        if r then r.AssemblyLinearVelocity = Vector3.new(0, 220, 0) end
    end, "Launch")
    btn(Pg, "TP PLAYER ALEATÓRIO", function()
        local o = {}
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= LP and rt(p.Character) then table.insert(o, p) end
        end
        local r = rt(ch())
        if #o > 0 and r then
            local p = o[math.random(1, #o)]
            selectP(p)
            r.CFrame = rt(p.Character).CFrame * CFrame.new(0, 0, 5)
        end
    end, "TPRand")

    sec(Pg, "Chat spam")
    local msgBox = tbox(Pg, "Mensagem do chat")
    local function sendChat(msg)
        local ok = pcall(function()
            local chs = TCS:FindFirstChild("TextChannels")
            local gen = chs and chs:FindFirstChild("RBXGeneral")
            if not gen then error("sem TextChatService") end
            gen:SendAsync(msg)
        end)
        if not ok then
            pcall(function()
                RS.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
            end)
        end
    end
    btn(Pg, "ENVIAR MENSAGEM 1X", function()
        if msgBox.Text == "" then toast("Digite uma mensagem", Theme.Bad) return end
        sendChat(msgBox.Text)
    end, "ChatSend")
    local spamTok = 0
    feature(Pg, "ChatSpam", "CHAT SPAM", function(on)
        spamTok += 1
        if not on then return end
        if msgBox.Text == "" then
            toast("Digite uma mensagem", Theme.Bad)
            if H.ChatSpam then H.ChatSpam() end
            return
        end
        local my = spamTok
        task.spawn(function()
            while spamTok == my do
                sendChat(msgBox.Text)
                task.wait(CFG.SpamDelay)
            end
        end)
    end)
    EX(function() spamTok += 1 end, H.ChatSpam)
    slider(Pg, "Intervalo do spam (s)", 1, 30, CFG.SpamDelay, 0.5, function(v) CFG.SpamDelay = v end)

    sec(Pg, "Roupa (client)")
    local function isOutfit(i)
        return i:IsA("Accessory") or i:IsA("Shirt") or i:IsA("Pants") or i:IsA("ShirtGraphic") or i:IsA("BodyColors")
    end
    local function clearOutfit(mc)
        for _, c in ipairs(mc:GetChildren()) do
            if isOutfit(c) then c:Destroy() end
        end
    end
    local function faceOf(c)
        local hd = c and c:FindFirstChild("Head")
        return hd and hd:FindFirstChildOfClass("Decal")
    end
    btn(Pg, "COPIAR ROUPA DO SELECIONADO (client)", function()
        local tc, mc = Sel and Sel.Character, ch()
        local mh = hm(mc)
        if not tc or not mc or not mh then toast("Selecione um jogador", Theme.Bad) return end
        if not Applied.OutfitOrig then
            Applied.OutfitOrig = {}
            for _, c in ipairs(mc:GetChildren()) do
                if isOutfit(c) then table.insert(Applied.OutfitOrig, c:Clone()) end
            end
            local f = faceOf(mc)
            Applied.FaceOrig = f and f.Texture or nil
        end
        clearOutfit(mc)
        for _, c in ipairs(tc:GetChildren()) do
            if c:IsA("Accessory") then
                mh:AddAccessory(c:Clone())
            elseif isOutfit(c) then
                c:Clone().Parent = mc
            end
        end
        local tf, mf = faceOf(tc), faceOf(mc)
        if tf and mf then mf.Texture = tf.Texture end
        toast("Roupa copiada (só você vê)", Theme.Good)
    end, "CopyOutfit")
    btn(Pg, "RESTAURAR MINHA ROUPA", function()
        local mc = ch()
        local mh = hm(mc)
        if not mc or not mh or not Applied.OutfitOrig then toast("Nada para restaurar", Theme.Bad) return end
        clearOutfit(mc)
        for _, c in ipairs(Applied.OutfitOrig) do
            if c:IsA("Accessory") then mh:AddAccessory(c:Clone()) else c:Clone().Parent = mc end
        end
        local mf = faceOf(mc)
        if mf and Applied.FaceOrig then mf.Texture = Applied.FaceOrig end
        toast("Roupa restaurada", Theme.Good)
    end, "RestoreOutfit")

    sec(Pg, "Troll settings")
    slider(Pg, "Spin speed", -100, 100, CFG.SpinSpd, 1, function(v) CFG.SpinSpd = v end)
    slider(Pg, "Orbit raio", 2, 100, CFG.OrbitR, 1, function(v) CFG.OrbitR = v end)
    slider(Pg, "Orbit velocidade", -30, 30, CFG.OrbitSpd, 0.5, function(v) CFG.OrbitSpd = v end)
    slider(Pg, "Follow distância", 1, 100, CFG.FollowD, 1, function(v) CFG.FollowD = v end)
    slider(Pg, "Scary duração (s)", 0.2, 10, CFG.ScaryDur, 0.1, function(v) CFG.ScaryDur = v end)
    slider(Pg, "Scary intervalo (s)", 0.5, 20, CFG.ScaryDelay, 0.5, function(v) CFG.ScaryDelay = v end)
    slider(Pg, "Força do fling", 1000, 20000, CFG.FlingPower, 500, function(v) CFG.FlingPower = v end)
    slider(Pg, "Giro do fling", 100, 3000, CFG.FlingSpin, 100, function(v) CFG.FlingSpin = v end)
end

Tabs.VISUAL = function(Pg)
    sec(Pg, "Visual")
    feature(Pg, "Xray", "X-RAY (paredes)", function(on)
        if on then Fn.startXray() else Fn.stopXray() end
    end, Enum.KeyCode.X)
    EX(function() Fn.stopXray() end, H.Xray)

    feature(Pg, "FB", "FULLBRIGHT", function(on)
        if on then
            Fn.stopFB()
            savedL = {Brightness = L.Brightness, ClockTime = L.ClockTime, FogEnd = L.FogEnd,
                GlobalShadows = L.GlobalShadows, Ambient = L.Ambient, OutdoorAmbient = L.OutdoorAmbient}
            C("FB", R.Heartbeat:Connect(function()
                L.Brightness = 2
                L.ClockTime = 14
                L.FogEnd = 1e6
                L.GlobalShadows = false
                L.Ambient = rgb(178, 178, 178)
                L.OutdoorAmbient = rgb(178, 178, 178)
            end))
        else
            Fn.stopFB()
        end
    end)
    EX(function() Fn.stopFB() end, H.FB)

    feature(Pg, "AFK", "ANTI AFK", function(on)
        D("AFK")
        if on then
            C("AFK", LP.Idled:Connect(function()
                VU:CaptureController()
                VU:ClickButton2(Vector2.new())
            end))
        end
    end)
    EX(function() D("AFK") end, H.AFK)

    slider(Pg, "X-ray raio", 10, 200, CFG.XrayRad, 1, function(v) CFG.XrayRad = v end)
    slider(Pg, "Hora do dia (client)", 0, 24, L.ClockTime, 0.1, function(v) L.ClockTime = v end)

    sec(Pg, "Skybox (cliente)")
    local function applySky(rawId)
        local id = tostring(rawId):gsub("%s+", "")
        if id == "" then toast("Digite um ID", Theme.Bad) return end
        if id:match("^%d+$") then id = "rbxassetid://" .. id end
        if not id:match("^rbxassetid://") and not id:match("^rbxasset://") then
            toast("ID inválido", Theme.Bad)
            return
        end
        if not origSky then
            origSky = {}
            for _, obj in ipairs(L:GetChildren()) do
                if obj:IsA("Sky") then
                    table.insert(origSky, obj:Clone())
                    obj:Destroy()
                end
            end
        end
        for _, obj in ipairs(L:GetChildren()) do
            if obj:IsA("Sky") and obj.Name == "N_SKY" then obj:Destroy() end
        end
        new("Sky", {Name = "N_SKY", SkyboxBk = id, SkyboxDn = id, SkyboxFt = id, SkyboxLf = id,
            SkyboxRt = id, SkyboxUp = id, SunAngularSize = 0, MoonAngularSize = 0}, L)
        toast("Skybox aplicado", Theme.Good)
    end
    local function removeSky()
        for _, obj in ipairs(L:GetChildren()) do
            if obj:IsA("Sky") then obj:Destroy() end
        end
        if origSky then
            for _, sky in ipairs(origSky) do
                if sky then sky:Clone().Parent = L end
            end
        end
        toast("Skybox restaurado", Theme.Good)
    end

    local presets = OWNER.SkyboxPresets or {}
    if #presets > 0 then
        lbl(Pg, "Presets (configurados no script):")
        for _, p in ipairs(presets) do
            btn(Pg, p.Name or tostring(p.Id), function() applySky(p.Id) end)
        end
    end

    local SkyBox = tbox(Pg, "ID do skybox (ex: 123456)")
    btn(Pg, "APLICAR SKYBOX DIGITADO", function() applySky(SkyBox.Text) end)
    btn(Pg, "REMOVER SKYBOX", function() removeSky() end)
    lbl(Pg, "Só afeta você (client-side). O ID precisa ser de uma Image, não de um Decal.")

    sec(Pg, "Câmera")
    local fovS = slider(Pg, "FOV", 30, 120, 70, 1, function(v) Cam.FieldOfView = v end)
    btn(Pg, "RESET FOV", function()
        Cam.FieldOfView = 70
        fovS.set(70, true)
    end)
    local zoomOrig = nil
    feature(Pg, "Zoom", "ZOOM INFINITO", function(on)
        D("Zoom")
        if on then
            zoomOrig = zoomOrig or {Max = LP.CameraMaxZoomDistance, Min = LP.CameraMinZoomDistance, Mode = LP.CameraMode}
            C("Zoom", R.RenderStepped:Connect(function()
                if LP.CameraMode ~= Enum.CameraMode.Classic then LP.CameraMode = Enum.CameraMode.Classic end
                if LP.CameraMaxZoomDistance ~= CFG.ZoomMax then LP.CameraMaxZoomDistance = CFG.ZoomMax end
                if LP.CameraMinZoomDistance ~= 0.5 then LP.CameraMinZoomDistance = 0.5 end
            end))
        elseif zoomOrig then
            LP.CameraMaxZoomDistance = zoomOrig.Max
            LP.CameraMinZoomDistance = zoomOrig.Min
            LP.CameraMode = zoomOrig.Mode
            zoomOrig = nil
        end
    end)

    sec(Pg, "Utilidades")
    btn(Pg, "SALVAR POSIÇÃO", function()
        local r = rt(ch())
        if r then
            savedPos = r.CFrame
            toast("Posição salva", Theme.Good)
        end
    end, "SavePos")
    btn(Pg, "IR PARA POSIÇÃO", function()
        local r = rt(ch())
        if r and savedPos then r.CFrame = savedPos end
    end, "SavedPos", Enum.KeyCode.G)
    btn(Pg, "RESETAR PERSONAGEM", function()
        local h = hm(ch())
        if h then h.Health = 0 end
    end, "ResetChar")
    btn(Pg, "REJOIN (mantém suas configs)", function()
        local ok, json = pcall(function() return HS:JSONEncode(cfgExport()) end)
        pcall(function()
            TS:Teleport(game.PlaceId, LP, ok and {N_SYSTEM_CFG = json} or nil)
        end)
    end)
end

Tabs.ESP = function(Pg)
    local E = {Chams = true, Name = true, Dist = true, Health = false, HealthBar = true, Weapon = false,
        Box = true, Tracers = false, Skeleton = false, TeamColor = true, TeamName = false, HideMyTeam = false,
        TeamFilter = "", MaxDist = 2000, Origin = "Baixo"}
    local ESPgui = new("ScreenGui", {Name = "N_ESP", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 3}, PG)
    local objs = {}
    local R15 = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}}
    local R6 = {{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}}

    local function mkLine()
        return new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, Visible = false}, ESPgui)
    end
    local function setLine(f, a, b, col)
        local d = b - a
        f.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
        f.Size = UDim2.fromOffset(d.Magnitude, 1.5)
        f.Rotation = math.deg(math.atan2(d.Y, d.X))
        f.BackgroundColor3 = col
        f.Visible = true
    end
    local function mkLabel(anchor)
        return new("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 12,
            TextStrokeTransparency = 0.4, Visible = false, Size = UDim2.fromOffset(220, 16), AnchorPoint = anchor}, ESPgui)
    end
    local function mkObj()
        local o = {}
        o.box = new("Frame", {BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false}, ESPgui)
        o.stroke = new("UIStroke", {Thickness = 1.5}, o.box)
        o.hpBack = new("Frame", {BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.4,
            BorderSizePixel = 0, Visible = false}, ESPgui)
        o.hpFill = new("Frame", {AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), BorderSizePixel = 0}, o.hpBack)
        o.top = mkLabel(Vector2.new(0.5, 1))
        o.bot = mkLabel(Vector2.new(0.5, 0))
        o.tracer = mkLine()
        o.skel = {}
        return o
    end
    local function hide(o)
        o.box.Visible = false o.hpBack.Visible = false o.top.Visible = false o.bot.Visible = false o.tracer.Visible = false
        for _, l in ipairs(o.skel) do l.Visible = false end
    end
    local function destroyObj(o)
        for _, k in ipairs({"box", "hpBack", "top", "bot", "tracer"}) do o[k]:Destroy() end
        for _, l in ipairs(o.skel) do l:Destroy() end
    end
    local function clearAll()
        for _, o in pairs(objs) do destroyObj(o) end
        table.clear(objs)
        for _, p in ipairs(P:GetPlayers()) do
            local c = p.Character
            local hl = c and c:FindFirstChild("N_ESP")
            if hl then hl:Destroy() end
        end
    end
    P.PlayerRemoving:Connect(function(p)
        local o = objs[p]
        if o then destroyObj(o) objs[p] = nil end
    end)

    local function update()
        local cp = Cam.CFrame.Position
        local vs = Cam.ViewportSize
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= LP then
                local o = objs[p]
                if not o then o = mkObj() objs[p] = o end
                local c = p.Character
                local r, h = rt(c), hm(c)
                local col = (E.TeamColor and p.Team) and p.TeamColor.Color or Theme.Accent
                local shown = false
                local skip = false
                if E.HideMyTeam and p.Team and LP.Team and p.Team == LP.Team then skip = true end
                if not skip and E.TeamFilter ~= "" and
                    not (p.Team and string.lower(p.Team.Name) == string.lower(E.TeamFilter)) then skip = true end
                if not skip and r and h and h.Health > 0 and (r.Position - cp).Magnitude <= E.MaxDist then
                    local tp = Cam:WorldToViewportPoint(r.Position + Vector3.new(0, 3, 0))
                    local bp = Cam:WorldToViewportPoint(r.Position - Vector3.new(0, 3.2, 0))
                    if tp.Z > 0 and bp.Z > 0 then
                        shown = true
                        local hgt = math.max(bp.Y - tp.Y, 4)
                        local w = hgt * 0.55
                        local cx = (tp.X + bp.X) / 2
                        o.box.Visible = E.Box
                        if E.Box then
                            o.box.Position = UDim2.fromOffset(cx - w / 2, tp.Y)
                            o.box.Size = UDim2.fromOffset(w, hgt)
                            o.stroke.Color = col
                        end
                        local ratio = math.clamp(h.Health / math.max(h.MaxHealth, 1), 0, 1)
                        o.hpBack.Visible = E.HealthBar
                        if E.HealthBar then
                            o.hpBack.Position = UDim2.fromOffset(cx - w / 2 - 6, tp.Y)
                            o.hpBack.Size = UDim2.fromOffset(3, hgt)
                            o.hpFill.Size = UDim2.new(1, 0, ratio, 0)
                            o.hpFill.BackgroundColor3 = Color3.fromHSV(ratio * 0.33, 1, 1)
                        end
                        local parts = {}
                        if E.Name then parts[#parts + 1] = p.DisplayName end
                        if E.TeamName then parts[#parts + 1] = "(" .. (p.Team and p.Team.Name or "Sem time") .. ")" end
                        if E.Dist then parts[#parts + 1] = "[" .. math.floor((r.Position - cp).Magnitude) .. "m]" end
                        if E.Health then parts[#parts + 1] = math.floor(h.Health) .. "hp" end
                        o.top.Visible = #parts > 0
                        if #parts > 0 then
                            o.top.Text = table.concat(parts, " ")
                            o.top.Position = UDim2.fromOffset(cx, tp.Y - 2)
                            o.top.TextColor3 = col
                        end
                        local tool = E.Weapon and c:FindFirstChildOfClass("Tool") or nil
                        o.bot.Visible = tool ~= nil
                        if tool then
                            o.bot.Text = tool.Name
                            o.bot.Position = UDim2.fromOffset(cx, bp.Y + 2)
                            o.bot.TextColor3 = col
                        end
                        o.tracer.Visible = false
                        if E.Tracers then
                            local from
                            if E.Origin == "Cima" then from = Vector2.new(vs.X / 2, 0)
                            elseif E.Origin == "Centro" then from = vs / 2
                            else from = Vector2.new(vs.X / 2, vs.Y) end
                            setLine(o.tracer, from, Vector2.new(cx, bp.Y), col)
                        end
                        local used = 0
                        if E.Skeleton then
                            local list = c:FindFirstChild("UpperTorso") and R15 or R6
                            for _, pr in ipairs(list) do
                                local a, b = c:FindFirstChild(pr[1]), c:FindFirstChild(pr[2])
                                if a and b then
                                    local pa = Cam:WorldToViewportPoint(a.Position)
                                    local pb = Cam:WorldToViewportPoint(b.Position)
                                    if pa.Z > 0 and pb.Z > 0 then
                                        used += 1
                                        local l = o.skel[used]
                                        if not l then l = mkLine() o.skel[used] = l end
                                        setLine(l, Vector2.new(pa.X, pa.Y), Vector2.new(pb.X, pb.Y), col)
                                    end
                                end
                            end
                        end
                        for i = used + 1, #o.skel do o.skel[i].Visible = false end
                    end
                end
                if not shown then hide(o) end
                if c then
                    local hl = c:FindFirstChild("N_ESP")
                    if E.Chams then
                        if not hl then
                            hl = new("Highlight", {Name = "N_ESP", FillTransparency = 0.6,
                                DepthMode = Enum.HighlightDepthMode.AlwaysOnTop}, c)
                        end
                        hl.FillColor = col
                        hl.OutlineColor = Theme.Text
                    elseif hl then
                        hl:Destroy()
                    end
                end
            end
        end
    end

    sec(Pg, "ESP de jogadores")
    feature(Pg, "ESP", "ESP (MASTER)", function(on)
        D("ESP")
        clearAll()
        if on then C("ESP", R.RenderStepped:Connect(update)) end
    end)
    EX(function() D("ESP") clearAll() end, H.ESP)

    sec(Pg, "O que mostrar")
    toggle(Pg, "CAIXAS", function(on) E.Box = on end, {def = E.Box})
    toggle(Pg, "BARRA DE VIDA", function(on) E.HealthBar = on end, {def = E.HealthBar})
    toggle(Pg, "NOME", function(on) E.Name = on end, {def = E.Name})
    toggle(Pg, "DISTÂNCIA", function(on) E.Dist = on end, {def = E.Dist})
    toggle(Pg, "VIDA (número)", function(on) E.Health = on end)
    toggle(Pg, "ARMA", function(on) E.Weapon = on end)
    toggle(Pg, "TRACERS", function(on) E.Tracers = on end)
    toggle(Pg, "ESQUELETO", function(on) E.Skeleton = on end)
    toggle(Pg, "CHAMS (brilho)", function(on) E.Chams = on end, {def = E.Chams})
    toggle(Pg, "COR POR TIME", function(on) E.TeamColor = on end, {def = E.TeamColor})
    toggle(Pg, "NOME DO TIME", function(on) E.TeamName = on end, {def = E.TeamName})
    toggle(Pg, "ESCONDER MEU TIME", function(on) E.HideMyTeam = on end, {def = E.HideMyTeam})

    sec(Pg, "Ajustes")
    slider(Pg, "Distância máxima", 50, 5000, E.MaxDist, 10, function(v) E.MaxDist = v end)
    cycle(Pg, "Origem dos tracers", {"Baixo", "Centro", "Cima"}, E.Origin, function(v) E.Origin = v end)
    local teamFilterBox = tbox(Pg, "Só mostrar esse time (nome exato, vazio = todos)")
    teamFilterBox:GetPropertyChangedSignal("Text"):Connect(function() E.TeamFilter = teamFilterBox.Text end)

    sec(Pg, "ESP de itens")
    local itemBox = tbox(Pg, "Itens (nomes separados por vírgula)")
    local itemObjs = {}
    local function clearItems()
        for _, g in pairs(itemObjs) do g:Destroy() end
        table.clear(itemObjs)
    end
    local function parseNames()
        local names = {}
        for n in string.gmatch(string.lower(itemBox.Text), "[^,]+") do
            n = n:gsub("^%s+", ""):gsub("%s+$", "")
            if n ~= "" then names[#names + 1] = n end
        end
        return names
    end
    feature(Pg, "ItemESP", "ESP DE ITENS", function(on)
        D("ItemESP")
        clearItems()
        if not on then return end
        local names = parseNames()
        if #names == 0 then
            toast("Digite os nomes dos itens", Theme.Bad)
            if H.ItemESP then H.ItemESP() end
            return
        end
        local scanT, updT = 99, 0
        C("ItemESP", R.Heartbeat:Connect(function(dt)
            scanT += dt
            updT += dt
            if scanT >= 3 then
                scanT = 0
                names = parseNames()
                local count = 0
                for _ in pairs(itemObjs) do count += 1 end
                for _, d in ipairs(workspace:GetDescendants()) do
                    if count >= 80 then break end
                    if (d:IsA("Model") or d:IsA("BasePart")) and not itemObjs[d] then
                        local ln = d.Name:lower()
                        local match = false
                        for _, k in ipairs(names) do
                            if ln:find(k, 1, true) then match = true break end
                        end
                        if match then
                            local m = d:IsA("Model") and d or d:FindFirstAncestorWhichIsA("Model")
                            if not (m and m:FindFirstChildOfClass("Humanoid")) then
                                local adornee = d:IsA("Model") and (d.PrimaryPart or d:FindFirstChildWhichIsA("BasePart")) or d
                                if adornee then
                                    local g = new("BillboardGui", {Size = UDim2.fromOffset(160, 20), StudsOffset = Vector3.new(0, 2, 0),
                                        AlwaysOnTop = true, Adornee = adornee}, ESPgui)
                                    new("TextLabel", {Name = "L", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
                                        TextColor3 = Theme.Good, TextStrokeTransparency = 0.3, Font = Enum.Font.GothamBold,
                                        TextSize = 12, Text = d.Name}, g)
                                    itemObjs[d] = g
                                    count += 1
                                end
                            end
                        end
                    end
                end
            end
            if updT >= 0.3 then
                updT = 0
                local mr = rt(ch())
                for d, g in pairs(itemObjs) do
                    if not d.Parent or not d:IsDescendantOf(workspace) then
                        g:Destroy()
                        itemObjs[d] = nil
                    elseif mr and g.Adornee then
                        g.L.Text = d.Name .. " [" .. math.floor((g.Adornee.Position - mr.Position).Magnitude) .. "m]"
                    end
                end
            end
        end))
    end)
    EX(function() D("ItemESP") clearItems() end, H.ItemESP)
end

Tabs.AIMBOT = function(Pg)
    sec(Pg, "Aimbot")
    local fovCircle = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false}, FovGui)
    new("UICorner", {CornerRadius = UDim.new(0.5, 0)}, fovCircle)
    local fs = new("UIStroke", {Thickness = 1.5, Transparency = 0.4}, fovCircle)
    themed(function() fs.Color = Theme.Accent end)
    local function updateFovSize() fovCircle.Size = UDim2.fromOffset(Aimbot.FOV * 2, Aimbot.FOV * 2) end
    updateFovSize()

    local locked = nil
    local rpVis = RaycastParams.new()
    rpVis.FilterType = Enum.RaycastFilterType.Exclude

    local function originPos()
        if Aimbot.Origin == "Mouse" then return U:GetMouseLocation() end
        return Cam.ViewportSize / 2
    end
    local function aimPart(c)
        local part
        if Aimbot.Part == "Torso" then part = c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")
        elseif Aimbot.Part == "Root" then part = rt(c)
        else part = c:FindFirstChild("Head") end
        return part or rt(c)
    end
    local function aimPoint(part)
        local pos = part.Position
        if Aimbot.Prediction > 0 then pos = pos + part.AssemblyLinearVelocity * Aimbot.Prediction end
        return pos
    end
    -- ignora parte transparente / sem colisão (acessórios, vidro, etc.)
    local function visible(part, char)
        local origin = Cam.CFrame.Position
        local ignore = {LP.Character, char}
        for _ = 1, 6 do
            rpVis.FilterDescendantsInstances = ignore
            local res = workspace:Raycast(origin, part.Position - origin, rpVis)
            if not res then return true end
            local hit = res.Instance
            if hit.Transparency >= 0.9 or not hit.CanCollide then
                table.insert(ignore, hit)
            else
                return false
            end
        end
        return false
    end
    local function evaluate(p, maxFov)
        local c = p.Character
        if not c then return end
        local h = hm(c)
        if not h or h.Health <= 0 then return end
        if Aimbot.TeamCheck and LP.Team and p.Team == LP.Team then return end
        local part = aimPart(c)
        if not part then return end
        local pos = aimPoint(part)
        if (pos - Cam.CFrame.Position).Magnitude > Aimbot.MaxDist then return end
        local sp, on = Cam:WorldToViewportPoint(pos)
        if not on then return end
        local d = (Vector2.new(sp.X, sp.Y) - originPos()).Magnitude
        if d > maxFov then return end
        if Aimbot.VisibleCheck and not visible(part, c) then return end
        return part, pos, d
    end
    local function findTarget()
        if Aimbot.Sticky and locked and locked.Parent then
            local part, pos = evaluate(locked, Aimbot.FOV * 1.5)
            if part then return pos end
        end
        local bestPos, bestD, bestP = nil, Aimbot.FOV, nil
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= LP then
                local part, pos, d = evaluate(p, bestD)
                if part and d <= bestD then bestPos, bestD, bestP = pos, d, p end
            end
        end
        locked = bestP
        return bestPos
    end

    feature(Pg, "Aim", "AIMBOT", function(on)
        Aimbot.Enabled = on
        locked = nil
        if on then
            stopC("Freecam")
            toast("Aimbot ON", Theme.Good)
        else
            toast("Aimbot OFF", Theme.Bad)
        end
    end, Enum.KeyCode.T)

    -- roda logo DEPOIS do script de câmera do Roblox, senão ele sobrescreve a mira
    R:BindToRenderStep("N_Aimbot", Enum.RenderPriority.Camera.Value + 1, function(dt)
        if not Aimbot.Enabled then
            fovCircle.Visible = false
            return
        end
        fovCircle.Visible = true
        local o = originPos()
        fovCircle.Position = UDim2.fromOffset(o.X, o.Y)
        if En.Freecam or En.View or En.Spectate then locked = nil return end

        local shouldAim = true
        if Aimbot.HoldMode then
            local k = Binds.AimHold and Binds.AimHold.key
            if k then
                shouldAim = U:IsKeyDown(k)
            else
                shouldAim = U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            end
        end
        if not shouldAim then locked = nil return end

        local pos = findTarget()
        if not pos then return end
        local cf = Cam.CFrame
        local goal = CFrame.lookAt(cf.Position, pos)
        local s = math.clamp(Aimbot.Smooth, 0.01, 1)
        local alpha = (s >= 1) and 1 or (1 - (1 - s) ^ (dt * 60)) -- independe do FPS
        Cam.CFrame = cf:Lerp(goal, alpha)
    end)

    slider(Pg, "FOV do aimbot", 20, 600, Aimbot.FOV, 1, function(v) Aimbot.FOV = v updateFovSize() end)
    slider(Pg, "Smooth (1 = instantâneo)", 0.01, 1, Aimbot.Smooth, 0.01, function(v) Aimbot.Smooth = v end)
    slider(Pg, "Predição de movimento", 0, 0.3, Aimbot.Prediction, 0.01, function(v) Aimbot.Prediction = v end)
    slider(Pg, "Distância máxima", 50, 3000, Aimbot.MaxDist, 10, function(v) Aimbot.MaxDist = v end)
    cycle(Pg, "Parte alvo", {"Head", "Torso", "Root"}, Aimbot.Part, function(v) Aimbot.Part = v end)
    cycle(Pg, "Centro do FOV", {"Centro", "Mouse"}, Aimbot.Origin, function(v) Aimbot.Origin = v end)

    toggle(Pg, "TEAM CHECK", function(on) Aimbot.TeamCheck = on end, {def = Aimbot.TeamCheck})
    toggle(Pg, "VISIBLE CHECK", function(on) Aimbot.VisibleCheck = on end)
    toggle(Pg, "TRAVAR NO ALVO", function(on) Aimbot.Sticky = on locked = nil end, {def = Aimbot.Sticky})
    local hold = toggle(Pg, "SEGURAR PARA MIRAR", function(on) Aimbot.HoldMode = on end, {reserve = 128})
    addBind("AimHold", "Aimbot (segurar)", "hold", nil, Enum.KeyCode.Z)
    bindWidgets(hold.row, "AimHold", -54)
    lbl(Pg, "No modo segurar, use a tecla ao lado (sem tecla = botão direito do mouse).")
end

Tabs.OVERLAYS = function(Pg)
    sec(Pg, "FPS / Ping")
    local fpsOv = mkOverlay("stats", "FPS / PING", 180, 80)
    local function ovLabel(txt)
        local l = new("TextLabel", {Size = UDim2.new(1, -4, 0, 20), BackgroundTransparency = 1, Text = txt,
            Font = Enum.Font.Code, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left}, fpsOv.Body)
        themed(function() l.TextColor3 = Theme.Text end)
        return l
    end
    local fpsLbl, pingLbl = ovLabel("FPS: --"), ovLabel("Ping: --")
    feature(Pg, "Stats", "OVERLAY FPS / PING", function(on)
        fpsOv.Frame.Visible = on
        D("Stats")
        if on then
            local frames, lastT = 0, os.clock()
            C("Stats", R.RenderStepped:Connect(function()
                frames += 1
                local now = os.clock()
                if now - lastT >= 1 then
                    fpsLbl.Text = string.format("FPS: %.0f", frames / (now - lastT))
                    frames = 0
                    lastT = now
                    local ok, p = pcall(function() return St.Network.ServerStatsItem["Data Ping"]:GetValue() end)
                    if ok and p then pingLbl.Text = string.format("Ping: %.0f ms", p) end
                end
            end))
        end
    end, Enum.KeyCode.P)
    fpsOv.OnClose = function() if H.Stats then H.Stats() end end

    sec(Pg, "Chat logger")
    local chatOv = mkOverlay("chat", "CHAT LOG", 260, 180)
    local chatScroll = new("ScrollingFrame", {Size = UDim2.new(1, -4, 1, -4), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 2, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new()}, chatOv.Body)
    themed(function() chatScroll.ScrollBarImageColor3 = Theme.Accent end)
    new("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, chatScroll)
    local chatN = 0
    local function addChat(name, txt)
        chatN += 1
        new("TextLabel", {Size = UDim2.new(1, -4, 0, 16), BackgroundTransparency = 1, Text = name .. ": " .. txt,
            TextColor3 = Theme.Text, Font = Enum.Font.Code, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = chatN}, chatScroll)
        task.defer(function() chatScroll.CanvasPosition = Vector2.new(0, 1e6) end)
        local labels = {}
        for _, c in ipairs(chatScroll:GetChildren()) do
            if c:IsA("TextLabel") then table.insert(labels, c) end
        end
        if #labels > 200 then labels[1]:Destroy() end
    end
    local function stopChat()
        D("ChatLogNew")
        D("ChatLogTCS")
        for k in pairs(Cn) do
            if tostring(k):sub(1, 8) == "ChatLog_" then D(k) end
        end
    end
    feature(Pg, "Chat", "CHAT LOGGER", function(on)
        chatOv.Frame.Visible = on
        stopChat()
        if on then
            if TCS.ChatVersion == Enum.ChatVersion.TextChatService then
                pcall(function()
                    C("ChatLogTCS", TCS.MessageReceived:Connect(function(msg)
                        local n = msg.TextSource and msg.TextSource.Name or "?"
                        if msg.Text and msg.Text ~= "" then addChat(n, msg.Text) end
                    end))
                end)
            end
            local function hook(p)
                C("ChatLog_" .. p.Name, p.Chatted:Connect(function(m) addChat(p.Name, m) end))
            end
            for _, p in ipairs(P:GetPlayers()) do hook(p) end
            C("ChatLogNew", P.PlayerAdded:Connect(hook))
        end
    end, Enum.KeyCode.L)
    chatOv.OnClose = function() if H.Chat then H.Chat() end end

    sec(Pg, "Binds na tela")
    local blOv = mkOverlay("binds", "BINDS ATIVAS", 230, 210)
    local blLbl = new("TextLabel", {Size = UDim2.new(1, -4, 1, -4), BackgroundTransparency = 1, Text = "", RichText = true,
        Font = Enum.Font.Code, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top}, blOv.Body)
    themed(function() blLbl.TextColor3 = Theme.Text end)
    feature(Pg, "BindList", "LISTA DE BINDS NA TELA", function(on)
        blOv.Frame.Visible = on
        D("BindList")
        if on then
            local acc = 1
            C("BindList", R.Heartbeat:Connect(function(dt)
                acc += dt
                if acc < 0.4 then return end
                acc = 0
                local lines, n = {}, 0
                for _, id in ipairs(BindOrder) do
                    local b = Binds[id]
                    if b.key and b.kind ~= "hold" and (b.use or b.kind == "always") then
                        n += 1
                        if n <= 13 then
                            local st = Feat[id] and Feat[id].get()
                            lines[#lines + 1] = string.format("[%s] %s%s", keyName(b.key), b.name,
                                st and ' <font color="' .. hex(Theme.Good) .. '">●</font>' or "")
                        end
                    end
                end
                if n > 13 then lines[#lines + 1] = "+" .. (n - 13) .. " mais..." end
                blLbl.Text = #lines > 0 and table.concat(lines, "\n") or "Nenhuma bind ativa"
            end))
        end
    end)
    blOv.OnClose = function() if H.BindList then H.BindList() end end
    lbl(Pg, "Overlays arrastáveis pela barra de título.")
end

--==================== SCRIPTS (executor via loadstring; lista só no OWNER) ====================
Tabs.SCRIPTS = function(Pg)
    local X = OWNER.Executor or {}
    local list = X.Scripts or {}
    sec(Pg, "Scripts")
    if #list == 0 then
        lbl(Pg, "Nenhum script configurado.")
        return
    end

    local function fetch(url)
        local ok, res = pcall(function() return game:HttpGet(url) end)
        if ok and type(res) == "string" and res ~= "" then return res end
        ok, res = pcall(function() return HS:GetAsync(url) end)
        if ok and type(res) == "string" and res ~= "" then return res end
        return nil
    end
    local function run(s)
        local ls = loadstring or (getgenv and getgenv().loadstring)
        if not ls then
            toast("loadstring indisponível aqui", Theme.Bad)
            return
        end
        local src = s.Code or (s.Url and fetch(s.Url))
        if not src then
            toast("Falha ao baixar: " .. s.Name, Theme.Bad)
            return
        end
        local ok, fn, err = pcall(ls, src)
        if not ok or not fn then
            toast("Erro ao compilar: " .. s.Name, Theme.Bad)
            warn("[N SYSTEM]", ok and err or fn)
            return
        end
        toast("Executando: " .. s.Name, Theme.Good)
        task.spawn(function()
            local ok2, e2 = pcall(fn)
            if not ok2 then
                toast("Erro em: " .. s.Name, Theme.Bad)
                warn("[N SYSTEM]", e2)
            end
        end)
    end

    for _, s in ipairs(list) do
        btn(Pg, s.Name, function() run(s) end)
    end
    lbl(Pg, "Lista definida no código (OWNER.Executor). Precisa de ambiente com loadstring/HttpGet.")

    for _, s in ipairs(list) do
        if s.AutoRun then task.spawn(run, s) end
    end
end

Tabs.FAVORITOS = function(Pg)
    sec(Pg, "Favoritos")
    UI.favEmpty = lbl(Pg, "Nenhum favorito ainda. Clique na ☆ ao lado de qualquer opção para fixar aqui.")
    updateFavEmpty()
end

-- desligar tudo
local function disableAll()
    for _, fn in pairs(H) do pcall(fn) end
    Fn.stopFly()
    Fn.restoreCol()
    Fn.stopSpin()
    Fn.stopFling()
    stopT()
    stopC()
    local h = hm(ch())
    if h then Cam.CameraSubject = h end
    for _, e in ipairs(Extras) do
        if e.stop then pcall(e.stop) end
        if e.reset then pcall(e.reset) end
    end
end

Tabs.THEME = function(Pg)
    sec(Pg, "Tema")
    cycle(Pg, "Preset", PresetNames, (OWNER.System and OWNER.System.DefaultTheme) or "Roxo", function(name)
        for k, v in pairs(Presets[name]) do Theme[k] = v end
        applyTheme()
    end)
    local function colorRow(key, text)
        local f = row(Pg, 34)
        rowLabel(f, text, 150)
        local sw = new("Frame", {Size = UDim2.fromOffset(22, 22), Position = UDim2.new(1, -32, 0.5, -11), BorderSizePixel = 0}, f)
        rcorner(sw, -4)
        rstroke(sw, 0.3, 1)
        local box = new("TextBox", {Size = UDim2.fromOffset(78, 22), Position = UDim2.new(1, -116, 0.5, -11), Text = "",
            Font = Enum.Font.Code, TextSize = 11, ClearTextOnFocus = false, BorderSizePixel = 0, ZIndex = 3}, f)
        rcorner(box, -4)
        themed(function()
            sw.BackgroundColor3 = Theme[key]
            box.Text = hex(Theme[key])
            box.BackgroundColor3 = Theme.Main
            box.TextColor3 = Theme.Text
        end)
        box.FocusLost:Connect(function()
            local ok, c = pcall(Color3.fromHex, box.Text)
            if ok and c then
                Theme[key] = c
                applyTheme()
            else
                box.Text = hex(Theme[key])
            end
        end)
    end
    colorRow("Accent", "Cor principal")
    colorRow("Main", "Cor de fundo")
    colorRow("Element", "Cor dos elementos")
    colorRow("Text", "Cor do texto")
    sec(Pg, "Aparência")
    UI.sTransp = slider(Pg, "Transparência do painel", 0, 0.9, Theme.Transp, 0.01, function(v) Theme.Transp = v applyTheme() end)
    UI.sRadius = slider(Pg, "Raio dos cantos", 0, 20, Theme.Radius, 1, function(v) Theme.Radius = v applyTheme() end)
    UI.sScale = slider(Pg, "Escala da UI", 0.7, 1.3, 1, 0.05, function(v) WinScale.Scale = v end)
    toggle(Pg, "BLUR DE FUNDO", function(on)
        En.BlurActive = on
        panelBlur.Enabled = on and Win.Visible
    end)
    lbl(Pg, "Blur só funciona com o painel aberto. Cores aceitam hex (ex: #8f41dc).")
end

Tabs.SETTINGS = function(Pg)
    sec(Pg, "Tamanho do painel")
    local function setSize(v) Win.Size = UDim2.fromOffset(v.X, v.Y + BAR) end
    btn(Pg, "PEQUENO (S)", function() setSize(CFG.Sizes.S) end)
    btn(Pg, "MÉDIO (M)", function() setSize(CFG.Sizes.M) end)
    btn(Pg, "GRANDE (L)", function() setSize(CFG.Sizes.L) end)

    sec(Pg, "Comportamento")
    UI.tToast = toggle(Pg, "NOTIFICAÇÕES", function(on) Settings.Toasts = on end, {def = true})
    slider(Pg, "Máx. de notificações", 1, 10, Settings.MaxToasts, 1, function(v) Settings.MaxToasts = v end)
    UI.tKeep = toggle(Pg, "MANTER FUNÇÕES AO RESPAWNAR", function(on) Settings.KeepOnRespawn = on end)
    UI.tCompact = toggle(Pg, "MODO COMPACTO (só ícones)", function(on) Settings.Compact = on applyCompact() end)
    UI.tFloat = toggle(Pg, "BOTÃO FLUTUANTE (mobile)", function(on) Settings.FloatBtn = on UI.FB.Visible = on end,
        {def = Settings.FloatBtn})
    lbl(Pg, "Respawn: funções que dependem do personagem (fly, noclip...) sempre desligam.")

    sec(Pg, "Config")
    local cfgBox = tbox(Pg, "Cole aqui uma config para importar")
    btn(Pg, "EXPORTAR CONFIG (tema + binds + favoritos)", function()
        cfgBox.Text = HS:JSONEncode(cfgExport())
        toast("Config exportada na caixa (Ctrl+A, Ctrl+C)", Theme.Good)
    end)
    btn(Pg, "IMPORTAR CONFIG", function()
        local ok, t = pcall(function() return HS:JSONDecode(cfgBox.Text) end)
        if not ok or type(t) ~= "table" then toast("Config inválida", Theme.Bad) return end
        cfgImport(t)
        toast("Config importada", Theme.Good)
    end)
    lbl(Pg, "Sem acesso a arquivos num LocalScript: a config sobrevive ao REJOIN do painel, ou cole o texto exportado.")

    sec(Pg, "Jogo atual")
    local gameNameLbl = lbl(Pg, "Nome: buscando...")
    lbl(Pg, "PlaceId: " .. tostring(game.PlaceId))
    lbl(Pg, "UniverseId: " .. tostring(game.GameId))
    lbl(Pg, "JobId: " .. tostring(game.JobId ~= "" and game.JobId or "(estúdio/solo, sem JobId)"))
    btn(Pg, "COPIAR JOBID", function()
        if game.JobId == "" then toast("Sem JobId (estúdio/solo)", Theme.Bad) return end
        local ok = pcall(function() setclipboard(game.JobId) end)
        toast(ok and "JobId copiado" or "Não deu pra copiar neste executor", ok and Theme.Good or Theme.Bad)
    end)
    task.spawn(function()
        local MPS = game:GetService("MarketplaceService")
        local ok, info = pcall(function() return MPS:GetProductInfo(game.PlaceId) end)
        gameNameLbl.Text = (ok and info and info.Name) and ("Nome: " .. info.Name)
            or "Nome: não consegui buscar (API indisponível aqui)"
    end)

    sec(Pg, "Créditos")
    local people = (OWNER.Credits and OWNER.Credits.People) or {}
    if #people == 0 then
        lbl(Pg, "Nenhum crédito configurado (edite OWNER.Credits.People no script).")
    else
        for _, person in ipairs(people) do
            lbl(Pg, (person.Name or "?") .. (person.Role and (" — " .. person.Role) or ""))
        end
    end
    local discordLink = OWNER.Credits and OWNER.Credits.Discord
    if discordLink and discordLink ~= "" then
        btn(Pg, "COPIAR LINK DO DISCORD", function()
            local ok = pcall(function() setclipboard(discordLink) end)
            if ok then toast("Link do Discord copiado!", Theme.Good) else toast(discordLink, Theme.Sub) end
        end)
    end

    sec(Pg, "Geral")
    lbl(Pg, string.format("%s - ADMIN PANEL | Criador: %s | %s",
        OWNER.System and OWNER.System.Name or "N SYSTEM",
        OWNER.System and OWNER.System.Creator or "?",
        OWNER.System and OWNER.System.Version or ""))
    btn(Pg, "DESLIGAR TODAS AS FUNÇÕES", function()
        disableAll()
        toast("Tudo desligado", Theme.Bad)
    end, "DisableAll")
end

Tabs.KEYBINDS = function(Pg)
    sec(Pg, "Keybinds")
    UI.tMaster = toggle(Pg, "USAR KEYBINDS (geral)", function(on)
        BindsEnabled = on
        toast(on and "Keybinds ativados" or "Keybinds desativados", on and Theme.Good or Theme.Bad)
    end, {def = true})
    lbl(Pg, "Clique no botão da tecla e aperte a tecla. Backspace limpa, Esc cancela. O quadrado ao lado liga/desliga a bind.")
    btn(Pg, "ATIVAR TODAS AS BINDS COM TECLA", function()
        for id, b in pairs(Binds) do
            if (b.kind == "toggle" or b.kind == "action") and b.key then b.use = true refreshBind(id) end
        end
    end)
    btn(Pg, "DESATIVAR TODAS AS BINDS", function()
        for id, b in pairs(Binds) do
            if b.kind == "toggle" or b.kind == "action" then b.use = false refreshBind(id) end
        end
    end)
    sec(Pg, "Todas as binds")
    for _, id in ipairs(BindOrder) do
        local b = Binds[id]
        local f = row(Pg, 30)
        rowLabel(f, b.name .. ((b.kind == "hold") and " (segurar)" or ""), 120)
        bindWidgets(f, id, -10)
    end
end

--==================== BOTÃO FLUTUANTE ====================
do
    local FB = new("TextButton", {Size = UDim2.fromOffset(46, 46), Position = UDim2.new(0, 14, 0.5, -23), Text = "N",
        Font = Enum.Font.GothamBold, TextSize = 18, AutoButtonColor = false, BorderSizePixel = 0,
        Visible = Settings.FloatBtn}, FloatGui)
    new("UICorner", {CornerRadius = UDim.new(1, 0)}, FB)
    rstroke(FB, 0.2, 1.5)
    themed(function() FB.BackgroundColor3 = Theme.Main FB.TextColor3 = Theme.Accent end)
    UI.FB = FB
    local dragging, moved, startPos, startUD = false, false, nil, nil
    FB.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, moved, startPos, startUD = true, false, i.Position, FB.Position
        end
    end)
    U.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startPos
            if d.Magnitude > 6 then moved = true end
            if moved then
                FB.Position = UDim2.new(startUD.X.Scale, startUD.X.Offset + d.X, startUD.Y.Scale, startUD.Y.Offset + d.Y)
            end
        end
    end)
    U.InputEnded:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            if not moved then togglePanel() end
        end
    end)
end

--==================== MONTAGEM ====================
addBind("Panel", "Abrir/Fechar painel", "always", function() togglePanel() end, (OWNER.System and OWNER.System.PanelKey) or Enum.KeyCode.Home)
addBind("Panic", "PÂNICO (desliga tudo e esconde)", "action", function()
    disableAll()
    panelOpen = false
    Win.Visible = false
    panelBlur.Enabled = false
    toast("Pânico ativado", Theme.Bad)
end, OWNER.System and OWNER.System.PanicKey or nil)

local order = {"PLAYER", "MOVEMENT", "TROLL", "VISUAL", "ESP", "AIMBOT", "OVERLAYS", "FAVORITOS", "THEME", "SETTINGS", "KEYBINDS"}
if OWNER.Executor and OWNER.Executor.Enabled then table.insert(order, 8, "SCRIPTS") end
if Access ~= "admin" then
    local hide = (OWNER.KeySystem and OWNER.KeySystem.NormalHiddenTabs) or {}
    for i = #order, 1, -1 do
        if table.find(hide, order[i]) then table.remove(order, i) end
    end
end
for _, name in ipairs(order) do
    local pg = tab(name)
    Tabs[name](pg)
end
local SearchPg = createPage("BUSCA")
switchPage("PLAYER")

--==================== BUSCA ====================
local function jumpTo(it)
    local pg = it.row.Parent
    SearchBox.Text = ""
    if pg then switchPage(pg.Name) end
    task.defer(function()
        task.wait(0.1)
        if pg and it.row.Parent == pg then
            pg.CanvasPosition = Vector2.new(0, math.max(0, (it.row.AbsolutePosition.Y - pg.AbsolutePosition.Y) / WinScale.Scale + pg.CanvasPosition.Y - 8))
            T:Create(it.row, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
            task.delay(0.35, function() T:Create(it.row, TweenInfo.new(0.4), {BackgroundColor3 = Theme.Element}):Play() end)
        end
    end)
end
local function runSearch()
    local q = string.lower(SearchBox.Text)
    for _, c in ipairs(SearchPg:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    if q == "" then
        SearchPg.Visible = false
        switchPage(curTab)
        return
    end
    for _, pg in pairs(Pages) do pg.Visible = false end
    SearchPg.Visible = true
    local n = 0
    for _, it in ipairs(Items) do
        if n >= 40 then break end
        local pname = it.row.Parent and it.row.Parent.Name or ""
        if it.text:lower():find(q, 1, true) or pname:lower():find(q, 1, true) then
            n += 1
            local b = new("TextButton", {Size = UDim2.new(1, -8, 0, 30), Text = "  " .. pname .. "  ›  " .. it.text,
                Font = Enum.Font.GothamMedium, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = n, BackgroundColor3 = Theme.Element,
                BackgroundTransparency = 0.25, TextColor3 = Theme.Text, TextTruncate = Enum.TextTruncate.AtEnd}, SearchPg)
            new("UICorner", {CornerRadius = UDim.new(0, 6)}, b)
            b.MouseButton1Click:Connect(function() jumpTo(it) end)
        end
    end
end
SearchBox:GetPropertyChangedSignal("Text"):Connect(runSearch)

--==================== TOPBAR / STATUS / BADGE ====================
do
    local frames, last = 0, os.clock()
    R.RenderStepped:Connect(function()
        frames += 1
        local now = os.clock()
        if now - last >= 1 then
            fpsL.Text = string.format("%.0f FPS", frames / (now - last))
            frames = 0
            last = now
            timeL.Text = os.date("%H:%M:%S")
            local ok, p = pcall(function() return St.Network.ServerStatsItem["Data Ping"]:GetValue() end)
            if ok and p then pingL.Text = string.format("%.0f ms", p) end
        end
    end)
    local acc = 0
    R.Heartbeat:Connect(function(dt)
        acc += dt
        if acc < 0.3 then return end
        acc = 0
        local t = Sel
        if t and t.Parent then
            local r, h, mr = rt(t.Character), hm(t.Character), rt(ch())
            local d = (r and mr) and math.floor((r.Position - mr.Position).Magnitude) or 0
            Status.Text = string.format("  ◎ %s  ·  %dm  ·  %s  ·  HP %d", t.DisplayName, d,
                t.Team and t.Team.Name or "Sem time", h and math.floor(h.Health) or 0)
        else
            Status.Text = "  ◎ Nenhum jogador selecionado"
        end
    end)
end
local lastN = -1
R.Heartbeat:Connect(function()
    local n = 0
    for _, v in pairs(En) do
        if v then n += 1 end
    end
    if Aimbot.Enabled then n += 1 end
    if n ~= lastN then
        lastN = n
        Badge.Text = "● " .. n .. " ativo" .. (n == 1 and "" or "s")
        Badge.TextColor3 = n > 0 and Theme.Accent or Theme.Sub
    end
end)
themed(function() Badge.TextColor3 = (lastN > 0) and Theme.Accent or Theme.Sub end)

--==================== MIN / SIZE / CLOSE ====================
togglePanel = function()
    panelOpen = not panelOpen
    Win.Visible = panelOpen
    panelBlur.Enabled = panelOpen and En.BlurActive == true
end
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Body.Visible = not minimized
    MinBtn.Text = minimized and "+" or "-"
end)
SizeBtn.MouseButton1Click:Connect(function()
    local sz = Win.AbsoluteSize.X / WinScale.Scale
    local target
    if sz < CFG.Sizes.M.X - 1 then target = CFG.Sizes.M
    elseif sz < CFG.Sizes.L.X - 1 then target = CFG.Sizes.L
    else target = CFG.Sizes.S end
    T:Create(Win, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.fromOffset(target.X, target.Y + BAR)}):Play()
end)
CloseBtn.MouseButton1Click:Connect(function()
    panelOpen = false
    Win.Visible = false
    panelBlur.Enabled = false
end)

--==================== KEYBIND HANDLER ====================
local mouseDown = false
U.InputBegan:Connect(function(i, t)
    if t then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.MouseButton2 then
        mouseDown = true
    end
end)
U.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.MouseButton2 then
        mouseDown = false
    end
end)
U.InputBegan:Connect(function(i, t)
    if t or capId then return end
    if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if i.KeyCode == Enum.KeyCode.Unknown then return end
    if U:GetFocusedTextBox() then return end
    for _, b in pairs(Binds) do
        if b.key == i.KeyCode and b.fire then
            if b.kind == "always" then
                b.fire()
            elseif BindsEnabled and b.use and not mouseDown then
                b.fire()
            end
            return
        end
    end
end)

--==================== CONFIG (export / import) ====================
cfgExport = function()
    local t = {v = 5, theme = {}, binds = {}, favs = {}, set = {}, win = {}}
    for _, k in ipairs({"Accent", "Main", "Element", "Text"}) do t.theme[k] = hex(Theme[k]) end
    t.theme.Transp = Theme.Transp
    t.theme.Radius = Theme.Radius
    t.theme.Scale = WinScale.Scale
    for id, b in pairs(Binds) do t.binds[id] = {k = b.key and b.key.Name or "", u = b.use} end
    for _, it in ipairs(Items) do
        if it.fav then table.insert(t.favs, it.key) end
    end
    t.set = {KeepOnRespawn = Settings.KeepOnRespawn, Toasts = Settings.Toasts, Compact = Settings.Compact,
        FloatBtn = Settings.FloatBtn, BindsEnabled = BindsEnabled}
    t.win = {Win.Size.X.Offset, Win.Size.Y.Offset}
    return t
end
cfgImport = function(t)
    if type(t) ~= "table" then return end
    if type(t.theme) == "table" then
        for _, k in ipairs({"Accent", "Main", "Element", "Text"}) do
            if type(t.theme[k]) == "string" then
                local ok, c = pcall(Color3.fromHex, t.theme[k])
                if ok and c then Theme[k] = c end
            end
        end
        if type(t.theme.Transp) == "number" then
            Theme.Transp = t.theme.Transp
            if UI.sTransp then UI.sTransp.set(Theme.Transp, true) end
        end
        if type(t.theme.Radius) == "number" then
            Theme.Radius = t.theme.Radius
            if UI.sRadius then UI.sRadius.set(Theme.Radius, true) end
        end
        if type(t.theme.Scale) == "number" then
            WinScale.Scale = math.clamp(t.theme.Scale, 0.7, 1.3)
            if UI.sScale then UI.sScale.set(WinScale.Scale, true) end
        end
        applyTheme()
    end
    if type(t.binds) == "table" then
        for id, v in pairs(t.binds) do
            local b = Binds[id]
            if b and type(v) == "table" then
                local ok, kc = pcall(function() return Enum.KeyCode[v.k] end)
                b.key = (ok and kc) or nil
                if b.kind == "toggle" or b.kind == "action" then b.use = (v.u == true) and b.key ~= nil end
                refreshBind(id)
            end
        end
    end
    if type(t.favs) == "table" then
        for _, key in ipairs(t.favs) do
            for _, it in ipairs(Items) do
                if it.key == key then setFav(it, true) end
            end
        end
    end
    if type(t.set) == "table" then
        local s = t.set
        if UI.tKeep and type(s.KeepOnRespawn) == "boolean" then UI.tKeep.set(s.KeepOnRespawn) end
        if UI.tToast and type(s.Toasts) == "boolean" then UI.tToast.set(s.Toasts) end
        if UI.tCompact and type(s.Compact) == "boolean" then UI.tCompact.set(s.Compact) end
        if UI.tFloat and type(s.FloatBtn) == "boolean" then UI.tFloat.set(s.FloatBtn) end
        if UI.tMaster and type(s.BindsEnabled) == "boolean" then UI.tMaster.set(s.BindsEnabled) end
    end
    if type(t.win) == "table" and tonumber(t.win[1]) and tonumber(t.win[2]) then
        Win.Size = UDim2.fromOffset(math.clamp(t.win[1], 560, 1000), math.clamp(t.win[2], 360 + BAR, 760))
    end
end

-- carrega config vinda de um REJOIN do painel
do
    local ok, d = pcall(function() return TS:GetLocalPlayerTeleportData() end)
    if ok and type(d) == "table" and type(d.N_SYSTEM_CFG) == "string" then
        local ok2, t = pcall(function() return HS:JSONDecode(d.N_SYSTEM_CFG) end)
        if ok2 then pcall(cfgImport, t) end
    end
end

--==================== RESPAWN ====================
LP.CharacterAdded:Connect(function()
    Applied.OutfitOrig, Applied.FaceOrig = nil, nil
    Fn.stopFly()
    Fn.restoreCol()
    Fn.stopSpin()
    Fn.stopFling()
    for _, id in ipairs({"Fly", "Noclip", "Spin", "Follow", "View", "Free", "Spec", "Sprint", "Fling", "FlingT"}) do
        if H[id] then pcall(H[id]) end
    end
    stopT()
    stopC()
    if not Settings.KeepOnRespawn then
        for _, e in ipairs(Extras) do
            if e.stop then pcall(e.stop) end
            if e.reset then pcall(e.reset) end
        end
    end
    task.wait(0.5)
    local h = hm(ch())
    if h then
        Cam.CameraSubject = h
        if Applied.W then h.WalkSpeed = Applied.W end
        if Applied.J then h.UseJumpPower = true h.JumpPower = Applied.J end
    end
end)

print(string.format("[%s %s] carregado", OWNER.System and OWNER.System.Name or "N SYSTEM", OWNER.System and OWNER.System.Version or ""))
