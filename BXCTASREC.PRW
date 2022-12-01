#Include 'Protheus.ch'


/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Relatório Controle de Baixas a Receber
//Servirá para controlar as baixas que foram feitas em um determinado tempo
//Criado por Leandro Fini - Farinelli Sistemas
//Em 20/07/2015 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/

User Function BXCTASREC()

local oReport
local cPerg  := 'BXCTASREC'
local cAlias := getNextAlias()

//criaSx1(cPerg)
Pergunte(cPerg, .F.)

oReport := reportDef(cAlias, cPerg)
oReport:printDialog()

return
        
//+-----------------------------------------------------------------------------------------------+
//! Rotina para montagem dos dados do relatório.                                  !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportPrint(oReport,cAlias)
              
local oSecao1 := oReport:Section(1)

oSecao1:BeginQuery()

BeginSQL Alias cAlias     


SELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E5_HISTOR, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_EMISSAO, E1_VENCREA, E1_VALOR, E1_BAIXA  FROM %Table:SE1% SE1
JOIN SE5010 SE5 ON E5_NUMERO = E1_NUM
AND E1_FILIAL = E5_FILIAL
AND E1_CLIENTE = E5_CLIFOR
AND E1_PARCELA = E5_PARCELA
AND E1_PREFIXO = E5_PREFIXO
AND E1_LOJA = E5_LOJA
AND SE1.D_E_L_E_T_ = ''
AND E5_RECPAG = 'R'
AND E1_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
AND E1_BAIXA BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
AND E1_CLIENTE BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
ORDER BY E1_VENCREA

EndSQL

oSecao1:EndQuery()
oReport:SetMeter((cAlias)->(RecCount()))
oSecao1:Print() 

return

//+-----------------------------------------------------------------------------------------------+
//! Função para criação da estrutura do relatório.                                                !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportDef(cAlias,cPerg)

local cTitle  := "Controle Baixas - Contas a Receber"
local cHelp   := "Permite gerar relação de baixas de contas a receber."
local oReport
local oSection1

oReport := TReport():New('BXCTASREC',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)

//Primeira seção
oSection1 := TRSection():New(oReport,"Contas a Receber",{"SE1"}) 

//ELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_EMISSAO, E1_VENCREA, E1_VALOR, E1_BAIXA FROM %Table:SE1% SE1
TRCell():New(oSection1,"E1_FILIAL", "SE1", "Filial")    
TRCell():New(oSection1,"E1_PREFIXO", "SE1", "Prefixo")
TRCell():New(oSection1,"E1_NUM", "SE1", "Num. Titulo")
TRCell():New(oSection1,"E1_PARCELA", "SE1", "Parcela")
TRCell():New(oSection1,"E1_TIPO", "SE1", "Tipo")
TRCell():New(oSection1,"E5_HISTOR", "SE5", "Historico")
TRCell():New(oSection1,"E1_CLIENTE", "SE1", "Cod Cliente") 
TRCell():New(oSection1,"E1_LOJA", "SE1", "Loja")
TRCell():New(oSection1,"E1_NOMCLI", "SE1", "Nome Cliente")
TRCell():New(oSection1,"E1_EMISSAO", "SE1", "Emissao")
TRCell():New(oSection1,"E1_VENCREA", "SE1", "Venc Real")
TRCell():New(oSection1,"E1_VALOR", "SE1", "Valor")
TRCell():New(oSection1,"E1_BAIXA", "SE1", "Dt Baixa") 


Return(oReport)

//+-----------------------------------------------------------------------------------------------+
//! Função para criação das perguntas (se não existirem)                                          !
//+-----------------------------------------------------------------------------------------------+
/*
static function criaSX1(cPerg)

putSx1(cPerg, '01', 'Filial de?'          , '', '', 'mv_ch1', 'C', 02, 0, 0, 'G', '', 'SM0', '', '', 'mv_par01')
putSx1(cPerg, '02', 'Filial ate?'         , '', '', 'mv_ch2', 'C', 02, 0, 0, 'G', '', 'SM0', '', '', 'mv_par02')
putSx1(cPerg, '03', 'da Data?'         , '', '', 'mv_ch3', 'D', 8, 0, 0, 'G', '', '', '', '', 'mv_par03') 
putSx1(cPerg, '04', 'ate Data?'         , '', '', 'mv_ch4', 'D', 8, 0, 0, 'G', '', '', '', '', 'mv_par04')
putSx1(cPerg, '05', 'do Cliente?'         , '', '', 'mv_ch5', 'C', 6, 0, 0, 'G', '', 'SA1', '', '', 'mv_par05')
putSx1(cPerg, '06', 'ate Cliente?'         , '', '', 'mv_ch6', 'C', 6, 0, 0, 'G', '', 'SA1', '', '', 'mv_par06')


Return
*/

