Config = {

    search_fatigue_up = 5,
    search_stress_up = 5,
    search_duration = 10000,

    cd_searchmini = 3 * 60, -- min * 60s
    cd_searchmaxi = 6 * 60, -- min * 60s
    
    jobRequired = {
        'archive',
        'admin'
        },
    jobtoprod = 'archive',

    archivesearch_props = {
        'office_04_binders_01',
        'office_04_binders_02',
        'office_04_binders_03',
    },
    adminprops = 'v_ind_dc_desk01',

    baddoc_wh = {
        'doctext_letter1',
        'doctext_letter2',
        'doctext_letter3',
        'doctext_letter4',
        'doctext_letter5',
        'docimage_recette_boissons',
        'docimage_recette_burger',
        'docimage_recette_frite',
        'docimage_recette_omelette',
        'docimage_recette_salade',
        'docimage_recette_cafe',
        'docimage_nds_bonbonne',
        'docimage_nds_courrier',
        'docimage_nds_livraison',
        'docimage_nds_commande',
        'docimage_jobdoc_it',
        'docimage_jobdoc_cafet',
        'docimage_jobdoc_archive',
        'docimage_jobdoc_menage',
        'docimage_jobdoc_compta',
        'docimage_jobdoc_accueil',
        'docimage_jobdoc_infirmerie',
        'docimage_jobdoc_communication',
        'docimage_useless1',
        'docimage_useless2',
        'docimage_useless3',
        'docimage_useless4',
        'docimage_useless5',
        'docimage_useless6',
        'docimage_useless7',
        'docimage_useless8',
        'docimage_recette_grosjoint',
        'docimage_pub',
        'docimage_pub2',
        'docimage_pub3',
        'docimage_pub4',
        'docimage_pub6',
        'docimage_pub7',
        'docimage_pola_04',
        'docimage_pola_05',
        'docimage_pola_06',
        'docimage_pola_07',
        'docimage_pola_08',
        'docimage_pola_09',
        'docimage_joblist',
    },

    gooddoc_wh = {
        'docimage_code1',
        'docimage_pola_01',
        'docimage_pola_02',
        'docimage_pola_03',
        'docimage_pola_07',
        'docimage_photo_1',
        'docimage_pub',
        'docimage_recette_grosjoint',
        'docimage_code2',
        'docimage_code3',
        'docimage_code4',
        'docimage_code5',
        'docimage_code6',

    },

-- tri de document

    receiptslots = 30,
    upprod = 0.2,
    upstress = 2,
    upfatigue = 5,

    dropfile_duration = 2000,

    -- item a tri:
    it_doc = "doctri_it",
    it_doc_name = 'document bleu claire',
    cafet_doc = 'doctri_cafet',
    cafet_doc_name = 'document jaune',
    archive_doc = "doctri_archive",
    archive_doc_name = 'document truquoise',
    menage_doc ='doctri_menage',
    menage_doc_name = 'document orange',
    compta_doc = 'doctri_compta',
    compta_doc_name = 'document rouge',
    accueil_doc = 'doctri_accueil',
    accueil_doc_name = 'document rose',
    communication_doc = 'doctri_com',
    communication_doc_name = 'document violet',
    infirmerie_doc = 'doctri_inf',
    infirmerie_doc_name = 'document vert',

    -- Tri position
    telegestion_pos = vec3(93.32, 1.39, -19.0),
    culinaire_pos= vec3(77.81, -18.42, -19.0),
    consignation_pos = vec3(91.98, 0.53, -12.1),
    sanitaire_pos = vec3(93.31, -8.56, -19.0),
    budget_pos = vec3(106.82, 1.67, -15.4),
    coordination_pos = vec3(103.35, -11.65, -12.1),
    transmission_pos = vec3(105.88, -1.11, -19.0),
    therapeutique_pos = vec3(100.88, -7.45, -19.0),
    

}
