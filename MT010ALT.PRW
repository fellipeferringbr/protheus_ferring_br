#INCLUDE "Protheus.ch"

/*
|-----------------------------------------------------------------------------|
|Programa | MT010ALT	| Autor: GILDESIO CAMPOS 			|DATA: 20/03/2012 |
|-----------------------------------------------------------------------------|
|Descricao| Ponto de Entrada na confirma��o da altera��o de dados cadastrais  |
|		  | de Produtos.                                                      |
|-----------------------------------------------------------------------------|
|Objetivo | Gravar a data de altera��o dos dados do Produto					  |
|-----------------------------------------------------------------------------|
|Uso      | Processo de Integracao Protheus X CRM CONSUMER VOICE 			  |
|-----------------------------------------------------------------------------|
*/
User Function MT010ALT()

Reclock("SB1", .F.)
SB1->B1_X_DATA := DDATABASE    
SB1->(MsUnlock())

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return Nil