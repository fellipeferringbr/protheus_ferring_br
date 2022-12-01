#INCLUDE "PROTHEUS.CH"

USER FUNCTION LOTE_DT(_Tipo,_cLote)

Local _dFab:=" "
Local _dVenc := ""
Local bQuery    := {|| Iif(Select("TMP_X") > 0, TMP_X->(dbCloseArea()), Nil), dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP_X",.F.,.T.) , dbSelectArea("TMP_X"),TMP_X->(dbGoTop())}

_aArea:=GETAREA()


cQuery := " SELECT B8_DTFABR, B8_DTVALID,B8_LOTECTL "
cQuery += " FROM " + RetSQLName("SB8") + " SB8 "
cQuery += " WHERE B8_LOTECTL='"+_cLote+"'"
cQuery += " AND SB8.D_E_L_E_T_ = ' ' "
LJMsgRun(,,bQuery)
If !EOF()
	While !EOF().and.(empty(_dFab).or.empty(_dVenc))
		if empty(_dFab)
			_dFab:=B8_DTFABR
		Endif
		if empty(_dVenc)                                       
			_dVenc := B8_DTVALID
		Endif
		DBSKIP()
	END
Endif

restarea(_aArea)

RETURN(IF(_Tipo=1,_dFab,_dVenc))      
