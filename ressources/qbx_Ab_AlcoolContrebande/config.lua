Config = {

-- PARTIE ALCOOL

    tic_time_undrunk = 10000, -- pour le temps entre chaque réduction de 1 du niveau d'alcool (ici 0 a 100 en 16min)

    -- Les palier de changement de niveau d'ébriété
    drunk_palier1 = 10,
    drunk_palier2 = 30,
    drunk_palier3 = 50,
    drunk_palier4 = 80,
    drunk_palier5 = 100,
    drunk_paliermax = 150,

    ethylo_jobRequired = {'admin', 'infirmerie'},
    item_ethylo = 'ethylostest',

-- PARTIE CONTREBANDE

    parkingWait_time = 15*60*1000,

    -- item d'échange 
    giveitem_1 = 'golden_ducky',
    giveitem_1_name = 'Golden Ducky',
    receiveitem_1 = 'cdrom_blackmarket',

    giveitem_2 = 'good_carte_mere',
    giveitem_2_name = 'Carte mère',
    receiveitem_2 = 'os_weed',

    giveitem_3 = 'bad_carte_mere',
    giveitem_3_name = 'Carte mère cassée',
    receiveitem_3 = 'alanis_bottle',

    giveitem_4 = 'clean_sign',
    giveitem_4_name = 'Panneau de ménage',
    receiveitem_4 = 'gin_bottle',

    giveitem_5 = 'chococho',
    giveitem_5_name = 'Chococho',
    receiveitem_5 = 'windy_bottle_rose',

    giveitem_6 = 'hamburger',
    giveitem_6_name = 'Hamburger',
    receiveitem_6 = 'windy_bottle_verte',

    giveitem_7 = 'jeton',
    giveitem_7_name = 'Bon point',
    receiveitem_7 = 'empty_pills',

    giveitem_8 = 'vitamines',
    giveitem_8_name = 'Vitamines',
    receiveitem_8 = 'desinfectos',

-- Autre 

    waterfillprop = {
        'prop_bar_sink_01',
        'office_sink_decoy',
        'prop_ff_sink_02',
    },

}