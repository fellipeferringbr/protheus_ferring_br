#include "rwmake.ch"       
#include "colors.ch"
#include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBLQFIN    บAutor  ณAndrea Pereira      บ Data ณ  03/10/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Funcao para bloquear a data de movimentacao do financeiro บฑฑ
ฑฑบ          ณ  (inclusao, alteracao, exclusao, baixa)                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

//************************
User Function FCTBM001()        
//************************

    TelaPar()
	
Return


//*****************************
Static Function TelaPar()
//*****************************
Local wdatafin
Local wdatafis
Local dDATAFIS 
Local dDATAFIN
Local lAtu := .F.

//dDATAFIS := Ctod(" / /    ")  
//dDATAFIN := Ctod(" / /    ")


wdatafis := GETMV("MV_DATAFIS")  
wdatafin := GETMV("MV_DATAFIN")  

dDATAFIS := wdatafis  
dDATAFIN := wdatafin

DEFINE MSDIALOG oDLG FROM 000,000 TO 250,450 TITLE "Altera็ใo de Parโmetros" OF oMainWnd PIXEL
//@ 05,80 SAY "ATUALIZAวรO DE PARยMETROS" SIZE 200,012 OF oDLG PIXEL COLOR CLR_HRED
@ 10,10 TO 100,200 OF oDLG PIXEL               
@ 15,15 SAY "FISCAL - Dt Lim. Mov. - Atual" SIZE 200,012 OF oDLG PIXEL COLOR CLR_HBLUE 
@ 15,135 MSGET wdatafis     PICTURE "@E" SIZE 060,005 WHEN .F. OF oDLG PIXEL 
@ 25,15 SAY "FISCAL - Dt Lim. Mov. - Nova" SIZE 200,012 OF oDLG PIXEL COLOR CLR_HBLUE
@ 25,135 MSGET dDATAFIS     PICTURE "@E" SIZE 060,005 OF oDLG PIXEL   
@ 35,15 SAY "FINANCEIRO - Dt Lim. Mov. - Atual" SIZE 200,012 OF oDLG PIXEL COLOR CLR_HBLUE 
@ 35,135 MSGET wdatafin     PICTURE "@E" SIZE 060,005 WHEN .F. OF oDLG PIXEL 
@ 45,15 SAY "FINANCEIRO - Dt Lim. Mov. - Nova" SIZE 200,012 OF oDLG PIXEL COLOR CLR_HBLUE
@ 45,135 MSGET dDATAFIN     PICTURE "@E" SIZE 060,005 OF oDLG PIXEL
                  
DEFINE SBUTTON FROM 106,125 TYPE 1 ENABLE OF oDLG ACTION (nOpcao := 1,oDLG:End())
DEFINE SBUTTON FROM 106,175 TYPE 2 ENABLE OF oDLG ACTION (nOpcao := 0,oDLG:End())
               
ACTIVATE MSDIALOG oDLG CENTERED

If nOpcao == 1
     AtuFIS(dDATAFIS)
     AtuFIN(dDATAFIN)
     MsgInfo ("Atualiza็ใo realizada com Sucesso !")

Else
     MsgInfo ("Os Parโmetros nใo foram atualizados!")     
Endif

Return(Nil)


//********************************************
Static Function AtuFIS(dDATAFIS)
//********************************************

Local dData 

dData := dDATAFIS

PutMV("MV_DATAFIS",dData)        

Return

//********************************************
Static Function AtuFIN(dDATAFIN)
//********************************************
Local dData   

dData := dDATAFIN

PutMV("MV_DATAFIN",dData)  


Return
