package.path = package.path .. ";data/scripts/lib/?.lua;"
require ("utility")
require ("randomext")
require ("stringutility")
local Dialog = require("dialogutility")
--UI
local window
local playerSelectionComboLeft, playerSelectionComboRight
local allianceChekboxLeft, allianceChekboxRight
local moveAllButton
local fromInventorySelection
local toInventorySelection

local uiInitialized

--data
local selectedLeftPlayer

function initialize()
    if onClient()then
        InteractionText().text = Dialog.generateStationInteractionText(Entity(), random())
    end
end

function interactionPossible(playerIndex, option)
    return true --Server():hasAdminPrivileges(Player(playerIndex))
end

function initUI()

        local res = getResolution()
        local size = vec2(1700, 900)

        local menu = ScriptUI()
        window = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))

        window.caption = "Module Viewer"
        window.showCloseButton = 1
        window.moveable = 1
        menu:registerWindow(window, "Module Viewer")

        local leftX = 10
        local y = 10

        playerSelectionComboLeft = window:createValueComboBox(Rect(leftX, y, leftX + 200, y + 25), "setNewPlayerLeft")
        playerSelectionComboRight = window:createValueComboBox(Rect(size.x/2+leftX, y, size.x-50, y + 25), "setNewPlayerRight")
        y = y + 35
        allianceChekboxLeft = window:createCheckBox(Rect(leftX, y, leftX + 25, y + 25), "", "onAllianceCheckedLeft")
        allianceChekboxLeft.tooltip = "Select Alliance"
        allianceChekboxRight = window:createCheckBox(Rect(size.x - 40, y, size.x - 15, y + 25), "", "onAllianceCheckedRight")
        allianceChekboxRight.tooltip = "Select Alliance"
        y = y + 35

        moveAllButton = window:createButton(Rect(leftX, y, leftX + 100, y + 25), "move All >>", "onMoveAllPressed")
        y = y + 35

        fromInventorySelection = window:createInventorySelection(Rect(leftX, y, size.x/2 - 25, size.y - 50), 10)
        fromInventorySelection:addEmpty()
        fromInventorySelection.onDroppedFunction = "onDroppedFromFunction"
        fromInventorySelection.onClickedFunction = "onFromClicked"

        toInventorySelection = window:createInventorySelection(Rect(size.x/2, y, size.x - 25, size.y - 50), 10)
        toInventorySelection.onDroppedFunction = "onDroppedToFunction"
        toInventorySelection.onClickedFunction = "onToClicked"
        toInventorySelection:addEmpty()
        y = y + 35




        uiInitialized = true
        invokeServerFunction("sendPlayers")
end

function onShowWindow()
    print("onshow")
end

function sendPlayers()
    local players = {Server():getOnlinePlayers()} or {}
    local indices = {}
    for _, player in pairs(players) do
        table.insert(indices, player.index)
    end
    invokeClientFunction(Player(callingPlayer), "receivePlayers", indices)
end

function receivePlayers(indices)
    playerSelectionComboLeft:clear()
    playerSelectionComboRight:clear()
    playerSelectionComboLeft:addEntry(nil, "-Select Player-")
    playerSelectionComboRight:addEntry(nil, "-Select Player-")
    for _,playerIndex in ipairs(indices) do
        playerSelectionComboLeft:addEntry(playerIndex, Player(playerIndex).name)
        playerSelectionComboRight:addEntry(playerIndex, Player(playerIndex).name)
    end
end

function getUpdateInterval()
  return 1
end

function updateClient(timestep)
    if uiInitialized and window.visible then
        if not selectedLeftPlayer or not selectedRightPlayer then print("F") return end
        for i = 1, 10 do
            fromInventorySelection:addEmpty()
            toInventorySelection:addEmpty()
        end
        local player = Player()
        fromInventorySelection:fill(selectedLeftPlayer.index)
        toInventorySelection:fill(selectedRightPlayer.index)
    end
end

function moveAllModules(fromIndex, toIndex)
    if not Server():hasAdminPrivileges(Player(callingPlayer)) then print(Player(callingPlayer).name, "Tried to access moveAllModules") return end
    local from = Faction(fromIndex):getInventory()
    local to = Faction(toIndex):getInventory()
    local items = from:getItems()
    print("Size", from.occupiedSlots)
    for i, data in pairs(items) do
        local amount = data.amount
        local a = to:add(data.item)
        to:setAmount(a, to:amount(a) + amount-1)
        from:removeAll(i)
    end
end

function setNewPlayerLeft(comboBoxIndex, value, selectedIndex)
    print("setNewPlayerLeft")
    allianceChekboxLeft:setCheckedNoCallback(false)
    selectedLeftPlayer = Player(value)
end
function setNewPlayerRight(comboBoxIndex, value, selectedIndex)
    print("setNewPlayerRight")
    allianceChekboxRight:setCheckedNoCallback(false)
    selectedRightPlayer = Player(value)
end

function onAllianceCheckedLeft()
    if not selectedLeftPlayer then return end
    if allianceChekboxLeft.checked then
        selectedLeftPlayer = selectedLeftPlayer.alliance
    else
        selectedLeftPlayer = Player(playerSelectionComboLeft:getValue(playerSelectionComboLeft.selectedIndex))
    end
end
function onAllianceCheckedRight()
    if not selectedRightPlayer then return end
    if allianceChekboxRight.checked then
        selectedRightPlayer = selectedRightPlayer.alliance
    else
        selectedRightPlayer = Player(playerSelectionComboRight:getValue(playerSelectionComboRight.selectedIndex))
    end
end

function onMoveAllPressed()
    if not selectedLeftPlayer or not selectedRightPlayer then print("F") return end
    print("onMoveAllPressed")
    invokeServerFunction("moveAllModules", selectedLeftPlayer.index, selectedRightPlayer.index)
end

function onDroppedFromFunction(selectionIndex, kx, ky)
    if not selectedLeftPlayer or not selectedRightPlayer then print("F") return end
    local selection = Selection(selectionIndex)
    local item = selection:getItem(ivec2(kx,ky))
    invokeServerFunction("moveItem", selectedRightPlayer.index, selectedLeftPlayer.index, item.index)
end

function onDroppedToFunction(selectionIndex, kx, ky)
    if not selectedLeftPlayer or not selectedRightPlayer then print("F") return end
    local selection = Selection(selectionIndex)
    local item = selection:getItem(ivec2(kx,ky))
    invokeServerFunction("moveItem", selectedLeftPlayer.index, selectedRightPlayer.index, item.index)
end

function onFromClicked(selectionIndex, kx, ky, item, button)
    if not selectedLeftPlayer or not selectedRightPlayer then print("F") return end
    if button == 3 then
        invokeServerFunction("moveItem", selectedRightPlayer.index, selectedLeftPlayer.index, item.index)
    end
end

function onToClicked(selectionIndex, kx, ky, item, button)
    if not selectedLeftPlayer or not selectedRightPlayer then print("F") return end
    if button == 3 then
        invokeServerFunction("moveItem", selectedLeftPlayer.index, selectedRightPlayer.index, item.index)
    end
end

function moveItem(fromIndex, toIndex, itemIndex)
    if not Server():hasAdminPrivileges(Player(callingPlayer)) then print(Player(callingPlayer).name, "Tried to access moveItem",fromIndex, toIndex, itemIndex) return end
    local from = Faction(fromIndex):getInventory()
    local to = Faction(toIndex):getInventory()
    local item = from:find(itemIndex)
    if not item then print("no item with index", itemIndex) return end
    local amount = from:amount(itemIndex)
    local a = to:add(item)
    to:setAmount(a, to:amount(a) + amount-1)
    from:removeAll(itemIndex)
end
