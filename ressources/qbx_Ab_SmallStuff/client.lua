-- PARAPLUIE

    function getRandomUmbrella()
        local umbrellas = {'umbrella1', 'umbrella2', 'umbrella3'}
        local randomIndex = math.random(1, #umbrellas)
        return umbrellas[randomIndex]
    end

    exports.ox_target:addModel(
        'v_res_fa_umbrella',  
    {  
            -- Option pour prendre un parapluie
            {
                name = "pickup_umbrella",
                label = "Prendre un parapluie",
                icon = 'fa-solid fa-umbrella',
                distance = 1.5,
                onSelect = function(data)
                    TriggerEvent('scully_emotemenu:playEmoteByCommand', getRandomUmbrella())
                end,
            },

        }
    )

-- basket ball

    function getRandombasketemote()
        local basketball = {'bball', 'bball2', 'bball3', 'bball4'}
        local randomIndex = math.random(1, #basketball)
        return basketball[randomIndex]
    end

    exports.ox_target:addModel(
        'prop_bskball_01',  
    {  
            -- Option pour prendre un parapluie
            {
                name = "pickup_bball",
                label = "Prendre un ballon de basket",
                icon = 'fa-solid fa-basketball',
                distance = 1.5,
                onSelect = function(data)
                    TriggerEvent('scully_emotemenu:playEmoteByCommand', getRandombasketemote())
                end,
            },

        }
    )

-- airhockey
    exports.ox_target:addModel(
        'prop_airhockey_01',  
        {  
            -- Option pour prendre un parapluie
            {
                name = "airhokey",
                label = "Faire du Air Hockey",
                icon = 'fa-solid fa-gamepad',
                distance = 1.5,
                onSelect = function(data)
                    exports.qbx_core:Notify('La machine est en panne, autant aller jouer à Shufflepuck Cafe.', 'error', 8000)
                end,
            },

        }
    )

-- handbag
    exports.ox_target:addModel(
        'v_ret_ps_bag_01',  
        {  
            -- Option pour prendre 
            {
                name = "handbag",
                label = "Prendre la saccoche",
                icon = 'fa-solid fa-suitcase',
                distance = 1.5,
                onSelect = function(data)
                    TriggerEvent('scully_emotemenu:playEmoteByCommand', 'handbag')
                end,
            },

        }
    )    

    exports.ox_target:addModel(
    'v_ret_ps_bag_02',  
        {  
            -- Option pour prendre
            {
                name = "handbag2",
                label = "Prendre la saccoche",
                icon = 'fa-solid fa-suitcase',
                distance = 1.5,
                onSelect = function(data)
                    TriggerEvent('scully_emotemenu:playEmoteByCommand', 'handbag2')
                end,
            },

        }
    )

    exports.ox_target:addModel(
    'prop_ld_case_01',  
        {  
            -- Option pour prendre
            {
                name = "briefcase",
                label = "Prendre la saccoche",
                icon = 'fa-solid fa-suitcase',
                distance = 1.5,
                onSelect = function(data)
                    TriggerEvent('scully_emotemenu:playEmoteByCommand', 'brief')
                end,
            },

        }
    )    

    exports.ox_target:addModel(
        'prop_beachbag_05',  
            {  
                -- Option pour prendre
                {
                    name = "briefcase",
                    label = "Prendre le sac de plage",
                    icon = 'fa-solid fa-suitcase',
                    distance = 1.5,
                    onSelect = function(data)
                        TriggerEvent('scully_emotemenu:playEmoteByCommand', 'beachbag')
                    end,
                },
    
            }
        ) 

    exports.ox_target:addModel(
        'prop_beachbag_06',  
            {  
                -- Option pour prendre
                {
                    name = "briefcase",
                    label = "Prendre le sac de plage",
                    icon = 'fa-solid fa-suitcase',
                    distance = 1.5,
                    onSelect = function(data)
                        TriggerEvent('scully_emotemenu:playEmoteByCommand', 'beachbag2')
                    end,
                },
    
            }
        )  
        
    exports.ox_target:addModel(
        'prop_beachbag_01',  
            {  
                -- Option pour prendre
                {
                    name = "briefcase",
                    label = "Prendre le sac de plage",
                    icon = 'fa-solid fa-suitcase',
                    distance = 1.5,
                    onSelect = function(data)
                        TriggerEvent('scully_emotemenu:playEmoteByCommand', 'beachbag3')
                    end,
                },
    
            }
        ) 


-- boué

    exports.ox_target:addModel(
        'prop_beach_ring_01',  
            {  
                -- Option pour prendre un parapluie
                {
                    name = "boue",
                    label = "Prendre la boué",
                    icon = 'fa-solid fa-person-swimming',
                    distance = 1.5,
                    onSelect = function(data)
                        TriggerEvent('scully_emotemenu:playEmoteByCommand', 'beachring')
                    end,
                },

            }
        )  

-- lavabo

    exports.ox_target:addModel(
        Config.lavaboprop,  
            {  
                -- Option pour prendre un parapluie
                {
                    name = "washhands",
                    label = "Se laver les mains",
                    icon = 'fa-solid fa-soap',
                    distance = 1.5,
                    onSelect = function(data)
                        TriggerEvent('scully_emotemenu:playEmoteByCommand', 'cleanhands')
                    end,
                },

            }
        )

-- cachette

    local cachettearchive = {
        coords = vec3(74.73, -19.77, -19.8), 
        name = 'area_cachettestash',
        radius = 0.5,
        debug = false,
        drawSprite = false,
        options = {  
            {
                name = "open_cachettestash",
                label = "fouiller",
                icon = 'fa-solid fa-hand',
                distance = 1.5,
                onSelect = function(data)
                    exports.ox_inventory:openInventory(archive_cachettestash, 'archive_cachette')
                end,
            },
        }
    }

    exports.ox_target:addSphereZone(cachettearchive)

-- golf

    local zonegolf = {
        coords = vec3(48.72, -13.21, 238.00), 
        name = 'area_golf',
        radius = 1.5,
        debug = false,
        drawSprite = false,
        options = {  
            {
                name = "golf",
                label = "Faire du golf",
                icon = 'fa-solid fa-golf-ball-tee',
                distance = 1.5,
                onSelect = function(data)
                    TriggerEvent('scully_emotemenu:playEmoteByCommand', 'golfswing')
                end,
            },
        }
    }
    exports.ox_target:addSphereZone(zonegolf)
    
-- VIDEO

    local zoneTvCEO = {
        coords = vec3(38.17, -11.66, 238.00), 
        name = 'area_tvCEO',
        radius = 1,
        debug = false,
        drawSprite = false,
        options = {  
            {
                name = "tvceo",
                label = "Regarder la télé",
                icon = 'fa-solid fa-tv',
                distance = 1.5,
                onSelect = function(data)
                    TriggerEvent('playVideoForAll', Config.video_ceo, 50)
                end,
            },
        }
    }
    exports.ox_target:addSphereZone(zoneTvCEO)

    local zoneTvfondArchive = {
        coords = vec3(80.33, -19.05, -19.5),
        name = 'area_tvfondarchive',
        radius = 1,
        debug = false,
        drawSprite = false,
        options = {  
            {
                name = "tvhorreur",
                label = "Regarder le film d'horreur",
                icon = 'fa-solid fa-tv',
                items = 'vhs_horreur',
                distance = 1.5,
                onSelect = function(data)
                    TriggerEvent('video_cassette_horreur', Config.video_cassette_horreur, 50)
                end,
            },
            {
                name = "tvx1",
                label = "Regarder la vidéo X",
                icon = 'fa-solid fa-tv',
                items = 'vhs_x1',
                distance = 1.5,
                onSelect = function(data)
                    TriggerEvent('playVideoForAll', Config.video_cassette_x1, 50)
                end,
            },
            {
                name = "tvx2",
                label = "Regarder la vidéo X",
                icon = 'fa-solid fa-tv',
                items = 'vhs_x2',
                distance = 1.5,
                onSelect = function(data)
                    TriggerEvent('playVideoForAll', Config.video_cassette_x2, 50)
                end,
            },
        }
    }
    exports.ox_target:addSphereZone(zoneTvfondArchive)

    local zoneTvbureauArchive = {
        coords = vec3(80.14, 8.1, -19.5),
        name = 'area_tvbureauarchive',
        radius = 1,
        debug = false,
        drawSprite = false,
        options = {  
            {
                name = "tvhorreur",
                label = "Regarder le film d'horreur",
                icon = 'fa-solid fa-tv',
                items = 'vhs_horreur',
                distance = 1.5,
                onSelect = function(data)
                    TriggerEvent('playVideoForAll', Config.video_fond_archive, 50)
                end,
            },
            {
                name = "tvx1",
                label = "Regarder la vidéo X",
                icon = 'fa-solid fa-tv',
                items = 'vhs_x1',
                distance = 1.5,
                onSelect = function(data)
                    TriggerEvent('playVideoForAll', Config.video_cassette_x1, 50)
                end,
            },
            {
                name = "tvx2",
                label = "Regarder la vidéo X",
                icon = 'fa-solid fa-tv',
                items = 'vhs_x2',
                distance = 1.5,
                onSelect = function(data)
                    TriggerEvent('playVideoForAll', Config.video_cassette_x2, 50)
                end,
            },
        }
    }
    exports.ox_target:addSphereZone(zoneTvbureauArchive)

    local zoneBigTvArchive = {
        coords = vec3(88.27, -11.83, -19.3),
        name = 'area_bigtvarchive',
        radius = 1,
        debug = false,
        drawSprite = false,
        options = {  
            {
                name = "bigtvarchive",
                label = "Regarder la TV",
                icon = 'fa-solid fa-tv',
                distance = 1.5,
                onSelect = function(data)
                    TriggerEvent('playVideoForAll', Config.video_bigtv_archive, 50)
                end,
            },
        }
    }
    exports.ox_target:addSphereZone(zoneBigTvArchive)

    local zoneBureauReu = {
        coords = vec3(11.31, 198.67, -19.5),
        name = 'area_bureauReu',
        radius = 1,
        debug = false,
        drawSprite = false,
        options = {  
            {
                name = "bureauReuTV",
                label = "Regarder la TV",
                icon = 'fa-solid fa-tv',
                distance = 1.5,
                onSelect = function(data)
                    TriggerEvent('playVideoForAll', Config.video_reunion_bureau, 50)
                end,
            },
        }
    }
    exports.ox_target:addSphereZone(zoneBureauReu)

    local zonegarageblanc = {
        coords = vec3(228.83, -974.96, -99.0),
        name = 'area_garageblanc',
        radius = 1,
        debug = false,
        drawSprite = false,
        options = {  
            {
                name = "garageblancTV",
                label = "Regarder la TV",
                icon = 'fa-solid fa-tv',
                distance = 1.5,
                onSelect = function(data)
                    TriggerEvent('playVideoForAll', Config.video_garageblanc, 50)
                end,
            },
        }
    }
    exports.ox_target:addSphereZone(zonegarageblanc)