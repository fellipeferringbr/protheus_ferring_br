#include "totvs.ch"


/**************************************************************************************************
Função:
MTA010E

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descrição:
Ponto de entrada para complementar a exclusão no cadastro do Produto.
Executado após deletar todos os registros pertinentes do Produto (SB2,SB5,SB9, etc.) este Ponto 
de Entrada nem confirma nem cancela a operação, deve ser utilizado para gravar arquivos/campos 
do usuário, complementando a exclusão.

Parâmetros:
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
        ElseIf cIdPonto == 'FORMPOS'  //chamada na validação total do formulário
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
