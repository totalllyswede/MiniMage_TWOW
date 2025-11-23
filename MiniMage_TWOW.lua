local MM_Initialized = false

--
-- Global variable for storage of settings/options
--

MiniMageOptions = { };

--
-- Initialization functions
--

function class_OnLoad()
    MM_class = UnitClass("player");
    if (MM_class ~= "Mage") then
        this:Hide();
    end
end

function MM_Initialize()
    if MM_Initialized then return end
    MM_Initialized = true
    MM_fac = UnitFactionGroup('player');
    M_class = UnitClass("player");
    if (M_class == "Mage") then
        if (DEFAULT_CHAT_FRAME) then
            DEFAULT_CHAT_FRAME:AddMessage(MINIMAGE_ANNOUNCE_GREETING..M_class..MINIMAGE_ANNOUNCE_ENABLED);
        end
    else
        if (DEFAULT_CHAT_FRAME) then
            DEFAULT_CHAT_FRAME:AddMessage(MINIMAGE_ANNOUNCE_GREETING..M_class..MINIMAGE_ANNOUNCE_DISABLED);
        end
    end
end

function MM_Button_Initialize()
    if(event == "VARIABLES_LOADED") then
        if (MiniMageOptions.MMButtonPosition == nil) then
            MiniMageOptions.MMButtonPosition = 0;
        end
        if (MiniMageOptions.HidePortals == nil) then
            MiniMageOptions.HidePortals = false;
        end
    end
end

function MM_DropDown_Initialize()
    local dropdown;
    if ( UIDROPDOWNMENU_OPEN_MENU ) then
        dropdown = getglobal(UIDROPDOWNMENU_OPEN_MENU);
    else
        dropdown = this;
    end
    MM_DropDown_InitButtons();
end

function MM_DropDown_OnLoad()
    UIDropDownMenu_Initialize(this, MM_DropDown_Initialize, "MENU");
end

--
-- Minimap button drag/drop functions
--

-- Thanks to Atlas for the button dragging code

function MM_Button_BeingDragged()
    local xpos,ypos = GetCursorPosition();
    local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom();
    xpos = xmin-xpos/UIParent:GetScale()+70;
    ypos = ypos/UIParent:GetScale()-ymin-70;
    MM_Button_SetPosition(math.deg(math.atan2(ypos,xpos)));
end

function MM_Button_OnClick()
    MM_ToggleDropDown();
end

function MM_Button_OnEnter()
    GameTooltip:SetOwner(this, "ANCHOR_LEFT");
    GameTooltip:SetText(MINIMAGE_BUTTON_TOOLTIP0);
    GameTooltip:AddLine(MINIMAGE_BUTTON_TOOLTIP1);
    GameTooltip:AddLine(MINIMAGE_BUTTON_TOOLTIP2);
    GameTooltip:Show();
end

function MM_Button_SetPosition(v)
    if(v < 0) then
        v = v + 360;
    end
    MiniMageOptions.MMButtonPosition = v;
    MM_Button_UpdatePosition();
end

function MM_Button_UpdatePosition()
    MM_ButtonFrame:SetPoint(
        "TOPLEFT",
        "Minimap",
        "TOPLEFT",
        54 - (78 * cos(MiniMageOptions.MMButtonPosition)),
        (78 * sin(MiniMageOptions.MMButtonPosition)) - 55
    );
end

--
-- ADDED: REQUIRED LEVEL CHECKS
--

function MM_CanCastTeleport()
    return UnitLevel("player") >= 20;
end

function MM_CanCastPortal()
    return UnitLevel("player") >= 40;
end

--
-- Drop down menu functions
--

function MM_ToggleDropDown()
    MM_DropDownFrame.point = "TOPRIGHT";
    MM_DropDownFrame.relativePoint = "BOTTOMLEFT";
    ToggleDropDownMenu(1, nil, MM_DropDownFrame);
end

function MM_DropDown_InitButtons()
    local info = {};
    info.text = MINIMAGE_LABEL_TITLE;
    info.isTitle = 1;
    info.justifyH = "CENTER";
    info.notCheckable = 1;
    UIDropDownMenu_AddButton(info);

    local fact = UnitFactionGroup('player');
    if (fact == "Horde") then
        MM_DropDown_ForTheHorde();
    else
        MM_DropDown_ForTheAlliance();
    end
end

function MM_DropDown_ForTheHorde()
    local appender = ': ';

    -- PORTAL SECTION (hidden if HidePortals is true)
    if not MiniMageOptions.HidePortals then
        local info = { };
        info.text = MINIMAGE_LABEL_PORTAL;
        info.isTitle = 1;
        info.notCheckable = 1;
        UIDropDownMenu_AddButton(info);

        -- ORG PORTAL
        info = { };
        info.text = MINIMAGE_LABEL_ORG;
        info.disabled = not MM_CanCastPortal();
        info.func = function(msg)
            if MM_CanCastPortal() then
                CastSpellByName(MINIMAGE_LABEL_PORTAL..appender..MINIMAGE_LABEL_ORG);
            end
        end;
        UIDropDownMenu_AddButton(info);

        -- STONARD PORTAL
        info = { };
        info.text = MINIMAGE_LABEL_STONARD;
        info.disabled = not MM_CanCastPortal();
        info.func = function(msg)
            if MM_CanCastPortal() then
                CastSpellByName(MINIMAGE_LABEL_PORTAL..appender..MINIMAGE_LABEL_STONARD);
            end
        end;
        UIDropDownMenu_AddButton(info);

        -- TB PORTAL
        info = { };
        info.text = MINIMAGE_LABEL_TB;
        info.disabled = not MM_CanCastPortal();
        info.func = function(msg)
            if MM_CanCastPortal() then
                CastSpellByName(MINIMAGE_LABEL_PORTAL..appender..MINIMAGE_LABEL_TB);
            end
        end;
        UIDropDownMenu_AddButton(info);

        -- UC PORTAL
        info = { };
        info.text = MINIMAGE_LABEL_UC;
        info.disabled = not MM_CanCastPortal();
        info.func = function(msg)
            if MM_CanCastPortal() then
                CastSpellByName(MINIMAGE_LABEL_PORTAL..appender..MINIMAGE_LABEL_UC);
            end
        end;
        UIDropDownMenu_AddButton(info);
    end

    -- TELEPORT SECTION
    local info = { };
    info.text = MINIMAGE_LABEL_TELEPORT;
    info.isTitle = 1;
    info.notCheckable = 1;
    UIDropDownMenu_AddButton(info);

    -- ORG TELEPORT
    info = { };
    info.text = MINIMAGE_LABEL_ORG;
    info.disabled = not MM_CanCastTeleport();
    info.func = function(msg)
        if MM_CanCastTeleport() then
            CastSpellByName(MINIMAGE_LABEL_TELEPORT..appender..MINIMAGE_LABEL_ORG);
        end
    end;
    UIDropDownMenu_AddButton(info);

    -- STONARD TELEPORT
    info = { };
    info.text = MINIMAGE_LABEL_STONARD;
    info.disabled = not MM_CanCastTeleport();
    info.func = function(msg)
        if MM_CanCastTeleport() then
            CastSpellByName(MINIMAGE_LABEL_TELEPORT..appender..MINIMAGE_LABEL_STONARD);
        end
    end;
    UIDropDownMenu_AddButton(info);

    -- TB TELEPORT
    info = { };
    info.text = MINIMAGE_LABEL_TB;
    info.disabled = not MM_CanCastTeleport();
    info.func = function(msg)
        if MM_CanCastTeleport() then
            CastSpellByName(MINIMAGE_LABEL_TELEPORT..appender..MINIMAGE_LABEL_TB);
        end
    end;
    UIDropDownMenu_AddButton(info);

    -- UC TELEPORT
    info = { };
    info.text = MINIMAGE_LABEL_UC;
    info.disabled = not MM_CanCastTeleport();
    info.func = function(msg)
        if MM_CanCastTeleport() then
            CastSpellByName(MINIMAGE_LABEL_TELEPORT..appender..MINIMAGE_LABEL_UC);
        end
    end;
    UIDropDownMenu_AddButton(info);
end

function MM_DropDown_ForTheAlliance()
    local appender = ': ';

    -- PORTAL SECTION (hidden if HidePortals is true)
    if not MiniMageOptions.HidePortals then
        local info = { };
        info.text = MINIMAGE_LABEL_PORTAL;
        info.isTitle = 1;
        info.notCheckable = 1;
        UIDropDownMenu_AddButton(info);

        -- ALAH PORTAL
        info = { };
        info.text = MINIMAGE_LABEL_ALAH;
        info.disabled = not MM_CanCastPortal();
        info.func = function(msg)
            if MM_CanCastPortal() then
                CastSpellByName(MINIMAGE_LABEL_PORTAL..appender..MINIMAGE_LABEL_ALAH);
            end
        end;
        UIDropDownMenu_AddButton(info);

        -- DARNASSUS PORTAL
        info = { };
        info.text = MINIMAGE_LABEL_DARNASSUS;
        info.disabled = not MM_CanCastPortal();
        info.func = function(msg)
            if MM_CanCastPortal() then
                CastSpellByName(MINIMAGE_LABEL_PORTAL..appender..MINIMAGE_LABEL_DARNASSUS);
            end
        end;
        UIDropDownMenu_AddButton(info);

        -- IF PORTAL
        info = { };
        info.text = MINIMAGE_LABEL_IF;
        info.disabled = not MM_CanCastPortal();
        info.func = function(msg)
            if MM_CanCastPortal() then
                CastSpellByName(MINIMAGE_LABEL_PORTAL..appender..MINIMAGE_LABEL_IF);
            end
        end;
        UIDropDownMenu_AddButton(info);

        -- SW PORTAL
        info = { };
        info.text = MINIMAGE_LABEL_SW;
        info.disabled = not MM_CanCastPortal();
        info.func = function(msg)
            if MM_CanCastPortal() then
                CastSpellByName(MINIMAGE_LABEL_PORTAL..appender..MINIMAGE_LABEL_SW);
            end
        end;
        UIDropDownMenu_AddButton(info);

        -- THERAMORE PORTAL
        info = { };
        info.text = MINIMAGE_LABEL_THERAMORE;
        info.disabled = not MM_CanCastPortal();
        info.func = function(msg)
            if MM_CanCastPortal() then
                CastSpellByName(MINIMAGE_LABEL_PORTAL..appender..MINIMAGE_LABEL_THERAMORE);
            end
        end;
        UIDropDownMenu_AddButton(info);
    end

    -- TELEPORT SECTION
    local info = { };
    info.text = MINIMAGE_LABEL_TELEPORT;
    info.isTitle = 1;
    info.notCheckable = 1;
    UIDropDownMenu_AddButton(info);

    -- ALAH TELEPORT
    info = { };
    info.text = MINIMAGE_LABEL_ALAH;
    info.disabled = not MM_CanCastTeleport();
    info.func = function(msg)
        if MM_CanCastTeleport() then
            CastSpellByName(MINIMAGE_LABEL_TELEPORT..appender..MINIMAGE_LABEL_ALAH);
        end
    end;
    UIDropDownMenu_AddButton(info);

    -- DARN TELEPORT
    info = { };
    info.text = MINIMAGE_LABEL_DARNASSUS;
    info.disabled = not MM_CanCastTeleport();
    info.func = function(msg)
        if MM_CanCastTeleport() then
            CastSpellByName(MINIMAGE_LABEL_TELEPORT..appender..MINIMAGE_LABEL_DARNASSUS);
        end
    end;
    UIDropDownMenu_AddButton(info);

    -- IF TELEPORT
    info = { };
    info.text = MINIMAGE_LABEL_IF;
    info.disabled = not MM_CanCastTeleport();
    info.func = function(msg)
        if MM_CanCastTeleport() then
            CastSpellByName(MINIMAGE_LABEL_TELEPORT..appender..MINIMAGE_LABEL_IF);
        end
    end;
    UIDropDownMenu_AddButton(info);

    -- SW TELEPORT
    info = { };
    info.text = MINIMAGE_LABEL_SW;
    info.disabled = not MM_CanCastTeleport();
    info.func = function(msg)
        if MM_CanCastTeleport() then
            CastSpellByName(MINIMAGE_LABEL_TELEPORT..appender..MINIMAGE_LABEL_SW);
        end
    end;
    UIDropDownMenu_AddButton(info);

    -- THERAMORE TELEPORT
    info = { };
    info.text = MINIMAGE_LABEL_THERAMORE;
    info.disabled = not MM_CanCastTeleport();
    info.func = function(msg)
        if MM_CanCastTeleport() then
            CastSpellByName(MINIMAGE_LABEL_TELEPORT..appender..MINIMAGE_LABEL_THERAMORE);
        end
    end;
    UIDropDownMenu_AddButton(info);
end

--
-- Slash Commands
--

SLASH_MINIMAGE1 = "/mmage"

SlashCmdList["MINIMAGE"] = function(msg)
    msg = string.lower(msg or "")

    if msg == "reset" then
        MiniMageOptions = {}
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00MiniMage: options reset.|r")

    elseif msg == "icon" then
        if MM_ButtonFrame:IsShown() then
            MM_ButtonFrame:Hide()
            DEFAULT_CHAT_FRAME:AddMessage("|cffffff00MiniMage: minimap button hidden.|r")
        else
            MM_ButtonFrame:Show()
            DEFAULT_CHAT_FRAME:AddMessage("|cffffff00MiniMage: minimap button shown.|r")
        end

    elseif msg == "portals" then
        MiniMageOptions.HidePortals = not MiniMageOptions.HidePortals

        if MiniMageOptions.HidePortals then
            DEFAULT_CHAT_FRAME:AddMessage("|cffffff00MiniMage: Portal hidden.|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffffff00MiniMage: Portal shown.|r")
        end

    elseif msg == "help" or msg == "" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00MiniMage commands:|r")
        DEFAULT_CHAT_FRAME:AddMessage("/mmage help        - Show this help")
        DEFAULT_CHAT_FRAME:AddMessage("/mmage icon      - Show/Hide minimap button")
        DEFAULT_CHAT_FRAME:AddMessage("/mmage reset       - Reset addon saved options")
        DEFAULT_CHAT_FRAME:AddMessage("/mmage portals - Show/Hide portal in dropdown")

    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000MiniMage: unknown command.|r")
        DEFAULT_CHAT_FRAME:AddMessage("Type /mmage help for options.")
    end
end
