#include 'protheus.ch'
#include 'parmtype.ch'



User Function CustomerVendor()
	Local aParam    := PARAMIXB
	Local xRet      := .T.
	Local oObject   := aParam[1] //Objeto do formul�rio ou do modelo, conforme o caso
	Local cIdPonto  := aParam[2] //ID do local de execu��o do ponto de entrada(se �  p�s valida��o, pr� valida��o, commit, etc)
	Local cIdModel  := aParam[3] //ID do formul�rio   




	IF aParam[2] <> Nil //(Se ele clicar em Incluir/Alterar/Excluir/Visualizar)

		IF cIdPonto == "FORMCOMMITTTSPOS" 
		
		
/*******************************************************************************************************		
Fun��o:
M020INC

Autor:
Juscelino Alves dos Santos

Data:
15/07/2014

Descri��o:
Ponto de entrada para complementar a inclus�o no cadastro do Fornecedor.
Chamado ap�s incluir o Fornecedor. Deve ser utilizado para gravar arquivos/campos do usu�rio, 
complementando a inclus�o.

Par�metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/

			U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

		endif


	endif
	
	return xRet

