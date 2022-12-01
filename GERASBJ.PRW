#include "rwmake.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraSBJ   ³ Autor ³ Walter Matsui         ³ Data ³ 26/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera arquivo SBJ apos fechamento quando houver inconsist.  ³±±
±±³          ³                                                            ³±±        
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Estoque                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GeraSBJ()

Private _cPerg := "GERASBJ   " 

//PutSx1(_cPerg,"01","Data do Fechamento           ?","Data do Fechamento           ?","Data do Fechamento           ?","mv_ch1","D",08,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",{},{},{})

Pergunte(_cPerg,.T.)

If Msgyesno("Confirma Geração de Arquivo SBJ ?","YESNO" )
	
 	_lOk:= .T.
	
	oProcess:= MsNewProcess():New({|| GeraProc(oProcess)},"","",.F.)
	oProcess:cTitle:="Geração de Arquivo de Fechamento por Lote (SBJ)"
	oProcess:Activate()
Else
	_lOk:= .F.
Endif

If _lOk
	MsgAlert("Processamento Ok ")
Else
	MsgAlert("Processamento nao realizado.")
Endif

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ GeraProc ³ Autor ³ Walter Matsui         ³ Data ³ 26/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera arquivo SBJ                                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Estoque                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Static Function GeraProc()

Local bQuery    := {|| Iif(Select("TMP") > 0, TMP->(dbCloseArea()), Nil), dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.T.) , dbSelectArea("TMP"),TMP->(dbGoTop())}
oProcess:SetRegua1(2700)

dbSelectArea("SB8")
dbSetOrder(1)
dbGotop()

cQuery := " SELECT B8_PRODUTO,B8_LOCAL,B8_LOTECTL,B8_DTVALID " + Chr(13) + Chr(10)
cQuery += " FROM " + RetSQLName("SB8") + Chr(13) + Chr(10)
cQuery += " WHERE B8_FILIAL = '" + xFilial("SB8") + "' AND D_E_L_E_T_ = ' ' "+ Chr(13) + Chr(10)
cQuery += " GROUP BY B8_PRODUTO,B8_LOCAL,B8_LOTECTL,B8_DTVALID "+ Chr(13) + Chr(10)
cQuery += " ORDER BY B8_PRODUTO,B8_LOCAL,B8_LOTECTL,B8_DTVALID "+ Chr(13) + Chr(10)

LJMsgRun("Consultando Lançamentos...","Aguarde...",bQuery)

While !Eof()                                 
   
	aSaldo := CalcEstL(SB8->B8_PRODUTO,SB8->B8_LOCAL,(MV_PAR01+1),SB8->B8_LOTECTL,SB8->B8_NUMLOTE,"","",.T.) 
   /*
   Parametros³ ExpC1 = Codigo do Produto                 
             ³ ExpC2 = Local (Almoxarifado)              
             ³ ExpD1 = Data para obter o Saldo Inicial.  
             ³ ExpC3 = Lote                              
             ³ ExpC4 = Sub-Lote                          
             ³ ExpC5 = Localizacao                       
             ³ ExpC6 = Numero de Serie                   
             ³ ExpL1 = Verifica se obtem o saldo por Sub-Lote com rastro L
    */
    
  	oProcess:IncRegua1("Processando Arquivo SB8") //Incrementa primeira regua

    GravaSBJ()         
    
    dbSelectArea("SB8") 
    dbSkip()
    
Enddo


Return(Nil)

    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GravaSBJ  ³ Autor ³ Walter Matsui         ³ Data ³ 26/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava arquivo SBJ.                                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GravaSBJ()

//   Verificacao dos dados antes de gravar SBJ
IF SB8->B8_PRODUTO='50.012.001'
   Aviso("Mensagem",SB8->B8_PRODUTO+SB8->B8_LOCAL+" "+dTos(dDatabase+1)+" "+SB8->B8_LOTECTL+" "+Transform(aSaldo[1],"@E 999,999.999"),{"Ok"})
Endif

/*
dbSelectArea("SBJ")
RecLock("SBJ",.T.)
BJ_FILIAL	:= xFilial("SBJ")
BJ_COD		:= TMP->B8_PRODUTO
BJ_LOCAL	:= TMP->B8_LOCAL
BJ_DATA		:= Dtos(MV_PAR01)
BJ_QINI		:= aSaldo[1]
BJ_QISEGUM	:= 0
BJ_LOTECTL	:= TMP->B8_LOTECTL
BJ_NUMLOTE	:= TMP->B8_NUMLOTE
BJ_DTVALID	:= TMP->B8_DTVALID
MsUnlock()
*/

Return(Nil)
 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ GeraPerg º Autor ³ Walter Matsui      º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Verifica a existencia das perguntas criando-as caso seja   º±±
±±º          ³ necessario (caso nao existam).                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//Static Function GeraPerg(_cPerg)
//
//PutSx1(_cPerg,"01","Data do Fechamento           ?","Data do Fechamento           ?","Data do Fechamento           ?","mv_ch1","D",08,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",{},{},{})
//
//Return


