-- Variable pour savoir si l'UI est ouverte ou non
local isUIOpen = false

-- Fonction utilitaire pour dessiner du texte 3D au-dessus des boutons
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

-- Fonction pour ouvrir l'UI NUI (l'ascenseur)
local function OpenElevatorUI()
    if not isUIOpen then
        isUIOpen = true
        -- Bloque la souris + clavier pour l'UI
        SetNuiFocus(true, true)
        -- Envoie un message NUI vers index.html (ton interface)
        SendNUIMessage({
            type = "openElevator",
            floors = Config.Floors -- transmet la liste des étages
        })
        print("UI ouverte - Floors envoyés:", #Config.Floors)
    end
end

-- Fonction pour fermer l'UI NUI
local function CloseElevatorUI()
    if isUIOpen then
        isUIOpen = false
        -- Rend le jeu jouable à nouveau (débloque souris/clavier)
        SetNuiFocus(false, false)
        -- Informe le NUI de se fermer
        SendNUIMessage({
            type = "closeElevator"
        })
    end
end

-- Fonction de téléportation avec fondu (utilisée après choix étage)
local function TeleportTo(coords)
    local ped = PlayerPedId()
    DoScreenFadeOut(Config.FadeTime)
    Wait(Config.FadeTime + 50)

    -- Téléporte le joueur ou son véhicule
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

-- Callback quand le joueur clique un étage dans l'UI
RegisterNUICallback('selectFloor', function(data, cb)
    local floorId = data.floorId
    -- Ferme le menu
    CloseElevatorUI()
    -- Demande au serveur la téléportation vers l'étage choisi
    TriggerServerEvent("elevator:server:requestTeleport", floorId)
    cb('ok')
end)

-- Callback quand le joueur ferme le menu dans l'UI (croix ou ESC)
RegisterNUICallback('closeUI', function(data, cb)
    CloseElevatorUI()
    cb('ok')
end)

-- Boucle pour désactiver certaines touches quand l'UI est ouverte
CreateThread(function()
    while true do
        if isUIOpen then
            -- Désactive caméra, tir, visée, etc. pour éviter les actions dans le menu
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 263, true)
            
            -- Ferme l'UI si le joueur appuie sur Echap
            if IsControlJustReleased(0, 322) then
                CloseElevatorUI()
            end
        end
        Wait(0)
    end
end)

-- Boucle principale pour détecter si le joueur est proche d'un ascenseur
CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)
        local nearElevator = false

        -- Vérifie tous les boutons d'ascenseur configurés
        for _, btn in ipairs(Config.ElevatorButtons) do
            local dist = #(pCoords - btn.coords)

            -- Affiche un marker si le joueur est proche
            if dist < 20.0 and Config.DrawMarker then
                DrawMarker(Config.MarkerType, btn.coords.x, btn.coords.y, btn.coords.z - 0.98,
                    0, 0, 0, 0, 0, 0,
                    Config.MarkerScale.x, Config.MarkerScale.y, Config.MarkerScale.z,
                    Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a,
                    false, false, 2, false, nil, nil, false)
            end

            -- Interaction si le joueur est très proche (<2m)
            if dist < 2.0 then
                nearElevator = true
                Draw3DText(btn.coords.x, btn.coords.y, btn.coords.z + 0.2, "[E] Utiliser l'ascenseur")
                if IsControlJustReleased(0, Config.InteractionKey) and not isUIOpen then
                    OpenElevatorUI() -- 👉 Ouvre le menu NUI
                end
            end
        end

        -- Si le joueur s’éloigne → ferme l’UI automatiquement
        if not nearElevator and isUIOpen then
            CloseElevatorUI()
        end
    end
end)

-- Événement serveur → téléporte le joueur
RegisterNetEvent("elevator:client:teleport", function(coords)
    TeleportTo(coords)
end)


RegisterCommand("ascenseur", function()
    -- Ouvre le NUI et envoie les étages
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "openElevator",
        floors = Config.Floors -- prend les étages définis dans config.lua
    })
end)

RegisterCommand("clui", function()
    -- CLOSE le NUI et envoie les étages
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "closeElevator"
     })
end)

-- Callback quand le joueur ferme le menu
RegisterNUICallback("closeUI", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "closeElevator"
     })
end)