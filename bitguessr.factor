USING: accessors classes.struct formatting kernel math namespaces raylib ;
IN: bitguessr

CONSTANT: screen-width 800
CONSTANT: screen-height 450
CONSTANT: frames 3

SYMBOL: btn1-state
SYMBOL: btn0-state
SYMBOL: rand-bit
SYMBOL: mid-text
SYMBOL: score
SYMBOL: acc
SYMBOL: lives
SYMBOL: pause
SYMBOL: game-screen ! 0 for the main screen and 1 for the lose screen

: make-window ( -- )
    ! 4 set-config-flags ! FLAG_WINDOW_RESIZABLE
    screen-width screen-height "BitGuessr" init-window
    60 set-target-fps ;

: clear-window ( -- )
    RAYWHITE clear-background ;

MEMO: button-0 ( -- texture ) 
    "button-0.png" load-texture ;

MEMO: button-1 ( -- texture ) 
    "button-1.png" load-texture ;

MEMO: correct-fx ( -- sound ) 
    "correct.wav" load-sound ;

MEMO: wrong-fx ( -- sound ) 
    "wrong.wav" load-sound ;

MEMO: music ( -- music )
    "bitguessr_soundtrack.wav" load-music-stream t >>looping ;

:: button-rec ( button n -- rectangle )
    0 button height>> frames / n zero? [ btn0-state get * ] [ btn1-state get * ] if
    button [ width>> ] [ height>> frames / ] bi Rectangle <struct-boa> ;

: mouse ( -- vector2 )
    get-mouse-position ;

:: button-bounds ( button -- rectangle )
    screen-width 2/ button width>> 2/ -
    screen-height 2/ button height>> frames / 2/ -
    button width>> button height>> frames / Rectangle <struct-boa> ;

: button-0-draw ( -- )
    button-0 dup 0 button-rec button-0 button-bounds [ x>> 175 - ] [ y>> ] bi Vector2 <struct-boa> WHITE draw-texture-rec ;

: button-1-draw ( -- )
    button-1 dup 1 button-rec button-1 button-bounds [ x>> 175 + ] [ y>> ] bi Vector2 <struct-boa> WHITE draw-texture-rec ;

: button-0-do ( -- ) 
    2 btn0-state set 
    rand-bit get zero? [ "Correct! Go on" score get 1 + score set correct-fx play-sound acc get "0" append acc set ] [ "Wrong!" wrong-fx play-sound lives get 1 - lives set ] if mid-text set
    { 0 1 1 0 0 1 0 1 0 1 0 0 1 0 1 } random rand-bit set ;

: button-1-do ( -- )
    2 btn1-state set rand-bit get 1 = [ "Correct! Go on" score get 1 + score set correct-fx play-sound acc get "1" append acc set ] [ "Wrong!" wrong-fx play-sound lives get 1 - lives set ] if mid-text set
    { 0 1 1 0 0 1 0 1 0 1 0 0 1 0 1 } random rand-bit set ;

: render-loop ( -- )
    begin-drawing
    clear-window
    music update-music-stream

    game-screen get 1 = [ 
        KEY_ENTER is-key-pressed GESTURE_TAP is-gesture-detected or [ 
            3 lives set
            0 score set
            "" acc set
            { 0 1 1 0 0 1 0 1 0 1 0 0 1 0 1 } random rand-bit set
            0 game-screen set 
        ] when
    ] when
    lives get zero? [
        1 game-screen set
    ] when

    KEY_E is-key-pressed [ 
        pause get not pause set
        pause get [ music pause-music-stream ] [ music resume-music-stream ] if
    ] when

    KEY_Q is-key-pressed [
        0 score set
        3 lives set
    ] when

    mouse button-0 button-bounds dup x>> 175 - >>x check-collision-point-rec 
    [ MOUSE_BUTTON_LEFT is-mouse-button-pressed [ 
        button-0-do
    ] [ 1 btn0-state set ] if ] [ 0 btn0-state set ] if
    mouse button-1 button-bounds dup x>> 175 + >>x check-collision-point-rec 
    [ MOUSE_BUTTON_LEFT is-mouse-button-pressed [ 
        button-1-do
    ] [ 1 btn1-state set ] if ] [ 0 btn1-state set ] if
    KEY_A is-key-pressed [ button-0-do ] when
    KEY_D is-key-pressed [ button-1-do ] when

    game-screen get zero? [
        button-0-draw
        button-1-draw
        mid-text get dup screen-width 2/ swap length 5 * - screen-height 2/ 20 BLACK draw-text
        "BitGuessr" screen-width 2/ 110 - 30 50 BLACK draw-text
        score get "Score: %s" sprintf screen-width 150 - 20 25 BLACK draw-text
        lives get "Lives: %s" sprintf 30 20 25 BLACK draw-text
        "Press E to pause music; Press Q to reset score\n\nPress A for 0; Press D for 1" screen-width 2/ 250 - screen-height 80 - 16 BLACK draw-text
    ] [
        "You lost" screen-width 2/ 80 - 30 45 BLACK draw-text
        score get acc get "Stats:\n\n\t\t- Score: %s\n\n\t\t- Accumulated Number: %s" sprintf screen-width 2/ 200 - screen-height 2/ 60 - 30 BLACK draw-text
        "Press Enter or Tap screen to restart" screen-width 2/ 200 - screen-height 50 - 20 BLACK draw-text
    ] if

    end-drawing ; inline

: main ( -- )
    make-window
    init-audio-device
    music play-music-stream
    "bitguessr_icon.png" raylib:load-image [ 7 raylib:image-format ] [ set-window-icon ] bi
    0 btn1-state set
    0 btn0-state set
    0 score set
    "" acc set
    3 lives set
    f pause set
    0 game-screen set
    { 0 1 1 0 0 1 0 1 0 1 0 0 1 0 1 } random rand-bit set
    "Choose a button" mid-text set
    [ render-loop window-should-close not ] loop
    close-window ;

MAIN: main