local DLL_NAME = "gmcl_gelly-gmod_win64.dll"
local MODULE_NAME = "gelly-gmod"
local GITHUB_URL = "https://raw.githubusercontent.com/blenderenjoyer/gelly/main/" .. DLL_NAME
local function IsInstalled()
    local ok = pcall(require, MODULE_NAME)
    return ok
end
local function ShowInstallGuide()
    local frame = vgui.Create("DFrame")
    frame:SetSize(450, 200)
    frame:Center()
    frame:SetTitle("Gelly - Установка модуля")
    frame:MakePopup()
    
    local info = frame:Add("DLabel")
    info:Dock(TOP)
    info:DockMargin(10, 10, 10, 10)
    info:SetWrap(true)
    info:SetAutoStretchVertical(true)
    info:SetText([[
Файл скачан в: garrysmod/data/gelly_module/

Для установки:
1. Скопируйте файл ]] .. DLL_NAME .. [[
2. Вставьте в: garrysmod/lua/bin/
3. Перезапустите игру]])
    
    local btnOpen = frame:Add("DButton")
    btnOpen:Dock(BOTTOM)
    btnOpen:DockMargin(10, 5, 10, 10)
    btnOpen:SetTall(30)
    btnOpen:SetText("open the file")
    btnOpen.DoClick = function()
        file.AsyncRead("gelly_module/" .. DLL_NAME, "DATA", function() end)
        gui.OpenURL("file://" .. util.RelativePathToFull("data/gelly_module/"))
    end
end
local function DownloadModule()
    notification.AddLegacy("Gelly: downloading the module...", NOTIFY_HINT, 3)
    
    http.Fetch(GITHUB_URL,
        function(body, size, headers, code)
            if code ~= 200 then
                notification.AddLegacy("error loading: " .. code, NOTIFY_ERROR, 5)
                return
            end
            

            file.CreateDir("gelly_module")
            file.Write("gelly_module/" .. DLL_NAME, body)
            
            notification.AddLegacy("Gelly: file is downloaded!", NOTIFY_GENERIC, 3)
            ShowInstallGuide()
        end,
        function(err)
            notification.AddLegacy("error: " .. err, NOTIFY_ERROR, 5)
        end
    )
end
hook.Add("InitPostEntity", "Gelly_CheckModule", function()
    timer.Simple(3, function()
        if IsInstalled() then
            MsgC(Color(100, 255, 100), "[Gelly] module is loaded!\n")
            hook.Run("Gelly_Ready")
        else
            Derma_Query(
                "download module?",
                "Gelly",
                "yea", DownloadModule,
                "nope fuck ya", function() end
            )
        end
    end)
end)
