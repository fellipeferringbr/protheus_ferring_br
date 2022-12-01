#INCLUDE "Protheus.ch"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MA030ROT 
@type		    :   Ponto de Entrada 
@Sample			:  
@description	:   Ponto de entrada para permitir a adição de novos botões ao cadastro de clientes
                    (Adiciona botões no Browse de Cad. Clientes)  

@Param	PARAMIXB: 	Nulo

@return			:   aButton Array de botões
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: 22/10/2020
@version		: P12
/*/
//------------------------------------------------------------------------------------------
/*
User Function MA030ROT()

Local aButton := {}

// -------------------------------------------------------------------
//-- Rotina -> Cadastro de enderecos de entrega x clientes     
// -------------------------------------------------------------------
Aadd(aButton,{"End. Entrega"    , "U_RFATA010()"    , 0 , 4,0,NIL})

// -------------------------------------------------------------------
// Rotina -> Realiza desbloqueio ou bloqueio do cliente selecionado 
// -------------------------------------------------------------------
Aadd(aButton,{"Libera Cliente"  , "U_FFATA015('2')" , 0 , 4,0,NIL})
Aadd(aButton,{"Bloqueia Cliente", "U_FFATA015('1')" , 0 , 4,0,NIL})
 

Return(aButton)
*/

User Function CRM980MDEF()
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
        ElseIf cIdPonto == 'MODELCOMMITNTTS'
        ElseIf cIdPonto == 'FORMCOMMITTTSPOS'
        ElseIf cIdPonto == 'MODELCANCEL'
        ElseIf cIdPonto == 'BUTTONBAR'
                xRet:={}
                 // -------------------------------------------------------------------
                //-- Rotina -> Cadastro de enderecos de entrega x clientes     
                // -------------------------------------------------------------------
                Aadd(xRet,{"End. Entrega"    , "U_RFATA010()"    , 0 , 4,0,NIL})

                // -------------------------------------------------------------------
                // Rotina -> Realiza desbloqueio ou bloqueio do cliente selecionado 
                // -------------------------------------------------------------------
                Aadd(xRet,{"Libera Cliente"  , "U_FFATA015('2')" , 0 , 4,0,NIL})
                Aadd(xRet,{"Bloqueia Cliente", "U_FFATA015('1')" , 0 , 4,0,NIL})
                
        EndIf
    EndIf

Return xRet
