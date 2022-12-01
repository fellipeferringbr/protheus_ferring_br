#Include 'Protheus.ch'


/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Relatório Match de Estoque destinado ao Marketing
//Servirá para alimentar informações para o software solicitação de campo
//Criado por Leandro Fini - Farinelli Sistemas
//Em 14/05/2015 - tratado no INC295742
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/

User Function MATCHEST()

local oReport
local cPerg  := 'EXTREPCLI'
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
 
SELECT Z4_PRODUTO, B1_DESC, Z4_QTDE, Z4_DTARQ FROM %Table:SZ4% SZ4
JOIN SB1010 SB1 ON B1_COD = Z4_PRODUTO
AND Z4_PRODUTO BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
AND Z4_DTARQ = %Exp:MV_PAR03%
AND SZ4.D_E_L_E_T_ = ' '
AND SB1.D_E_L_E_T_ = ' '
ORDER BY Z4_PRODUTO 
 
EndSQL

oSecao1:EndQuery()
oReport:SetMeter((cAlias)->(RecCount()))
oSecao1:Print() 

return

//+-----------------------------------------------------------------------------------------------+
//! Função para criação da estrutura do relatório.                                                !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportDef(cAlias,cPerg)

local cTitle  := "Relatório Match de Estoque"
local cHelp   := "Permite gerar relação de Match de Estoque."
local oReport
local oSection1

oReport := TReport():New('EXCLI',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)

//Primeira seção
oSection1 := TRSection():New(oReport,"Match de Estoque",{"SZ4"}) 

TRCell():New(oSection1,"Z4_PRODUTO", "SZ4", "Codigo Produto")
TRCell():New(oSection1,"B1_DESC", "SB1", "Descrição") 
TRCell():New(oSection1,"Z4_QTDE", "SZ4", "Quantidade") 


Return(oReport)
/*
//+-----------------------------------------------------------------------------------------------+
//! Função para criação das perguntas (se não existirem)                                          !
//+-----------------------------------------------------------------------------------------------+
static function criaSX1(cPerg)

putSx1(cPerg, '01', 'Produto de?'          , '', '', 'mv_ch1', 'C', 10, 0, 0, 'G', '', 'SB1', '', '', 'mv_par01')
putSx1(cPerg, '02', 'Produto até?'         , '', '', 'mv_ch2', 'C', 10, 0, 0, 'G', '', 'SB1', '', '', 'mv_par02')
putSx1(cPerg, '03', 'Dt. Match BOMI'         , '', '', 'mv_ch2', 'D', 8, 0, 0, 'G', '', '', '', '', 'mv_par03')


Return
*/
