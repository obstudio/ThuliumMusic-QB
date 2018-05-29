DECLARE SUB fill (x1, y1, x2, y2, char$)
DECLARE SUB draw_window (title$, x1, y1, x2, y2, foreground, background)
DECLARE SUB draw_horizontal (x, y1, y2)
DIM songs$(200)
GOSUB sub_get_songs
song_start = 1
song_display_length = 19
song_selected = 1
main_window_focus = 0
DO
    GOSUB sub_draw_main_window
    SLEEP
    SELECT CASE INKEY$
        CASE CHR$(0) + CHR$(80)
            IF main_window_focus = 0 THEN song_selected = song_selected + 1
        CASE CHR$(0) + CHR$(72)
            IF main_window_focus = 0 THEN song_selected = song_selected - 1
        CASE CHR$(9)
            IF main_window_focus <> -1 THEN
                main_window_focus = main_window_focus + 1
                IF main_window_focus = 4 THEN main_window_focus = 0
            END IF
    END SELECT
    IF song_selected < 1 THEN
        song_selected = 1
    ELSEIF song_selected > songs_count THEN
        song_selected = songs_count
    END IF
    IF song_start > song_selected THEN
        song_start = song_selected
    ELSEIF song_start + song_display_length - 1 < song_selected THEN
        song_start = song_selected - song_display_length + 1
    END IF
LOOP
END

sub_get_songs:
SHELL "dir Songs /b /s >songs.dat"
OPEN "songs.dat" FOR INPUT AS #1
songs_count = 0
DO WHILE NOT (EOF(1))
    LINE INPUT #1, song_path$
    IF LCASE$(RIGHT$(song_path$, 3)) = ".tm" THEN
        songs_count = songs_count + 1
        songs$(songs_count) = song_path$
    END IF
LOOP
CLOSE #1
KILL "songs.dat"
RETURN

sub_draw_main_window:
draw_window "Thulium Music", 1, 1, 25, 80, 3, 0
COLOR 3, 0
draw_horizontal 21, 1, 80
LOCATE 23, 20
IF main_window_focus = 1 THEN
    COLOR 15, 0
ELSE
    COLOR 3, 0
END IF
PRINT "< Play >"
LOCATE 23, 37
IF main_window_focus = 2 THEN
    COLOR 15, 0
ELSE
    COLOR 3, 0
END IF
PRINT "< Pause >"
LOCATE 23, 54
IF main_window_focus = 3 THEN
    COLOR 15, 0
ELSE
    COLOR 3, 0
END IF
PRINT "< Stop >"
i = 0
DO WHILE i < song_display_length AND song_start + i <= songs_count
    song_path$ = songs$(song_start + i)
    j = LEN(song_path$)
    DO WHILE MID$(song_path$, j, 1) <> "\"
        j = j - 1
    LOOP
    song_name_start = j + 1
    LOCATE i + 2, 2
    IF song_start + i = song_selected THEN
        COLOR 0, 3
    ELSE
        COLOR 3, 0
    END IF
    PRINT " "; MID$(song_path$, song_name_start, LEN(song_path$) - song_name_start - 2); " ";
    i = i + 1
LOOP
RETURN

SUB draw_window (title$, x1, y1, x2, y2, foreground, background)
    COLOR foreground, background
    fill x1, y1 + 1, x1, y2 - 1, CHR$(196)
    fill x2, y1 + 1, x2, y2 - 1, CHR$(196)
    fill x1 + 1, y1, x2 - 1, y1, CHR$(179)
    fill x1 + 1, y2, x2 - 1, y2, CHR$(179)
    fill x1 + 1, y1 + 1, x2 - 1, y2 - 1, " "
    LOCATE x1, y1
    PRINT CHR$(218);
    LOCATE x1, y2
    PRINT CHR$(191);
    LOCATE x2, y1
    PRINT CHR$(192);
    LOCATE x2, y2
    PRINT CHR$(217);
    COLOR background, foreground
    LOCATE x1, (y2 - y1 - LEN(title$)) / 2 + y1
    PRINT " "; title$; " "
END SUB

SUB draw_horizontal (x, y1, y2)
    fill x, y1 + 1, x, y2 - 1, CHR$(196)
    LOCATE x, y1
    PRINT CHR$(195);
    LOCATE x, y2
    PRINT CHR$(180);
END SUB

SUB fill (x1, y1, x2, y2, char$)
    FOR i = x1 TO x2
        FOR j = y1 TO y2
            LOCATE i, j
            PRINT char$;
        NEXT
    NEXT
END SUB
