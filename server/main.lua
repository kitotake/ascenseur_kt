local FloorsById = {}
for _, f in ipairs(Config.Floors) do
    FloorsById[f.id] = f.coords
end

RegisterNetEvent("elevator:server:requestTeleport", function(floorId)
    local src = source
    local coords = FloorsById[floorId]
    if not coords then
        print(("Ascenseur: demande d'étage inconnu %s de %s"):format(floorId, src))
        return
    end

    TriggerClientEvent("elevator:client:teleport", src, coords)
end)
