*&---------------------------------------------------------------------*
*& Report ZDENEME
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDENEME.

TABLES sscrfields.

PARAMETERS: pp_id TYPE zbk_pid_de,
            pp_isim TYPE zbk_pisim_de,
            pp_soyis TYPE zbk_psoyisim_de,
            pp_gorev TYPE zbk_pgorev_de,
            pp_g_tar TYPE zbk_pgirtarih_de.

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: pp_cins1 RADIOBUTTON GROUP gr1,
            pp_cins2 RADIOBUTTON GROUP gr1,
            pp_cins3 RADIOBUTTON GROUP gr1.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN SKIP 2.

SELECTION-SCREEN PUSHBUTTON 1(30) button1 USER-COMMAND addPersonel.
SELECTION-SCREEN PUSHBUTTON 35(30) button2 USER-COMMAND removePersonel.
SELECTION-SCREEN PUSHBUTTON 70(30) button4 USER-COMMAND overridePersonel.
SELECTION-SCREEN SKIP 2.
SELECTION-SCREEN PUSHBUTTON 1(20) button3 USER-COMMAND excelExport.

SELECTION-SCREEN SKIP 3.

INITIALIZATION.
CONCATENATE icon_checked TEXT-002 INTO button1 SEPARATED BY space.
CONCATENATE icon_dummy TEXT-003 INTO button2 SEPARATED BY space.
CONCATENATE icon_create TEXT-004 INTO button3 SEPARATED BY space.
CONCATENATE icon_change TEXT-005 INTO button4 SEPARATED BY space.
*****
DATA gs_struct TYPE zbk_personel_t.

DATA lt_personel TYPE TABLE OF zbk_personel_t.
DATA obj_salv TYPE REF TO cl_salv_table.

DATA flag_int TYPE int1 VALUE 0.
*****

AT SELECTION-SCREEN.
  CASE sscrfields.
    WHEN 'ADDPERSONEL'.
      PERFORM pers_kontrollu_ekle.
    WHEN 'REMOVEPERSONEL'.
      PERFORM pers_kontrollu_kaldir.
    WHEN 'OVERRIDEPERSONEL'.
      PERFORM pers_kontrollu_degistir.
    WHEN 'EXCELEXPORT'.
      PERFORM excel_export.
  ENDCASE.

START-OF-SELECTION.
  SELECT * FROM zbk_personel_t
    INTO TABLE lt_personel.
  SORT lt_personel BY p_id.
***
  CALL METHOD cl_salv_table=>factory
    IMPORTING
      r_salv_table = obj_salv
    CHANGING
      t_table = lt_personel.
***
  CALL METHOD obj_salv->display.
END-OF-SELECTION.

FORM pers_ekle.
  gs_struct-p_id = pp_id.
  gs_struct-p_isim = pp_isim.
  gs_struct-p_soyisim = pp_soyis.
  gs_struct-p_gorev = pp_gorev.
  gs_struct-p_g_tarih = pp_g_tar.
***
  IF pp_cins1 = 'X'.
    gs_struct-p_cinsiyet = 'M'.
  ELSEIF pp_cins2 = 'X'.
    gs_struct-p_cinsiyet = 'F'.
  ELSEIF pp_cins3 = 'X'.
    gs_struct-p_cinsiyet = 'O'.
  ENDIF.
***
  INSERT zbk_personel_t FROM gs_struct.
***
  PERFORM clear_struct.
  PERFORM clear_parameters.
ENDFORM.

FORM pers_kaldir.
  gs_struct-p_id = pp_id.
  DELETE FROM zbk_personel_t WHERE p_id EQ gs_struct-p_id.
  PERFORM clear_struct.
  PERFORM clear_parameters.
ENDFORM.

FORM clear_struct.
  CLEAR gs_struct-p_id.
  CLEAR gs_struct-p_isim.
  CLEAR gs_struct-p_soyisim.
  CLEAR gs_struct-p_gorev.
  CLEAR gs_struct-p_g_tarih.
ENDFORM.

FORM clear_parameters.
  CLEAR pp_id.
  CLEAR pp_isim.
  CLEAR pp_soyis.
  CLEAR pp_gorev.
  CLEAR pp_g_tar.
ENDFORM.

FORM check_id.
  DATA local_struct TYPE zbk_personel_t.
  SELECT * FROM zbk_personel_t INTO local_struct.
    IF pp_id = local_struct-p_id.
       flag_int = 1.
    ENDIF.
  ENDSELECT.
  IF pp_id IS INITIAL.
    flag_int = 2.
  ENDIF.
ENDFORM.

FORM pers_kontrollu_kaldir.
  PERFORM check_id.
      IF flag_int IS INITIAL.
        MESSAGE E208(00) WITH 'Error: ID does not exist.'.
      ELSEIF flag_int = 1.
        PERFORM pers_kaldir.
        "Make flag its initial value again
        CLEAR flag_int.
        MESSAGE S208(00) WITH 'Value successfully removed.'.
      ELSEIF flag_int = 2.
        MESSAGE E208(00) WITH 'Error: ID is empty.'.
        "Make flag its initial value again
        CLEAR flag_int.
      ENDIF.
ENDFORM.

FORM pers_kontrollu_ekle.
  PERFORM check_id.
      IF flag_int IS INITIAL.
        PERFORM pers_ekle.
        MESSAGE S208(00) WITH 'Value successfully added.'.
      ELSEIF flag_int = 1.
        "Make flag its initial value again
        CLEAR flag_int.
        MESSAGE E208(00) WITH 'Error: ID already exists.'.
      ELSEIF flag_int = 2.
        MESSAGE E208(00) WITH 'Error: ID is empty.'.
        "Make flag its initial value again
        CLEAR flag_int.
      ENDIF.
ENDFORM.

FORM excel_export. " Does not work very well, formatting is problematic
  SELECT * FROM zbk_personel_t
    INTO TABLE lt_personel.
  SORT lt_personel BY p_id.
  DATA file TYPE string VALUE 'C:\Users\10\OneDrive\Masaüstü\output.csv'.
  CALL FUNCTION 'GUI_DOWNLOAD'
  EXPORTING
    filename              = file
    filetype              = 'ASC'
  TABLES
    data_tab              = lt_personel.
ENDFORM.

FORM pers_degistir.
  gs_struct-p_id = pp_id.
  gs_struct-p_isim = pp_isim.
  gs_struct-p_soyisim = pp_soyis.
  gs_struct-p_gorev = pp_gorev.
  gs_struct-p_g_tarih = pp_g_tar.
***
  IF pp_cins1 = 'X'.
    gs_struct-p_cinsiyet = 'M'.
  ELSEIF pp_cins2 = 'X'.
    gs_struct-p_cinsiyet = 'F'.
  ELSEIF pp_cins3 = 'X'.
    gs_struct-p_cinsiyet = 'O'.
  ENDIF.
***
  IF gs_struct-p_isim IS NOT INITIAL.
    UPDATE zbk_personel_t SET p_isim = gs_struct-p_isim
    WHERE p_id EQ pp_id.
  ENDIF.
  IF gs_struct-p_soyisim IS NOT INITIAL.
    UPDATE zbk_personel_t SET p_soyisim = gs_struct-p_soyisim
    WHERE p_id EQ pp_id.
  ENDIF.
  IF gs_struct-p_gorev IS NOT INITIAL.
    UPDATE zbk_personel_t SET p_gorev = gs_struct-p_gorev
    WHERE p_id EQ pp_id.
  ENDIF.
  IF gs_struct-p_g_tarih IS NOT INITIAL.
    UPDATE zbk_personel_t SET p_g_tarih = gs_struct-p_g_tarih
    WHERE p_id EQ pp_id.
  ENDIF.
  UPDATE zbk_personel_t SET p_cinsiyet = gs_struct-p_cinsiyet
    WHERE p_id EQ pp_id.
***
  PERFORM clear_struct.
  PERFORM clear_parameters.
ENDFORM.

FORM pers_kontrollu_degistir.
  PERFORM check_id.
      IF flag_int IS INITIAL.
        MESSAGE E208(00) WITH 'Error: ID does not exist.'.
      ELSEIF flag_int = 1.
        IF pp_isim IS INITIAL AND pp_soyis IS INITIAL AND
          pp_gorev IS INITIAL AND pp_g_tar IS INITIAL.
          MESSAGE E208(00) WITH 'Error: No parameters to change.'.
        ELSE.
          PERFORM pers_degistir.
          "Make flag its initial value again
          CLEAR flag_int.
          MESSAGE S208(00) WITH 'Value successfully overriden.'.
        ENDIF.
      ELSEIF flag_int = 2.
        MESSAGE E208(00) WITH 'Error: ID is empty.'.
        "Make flag its initial value again
        CLEAR flag_int.
      ENDIF.
ENDFORM.