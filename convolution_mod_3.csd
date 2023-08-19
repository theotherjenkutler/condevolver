<Cabbage> bounds(0, 0, 0, 0)
form caption("ConDevolver") size(400, 350), guiMode("polling"), pluginId("ConD"), colour("black"), bundle("./assets")
;;;;;;;;form should include bundle command for packing vst with necessary files, etc
;;;;;;TOOOOO DOOOOOO
;;;;;;info button
;;;;;;savestate for vst recall
;;;;;;remainder of samples

image bounds(40, 8, 322, 89) channel("nameimage") file("./assets/text_top.png") 

image bounds(34, 92, 336, 232) channel("cymbalImage") identChannel("CYMBAL") file("./assets/CYMBAL.png") alpha(0) 
image bounds(34, 91, 337, 233) channel("mattressImage") identChannel("MATTRESS") file("./assets/MATTRESS.jpg") alpha(0)  

rslider bounds(40, 138, 87, 100), text("DRY/WET MIX"), colour(255, 255, 255, 255), trackerColour(135, 135, 135, 255), outlineColour(0, 0, 0, 255), textColour(250, 250, 250, 255),  channel("mix"), range(0, 1, 0.5, 1, 0.001) fontColour(255, 255, 255, 255) markerColour(0, 0, 0, 255) alpha(0.85) trackerOutsideRadius(0.8) valueTextBox(1)
rslider bounds(254, 138, 100, 100), text("OUTPUT"), colour(255, 255, 255, 255), trackerColour(156, 156, 156, 255), outlineColour(0, 0, 0, 255), textColour(250, 250, 250, 255),  channel("level"),       range(0, 1, 0.8, 1, 0.001) fontColour(255, 255, 255, 255) markerColour(0, 0, 0, 255)   trackerOutsideRadius(0.8) alpha(0.85) valueTextBox(1)
button  bounds(46, 266, 80, 49),    text("FORWARD", "REVERSE"),  channel("FwdBwd"), , fontColour:0(250, 250, 250, 255) colour:1(99, 99, 99, 255)   alpha(0.9) colour:0(34, 33, 33, 255)
infobutton bounds(264, 266, 80, 49) file("http://www.jenkutler.com") text("INFO") channel("infobutton")  fontColour:0(250, 250, 250, 255) colour:1(99, 99, 99, 255)   alpha(0.9) colour:0(34, 33, 33, 255)
listbox bounds(152, 138, 91, 178) channel("filename") populate("*.wav", "./assets") align("centre") channelType("string") value("") alpha(0.8) highlightColour(147, 147, 147, 255)

soundfiler bounds(268, 378, 58, 20), channel("beg", "len"), identChannel("ImpulseFile"),  colour(0, 255, 255, 255), fontColour(160, 160, 160, 255), visible(0) fontColour:0(160, 160, 160, 255)

rslider bounds(158, 378, 21, 19), text("Size Ratio"), colour(115, 10, 10, 255), trackerColour(255, 255, 150, 255), outlineColour(75, 35, 0, 255), textColour(250, 250, 250, 255),  channel("CompRat"),     range(0, 1, 1, 1, 0.001), visible(0)
rslider bounds(186, 376, 24, 20), text("Curve"),      colour(115, 10, 10, 255), trackerColour(255, 255, 150, 255), outlineColour(75, 35, 0, 255), textColour(250, 250, 250, 255),  channel("Curve"),       range(-8, 8, 0, 1, 0.001), visible(0)
rslider bounds(218, 378, 21, 17), text("In Skip"),    colour(115, 10, 10, 255), trackerColour(255, 255, 150, 255), outlineColour(75, 35, 0, 255), textColour(250, 250, 250, 255),  channel("skipsamples"), range(0, 1, 0, 1, 0.001), visible(0)
rslider bounds(244, 378, 18, 18), text("Del.OS."),    colour(115, 10, 10, 255), trackerColour(255, 255, 150, 255), outlineColour(75, 35, 0, 255), textColour(250, 250, 250, 255),  channel("DelayOS"),     range(-1, 1, 0, 1, 0.001), visible(0)

</Cabbage>
<CsoundSynthesizer>
<CsOptions>
-n -d -+rtmidi=NULL -M0 -m0d 
</CsOptions>
<CsInstruments>
; Initialize the global variables. 
ksmps = 32
nchnls = 2
0dbfs = 1


gScurrentImage = "0.png"

;giImpulse    ftgen   ; load stereo file
giImpulse    ftgen    1,0,2,-2,0
giDisplay    ftgen    2,0,ftlen(giImpulse),2,0                        ; display table table
tableicopy 2, 1
gkReady    init    0

; reverse function table UDO
opcode    tab_reverse,i,i
ifn             xin
iTabLen         =               ftlen(ifn)
iTableRev       ftgen           ifn + 100,0,-iTabLen,-2, 0
icount          =               0
loop:
ival            table           iTabLen-icount-1, ifn
                tableiw         ival,icount,iTableRev
                loop_lt         icount,1,iTabLen,loop
                xout               iTableRev
endop

; compress function table UDO
opcode    tab_compress,i,iii
ifn,iCompRat,iCurve    xin
iTabLen         =               ftlen(ifn)
iTabLenComp     =               int(ftlen(ifn)*iCompRat)
iTableComp      ftgen           ifn+200,0,-iTabLenComp,-2, 0
iAmpScaleTab    ftgen        ifn+300,0,-iTabLenComp,-16, 1,iTabLenComp,iCurve,0
icount          =               0
loop:
ival            table           icount, ifn
iAmpScale    table        icount, iAmpScaleTab
                tableiw         ival*iAmpScale,icount,iTableComp
                loop_lt         icount,1,iTabLenComp,loop
                xout               iTableComp
endop

; compress reverse function table UDO
opcode    tab_compress_rev,i,iii
ifn,iCompRat,iCurve    xin
iTabLen         =               nsamp(ifn)
iTabLenComp     =               int(nsamp(ifn)*iCompRat)
iTableComp      ftgen           ifn+400,0,-iTabLenComp,-2, 0
iAmpScaleTab    ftgen        ifn+500,0,-iTabLenComp,-16, 1,iTabLenComp,iCurve,0
icount          =               0
loop:
ival            table           icount, ifn
iAmpScale    table        icount, iAmpScaleTab
                tableiw         ival*iAmpScale, iTabLenComp-icount-1,iTableComp
                loop_lt         icount,1,iTabLenComp,loop
                xout               iTableComp
endop

opcode FileNameFromPath,S,S        ; Extract a file name (as a string) from a full path (also as a string)
 Ssrc    xin                ; Read in the file path string
 icnt    strlen    Ssrc            ; Get the length of the file path string
 LOOP:                    ; Loop back to here when checking for a backslash
 iasc    strchar Ssrc, icnt        ; Read ascii value of current letter for checking
 if iasc==92 igoto ESCAPE        ; If it is a backslash, escape from loop
 loop_gt    icnt,1,0,LOOP        ; Loop back and decrement counter which is also used as an index into the string
 ESCAPE:                ; Escape point once the backslash has been found
 Sname    strsub Ssrc, icnt+1, -1        ; Create a new string of just the file name
    xout    Sname            ; Send it back to the caller instrument
endop    

instr    1
    gSfilepath    chnget    "filename"
    kNewFileTrg    changed    gSfilepath        ; if a new file is loaded generate a trigger
    if kNewFileTrg==1 then ; if a new file has been loaded...

     event    "i",99,0,0                ; call instrument to update sample storage function table 
    endif
    
    if trigger:k(gkReady,0.5,0)==1 then        ; when a file is loaded for the first time do this conditional branch...
     event    "i",2,0,3600*24*7            ; start the convolution instrument
    endif
endin

instr    2    ;CONVOLUTION REVERB INSTRUMENT
    chnset    "visible(0)","InstructionID"        ; hide the instruction

    kFwdBwd        chnget    "FwdBwd"
    kresize        chnget    "resize"
    kmix        chnget    "mix"
    klevel        chnget    "level"
    kCompRat    chnget    "CompRat"
    kCurve        chnget    "Curve"
    kskipsamples    chnget    "skipsamples"
    kDelayOS    chnget    "DelayOS"
    kCompRat       init    1             ;IF THIS IS LEFT UNINITIALISED A CRASH WILL OCCUR! 

    
    ainL,ainR    ins                ;READ STEREO AUDIO INPUT
    ainMix        sum    ainL,ainR
    
    ;CREATE REVERSED TABLES
    irev    tab_reverse    giImpulse
        
        kSwitchStr    changed    gSfilepath
    kSwitchStr    delayk    kSwitchStr,1
    kSwitch    changed        kskipsamples,kFwdBwd,kDelayOS,kCompRat,kCurve,kresize    ;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
    kSwitch    +=    kSwitchStr
    if    kSwitch=1    then            ;IF I-RATE VARIABLE IS CHANGED...
        reinit    UPDATE                ;BEGIN A REINITIALISATION PASS IN ORDER TO EFFECT THIS CHANGE. BEGIN THIS PASS AT LABEL ENTITLED 'UPDATE' AND CONTINUE UNTIL rireturn OPCODE 
    endif                        ;END OF CONDITIONAL BRANCHING
    UPDATE:                        ;LABEL
    
    ;CREATE COMPRESSED TABLES
    icomp    tab_compress    giImpulse,i(kCompRat),i(kCurve)
        
    ;CREATE COMPRESSED REVERSED TABLES
    icomprev    tab_compress_rev    giImpulse,i(kCompRat),i(kCurve)
        
    iplen        =    1024                ;BUFFER LENGTH (INCREASE IF EXPERIENCING PERFORMANCE PROBLEMS, REDUCE IN ORDER TO REDUCE LATENCY)
    itab        =    giImpulse            ;DERIVE FUNCTION TABLE NUMBER OF CHOSEN TABLE FOR IMPULSE FILE
    iirlen        =    nsamp(itab)*0.5            ;DERIVE THE LENGTH OF THE IMPULSE RESPONSE IN SAMPLES. DIVIDE BY 2 AS TABLE IS STEREO.
    iskipsamples    =    nsamp(itab)*0.5*i(kskipsamples)    ;DERIVE INSKIP INTO IMPULSE FILE. DIVIDE BY 2 (MULTIPLY BY 0.5) AS ALL IMPULSE FILES ARE STEREO
    
        
    ;FORWARDS REVERB
    if kFwdBwd==0&&kresize==0 then
     aL,aR    ftconv    ainMix, itab, iplen,iskipsamples, iirlen        ;CONVOLUTE INPUT SOUND
     adelL    delay    ainL, abs((iplen/sr)+i(kDelayOS))     ;DELAY THE INPUT SOUND ACCORDING TO THE BUFFER SIZE
     adelR    delay    ainR, abs((iplen/sr)+i(kDelayOS))     ;DELAY THE INPUT SOUND ACCORDING TO THE BUFFER SIZE
        
        ;BACKWARDS REVERB
        elseif kFwdBwd==1&&kresize==0 then
     aL,aR    ftconv    ainMix, irev, iplen, iskipsamples, iirlen                ;CONVOLUTE INPUT SOUND
     adelL    delay    ainL,abs((iplen/sr)+(iirlen/sr)-(iskipsamples/sr)+i(kDelayOS))    ;DELAY THE INPUT SOUND ACCORDING TO THE BUFFER SIZE AND THE DURATION OF THE IMPULSE FILE
     adelR    delay    ainR,abs((iplen/sr)+(iirlen/sr)-(iskipsamples/sr)+i(kDelayOS))    ;DELAY THE INPUT SOUND ACCORDING TO THE BUFFER SIZE AND THE DURATION OF THE IMPULSE FILE
        
        ;FORWARDS COMPRESSED
    elseif kFwdBwd==0&&kresize==1 then
     aL,aR    ftconv    ainMix, icomp, iplen,iskipsamples, iirlen*i(kCompRat)        ;CONVOLUTE INPUT SOUND
     adelL    delay    ainL, abs((iplen/sr)+i(kDelayOS))                 ;DELAY THE INPUT SOUND ACCORDING TO THE BUFFER SIZE
     adelR    delay    ainR, abs((iplen/sr)+i(kDelayOS))                 ;DELAY THE INPUT SOUND ACCORDING TO THE BUFFER SIZE
        
        ;BACKWARDS COMPRESSED
    elseif kFwdBwd==1&&kresize==1 then
     aL,aR    ftconv    ainMix, icomprev, iplen, iskipsamples, iirlen*i(kCompRat)        ;CONVOLUTE INPUT SOUND
     adelL    delay    ainL,abs((iplen/sr)+((iirlen*i(kCompRat))/sr)-(iskipsamples/sr)+i(kDelayOS))    ;DELAY THE INPUT SOUND ACCORDING TO THE BUFFER SIZE AND THE DURATION OF THE IMPULSE FILE
     adelR    delay    ainR,abs((iplen/sr)+((iirlen*i(kCompRat))/sr)-(iskipsamples/sr)+i(kDelayOS))    ;DELAY THE INPUT SOUND ACCORDING TO THE BUFFER SIZE AND THE DURATION OF THE IMPULSE FILE
    endif
                 
        rireturn
        
    ; CREATE A DRY/WET MIX
    aMixL    ntrpol    adelL,aL*0.1,kmix
    aMixR    ntrpol    adelR,aR*0.1,kmix
        
            outs    aMixL*klevel,aMixR*klevel
endin

instr    99    ; load sound file

     giImpulse    ftgen    1,0,0,1,gSfilepath,0,0,0    ; load stereo file
     gkReady     init    1                    ; if no string has yet been loaded giReady will be zero
     Smessage sprintfk "file(%s)", gSfilepath            ; print file to viewer
     ;prints Smessage
     chnset Smessage, "filer1"  

     Smessage sprintfk "file(%s)", gSfilepath            ; print sound file image to fileplayer
     chnset Smessage, "ImpulseFile"

     Sname    FileNameFromPath    gSfilepath                ; Call UDO to extract file name from the full path
     Smessage sprintfk "text(%s)",Sname
     ;prints Sname
     chnset Smessage, "stringbox"
    
     istrlen strlen Sname
     idelimiter strindex Sname, "assets/"
     Simage strsub Sname, idelimiter + 7, istrlen - 4
     
     ;prints gScurrentImage
     ;prints "\n"
     chnset "alpha(0)", gScurrentImage 
     prints Simage
     prints "\n"
     
     
     chnset "alpha(0.71)", Simage
     gScurrentImage = Simage
     ;chnset Simage, gSCurrentImage

endin



</CsInstruments>
<CsScore>
;causes Csound to run for about 7000 years...
f0 z
;starts instrument 1 and runs it for a week
i1 0 [60*60*24*7] 
</CsScore>
</CsoundSynthesizer>
