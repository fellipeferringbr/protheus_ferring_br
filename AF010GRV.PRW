#include "totvs.ch"


/**************************************************************************************************
Função:
AF010GRV

Autor:
Tiago Bandeira Brasiliano

Data:
21/10/2014

Descrição:
Ponto de Entrada Executado após as gravações da rotina de alteração de Ativos (Caminho: 
SIGAATF > Atualizações > Cadastros > Ativos > Alterar)

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function AF010GRV()

//+-----------------------------------------------------+
//| Efetua gravação de auditoria customizada da Ferring |
//+-----------------------------------------------------+
U_GrLog(ProcName(), cModulo, __cUserID, dDatabase, Time(), cEmpAnt, cFilAnt)

Return .T.