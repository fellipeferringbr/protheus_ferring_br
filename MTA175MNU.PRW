#include "Protheus.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA175MNU    ºAutor  ³Microsiga           º Data ³  06/03/19 ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua na rotina Liberação de CQ a chamada da função       º±±
±±º          ³ MsDocument                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MTA175MNU                                                    

Aadd(aRotina, {"Laudos","u_Laudos" , 0 , 2, 0, NIL})   

Return  (Nil) 

User Function Laudos() 
Local aArea := GetArea()
Local aAreaSD7 := SD7->(GetArea())
Local cQuery := ""

	cQuery := " SELECT "
	cQuery += "   R_E_C_N_O_ D7_RECNO "
	cQuery += " FROM "
	cQuery += "   "+ SD7->(RetSQLName("SD7"))
	cQuery += " WHERE "                                                       
	cQuery += "   D7_FILIAL = '"+ SD7->(xFILIAL("SD7")) +"' AND D7_PRODUTO = '"+ SD7->D7_PRODUTO +"'  "
	cQuery += "   AND D7_LOTECTL = '"+ SD7->D7_LOTECTL +"' AND D7_SEQ = '001' "
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	TcQuery cQuery Alias TSD7A New
	TSD7A->(dbGoTop())
	SD7->(dbGoTo(TSD7A->D7_RECNO))
	TSD7A->(dbCloseArea())

	MsDocument('SD7',SD7->(RecNo()), 3)


RestArea(aAreaSD7)
RestArea(aArea)
Return  (Nil)
