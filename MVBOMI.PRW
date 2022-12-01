#include "RWMAKE.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ALTMV    ³ Autor ³ RENATO TAKAO          ³ Data ³ 18/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza parametro(SX6) BOMI                           ³±±
±±³          ³                                                            ³±±

±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Faturamento                                                 ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION MVBOMI()
    local _i,_x 
Private _aMV:={}
AADD(_aMV,{"MV_XFTPBOMI",GetMv("MV_XFTPBOMI",,"mail.bomifarma.com.br"),"Endereço do FTP da BOMI"})
AADD(_aMV,{"MV_XUSRBOMI",GetMv("MV_XUSRBOMI",,"ferring"),"Nome de usuário para login no FTP da BOMI"})
AADD(_aMV,{"MV_XSENBOMI",GetMv("MV_XSENBOMI",,"ferr#1601"),"Senha de usuário para login no FTP da BOMI"})
AADD(_aMV,{"MV_XDIRFTP",GetMv("MV_XDIRFTP",,"/in/"),"Pasta para gravação dos arquivos remetidos para BOMI no FTP"})
AADD(_aMV,{"MV_XFTPOUT",GetMv("MV_XFTPOUT",,"/out/"),"Pasta para leitura dos arquivos retornados pela BOMI no FTP"})
AADD(_aMV,{"MV_BOMI1",GetMv("MV_BOMI1",,"\arqs_bomi\envio\"),"Pasta local de gravação dos arquivos enviados para BOMI"})
AADD(_aMV,{"MV_BOMI2",GetMv("MV_BOMI2",,"\arqs_bomi\retorno\") ,"Pasta local de gravação dos arquivos retornados pela BOMI"})
AADD(_aMV,{"MV_XTESTRF",GetMv("MV_XTESTRF",,"066|970"),"Códigos das TES para considerar na interface de ARMAZENAGEM"})
AADD(_aMV,{"MV_XCODSAI",GetMv("MV_XCODSAI",,"00026402"),"Código do cliente para nota fiscal de retorno simbolico"})
AADD(_aMV,{"MV_XSERNF",GetMv("MV_XSERNF",,"1  "),"Série da nota fiscal de retorno simbolico"})
//AADD(_aMV,{GetMv("MV_XCNDENT",,"001")   ,"Código de condição de pagamento padrão para nota fiscal de retorno simbolico"})
//AADD(_aMV,{"MV_XBOMIAT",GetMv("MV_XBOMIAT",,.F.),"Indica se está ativo controle de pedidos BOMI para bloquear faturamento de pedidos pendentes"})  
// Relatório MATCH de estoque
AADD(_aMV,{"MV_XLOCQUA",GetMv("MV_XLOCQUA",,"50"),"Código dos almoxarifados equivalentes ao status QUA na BOMI - separados por |"})
AADD(_aMV,{"MV_XLOCBOM",GetMv("MV_XLOCBOM",,"01"),"Código dos almoxarifados equivalentes ao status DIS na BOMII - separados por |"})
AADD(_aMV,{"MV_XLOCAVA",GetMv("MV_XLOCAVA",,"85|55"),"Código dos almoxarifados equivalentes ao status AVA na BOMII - separados por |"})

// 13 parametros
DEFINE MSDIALOG oDlg1 from 50,50 TO 85,160 TITLE "Parametros BOMI"  

For _i:=1 to len(_aMV)
	@ 005+((15*_i)-15),090 Say _aMV[_i][3] 
Next

_c1:=_aMV[1][2]
_c2:=_aMV[2][2]
_c3:=_aMV[3][2]
_c4:=_aMV[4][2]
_c5:=_aMV[5][2]
_c6:=_aMV[6][2]
_c7:=_aMV[7][2]
_c8:=_aMV[8][2]
_c9:=_aMV[9][2]
_c10:=_aMV[10][2]
_c11:=_aMV[11][2]
_c12:=_aMV[12][2]
_c13:=_aMV[13][2]
                       
_i:=1
@ 005+((15*_i++)-15),010 Get _c1 size 70,10 
@ 005+((15*_i++)-15),010 Get _c2 size 70,10 
@ 005+((15*_i++)-15),010 Get _c3 size 70,10 
@ 005+((15*_i++)-15),010 Get _c4 size 70,10 
@ 005+((15*_i++)-15),010 Get _c5 size 70,10 
@ 005+((15*_i++)-15),010 Get _c6 size 70,10 
@ 005+((15*_i++)-15),010 Get _c7 size 70,10 
@ 005+((15*_i++)-15),010 Get _c8 size 70,10 
@ 005+((15*_i++)-15),010 Get _c9 size 70,10 
@ 005+((15*_i++)-15),010 Get _c10 size 70,10 
@ 005+((15*_i++)-15),010 Get _c11 size 70,10 
@ 005+((15*_i++)-15),010 Get _c12 size 70,10 
@ 005+((15*_i++)-15),010 Get _c13 size 70,10 

@ 220,50 BMPBUTTON TYPE 01 ACTION (GRVPAR(),Close(oDlg1))
@ 220,90 BMPBUTTON TYPE 02 ACTION Close(oDlg1)
ACTIVATE DIALOG oDlg1 CENTERED

RETURN()

Static Function GRVPAR()
local _x
//dbSelectArea("SX6")
//dbSetOrder(1)

For _x:=1 to len(_aMV)
/*
	If dbSeek(xFilial("SX6")+_aMV[_x][1])
		RecLock("SX6",.F.)
			X6_CONTEUD :=&("_c"+alltrim(str(_x))) //_aMV[_x][2]
		MSUnLock()                            
	Else
		RecLock("SX6",.T.)
			X6_VAR 			:=_aMV[_x][1]
			X6_TIPO 			:="C"
			X6_CONTEUD 	:=&("_c"+alltrim(str(_x))) //_aMV[_x][2]
			X6_DESCRIC 	:=_aMV[_x][3]
			X6_DSCSPA 		:=_aMV[_x][3]
			X6_DSCENG 	:=_aMV[_x][3]
			If len(alltrim(_aMV[_x][3]))>50
				X6_DESC1 		:=substr(_aMV[_x][3],51,50)
				X6_DSCSPA1 	:=substr(_aMV[_x][3],51,50)
				X6_DSCENG1 	:=substr(_aMV[_x][3],51,50)
			Endif
		MSUnLock()                            
	Endif
    */
    PutMv(_aMV[_x][1],&("_c"+alltrim(str(_x))))
Next

RETURN()
