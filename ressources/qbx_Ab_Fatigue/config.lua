Config = {

    veryhighfat = 95,
    highfat = 75,
    midfat = 50,
    
    warningtime = 7000,

    jobRequired = {'admin', 'infirmerie'},


    goodbedprop = {
        'office_05_big_bed',
        'office_ceo_lay_bed',
    },
    medicalbedprop = 'v_med_bed2',
    badbedprop = {
        'office_05_lay_bed',
        'office_ss_lay_bed',
    },
    transatprop = 'eaz_lounger_01',
    massageprop = 'eaz_massage_chair',

    -- 3 = une minutes pour faire 100 a 0 de fatigue pour -5 de downfatigue
    timegood = 12, -- trigger en seconde de réduction de fatigue
    timebad = 24, -- trigger en seconde de réduction de fatigue
    timetransat = 48,  -- trigger en seconde de réduction de fatigue
    timemedic = 8, -- trigger en seconde de réduction de fatigue

    timedestress = 20, -- seconde entre les tics de stress
    timetotalmassage = 60,  -- en seconde

    timeInfoSlow = 8,
    timeInfoFast = 1,

    downfatigue_resting = -5,
    downstress_resting_low = 1,
    downstress_resting_high = 5,
    downstress_resting_veryhigh = 10,

    -- sport: 

    tapisprop = {
    'prop_yoga_mat_01',
    'prop_yoga_mat_02',
    'prop_yoga_mat_03',
    },
    doublealterprop = 'prop_weight_squat',
    simplealterprop_big = 'prop_weight_rack_02',
    simplealterprop_medium = 'prop_freeweight_02',
    simplealterprop_small = 'prop_freeweight_01',
    layalterprop = 'prop_muscle_bench_03',
    tractionprop = 'prop_muscle_bench_05',
    showerprops = {
        'office_05_r7_showers',
        'office_05_shower_priv',
        'door_office_klr_show',
        'office_showers_duo',
        'office_ceo_shower_priv',
    },


    simplealtermodel_big = 'prop_barbell_01',
    simplealtermodel_medium = 'prop_freeweight_02',
    simplealtermodel_small = 'prop_freeweight_01',
    simplealtermodel_small_bis = 'v_res_tre_weight',

    -- temps en seconde entre chaque tic d'augmentation de fatigue et réduction de stress
    timesporthigh = 5,
    timesportmedium = 10,
    timesportlow = 15,

    timetotalshower = 30,  -- en seconde

    upfatigue_sport = 5,
    downstress_sport = 6,
    downfatigue_douche = -2,

}