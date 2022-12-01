#INCLUDE "Protheus.ch"

User Function FE_A1VldCGC(lInclui)
Local lRet := .T.

Default lInclui := .F.

/*
X3_CAMPO     | X3_TIPO   | X3_TAMANHO   | X3_TITULO      | X3_RELACAO   | X3_NIVEL   | X3_VISUAL   | X3_VLDUSER                                                                                                      | X3_CBOX
A1_CGC       | C         |     14.00000 | CNPJ/CPF       |              |      1.000 | A           | IIF(ALLTRIM(M->A1_TIPO)!="X",U_BCNPJCLI(),.T.) .And. ((! ExistBlock("FE_A1VldCGC").or.U_FE_A1VldCGC(INCLUI)))   |
A1_MSBLQL    | C         |      1.00000 | BLOQUEADO      | "1"          |      1.000 | V           |                                                                                                                 | 1=Inativo;2=Ativo
A1__CONGEL   | C         |      1.00000 | Clie.Congel.   | 2            |      0.000 | V           | Pertence(" 12")                                                                                                 | 1=Sim;2=Nao
A2_CGC       | C         |     14.00000 | CNPJ/CPF       |              |      1.000 | A           | IIF(ALLTRIM(M->A2_TIPO)!="X",U_bCNPJFor(),.T.) .And. ((! ExistBlock("FE_A2VldCGC").or.U_FE_A2VldCGC(INCLUI)))   |
A2_MSBLQL    | C         |      1.00000 | Bloqueado      | "1"          |      1.000 | V           |                                                                                                                 | 1=Sim;2=Nao
A2__CONGEL   | C         |      1.00000 | Congelado?     |              |      0.000 | A           |                                                                                                                 | 1=Sim;2=Nao

X3_CAMPO  ; X3_TITULO   ; X3_VLDUSER
A1_CGC    ; CNPJ/CPF    ; IIF(ALLTRIM(M->A1_TIPO)!="X",U_BCNPJCLI(),.T.) .And. ((! ExistBlock("FE_A1VldCGC").or.U_FE_A1VldCGC(INCLUI)))
A2_CGC    ; CNPJ/CPF    ; IIF(ALLTRIM(M->A2_TIPO)!="X",U_bCNPJFor(),.T.) .And. ((! ExistBlock("FE_A2VldCGC").or.U_FE_A2VldCGC(INCLUI)))

*/

If M->A1__CONGEL <> "1" .And. (! Empty(M->A1_CGC))  // Descongelado e A1_CGC preenchido
	// Verifica se o CPF/CNPJ do cliente já existe na base de dados e não permitirá nova inclusão.
	If FE_A1BusCGC(lInclui)  //  ExistChav("SA1",cFilial+M->A1_CGC,3,.F.)
		MsgAlert("Verifique o CNPJ/CPF "+M->A1_CGC+" pois não poderá ser duplicado ", ;
				 "Duplicidade CNPJ/CPF")
		lRet := .F.
	EndIf
Endif

Return(lRet)


Static Function FE_A1BusCGC(lInclui)
Local cQuery    := Nil
Local cAliasTop := "TRB" + Dtos(Date()) + StrTran(Time(), ":", "")
Local aSavAre   := GetArea()
Local lExist    := .F.

cQuery := " SELECT "                                                             + ;
          " A1_CGC, A1_MSBLQL "                                                  + ;
          " FROM " + RetSqlName("SA1") + " SA1 "                                 + ;
          " WHERE "                                                              + ;
          " SA1.D_E_L_E_T_ = ' '  AND A1_FILIAL = '" + xFilial("SA1") + "' "     + ;
          " AND A1_CGC = '" + M->A1_CGC + "' "

If SA1->(FieldPos("A1__CONGEL")) > 0
	cQuery += " AND A1__CONGEL <> '1' "
Endif

If ! Inclui
	cQuery += " AND A1_MSBLQL <> '1' "
	cQuery += " AND R_E_C_N_O_ <> " + cValToChar(SA1->(Recno())) + " "
Endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTop, .F., .T.)

lExist := (! Eof())

(cAliasTop)->(dbCloseArea())

RestArea(aSavAre)
Return(lExist)


User Function FE_A2VldCGC(lInclui)
Local lRet := .T.

Default lInclui := .F.

If M->A2_CONGEL <> "1" .And. (! Empty(M->A2_CGC))  // Descongelado e A2_CGC preenchido
	// Verifica se o CPF/CNPJ do cliente já existe na base de dados e não permitirá nova inclusão.
	If FE_A2BusCGC(lInclui)
		MsgAlert("Verifique o CNPJ/CPF "+M->A2_CGC+" pois não poderá ser duplicado ", ;
				 "Duplicidade CNPJ/CPF")
		lRet := .F.
	EndIf
Endif
Return(lRet)


Static Function FE_A2BusCGC(lInclui)
Local cQuery    := Nil
Local cAliasTop := "TRB" + Dtos(Date()) + StrTran(Time(), ":", "")
Local aSavAre   := GetArea()
Local lExist    := .F.

cQuery := " SELECT "                                                          + ;
          " A2_CGC, A2_MSBLQL, A2__CONGEL "                                   + ;
          " FROM " + RetSqlName("SA2") + " SA2 "                              + ;
          " WHERE "                                                           + ;
          " SA2.D_E_L_E_T_ = ' '  AND A2_FILIAL = '" + xFilial("SA2") + "' "  + ;
          " AND A2_CGC = '" + M->A2_CGC + "' "                                + ;
          " AND A2__CONGEL <> '1' "

If ! Inclui
	cQuery += " AND A2_MSBLQL <> '1' "
	cQuery += " AND R_E_C_N_O_ <> " + cValToChar(SA2->(Recno()))
Endif
dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTop, .F., .T.)

lExist := (! Eof())

(cAliasTop)->(dbCloseArea())

RestArea(aSavAre)
Return(lExist)

