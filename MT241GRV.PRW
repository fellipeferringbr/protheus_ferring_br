#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  MT241GRV   ³ Autor ³ Renato Takao          ³ Data ³08/052008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Ponto de entrada gravacao movimentos internos modelo 2            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MT241GRV()

Local aArea     := GetArea()
Local _n := 0

dbselectarea("SB8")  // posiciona no lote para pegar data validade e fabricacao
aAreaSB8     := GetArea()
_aPosLOCAL:= AScan(aHeader,{|x| AllTrim(x[2]) == "D3_LOCAL" })
_aPosCOD:= AScan(aHeader,{|x| AllTrim(x[2]) == "D3_COD" })
_aPosLOTE:= AScan(aHeader,{|x| AllTrim(x[2]) == "D3_LOTECTL" })
_aPosDTF:= AScan(aHeader,{|x| AllTrim(x[2]) == "D3_DTFABR" })

If _aPosLOCAL*_aPosCOD*_aPosLOTE*_aPosDTF=0
	return
Endif

For _n:=1 to len(acols)                 

	If !(empty(aCols[_n][_aPosLOTE]) .OR. CTM>"500")
	
		dbselectarea("SB8")  // posiciona no lote para pegar data validade e fabricacao
		dbsetorder(3)
		dbseek(xfilial("SB8")+aCols[_n][_aPosCOD]+aCols[_n][_aPosLOCAL]+aCols[_n][_aPosLOTE])
		While    SB8->(B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL)=xfilial("SD3")+aCols[_n][_aPosCOD]+aCols[_n][_aPosLOCAL]+aCols[_n][_aPosLOTE]
			If empty(SB8->B8_DTFABR)
				reclock("SB8",.F.)
					SB8->B8_DTFABR:=aCols[_n][_aPosDTF]
				MSUNLOCK()
			Endif                       
			dbskip()
		End
	
	Endif
	
Next

restarea(aAreaSB8)
restarea(aArea)

return
