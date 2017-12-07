DECLARE SUB qymPlay (filename$)
DECLARE FUNCTION tonalityDict (comment$)
DECLARE FUNCTION pitchDict (comment)
SCREEN 12
CLS
nowplay = 0
loopt = 1
DIM sl$(100)
st$ = ""
DO WHILE LCASE$(f$) <> "exit"
	IF loopt <> 1 THEN st$ = "(Play" + STR$(loopt) + " times) " + st$
	GOSUB sub1
	INPUT ">", f$
	IF LCASE$(LEFT$(f$, 4)) = "add " THEN
		exi = 0
		FOR i = 1 TO r
			IF LCASE$(sl$(i)) = LCASE$(MID$(f$, 5)) THEN
				exi = 1
			END IF
		NEXT
		IF exi = 1 THEN
			st$ = "The song is in the playlist!  "
		ELSE
			OPEN "Songs\" + MID$(f$, 5) + ".qym" FOR APPEND AS #1
			CLOSE #1
			OPEN "Songs\" + MID$(f$, 5) + ".qym" FOR INPUT AS #1
			asdf = EOF(1)
			CLOSE #1
			IF asdf THEN
				KILL MID$(f$, 5) + ".qym"
				st$ = "The song do not exist!  "
			ELSE
				OPEN "playlist.dat" FOR APPEND AS #1
				PRINT #1, MID$(f$, 5)
				CLOSE #1
				st$ = ""
			END IF
		END IF
	ELSEIF LCASE$(f$) = "help" THEN
		GOSUB sub2
	ELSEIF LCASE$(LEFT$(f$, 7)) = "delete " THEN
		IF VAL(MID$(f$, 8)) < 1 THEN
			st$ = "Value error!"
		ELSEIF r < VAL(MID$(f$, 8)) THEN
			st$ = "The song is not in the playlist!  "
		ELSE
			FOR i = VAL(MID$(f$, 8)) TO r - 1
				sl$(i) = sl$(i + 1)
			NEXT
			r = r - 1
			OPEN "playlist.dat" FOR OUTPUT AS #1
			FOR i = 1 TO r
				PRINT #1, sl$(i)
			NEXT
			CLOSE #1
			st$ = ""
		END IF
	ELSEIF LCASE$(LEFT$(f$, 5)) = "loop " THEN
		loopt = VAL(MID$(f$, 6))
		IF loopt < 1 THEN
			loopt = 1
			st$ = "Value error!  "
		ELSE
			st$ = ""
		END IF
	ELSE
		IF r < VAL(f$) OR VAL(f$) < 1 THEN
			st$ = "The song is not in the playlist!  "
		ELSE
			nowplay = VAL(f$)
			f$ = sl$(nowplay)
			st$ = "Playing..."
			GOSUB sub1
			qymPlay ("Songs\" + f$ + ".qym")
			loopt = 1
			st$ = ""
			gc$ = ""
			nowplay = 0
		END IF
	END IF
LOOP
END

sub1:
CLS
LOCATE 1, 28
PRINT "Qingyun Music Player 1.0.1"
LINE (0, 25)-(1000, 25)
LINE (400, 25)-(400, 455)
LINE (0, 455)-(1000, 455)
LOCATE 3, 62
PRINT "Playlist"
OPEN "playlist.dat" FOR APPEND AS #1
CLOSE #1
OPEN "playlist.dat" FOR INPUT AS #1
r = 0
DO WHILE NOT (EOF(1))
	r = r + 1
	LINE INPUT #1, sl$(r)
	LOCATE 4 + r, 52
	IF nowplay = r THEN COLOR 14 ELSE COLOR 15
	PRINT r; ". "; sl$(r)
LOOP
CLOSE #1
COLOR 15
LOCATE 15, 1
PRINT gc$
LOCATE 30, 1
PRINT st$;
RETURN

sub2:
CLS
LOCATE 1, 28
PRINT "Qingyun Music Player 1.0.0.1"
LOCATE 3, 38
PRINT "Help"
LOCATE 5, 1
PRINT "Input the number in the playlist to play a song"
PRINT "Input 'add' and the name of the song to add a new song to the playlist"
PRINT "Input 'delete' and the number in the playlist to delete a song"
PRINT "Input 'exit' to quit this program"
PRINT "Input 'help' for this page"
PRINT "Press ENTER to go back to the main menu";
LINE (0, 25)-(1000, 25)
COLOR 0
INPUT "", qwer
COLOR 15
RETURN

FUNCTION pitchDict (comment)
	SELECT CASE comment
	CASE 1
		pitchDict = 0
	CASE 2
		pitchDict = 2
	CASE 3
		pitchDict = 4
	CASE 4
		pitchDict = 5
	CASE 5
		pitchDict = 7
	CASE 6
		pitchDict = 9
	CASE 7
		pitchDict = 11
	END SELECT
END FUNCTION

SUB qymPlay (filename$)
	OPEN filename$ FOR INPUT AS #1
	LINE INPUT #1, initialdata$
	DO WHILE (MID$(initialdata$, 1, 2) = "//" AND NOT (EOF(1)))
		LINE INPUT #1, initialdata$
	LOOP
	IF (RIGHT$(initialdata$, 1) = ">" AND NOT (EOF(1))) THEN
		LINE INPUT #1, filedata$
		filedata$ = initialdata$ + filedata$
	ELSE
		filedata$ = initialdata$
	END IF
	CLOSE #1
	tonality = 0
	beat = 1
	speed = 88
	sharp = 0
	tercet = 0
	j = 1
	music$ = ""
	musicrepeat$ = ""
	musicclip$ = ""
	musicclip$ = musicclip$ + "T" + MID$(STR$(INT(speed / beat)), 2)
	DO WHILE j <= LEN(filedata$)
		midchar$ = MID$(filedata$, j, 1)
		IF ("0" <= midchar$ AND "7" >= midchar$) THEN
			note = VAL(midchar$)
			time = 1
			space = -1
			dot = 0
			IF note = 0 THEN
				pitch = 0
			ELSE
				pitch = 25 + pitchDict(note) + tonality + sharp
			END IF
			sharp = 0
			j = j + 1
			midchar$ = MID$(filedata$, j, 1)
			DO WHILE (j <= LEN(filedata$) AND (midchar$ = "-" OR midchar$ = "_" OR midchar$ = "'" OR midchar$ = "," OR midchar$ = "^" OR midchar$ = "."))
				SELECT CASE midchar$
				CASE "-"
					time = time + 1
				CASE "_"
					time = time / 2
				CASE "'"
					pitch = pitch + 12
				CASE ","
					pitch = pitch - 12
				CASE "."
					dot = -1
				CASE "^"
					space = 0
				END SELECT
				j = j + 1
				midchar$ = MID$(filedata$, j, 1)
			LOOP
			IF tercet > 0 THEN
				time = time * tercetTime
				tercet = tercet - 1
			END IF
			noteType = INT(4 / time)
			IF NOT (space) THEN
				musicclip$ = musicclip$ + "ML"
			END IF
			musicclip$ = musicclip$ + "L" + MID$(STR$(noteType), 2)
			musicclip$ = musicclip$ + "N" + MID$(STR$(pitch), 2)
			IF dot THEN
				musicclip$ = musicclip$ + "."
			END IF
			IF NOT (space) THEN
				musicclip$ = musicclip$ + "MN"
			END IF
		ELSE
			SELECT CASE midchar$
			CASE "#"
				sharp = sharp + 1
			CASE "b"
				sharp = sharp - 1
			CASE "<"
				match = INSTR(j + 1, filedata$, ">")
				comment$ = MID$(filedata$, j + 1, match - j - 1)
				SELECT CASE MID$(comment$, 2, 1)
				CASE "="
					tonality = tonalityDict(MID$(comment$, 3))
				CASE "/"
					beat = VAL(MID$(comment$, 3, 1)) / 4
					musicclip$ = musicclip$ + "T" + MID$(STR$(INT(speed / beat)), 2)
				CASE ELSE
					speed = VAL(comment$)
					musicclip$ = musicclip$ + "T" + MID$(STR$(INT(speed / beat)), 2)
				END SELECT
				j = match
			CASE "("
				match = INSTR(j + 1, filedata$, ")")
				comment$ = MID$(filedata$, j + 1, match - j - 1)
				tercet = VAL(comment$)
				tercetTime = (2 ^ INT(LOG(tercet) / LOG(2))) / tercet
				j = match
			CASE "{"
				match = INSTR(j + 1, filedata$, "}")
				j = match
			CASE "/"
				IF MID$(filedata$, j + 1, 1) = "/" THEN
					EXIT DO
				END IF
			CASE ":"
				IF MID$(filedata$, j + 1, 1) = "|" THEN
					IF musicrepeat$ = "" THEN
						music$ = music$ + musicclip$ + musicclip$
						musicclip$ = ""
					ELSE
						FOR k = 1 TO repeatTime
							music$ = music$ + musicclip$ + musicrepeat$
						NEXT
						repeatTime = 0
						musicclip$ = ""
					END IF
				ELSE
					music$ = music$ + musicclip$
					musicclip$ = ""
					musicrepeat$ = ""
				END IF
			CASE "["
				repeatTime = 0
				match = INSTR(j + 1, filedata$, "]")
				FOR k = j + 1 TO match - 1
					IF MID$(filedata$, k, 1) = "." THEN
						repeatTime = repeatTime + 1
					END IF
				NEXT
				IF MID$(filedata$, j + 1, 2) = "1." THEN
					music$ = music$ + musicclip$
					musicrepeat$ = musicclip$
					musicclip$ = ""
				END IF
				j = match
			END SELECT
			j = j + 1
		END IF
	LOOP
	music$ = music$ + musicclip$
	PLAY music$
END SUB

FUNCTION tonalityDict (comment$)
	SELECT CASE comment$
	CASE "C"
		tonalityDict = 0
	CASE "G"
		tonalityDict = 7
	CASE "D"
		tonalityDict = 2
	CASE "A"
		tonalityDict = -3
	CASE "E"
		tonalityDict = 4
	CASE "B"
		tonalityDict = -1
	CASE "#F"
		tonalityDict = 6
	CASE "#C"
		tonalityDict = 1
	CASE "F"
		tonalityDict = 5
	CASE "bB"
		tonalityDict = -2
	CASE "bE"
		tonalityDict = 3
	CASE "bA"
		tonalityDict = -4
	CASE "bD"
		tonalityDict = 1
	CASE "bG"
		tonalityDict = 6
	CASE "bC"
		tonalityDict = -1
	END SELECT
END FUNCTION

