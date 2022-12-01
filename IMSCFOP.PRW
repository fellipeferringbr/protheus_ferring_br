#INCLUDE "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcctbm001  บ Autor ณ Leandro Silcaบ Data ณ  29/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Permitir a atualiza็ใo d0 parametro de CFOPS              -บฑฑ
ฑฑบ          ณ Para emissใo do relatorio da IMS                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Ferring - Faturamento                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

*------------------*
User Function IMSCFOP
*------------------*

Private _cCFOP := ""
_cCFOP := alltrim(Getmv("ES_CFOPREL"))
_cCFOP := _cCFOP + Space(200-Len(_cCFOP))

@ 100,110 to 360,554 Dialog Odlg Title "Adicionar Cfop de Faturamento"
@ 05, 10 TO 055, 213 
@ 60, 10 TO 100, 218 
@ 10, 13 SAY "CFOP PARA REL IMS          "

@ 20, 13 SAY "Lembre-se, ao Adicionar o CFOP os mesmos serใo apresentadas no relatorio"

@ 08, 80 GET _cCFOP        SIZE 120, 7 

DEFINE SBUTTON FROM 110,150 TYPE 2 ENABLE OF oDlg ACTION ( oDlg:End() )
DEFINE SBUTTON FROM 110,180 TYPE 1 ENABLE OF oDlg ACTION AtuaPar()
ACTIVATE MSDIALOG oDlg CENTERED 
Return


*-----------------------*
STATIC FUNCTION CONSMAT()
*-----------------------*
Return .T.



*-------------------*
STATIC FUNCTION ATUAPAR()
*-------------------*
if msgyesno("Confirma atualiza็ใo do parametro ? ")
	putmv("ES_CFOPREL",_cCFOP)

   oDlg:End()
Endif
Return