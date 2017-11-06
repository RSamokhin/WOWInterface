local version = "v0.81";
local about = [[About:
I have started to make this addon as a tool for myself. Few people started to use it when I pushed it to Curse. Then updated it once with 6.2 release.
After some time I have catched a dialog on my own realm discussing it. I went to check curse page and I was shocked - it was in top-60 monthly downloaded addons with lots of suggestions and few bug reports.
I wasn't going to support it - because it was working - but now it looks like I have to spend at least some time to make it better.

Realm hopping has become a thing. The idea was rather obvious, but less people were using it at the start of WOD. Now every raid group with autoaccept are going to have some quiet people joining and leaving it. But since we became a huge community, it is up to us to control this.
The idea is to create groups from realmhoppers to realmhoppers. Taking small steps to not flood LFG too much. There are some ideas how to make realmhopping more comfortably while reducing annoyance to others.

FAQ:
Q: I cannot loot timeless coins / some other loot
A: Some items cannot be looted while in a raid group. However, rare timeless items can be.".

Q: I'm on the oceanic region and I can't hop to another realm
A: Unfortunately, oceanic realms are separated by Blizzard. There is little I can do :(

Changelog:

v0.7 - 0.76
- New options panel (Groundwork for future customization)
- Some UI customizations are now possible
- "Join to a friend" feature
- "Keywords" feature - blacklist, whitelist and highlight list
- You can add more info to "Manual Join" list
- Clicking to join group when you are already in a group causes you to leave it.
- You can now create a group for other people to use for realm hopping purpose
- You can now automatically create such group when AFK at garrison
- Added advanced filters
- Last column ("Misc") is now a sortable column - it uses base sort (by weight)

v0.8
- WoW Legion update
- Minor fixes

http://www.curse.com/addons/wow/crossrealmassist
https://www.reddit.com/r/crossrealmassist
]]

local AceConfig = LibStub("AceConfig-3.0")
local addon = CrossRealmAssist;

local db
local orderId = 0
local registered = false;
local needReloadUI = false;

local function haveToReloadUI()
    return not needReloadUI;
end

local function order()
    orderId = orderId + 1
    return orderId;
end

local function traverse(info, value)
    local node = db.global
    local last
    if info.arg then
        for k,v in ipairs(info.arg) do
            if last then node = node[last] end
            last = v;
        end
        if value ~= nil then
            local callback = info.arg.callback
            if callback then
                if (type(callback) == "string") then
                    addon[callback](value);
                elseif type(callback) == "function" then
                    callback(value)
                end
            end
            if info.arg.needReloadUI then
                needReloadUI = true
            end
        end
    else last = info[#info] end
    return node, last
end

local function getter(info)
    local node, last = traverse(info);
    return node[last]
end

local function setter(info, value)
    local node, last = traverse(info, value);
    node[last] = value;
end

local function multiGetter(info, key)
    local node, last = traverse(info);
    return node[last][key];
end

local function multiSetter(info, key, value)
    local node, last = traverse(info, value);
    node[last][key] = value;
end

local function setMinimapIcon(hidden)
    if hidden then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Type |cffffffff/cra |cffff0000in chat to open Cross Realm Assist without minimap button");
        minimapIcon:Hide("CrossRealmAssistMinimapIcon")
    else
        minimapIcon:Show("CrossRealmAssistMinimapIcon")
    end
end

local function createKeywordTable(name, desc, listValue)
    local list = db.global[listValue];
    if not list then
        list = {}
        db.global[listValue] = list;
    end
    local selected = 0;

    local function setSelection(info, value)
        selected = value
    end

    local function getSelection()
        return selected
    end

    local function deleteSelected()
        if selected == 0  then return end;
        table.remove(list, selected);
        selected = 0;
    end

    local function addItem(info, value)
        if string.len(value) >= 3  then
            value = string.lower(value);
            for k,v in pairs(list) do
                if v == value then return end
            end
            table.insert(list, value);
        end
    end

    return {
        name = name,
        type = "group",
        order=order(),
        args = {
            desc = {
                type = "description",
                order=order(),
                name = desc
            },
            input = {
                type = "input",
                name = "Add new",
                order=order(),
                set = addItem
            },
            list = {
                name = "Current list",
                type = "select",
                values=list,
                style="radio",
                order=order(),
                set = setSelection,
                get = getSelection,
            },
            delete = {
                type = "execute",
                name = "Delete selected",
                order=order(),
                func = deleteSelected
            },
        },
    }
end

local function getLFGGroups()
    local table = {}
    for i=1,#addon.lfgGroups do
        local groupId = addon.lfgGroups[i]
        table[groupId] = (C_LFGList.GetCategoryInfo(groupId))
    end
    return table;
end

local function register()
    local CRAOptions = {
        type = "group",
        get = getter,
        set = setter,
        args = {
            reload = {
                type = "execute",
                name = "Reload UI",
                order=order(),
                func = ReloadUI,
                hidden = haveToReloadUI
            },
            reloadDesc = {
                name = "UI reload is required for some settings to take effect",
                type = "description",
                order=order(),
                width="double",
                hidden = haveToReloadUI
            },
            general={
                name = "General options",
                type = "group",
                order=order(),
                args = {
                    quickJoinHint = {
                        name = "Show Quick Join Hint",
                        type = "toggle",
                        order=order(),
                    },
                    minimap = {
                        name = "Hide minimap button",
                        type = "toggle",
                        arg = {"minimap","hide",callback="toggleMinimapIcon"},
                        order=order(),
                    },
                    allLanguages = {
                        name = "All language groups",
                        type = "toggle",
                        order=order(),
                    },
                    applyAsDD = {
                        name = "Apply to groups as DD only",
                        type = "toggle",
                        width = "double",
                        order=order(),
                    },
                    quickJoin = {
                        name = "Quick Join Categories",
                        type = "multiselect",
                        values = getLFGGroups(),
                        get = multiGetter,
                        set = multiSetter,
                        order=order()
                    },
                    hopGroupHeader = {
                        name = "Realm Hoppers Union",
                        type = "header",
                        order=order(),
                    },
                    hopGroupDesc = {
                        name = "Help other CrossRealmAssist users (and other people) and they will help you someday! Open a group for others when you are away. CRA can automatically open such group when following conditions are met:",
                        type = "description",
                        order=order(),
                    },
                    autoCreateHopGroup = {
                        name = "You are AFK at garrison",
                        type = "toggle",
                        order=order(),
                    }
                }
            },
            keywords={
                name = "Keywords",
                type = "group",
                order=order(),
                args={
                    blacklist = createKeywordTable("Blacklisted keywords","Groups with these keywords will be ignored when quick joining. Don't be evil","stoplist"),
                    whitelist = createKeywordTable("Priority keywords","Groups with these keywords are high-priority groups and are first to join regardless of group size","priorityList"),
                    highlight = createKeywordTable("Highlight keywords","Groups with these keywords will be highlighted in green in the Manual Join panel","highlightList")
                }
            },
            appearance={
                name = "Appearance",
                type = "group",
                order=order(),
                args={
                    uiScale = {
                        name = "Mini panel size",
                        type = "range",
                        min=0.5, max=1.5,isPercent=true,bigStep=0.05,
                        order=order(),
                        arg={"uiScale",callback="updateUIScale"}
                    },
                    lfgPanelScale = {
                        name = "Manual Join panel size",
                        type = "range",
                        min=0.5, max=1.5,isPercent=true,bigStep=0.05,
                        order=order(),
                        arg={"lfgPanelScale",callback="updateLfgScale"}
                    },
                    listItemCount = {
                        name = "Manual Join list size",
                        type = "range",
                        min=5, max=30,step=1,
                        order=order(),
                        arg={"listItemCount",needReloadUI=1}
                    },
                    extraColumns = {
                        name = "Show extra info in group table",
                        type = "multiselect",
                        values = {rtype="Realm type (PVE/PVP/etc)",groupAge="Group age",joinTime="Time since joining"},
                        arg={"extraColumns",needReloadUI=1},
                        get = multiGetter,
                        set = multiSetter,
                        order=order()
                    },
                }
            },
            about={
                name = "About",
                type = "group",
                order=order(),
                args={
                    aboutHeader = {
                        name = "CrossRealmAssist "..version.." by ShadowTheAge",
                        type = "header",
                        order=order(),
                    },
                    aboutDesc = {
                        name = about,
                        type = "description",
                        width = "full",
                        order=order(),
                    }
                }
            }
        }
    }
    AceConfig:RegisterOptionsTable("CrossRealmAssist", CRAOptions)
    registered = true;
end

addon.showSettings = function()
    db = addon.db;
    if not registered then register() end
    LibStub("AceConfigDialog-3.0"):Open("CrossRealmAssist")
end
