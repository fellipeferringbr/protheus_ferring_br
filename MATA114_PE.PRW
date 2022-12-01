#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MATA114 
@type		    :   Ponto de Entrada (MVC)  
@Sample			:  
@description	:   Ponto de entrada para manipulação do modelo de dados do Grupo de Aprovação

@Param	PARAMIXB: 	
					1     O        Objeto do formulário ou do modelo, conforme O ID Execuão
					2     C        ID do local de execução do ponto de entrada
					3     C        ID do formulário 

@return			:   lRet =  .T. (Validacao Sucesso) ou .F. (Validacao Inconsistência)
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: 14/10/2020
@version		: P12
/*/
//------------------------------------------------------------------------------------------
User Function MATA114()

Local aArea 		:= GetArea()
Local aParam     	:= PARAMIXB
Local nOperation 	:= 0
Local oObj       	:= Nil
Local cIdPonto   	:= ""
Local cIdModel   	:= ""
Local cPerfPadr 	:= ""
Local lIsGrid    	:= .F.
Local lRet       	:= .T.


// -----------------------------------------------------------------------	
// RECUPERA OS PARAMETROS DO PONTO DE ENTRADA [MVC]
// -----------------------------------------------------------------------	 
If ( aParam <> NIL )
  
	oObj       := aParam[1]
	cIdPonto   := aParam[2]
	cIdModel   := aParam[3]
	lIsGrid    := ( Len( aParam ) > 3 )

	// -----------------------------------------------------------------------	
	// MODELPOS - Equivale TudOK ( Confirmação do modelo de dados)   
	// -----------------------------------------------------------------------	       
	If cIdPonto == 'MODELPOS'

		nOperation := oObj:GetOperation() 

		If  ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE ) 
			
			// ------------------------------------------------------------------------
			// VALIDA PERFIL OBRIGATORIO 000001 
			// ------------------------------------------------------------------------

			cPerfPadr	:= SuperGetMv("ES_FPRFPAD",,"000001") //-- Perfil Padrão
			cPerfPadr	:= PadR(cPerfPadr, TamSX3("AL_PERFIL")[1]) 

			If !ExistPerf(oObj, cPerfPadr)
				oObj:SetErrorMessage("",,oObj:GetId(),"","MATA114","O Perfil de código "+ cPerfPadr +" é obrigatório." + CRLF + CRLF + ;
																	"Verifique se o bloqueio está igual a Sim") 
				lRet := .F. 
			EndIf 

			If ( lRet )
				// ------------------------------------------------------------------------
				// Alerta usuário sobre as definições em que ele aplicou no cadastro 
				// ------------------------------------------------------------------------
				lRet := ShowLevel(oObj, cPerfPadr)
			EndIf 
		EndIf 		
	EndIf
 
EndIf

RestArea(aArea)

Return( lRet )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ShowLevel 
@type		    :   Static Function
@Sample			:  
@description	:   Exibe tela de mensagem p/ usuário com o propósito de alertá-lo sobre as definições em que
					ele aplicou:
					01 - Mostrar os perfis (ignorados) que deixou de adicionar.
					02 - Mostarar os perfis em que ele adicionou porem setou como bloqueado.
					03 - Mostrar os perfis em que ele adicionou porém setou o tipo de liberação DIFERENTE de "N" - Por nível.

@Param	oModel: 	Objeto do modelo de dados (Cadastro de Aprovadores)
@return			:   Nulo
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: 15/10/2020
@version		: P12
/*/
//------------------------------------------------------------------------------------------
Static Function ShowLevel( oModel, cPerfPadr )

Local aArea 		:= GetArea()
Local cMessage		:= ""
Local oGridSAL 		:= Nil 
Local aNotPerfil	:= {}
Local lBloqueado	:= .F.
Local nI 			:= 0


DbSelectArea("DHL")
DHL->( DbGoTop() )

	oGridSAL 	:= oModel:GetModel("DetailSAL")

	While DHL->( !Eof() )

		//--  VARRE TODOS OS PERFIS EXCETO O PERFIL PADRÃO "000001"
		If cPerfPadr <>  DHL->DHL_COD

			If oGridSAL:SeekLine( { {"AL_PERFIL", DHL->DHL_COD } },/*lDeleted*/ .F., /*lLocate*/ .T.  ) 

				lBloqueado := oGridSAL:GetValue("AL_MSBLQL") == "1"

				If ( lBloqueado )
					aAdd( aNotPerfil, { DHL->DHL_COD , "Bloqueado."} )
				EndIf 
			Else 
				aAdd( aNotPerfil, { DHL->DHL_COD , "Não Informado."} )
			EndIf

		EndIf 

		DHL->( DbSkip() )
	EndDo 

	If Len(aNotPerfil) > 0
		
		cMessage := "ATENÇÃO ao definir o perfil de aprovação." + CRLF + CRLF 

		For nI := 1 To Len(aNotPerfil)

			cMessage += "Perfil: " + Alltrim( aNotPerfil[nI][1] +" "+ aNotPerfil[nI][2]) + CRLF
	
		Next

		FwAlertWarning(cMessage,"Perfil de Aprovação")

	EndIf 


RestArea( aArea )

Return( Nil )




Static Function ExistPerf( oModel, cCodPerf )

Local aSaveLines	:= FWSaveRows()
Local oGridSAL 		:= Nil 
Local nI 			:= 0
Local lExist		:= .F. 

#DEFINE  LIBERADO "2"

Default cCodPerf := "000001"

oGridSAL 	:= oModel:GetModel("DetailSAL")


// --------------------------------------------
//  VARRE GRID EM BUSCADO DO PERFIL CHAVE 
// --------------------------------------------
For nI := 1 To oGridSAL:Length()

	oGridSAL:GoLine( nI )

	If !( oGridSAL:IsDeleted() )

		If ( oGridSAL:GetValue("AL_PERFIL") == cCodPerf .And. oGridSAL:GetValue("AL_MSBLQL") == LIBERADO )
			lExist := .T. 
			Exit 
		EndIf 

	EndIf 

Next 


FWRestRows(aSaveLines)

Return( lExist )
