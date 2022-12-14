// #########################################################################################
// Projeto:
// Modulo :
// Fonte  : FEFAT100
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 07/06/19 | TOTVS | Developer Studio | Gerado pelo Assistente de C?digo
// ---------+-------------------+-----------------------------------------------------------

#include "rwmake.ch"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} novo
Permite a manuten??o de dados armazenados em ZZB.

@author    TOTVS | Developer Studio - Gerado pelo Assistente de C?digo
@version   1.xx
@since     7/06/2019
/*/
//------------------------------------------------------------------------------------------
user function FEFAT100()
	//--< vari?veis >---------------------------------------------------------------------------
	
	//Indica a permiss?o ou n?o para a opera??o (pode-se utilizar 'ExecBlock')
	local cVldAlt := ".T." // Operacao: ALTERACAO
	local cVldExc := ".T." // Operacao: EXCLUSAO
	
	//trabalho/apoio
	local cAlias
	
	//--< procedimentos >-----------------------------------------------------------------------
	cAlias := "ZZB"
	chkFile(cAlias)
	dbSelectArea(cAlias)
	//indices
	dbSetOrder(1)
	axCadastro(cAlias, "Cadastro de Budget / Forecast", cVldExc, cVldAlt)
	
return
//--< fim de arquivo >----------------------------------------------------------------------
