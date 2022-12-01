#include "totvs.ch"


/**************************************************************************************************
Função:
AF030GRV

Autor:
Tiago Bandeira Brasiliano

Data:
21/10/2014

Descrição:
Ponto de Entrada Executado após as gravações da rotina de baixa de ativo fixo (Caminho: 
SIGAATF > Atualizações > Movimentos > Baixas > Baixar)

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function AF030GRV()

//+-----------------------------------------------------+
//| Efetua gravação de auditoria customizada da Ferring |
//+-----------------------------------------------------+
U_GrLog(ProcName(), cModulo, __cUserID, dDatabase, Time(), cEmpAnt, cFilAnt)

Return .T.