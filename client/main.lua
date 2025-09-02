local function Draw3DText(x, y, z, text)
    SetDrawOrigin(x, y, z, 0)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

local function ShowFloorMenu()
    local chosen = nil
    local msg = "Ascenseur - Choisissez un étage:\n"
    for i, f in ipairs(Config.Floors) do
        msg = msg .. i .. ". " .. f.label .. "\\n"
    end
    msg = msg .. "Appuyez sur le chiffre correspondant (1-" .. #Config.Floors .. ")"

    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, true)

    while not chosen do
        Wait(0)
        for i = 1, #Config.Floors do
            if IsControlJustReleased(0, 157 + (i - 1)) then 
                chosen = Config.Floors[i]
                break
            end
        end
    end
    return chosen
end

local function TeleportTo(coords)
    local ped = PlayerPedId()
    DoScreenFadeOut(Config.FadeTime)
    Wait(Config.FadeTime + 50)

    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        SetEntityCoords(veh, coords.x, coords.y, coords.z, false, false, false, true)
        SetEntityHeading(veh, coords.w or 0.0)
    else
        SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, true)
        SetEntityHeading(ped, coords.w or 0.0)
    end

    Wait(200)
    DoScreenFadeIn(Config.FadeTime)
end

CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)

        for _, btn in ipairs(Config.ElevatorButtons) do
            local dist = #(pCoords - btn.coords)

            if dist < 20.0 and Config.DrawMarker then
                DrawMarker(Config.MarkerType, btn.coords.x, btn.coords.y, btn.coords.z - 0.98,
                    0, 0, 0, 0, 0, 0,
                    Config.MarkerScale.x, Config.MarkerScale.y, Config.MarkerScale.z,
                    Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a,
                    false, false, 2, false, nil, nil, false)
            end

            if dist < 2.0 then
                Draw3DText(btn.coords.x, btn.coords.y, btn.coords.z + 0.2, "[E] Utiliser l'ascenseur")
                if IsControlJustReleased(0, Config.InteractionKey) then
                    local chosenFloor = ShowFloorMenu()
                    if chosenFloor then
                        TriggerServerEvent("elevator:server:requestTeleport", chosenFloor.id)
                    end
                end
            end
        end
    end
end)

RegisterNetEvent("elevator:client:teleport", function(coords)
    TeleportTo(coords)
end)
