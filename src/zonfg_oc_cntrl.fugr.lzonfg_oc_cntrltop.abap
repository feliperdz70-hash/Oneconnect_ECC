FUNCTION-POOL ZONFG_OC_CNTRL.                   "MESSAGE-ID ..

CLASS CL_QUERY_JOIN_PERS DEFINITION LOAD.

type-pools: aqqis.

include rsaqcomc.
include rsaqcom0.
include rsaqcom1.
include rsaqcom2.
include MS38OF82.
include rsaqtxts.

tables: rs38q.

data: clntflag type flag.              " X - mit Mandantenfelder
include ms38of81.

data: g_sgname    type sgname,
      g_grafic    type flag,
      g_caller_id type c,     " Char indicating caller:
                              " determines GUI-Title for 110, 120.
                              " 'S' = Sachgebietspflege
                              " 'Q' = Quickview.

      ok_code    type syucomm,
      sav_okcode type syucomm.

data: g_mode   type aqqis_mode,
      gt_join  type aqq_t_join.

data: g_canceled type flag. " 'X' indicates cancel in Dynpro 0110:
                            "Changed Data is not copied back to parameters
                            "when leaving AQJD_DEFINE_JOIN

data: g_join_cntrl     type ref to  zoncl_join_cntrl, "cl_query_join_cntrl, ONEC
      g_join_data      type ref to cl_query_join_data.
data: g_main_container type ref to cl_gui_custom_container.

* dynpros:
*---
data: begin of g_dyn_0100,
            txt_x   type aqqtxt20,
            txt_y   type aqqtxt20,
            ea_x    type aqqproz,
            ea_y    type aqqproz,
            TXT_X%,
            TXT_Y%,
      end   of g_dyn_0100.
*---
data: begin of g_dyn_0300,
            tname     type AQ_SEGNAME,
            txt_tname type aq_segname,
      end   of g_dyn_0300.
*---
data: begin of g_dyn_0400,
            rad_searchtext type AQ_MARK,
            searchtext     type AQ_SEARCH,
            rad_searchdom  type AQ_MARK,
            searchdom      type aq_dom,
            rad_searchtype type AQ_MARK,
            txt_cleng      type aqqtxt15,
            txt_decnumb    type aqqtxt15,
            rad_searchline type AQ_MARK,
            rad_searchcur  type AQ_MARK,
            rad_searchfir  type AQ_MARK,
      end   of g_dyn_0400.

data: g_tname_l type aqs_tname,
      g_tname_r type aqs_tname.
*---
types: begin of f4_0500,
         tname     type aqs_tname,
         txt_tname type aqs_tname,
       end   of f4_0500.
data: f4_s_0500  type f4_0500,
      f4_t_0500l type standard table of f4_0500,
      f4_t_0500r type standard table of f4_0500.

data: gt_dbjt   type aqtdbjt.
