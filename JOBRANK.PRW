#INCLUDE "TOTVS.CH"


/**************************************************************************************************
Fun??o:
JOBRANK

Autor:
Tiago Bandeira Brasiliano em 06/04/2017

Data:
18/05/2018

Descri??o:
Rotina respons?vel pela gera??o autom?tica da planinha de Ranking de Vendas e disponibiliza??o 
do mesmo para a Ferring M?xico.
A mesma deve ser executada via job uma vez por dia (hor?rio inicial definido: 19h00).
Inicialmente esta fun??o havia sido desenvolvida para efetuar a gera??o deste arquivo e a c?pia
diretamente para um FTP, por?m isto foi modificado por quest?es t?cnicas.
Atualmente a rotina gera o arquivo de Ranking, uma vez por dia, diretamente em uma pasta do 
Protheus_Data (definida pelo par?metro ES_DIRRANK. Default: FTPRANKING).
Ap?s a c?pia para esta pasta, existe um Job no banco de dados do M?xico (Servidor: FEMX0004\FEMX0004,
Job: CopiaArquivo_BR) que verifica qual o ?ltimo arquivo dentro desta pasta de "ENVIADOS" e efetua 
a c?pia para o diret?rio \\FEMX0004\E\FTP\EXTERNOS\SSIS\ (diret?rio local do M?xico).

Par?metros:
aPar?metros => Par?metros que ser?o passado pelo Schedule informando os dados para prepara??o
               do ambiente (opcional).
               
Retorno:
Nenhum.
**************************************************************************************************/
User Function JOBRANK(aParametros)

Local cDir       := ""
Local cDirEnv    := ""

Default aParametros :=  {"01", "01", "000000"}    // 1=Empresa ; 2=Filial ; 3=Cod. Usu?rios 

//+---------------------------------------------+
//| Prepara o ambiente para uso                 |
//+---------------------------------------------+
RPCSetType(3)
RpcSetEnv(aParametros[1], aParametros[2], Nil, Nil, "FAT", Nil, {"SA1", "SA2", "SC5", "SC6", "SF2", "SD2", "SF1", "SD1"})

//+---------------------------------------------+
//| Defini??o dos diret?rios da rotina.         |
//+---------------------------------------------+
cDir       := GetNewPar("ES_DIRRANK", "\FTPRANKING\")
cDirEnv    := cDir + "ENVIADOS\"

//+---------------------------------------------+
//| Cria diret?rios da rotina.                  |
//+---------------------------------------------+
MakeDir(cDir)
MakeDir(cDirEnv)

ConOut("JOB-RANKING: Iniciando JOB do Ranking de Vendas")

//+---------------------------------------------------------------+
//| Cria o arquivo do ranking  de vendas no diret?rio do servidor |
//+---------------------------------------------------------------+
//U_RankingNovo(.T., cDirEnv, .F.)
U_FeRank(.T., cDirEnv, .F.)
ConOut("JOB-RANKING: Finalizado JOB do Ranking de Vendas")

//+---------------------------------------------+
//| Fecha o ambiente do Protheus.               |
//+---------------------------------------------+
RpcClearEnv()

Return .T.