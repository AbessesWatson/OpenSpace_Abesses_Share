POUR LE JS:


let firststart = true;

document.addEventListener('DOMContentLoaded', function () {
    window.addEventListener('message', function (event) {
        const { action, computerID } = event.data; // Récupérer les données du message

        switch (action) {
            case 'openGame':
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

function gml_Object_oGame_Create_0(_inst, _other) {
    global.gmllosetime = 0;
    global.gmlwin = false;
    global.gmllose = false;
}

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
    if (!yyGetBool(instance_exists(YYASSET_REF(0x00000004)))) {
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
            global.gmllose = true;
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
function gml_Object_oMouse_Create_0(_inst, _other) {
    _inst.gmlcatched = false;
    _inst.gmlallow_catch = true;
}
function gml_Object_oMouse_Step_0(_inst, _other) {
    _inst.x = g_pBuiltIn.get_mouse_x();
    _inst.y = g_pBuiltIn.get_mouse_y();
}
function gml_Object_oMouse_Collision_oPaper(_inst, _other) {}
function gml_Object_oMouse_Collision_oCroix(_inst, _other) {
    if (yyGetBool(mouse_check_button(1))) {
        {
            if (yyfequal(global.gmlwin, false)) {
                {
                    global.gmllose = true;
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

BACKUP INDEX:
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
        <script type="text/javascript" src="html5game/OS_minigame_file.js?cachebust=227064420"></script>

        <!-- Builtin injector for injecting runner path -->
        

        <!-- <script>window.onload = GameMaker_Init;</script> -->

        <!-- Builtin injector for injecting google analytics code -->
        

    </body>

    <!-- Custom PostBody code is injected here -->
    
</html>

<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Image Display</title>
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: transparent;
        }
        #imageContainer {
            display: none; /* Masqué par défaut */
        }
        img {
            max-width: 100%;
            max-height: 100%;
        }
    </style>
</head>
<body>
    <div id="imageContainer">
        <img src="File_Storage_Manual.png" alt="Displayed Image">
    </div>
    <script>
        window.addEventListener('message', function(event) {
            const { action } = event.data;
            if (action === 'showImage') {
                document.getElementById('imageContainer').style.display = 'block';
            } else if (action === 'hideImage') {
                document.getElementById('imageContainer').style.display = 'none';
            }
        });
    </script>
</body>
</html>
