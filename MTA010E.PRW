#include "totvs.ch"


/**************************************************************************************************
Fun??o:
MTA010E

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descri??o:
Ponto de entrada para complementar a exclus?o no cadastro do Produto.
Executado ap?s deletar todos os registros pertinentes do Produto (SB2,SB5,SB9, etc.) este Ponto 
de Entrada nem confirma nem cancela a opera??o, deve ser utilizado para gravar arquivos/campos 
do usu?rio, complementando a exclus?o.

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
/*
User Function MTA010E()


U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.
*/
User function MTA010E()
 Local aParam     := PARAMIXB
    Local xRet       := .T.
    Local oObj       := ''
    Local cIdPonto   := ''
    Local cIdModel   := ''
    
	
	
    If aParam <> NIL
        oObj       := aParam[1]
        cIdPonto   := aParam[2]
        cIdModel   := aParam[3]
         nOpera:=  oObj:nOperation //3 inclusa - 4 alteracao  - 5 exclusao
        If     cIdPonto == 'MODELPOS'
        ElseIf cIdPonto == 'FORMPOS'  //chamada na valida??o total do formul?rio
        ElseIf cIdPonto == 'FORMLINEPRE'
        ElseIf cIdPonto == 'FORMLINEPOS'
        ElseIf cIdPonto == 'MODELCOMMITTTS'
            if nOpera==5
              U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)
            endif
        ElseIf cIdPonto == 'MODELCOMMITNTTS'
        ElseIf cIdPonto == 'FORMCOMMITTTSPOS'
        ElseIf cIdPonto == 'MODELCANCEL'
        ElseIf cIdPonto == 'BUTTONBAR'
        EndIf
    EndIf

Return xRet
