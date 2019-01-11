
local moneyThreshold = 20000000 --20.000.000
local resourceThreshold = 50000 --50.000
function initialize()
    print("init")
    update()
end

function getUpdateInterval()
    return 30
end

function update(timestep)
    if onClient() then return end
    local faction = Faction()
    local receivingFaction = Faction(faction:getValue("punished.receiver"))
    local money = tonumber(faction:getValue("punished.money"))
    local res = {}
    res[(MaterialType.Iron)] = tonumber(faction:getValue("punished.iron"))
    res[(MaterialType.Titanium)] = tonumber(faction:getValue("punished.titanium"))
    res[(MaterialType.Naonite)] = tonumber(faction:getValue("punished.naonite"))
    res[(MaterialType.Trinium)] = tonumber(faction:getValue("punished.trinium"))
    res[(MaterialType.Xanion)] = tonumber(faction:getValue("punished.xanium"))
    res[(MaterialType.Ogonite)] = tonumber(faction:getValue("punished.ogonite"))
    res[(MaterialType.Avorion)] = tonumber(faction:getValue("punished.avorion"))

    if money <= 0 and
    res[(MaterialType.Iron)] <= 0 and
    res[(MaterialType.Titanium)] <= 0 and
    res[(MaterialType.Naonite)] <= 0 and
    res[(MaterialType.Trinium)] <= 0 and
    res[(MaterialType.Xanion)] <= 0 and
    res[(MaterialType.Ogonite)] <= 0 and
    res[(MaterialType.Avorion)] <= 0 then
        terminate()
        return
    end
    -- make him pay
    local moneyToPay = 0
    if faction.money > moneyThreshold then
        moneyToPay = math.min(faction.money - moneyThreshold, money)
    end
    local factionResources = {faction:getResources()}
    local resourcesToPay = {}
    for i,toPay in pairs(res) do
        if factionResources[i] and factionResources[i] > resourceThreshold then
            resourcesToPay[i] = math.min(factionResources[i] - resourceThreshold, toPay or 0)
        else
            resourcesToPay[i] = 0
        end
    end
    faction:pay(Format("You payed %2%CR %3% Iron %4% Titanium %5% Naonite %6% Trinium %7% Xanion %8% Ogonite %9% Avorion to %1%", receivingFaction.name), moneyToPay, unpack(resourcesToPay))
    receivingFaction:receive(Format("You received %2%CR %3% Iron %4% Titanium %5% Naonite %6% Trinium %7% Xanion %8% Ogonite %9% Avorion from %1%", faction.name), moneyToPay, unpack(resourcesToPay))
    faction:setValue("punished.money", money-moneyToPay)
    faction:setValue("punished.iron", res[(MaterialType.Iron)] - resourcesToPay[(MaterialType.Iron)]or 0)
    faction:setValue("punished.titanium", res[(MaterialType.Titanium)] - resourcesToPay[(MaterialType.Titanium)]or 0)
    faction:setValue("punished.naonite", res[(MaterialType.Naonite)] - resourcesToPay[(MaterialType.Naonite)]or 0)
    faction:setValue("punished.trinium", res[(MaterialType.Trinium)] - resourcesToPay[(MaterialType.Trinium)]or 0)
    faction:setValue("punished.xanium", res[(MaterialType.Xanion)] - resourcesToPay[(MaterialType.Xanion)]or 0)
    faction:setValue("punished.ogonite", res[(MaterialType.Ogonite)] - resourcesToPay[(MaterialType.Ogonite)]or 0)
    faction:setValue("punished.avorion", res[(MaterialType.Avorion)] - resourcesToPay[(MaterialType.Avorion)]or 0)

    print(faction.name, "left to pay to ", receivingFaction.name..":", faction:getValue("punished.money"),
    faction:getValue("punished.iron"),
    faction:getValue("punished.titanium"),
    faction:getValue("punished.naonite"),
    faction:getValue("punished.trinium"),
    faction:getValue("punished.xanium"),
    faction:getValue("punished.ogonite"),
    faction:getValue("punished.avorion"))
end
