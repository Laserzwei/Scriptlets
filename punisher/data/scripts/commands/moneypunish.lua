package.path = package.path .. ";data/scripts/player/?.lua"

function execute(sender, commandName, factionToPunish, receivingFaction, money, iron, titanium, naonite, trinium, xanium, ogonite, avorion)
    local playerWhoCalled = Player(sender)
    if not factionToPunish then playerWhoCalled:sendChatMessage("punisher", 0, "faction to punish not set") return end
    local punishedFaction
    if Player(factionToPunish) then
        punishedFaction = Player(factionToPunish)
    elseif Alliance(factionToPunish) then
        punishedFaction = Alliance(factionToPunish)
    end
    if not punishedFaction then playerWhoCalled:sendChatMessage("punisher", 0, "faction to punish not a valid Playe ror Alliance") return end
    receivingFaction = receivingFaction or -1
    local money = money or 0
    local iron = iron or 0
    local titanium = titanium or 0
    local naonite = naonite or 0
    local trinium = trinium or 0
    local xanium = xanium or 0
    local ogonite = ogonite or 0
    local avorion = avorion or 0
    print("Punishing",punishedFaction.name, "for", money, iron, titanium, naonite, trinium, xanium, ogonite, avorion)
    punishedFaction:setValue("punished.receiver", receivingFaction)
    punishedFaction:setValue("punished.money", money)
    punishedFaction:setValue("punished.iron", iron)
    punishedFaction:setValue("punished.titanium", titanium)
    punishedFaction:setValue("punished.naonite", naonite)
    punishedFaction:setValue("punished.trinium", trinium)
    punishedFaction:setValue("punished.xanium", xanium)
    punishedFaction:setValue("punished.ogonite", ogonite)
    punishedFaction:setValue("punished.avorion", avorion)

    punishedFaction:addScriptOnce("data/scripts/player/moneypunisher.lua")
    return 0, "", ""
end

function getDescription()
    return "usage /moneypunish <FactionToPunish> <ReceivingFaction> <Money> <Iron> <Titanium> <Naonite> <Trinium> <Xanium> <Ogonite> <Avorion>"
end

function getHelp()
    return "usage /moneypunish <FactionToPunish> <ReceivingFaction> <Money> <Iron> <Titanium> <Naonite> <Trinium> <Xanium> <Ogonite> <Avorion>"
end
