Config = {}

Config.DrawMarker = true
Config.MarkerType = 1
Config.MarkerScale = { x = 1.0, y = 1.0, z = 1.0 }
Config.MarkerColor = { r = 0, g = 150, b = 255, a = 100 }
Config.InteractionKey = 38 -- E
Config.FadeTime = 500


Config.Floors = {
    { id = 1, label = "Rez-de-chaussée", coords = vector4(-267.0, -962.0, 31.22, 0.0) },
    { id = 2, label = "Étage 1", coords = vector4(-267.0, -962.0, 41.22, 0.0) },
    { id = 3, label = "Étage 2", coords = vector4(-267.0, -962.0, 51.22, 0.0) }
}

Config.ElevatorButtons = {
    { name = "BOUTON_EXT", coords = vector3(-267.0, -962.0, 31.0) },
    { name = "BOUTON_INT", coords = vector3(-267.0, -962.0, 41.0) }
}
