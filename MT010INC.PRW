#include "totvs.ch"


/**************************************************************************************************
Fun??o:
MT010INC

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descri??o:
Ponto de entrada para complementar a inclus?o no cadastro do Produtos.
Executado ap?s incluir o Produto, este Ponto de Entrada nem confirma nem cancela a opera??o, deve 
ser utilizado para gravar arquivos/campos do usu?rio, complementando a inclus?o.

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function MT010INC()

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.