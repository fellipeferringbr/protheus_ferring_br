#INCLUDE "Protheus.ch"

User Function BACA_SD5()
Local nTotReg := 0
Local bQuery  := {|| Iif(Select("TMP_SD5") > 0, TMP_SD5->(dbCloseArea()), Nil), dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP_SD5",.F.,.T.) , dbSelectArea("TMP_SD5"),TMP_SD5->(dbEval({|| nTotReg++ })) ,TMP_SD5->(dbGoTop())}
Local cQuery  := ""
/*
SELECT A.R_E_C_N_O_ AS SD2RECNO 
FROM SD2010 A 
WHERE D2_FILIAL = '01' AND D2_EMISSAO BETWEEN '20090101' AND '20091231' AND 
A.D_E_L_E_T_ = ' ' AND D2_LOTECTL <> '       ' AND 
D2_DOC NOT IN ( SELECT D5_DOC 
FROM SD5010 B 
WHERE D5_FILIAL = '01' AND D5_PRODUTO = D2_COD AND 
D5_LOCAL = D2_LOCAL AND D5_DOC = D2_DOC AND D5_SERIE = D2_SERIE AND 
D5_CLIFOR = D2_CLIENTE AND D5_LOJA = D2_LOJA AND D5_LOTECTL = D2_LOTECTL AND 
B.D_E_L_E_T_ = ' ' ) 
*/
cQuery := " SELECT A.R_E_C_N_O_ AS SD2RECNO "
cQuery += " FROM SD2010 A "
cQuery += " WHERE D2_FILIAL = '01' AND D2_EMISSAO BETWEEN '20090101' AND '20091231' AND "
cQuery += "       A.D_E_L_E_T_ = ' ' AND D2_LOTECTL <> '       ' AND "
cQuery += "       D2_DOC NOT IN ( SELECT D5_DOC "
cQuery += "                       FROM SD5010 B "
cQuery += "                       WHERE D5_FILIAL = '01' AND D5_PRODUTO = D2_COD AND "
cQuery += "                             D5_LOCAL = D2_LOCAL AND D5_DOC = D2_DOC AND D5_SERIE = D2_SERIE AND "
cQuery += "                             D5_CLIFOR = D2_CLIENTE AND D5_LOJA = D2_LOJA AND D5_LOTECTL = D2_LOTECTL AND "
cQuery += "                             B.D_E_L_E_T_ = ' ' ) "
Eval(bQuery)
While TMP_SD5->(!Eof()) 
	dbSelectArea("SD2")
	SD2->(dbGoTo(TMP_SD5->SD2RECNO))
	GravaSD5("SD2",SD2->D2_COD,SD2->D2_LOCAL,SD2->D2_LOTECTL,SD2->D2_NUMLOTE,ProxNum(),SD2->D2_DOC,SD2->D2_SERIE,,SD2->D2_TES,SD2->D2_CLIENTE,SD2->D2_LOJA,"",SD2->D2_QUANT,,SD2->D2_EMISSAO,SD2->D2_DTVALID)
	TMP_SD5->(dbSkip())
EndDo

MsgAlert("Concluido..")

Return(Nil)