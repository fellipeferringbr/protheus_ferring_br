#include 'protheus.ch'
#include 'parmtype.ch'



User Function CustomerVendor()
	Local aParam    := PARAMIXB
	Local xRet      := .T.
	Local oObject   := aParam[1] //Objeto do formulário ou do modelo, conforme o caso
	Local cIdPonto  := aParam[2] //ID do local de execução do ponto de entrada(se é  pós validação, pré validação, commit, etc)
	Local cIdModel  := aParam[3] //ID do formulário   




	IF aParam[2] <> Nil //(Se ele clicar em Incluir/Alterar/Excluir/Visualizar)

		IF cIdPonto == "FORMCOMMITTTSPOS" 
		
		
/*******************************************************************************************************		
Função:
M020INC

Autor:
Juscelino Alves dos Santos

Data:
15/07/2014

Descrição:
Ponto de entrada para complementar a inclusão no cadastro do Fornecedor.
Chamado após incluir o Fornecedor. Deve ser utilizado para gravar arquivos/campos do usuário, 
complementando a inclusão.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/

			U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

		endif


	endif
	
	return xRet

