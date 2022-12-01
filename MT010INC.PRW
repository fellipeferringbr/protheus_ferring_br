#include "totvs.ch"


/**************************************************************************************************
Função:
MT010INC

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descrição:
Ponto de entrada para complementar a inclusão no cadastro do Produtos.
Executado após incluir o Produto, este Ponto de Entrada nem confirma nem cancela a operação, deve 
ser utilizado para gravar arquivos/campos do usuário, complementando a inclusão.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function MT010INC()

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.