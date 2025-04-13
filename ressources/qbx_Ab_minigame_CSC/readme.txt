COTE JS: 1010

// CEST ICI !
let firststart = true;

document.addEventListener('DOMContentLoaded', function () {
    window.addEventListener('message', function (event) {
        const { action, computerID } = event.data; // Récupérer les données du message

        switch (action) {
            case 'openGameGraph':
                console.log("Ouverture du jeu avec l'ordinateur ID :", computerID);

                // Stocker l'ID de l'ordinateur
                currentComputerID = computerID;    

				const elem = document.getElementById('gm4html5_div_id');
				elem.style.display = 'block';
				firstend = true
				if (firststart == true) {
					GameMaker_Init();
					firststart = false;
				}
				else {               
					game_restart();
				}
                break;
            default:
                break;
        }
    });
});

let firstend = true; 
let currentComputerID = null; // Variable globale pour stocker l'ID de l'ordinateur actif

function endgame(win) {
    // Vérifier que le NUI fournit le bon parent resource name
    const parentResourceName = GetParentResourceName();
    if (!parentResourceName) {
        console.error("Parent resource name introuvable !");
        return;
    }

    // Vérifier qu'un `computerID` est actif
    if (!currentComputerID) {
        console.error("Aucun ID d'ordinateur associé !");
        return;
    }

    // Préparer les données à envoyer
    const data = {
        win: win,
        computerID: currentComputerID
    };

    // Envoyer les résultats via une requête POST au serveur
    fetch(`https://${parentResourceName}/endgame`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify(data)
    }).then(() => {
        console.log("Résultat envoyé au serveur : ", data);
    }).catch((err) => console.error("Erreur lors de l'envoi des résultats :", err));
}

function gml_Object_oGame_Step_0(_inst, _other) {
    if (yyfequal(g_pBuiltIn.get_current_room(), YYASSET_REF(0x03000000))) {
        {
            room_goto(YYASSET_REF(0x03000001));
            return;
        }
    }
    if (yyfequal(global.gmldone, true)) {
        {
            {
                if (yyfequal(global.gmlwinsituation, true)) {
                    {
						global.gmlwin = true;
						if (firstend == true){
							endgame(true);
							// game_end();
							const elem = document.getElementById('gm4html5_div_id');
							elem.style.display = 'none';
							firstend = false; 
						}
                    }
                } else {
                    {
                        global.gmllosetime = yyfplus(global.gmllosetime, 1);
                        global.gmlgok = false;
                        global.gmlbok = false;
                        global.gmlrok = false;
                        global.gmlwinsituation = false;
                        room_restart();
                    }
                }
                global.gmldone = false;
            }
        }
    }
    if (yyGetBool(yyfequal(global.gmlgok, true)) && yyGetBool(yyfequal(global.gmlbok, true)) && yyGetBool(yyfequal(global.gmlrok, true))) {
        {
            global.gmlwinsituation = true;
        }
    } else {
        global.gmlwinsituation = false;
    }
    if (yyfgreater(global.gmllosetime, 2)) {
        {
            global.gmllose = false;
			if (firstend == true){
				endgame(false);
				// game_end();
				const elem = document.getElementById('gm4html5_div_id');
				elem.style.display = 'none';
				firstend = false; 
			}
        }
    }
}
function gml_Object_oGame_Keyboard_8(_inst, _other) {
    if (yyfequal(global.gmlwin, false)) {
        {
            global.gmllose = false;
			if (firstend == true){
				endgame(false);
				// game_end();
				const elem = document.getElementById('gm4html5_div_id');
				elem.style.display = 'none';
				firstend = false; 
			}
        }
    }
}
function gml_Object_oGame_Other_4(_inst, _other) {
    global.gmlgok = false;
    global.gmlbok = false;
    global.gmlrok = false;
    global.gmlwinsituation = false;
    global.gmldone = false;
    _inst.gmlrestart = false;
}
function gml_Object_oGame_Draw_0(_inst, _other) {
    draw_text(
        yyfplus(__yy_gml_errCheck(_inst.x), 10),
        yyfplus(__yy_gml_errCheck(_inst.y), 10),
        yyfplus(
            yyfplus(
                yyfplus(yyfplus(yyfplus(yyfplus(yyfplus("win situation: ", __yy_gml_errCheck(string(global.gmlwinsituation))), "gok: "), __yy_gml_errCheck(string(global.gmlgok))), "bok: "), __yy_gml_errCheck(string(global.gmlbok))),
                "rok: "
            ),
            __yy_gml_errCheck(string(global.gmlrok))
        )
    );
}
function gml_Object_oGreenBar_Create_0(_inst, _other) {
    _inst.gmlstretching = false;
    _inst.gmlcurrent_height = _inst.sprite_height;
    _inst.gmlorigin_y = _inst.y;
}
function gml_Object_oGreenBar_Step_0(_inst, _other) {
    _inst.gmlcurrent_height = clamp(_inst.gmlcurrent_height, 8, 176);
    if (yyfless(_inst.gmlcurrent_height, 8)) {
        _inst.gmlcurrent_height = 8;
    }
    var gmlsaved_y = yyfplus(__yy_gml_errCheck(_inst.gmlorigin_y), __yy_gml_errCheck(yyfminus(__yy_gml_errCheck(_inst.sprite_height), __yy_gml_errCheck(_inst.gmlcurrent_height))));
    if (yyGetBool(mouse_check_button_pressed(1))) {
        {
            if (
                yyGetBool(
                    point_in_rectangle(
                        g_pBuiltIn.get_mouse_x(),
                        g_pBuiltIn.get_mouse_y(),
                        _inst.x,
                        gmlsaved_y,
                        yyfplus(__yy_gml_errCheck(_inst.x), __yy_gml_errCheck(_inst.sprite_width)),
                        yyfplus(__yy_gml_errCheck(_inst.y), __yy_gml_errCheck(_inst.sprite_height))
                    )
                )
            ) {
                {
                    _inst.gmlstretching = true;
                }
            }
        }
    }
    if (yyGetBool(mouse_check_button_released(1))) {
        {
            _inst.gmlstretching = false;
        }
    }
    if (yyGetBool(yyfequal(global.gmlversion, 1)) || yyGetBool(yyfequal(global.gmlversion, 2)) || yyGetBool(yyfequal(global.gmlversion, 3)) || yyGetBool(yyfequal(global.gmlversion, 4)) || yyGetBool(yyfequal(global.gmlversion, 17))) {
        {
            if (yyGetBool(point_in_rectangle(198, 118, _inst.x, gmlsaved_y, yyfplus(__yy_gml_errCheck(_inst.x), __yy_gml_errCheck(_inst.sprite_width)), yyfplus(__yy_gml_errCheck(_inst.y), __yy_gml_errCheck(_inst.sprite_height))))) {
                {
                    global.gmlgok = true;
                }
            } else {
                {
                    global.gmlgok = false;
                }
            }
        }
    }
    if (yyGetBool(yyfequal(global.gmlversion, 5)) || yyGetBool(yyfequal(global.gmlversion, 6)) || yyGetBool(yyfequal(global.gmlversion, 7)) || yyGetBool(yyfequal(global.gmlversion, 8)) || yyGetBool(yyfequal(global.gmlversion, 18))) {
        {
            var gmlp1 = false;
            var gmlp2 = false;
            if (yyGetBool(point_in_rectangle(198, 118, _inst.x, gmlsaved_y, yyfplus(__yy_gml_errCheck(_inst.x), __yy_gml_errCheck(_inst.sprite_width)), yyfplus(__yy_gml_errCheck(_inst.y), __yy_gml_errCheck(_inst.sprite_height))))) {
                {
                    gmlp1 = true;
                }
            } else {
                {
                    gmlp1 = false;
                }
            }
            if (yyGetBool(point_in_rectangle(198, 158, _inst.x, gmlsaved_y, yyfplus(__yy_gml_errCheck(_inst.x), __yy_gml_errCheck(_inst.sprite_width)), yyfplus(__yy_gml_errCheck(_inst.y), __yy_gml_errCheck(_inst.sprite_height))))) {
                {
                    gmlp2 = true;
                }
            } else {
                {
                    gmlp2 = false;
                }
            }
            if (yyGetBool(yyfequal(gmlp1, false)) && yyGetBool(yyfequal(gmlp2, true))) {
                global.gmlgok = true;
            } else {
                global.gmlgok = false;
            }
        }
    }
    if (yyGetBool(yyfequal(global.gmlversion, 9)) || yyGetBool(yyfequal(global.gmlversion, 10)) || yyGetBool(yyfequal(global.gmlversion, 11)) || yyGetBool(yyfequal(global.gmlversion, 12)) || yyGetBool(yyfequal(global.gmlversion, 19))) {
        {
            var gmlp1 = false;
            var gmlp2 = false;
            if (yyGetBool(point_in_rectangle(198, 158, _inst.x, gmlsaved_y, yyfplus(__yy_gml_errCheck(_inst.x), __yy_gml_errCheck(_inst.sprite_width)), yyfplus(__yy_gml_errCheck(_inst.y), __yy_gml_errCheck(_inst.sprite_height))))) {
                {
                    gmlp1 = true;
                }
            } else {
                {
                    gmlp1 = false;
                }
            }
            if (yyGetBool(point_in_rectangle(198, 198, _inst.x, gmlsaved_y, yyfplus(__yy_gml_errCheck(_inst.x), __yy_gml_errCheck(_inst.sprite_width)), yyfplus(__yy_gml_errCheck(_inst.y), __yy_gml_errCheck(_inst.sprite_height))))) {
                {
                    gmlp2 = true;
                }
            } else {
                {
                    gmlp2 = false;
                }
            }
            if (yyGetBool(yyfequal(gmlp1, false)) && yyGetBool(yyfequal(gmlp2, true))) {
                global.gmlgok = true;
            } else {
                global.gmlgok = false;
            }
        }
    }
    if (yyGetBool(yyfequal(global.gmlversion, 13)) || yyGetBool(yyfequal(global.gmlversion, 14)) || yyGetBool(yyfequal(global.gmlversion, 15)) || yyGetBool(yyfequal(global.gmlversion, 16)) || yyGetBool(yyfequal(global.gmlversion, 20))) {
        {
            var gmlp1 = false;
            var gmlp2 = false;
            if (yyGetBool(point_in_rectangle(198, 198, _inst.x, gmlsaved_y, yyfplus(__yy_gml_errCheck(_inst.x), __yy_gml_errCheck(_inst.sprite_width)), yyfplus(__yy_gml_errCheck(_inst.y), __yy_gml_errCheck(_inst.sprite_height))))) {
                {
                    gmlp1 = true;
                }
            } else {
                {
                    gmlp1 = false;
                }
            }
            if (yyGetBool(point_in_rectangle(198, 238, _inst.x, gmlsaved_y, yyfplus(__yy_gml_errCheck(_inst.x), __yy_gml_errCheck(_inst.sprite_width)), yyfplus(__yy_gml_errCheck(_inst.y), __yy_gml_errCheck(_inst.sprite_height))))) {
                {
                    gmlp2 = true;
                }
            } else {
                {
                    gmlp2 = false;
                }
            }
            if (yyGetBool(yyfequal(gmlp1, false)) && yyGetBool(yyfequal(gmlp2, true))) {
                global.gmlgok = true;
            } else {
                global.gmlgok = false;
            }
        }
    }
}
function gml_Object_oGreenBar_Draw_0(_inst, _other) {
    var gmlsaved_y = yyfplus(__yy_gml_errCheck(_inst.gmlorigin_y), __yy_gml_errCheck(yyfminus(__yy_gml_errCheck(_inst.sprite_height), __yy_gml_errCheck(_inst.gmlcurrent_height))));
    if (yyGetBool(_inst.gmlstretching)) {
        {
            var gmlnew_height = yyfplus(__yy_gml_errCheck(_inst.sprite_height), __yy_gml_errCheck(yyfminus(__yy_gml_errCheck(g_pBuiltIn.get_mouse_y()), __yy_gml_errCheck(_inst.y))));
            _inst.gmlcurrent_height = __yy_gml_errCheck(-__yy_gml_errCheck(gmlnew_height));
            var gmlsaved_y = yyfplus(__yy_gml_errCheck(_inst.gmlorigin_y), __yy_gml_errCheck(yyfminus(__yy_gml_errCheck(_inst.sprite_height), __yy_gml_errCheck(_inst.gmlcurrent_height))));
            draw_sprite_stretched(_inst, _inst.sprite_index, 0, _inst.x, gmlsaved_y, _inst.sprite_width, _inst.gmlcurrent_height);
        }
    } else {
        {
            var gmlsaved_y = yyfplus(__yy_gml_errCheck(_inst.gmlorigin_y), __yy_gml_errCheck(yyfminus(__yy_gml_errCheck(_inst.sprite_height), __yy_gml_errCheck(_inst.gmlcurrent_height))));
            draw_sprite_stretched(_inst, _inst.sprite_index, 0, _inst.x, gmlsaved_y, _inst.sprite_width, _inst.gmlcurrent_height);
        }
    }
}
function gml_Object_oMouse_Create_0(_inst, _other) {
    _inst.gmlcatched = false;
    _inst.gmlallow_catch = true;
}
function gml_Object_oMouse_Step_0(_inst, _other) {
    _inst.x = g_pBuiltIn.get_mouse_x();
    _inst.y = g_pBuiltIn.get_mouse_y();
}
function gml_Object_oMouse_Collision_oCroix(_inst, _other) {
    if (yyGetBool(mouse_check_button(1))) {
        {
            if (yyfequal(global.gmlwin, false)) {
                {
					global.gmllose = false;
					if (firstend == true){
						endgame(false);
						// game_end();
						const elem = document.getElementById('gm4html5_div_id');
						elem.style.display = 'none';
						firstend = false; 
					}
                }
            }
        }
    }
}

INDEX:

<!DOCTYPE html>
<html lang="en">

    <!-- Custom PreHead code is injected here -->
    

    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name ="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0" />
        <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
        <meta charset="utf-8"/>

        <!-- Builtin injector for disabling cache -->
        <meta http-equiv="pragma" content="no-cache"/>

        <!-- Set the title bar of the page -->
        <title>Created with GameMaker</title>

        <!-- Custom PreStyle code is injected here -->
        

        <!-- Set the background colour of the document -->
        <style>
            body {
                background: #0;
                color: #cccccc;
                margin: 0px;
                padding: 0px;
                border: 0px;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
            }

            canvas {
                image-rendering: optimizeSpeed;
                -webkit-interpolation-mode: nearest-neighbor;
                -ms-touch-action: none;
                touch-action: none;
                margin: 0px;
                padding: 0px;
                border: 0px;
            }
            :-webkit-full-screen #canvas {
                width: 100%;
                height: 100%;
            }
            :-webkit-full-screen {
                width: 100%;
                height: 100%;
            }
            
            /* Custom Runner Styles */
            div.gm4html5_div_class {
                margin: 0px;
                padding: 0px;
                border: 0px;
            }
            div.gm4html5_login {
                padding: 20px;
                position: absolute;
                border: solid 2px #000000;
                background-color: #404040;
                color:#00ff00;
                border-radius: 15px;
                box-shadow: #101010 20px 20px 40px;
            }
            div.gm4html5_cancel_button {
                float: right;
            }
            div.gm4html5_login_button {
                float: left;
            }
            div.gm4html5_login_header {
                text-align: center;
            }
            /* END - Custom Runner Styles */
            
        </style>

        <!-- Custom PostStyle code is injected here -->
        

        <!-- Builtin injector for injecting flurry analytics code -->
        
    </head>

    <!-- Custom PostHead code is injected here -->
    

    <!-- Custom PreBody code is injected here -->
    

    <body>
        <div class="gm4html5_div_class" id="gm4html5_div_id">
            
            <!-- Builtin injector for splash screen -->
            

            <!-- Create the canvas element the game draws to -->
            <canvas id="canvas" width="640" height="360" >
                <p>Your browser doesn't support HTML5 canvas.</p>
            </canvas>
        </div>

        <!-- Run the game code -->
        <script type="text/javascript" src="html5game/OS_Minigame_Graph.js?cachebust=1831448140"></script>

        <!-- Builtin injector for injecting runner path -->
        

        <!--<script>window.onload = GameMaker_Init;</script> -->

        <!-- Builtin injector for injecting google analytics code -->
        

    </body>

    <!-- Custom PostBody code is injected here -->
    
<!-- RECHERCHE DE DOC -->

</html>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Carton Interaction</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            color: white;
            display: none;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        #container {
            background: #2a1f00;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            display: none;
        }
        input {
            margin: 10px 0;
            padding: 5px;
        }
        button {
            margin: 5px;
            padding: 10px 15px;
            background: #555;
            border: none;
            color: white;
            cursor: pointer;
        }
        button:hover {
            background: #777;
        }
    </style>
</head>
<body>
    <div id="container">
        <h1>Entrez une date :</h1>
        <input type="date" id="dateInput">
        <button onclick="submitDate()">Valider</button>
        <button onclick="closeInterface()">Fermer</button>
    </div>
    <script>
        // Gestion des messages envoyés par le client Lua
        window.addEventListener('message', function(event) {

            if (event.data.action === 'opendate') {
                document.body.style.display = 'flex'; // Affiche le body
                document.getElementById('container').style.display = 'block';
            } 
        });

        // Gestion de la soumission de la date
        function submitDate() {
            const dateInput = document.getElementById("dateInput").value;

            if (!dateInput) {
                // Si aucune date n'est saisie, fermer l'interface
                closeInterface();
                return;
            }

            // Envoyer la date au script client via fetch
            fetch(`https://${GetParentResourceName()}/submitDate`, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({ date: dateInput })
            });

            // Fermer l'interface après soumission
            closeInterface();
        }

        // Fermeture de l'interface
        function closeInterface() {
            // Fermer l'interface visuellement
            document.body.style.display = "none";
            document.getElementById('container').style.display = 'none';

            // Envoyer un callback "close" au script client
            fetch(`https://${GetParentResourceName()}/closedate`, {
                method: "POST"
            });
        }
    </script>
</body>
</html>
