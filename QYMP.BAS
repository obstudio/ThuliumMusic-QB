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
CLS
PRINT "Thank you for using Qingyun Music Player!"
PRINT "See you next time!"
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
PRINT "Qingyun Music Player 1.0.1"
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

FUNCTION getPitch (filedata$, position, tonality)
	note = VAL(MID$(filedata$, position, 1))
	IF note = 0 THEN
		getPitch = 0
	ELSE
		getPitch = 25 + pitchDict(note) + tonality
	END IF
	i = position - 1
	DO WHILE i >= 1
		SELECT CASE MID$(filedata$, i, 1)
		CASE "#"
			getPitch = getPitch + 1
		CASE "b"
			getPitch = getPitch - 1
		CASE ELSE
			EXIT DO
		END SELECT
		i = i - 1
	LOOP
	i = position + 1
	DO WHILE i <= LEN(filedata$)
		SELECT CASE MID$(filedata$, i, 1)
		CASE "'"
			getPitch = getPitch + 12
		CASE ","
			getPitch = getPitch - 12
		CASE ELSE
			EXIT DO
		END SELECT
		i = i + 1
	LOOP
	position = i
END FUNCTION

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
	filedata$ = ""
	IF EOF(1) THEN
		EXIT SUB
	ELSE
		LINE INPUT #1, dataline$
	END IF
	DO WHILE (LEN(dataline$) >= 2 AND LEFT$(dataline$, 2) = "//") '歌曲注释
		IF EOF(1) THEN
			EXIT DO
		ELSE
			LINE INPUT #1, dataline$
		END IF
	LOOP
	DO
		DO WHILE dataline$ = "" '空行
			IF EOF(1) THEN
				EXIT DO
			ELSE
				LINE INPUT #1, dataline$
			END IF
		LOOP
		DO WHILE (LEN(dataline$) >= 2 AND LEFT$(dataline$, 2) = "//") '乐章注释
			IF EOF(1) THEN
				EXIT DO
			ELSE
				LINE INPUT #1, dataline$
			END IF
		LOOP
		DO WHILE (dataline$ <> "" AND RIGHT$(dataline$, 1) = ">") '初始化行
			filedata$ = filedata$ + dataline$
			IF EOF(1) THEN
				EXIT DO
			ELSE
				LINE INPUT #1, dataline$
			END IF
		LOOP
		flag = -1 '标记是否该乐章第一个音轨
		DO WHILE (dataline$ <> "" AND (LEN(dataline$) < 2 OR LEFT$(dataline$, 2) <> "//")) '音轨
			IF flag THEN
				filedata$ = filedata$ + dataline$
				flag = 0
			END IF
			IF EOF(1) THEN
				EXIT DO
			ELSE
				LINE INPUT #1, dataline$
			END IF
		LOOP
	LOOP UNTIL EOF(1)
	CLOSE #1
	tonality = 0 '调性，与 C 大调相差的半音数，默认为 0（C 大调）
	beat = 1 '拍号，一个四分音符所占的拍数，默认为 1（4/4 拍）
	speed = 88 '速度，一分钟演奏多少个四分音符，默认为 88
	tercet = 0
	j = 1
	music$ = ""
	musicrepeat$ = ""
	musicclip$ = ""
	musicclip$ = musicclip$ + "T" + MID$(STR$(INT(speed / beat)), 2) '初始化为默认速度
	DO WHILE j <= LEN(filedata$)
		midchar$ = MID$(filedata$, j, 1)
		IF ("0" <= midchar$ AND "7" >= midchar$) THEN
			getPitchResult = getPitch(filedata$, j, tonality) '读取音调，参数不加括号为地址引用，函数中会改变 j 的值
			IF chord THEN '保留和弦的第一个音的音调
				chord = 0
			ELSE
				pitch = getPitchResult
			END IF
			time = 1
			space = -1
			dot = 0
			midchar$ = MID$(filedata$, j, 1)
			DO WHILE (j <= LEN(filedata$) AND (midchar$ = "-" OR midchar$ = "_" OR midchar$ = "." OR midchar$ = "^" OR midchar$ = "&"))
				SELECT CASE midchar$
				CASE "-"
					time = time + 1
				CASE "_"
					time = time / 2
				CASE "."
					dot = -1
				CASE "^"
					space = 0
				CASE "&"
					chord = -1
				END SELECT
				j = j + 1
				midchar$ = MID$(filedata$, j, 1)
			LOOP
			IF NOT(chord) THEN '和弦直接跳过播放，和弦的第一个音在和弦结束算出时值后播放
				IF tercet > 0 THEN
					time = time * tercetTime
					tercet = tercet - 1
				END IF
				IF time = 3 THEN '三拍的音符 noteType 不为整数，将其改为带附点的二分音符
					time = 2
					dot = -1
				END IF
				noteType = INT(4 / time)
				IF NOT (space) THEN
					musicclip$ = musicclip$ + "ML" '延长状态
				END IF
				musicclip$ = musicclip$ + "L" + MID$(STR$(noteType), 2)
				musicclip$ = musicclip$ + "N" + MID$(STR$(pitch), 2)
				IF dot THEN
					musicclip$ = musicclip$ + "."
				END IF
				IF NOT (space) THEN
					musicclip$ = musicclip$ + "MN" '重置为正常状态
				END IF
			END IF
		ELSE
			SELECT CASE midchar$
			CASE "<"
				match = INSTR(j + 1, filedata$, ">")
				comment$ = MID$(filedata$, j + 1, match - j - 1)
				SELECT CASE MID$(comment$, 2, 1)
				CASE "="
					tonality = tonalityDict(MID$(comment$, 3)) '设置调性
				CASE "/"
					beat = VAL(MID$(comment$, 3, 1)) / 4 '设置拍号
					musicclip$ = musicclip$ + "T" + MID$(STR$(INT(speed / beat)), 2) '重新调整速度
				CASE ELSE
					IF RIGHT$(comment$, 1) <> "%" THEN '排除音量标签
						speed = VAL(comment$)
						musicclip$ = musicclip$ + "T" + MID$(STR$(INT(speed / beat)), 2) '设置速度
					END IF
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
		tonalityDict = 9
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
		tonalityDict = 8
	CASE "bD"
		tonalityDict = 1
	CASE "bG"
		tonalityDict = 6
	CASE "bC"
		tonalityDict = -1
	END SELECT
END FUNCTION

