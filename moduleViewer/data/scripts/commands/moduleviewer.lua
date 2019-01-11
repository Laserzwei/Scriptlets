package.path = package.path .. ";data/scripts/player/?.lua"

function execute(sender, commandName)
    local player = Player(sender)
    local playership = player.craft
    playership:addScriptOnce("mods/moduleViewer/scripts/entity/moduleViewer.lua")
    return 0, "", ""
end

function getDescription()
    return "usage /moneypunish <FactionToPunish> <ReceivingFaction> <Money> <Iron> <Titanium> <Naonite> <Trinium> <Xanium> <Ogonite> <Avorion>"
end

function getHelp()
    return "usage /moneypunish <FactionToPunish> <ReceivingFaction> <Money> <Iron> <Titanium> <Naonite> <Trinium> <Xanium> <Ogonite> <Avorion>"
end
