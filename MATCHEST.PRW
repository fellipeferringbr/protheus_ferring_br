#Include 'Protheus.ch'


/*BEGINDOC
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿝elat?rio Match de Estoque destinado ao Marketing
//Servir? para alimentar informa寤es para o software solicita豫o de campo
//Criado por Leandro Fini - Farinelli Sistemas
//Em 14/05/2015 - tratado no INC295742
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
//! Rotina para montagem dos dados do relat?rio.                                  !
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
//! Fun豫o para cria豫o da estrutura do relat?rio.                                                !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportDef(cAlias,cPerg)

local cTitle  := "Relat?rio Match de Estoque"
local cHelp   := "Permite gerar rela豫o de Match de Estoque."
local oReport
local oSection1

oReport := TReport():New('EXCLI',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)

//Primeira se豫o
oSection1 := TRSection():New(oReport,"Match de Estoque",{"SZ4"}) 

TRCell():New(oSection1,"Z4_PRODUTO", "SZ4", "Codigo Produto")
TRCell():New(oSection1,"B1_DESC", "SB1", "Descri豫o") 
TRCell():New(oSection1,"Z4_QTDE", "SZ4", "Quantidade") 


Return(oReport)
/*
//+-----------------------------------------------------------------------------------------------+
//! Fun豫o para cria豫o das perguntas (se n?o existirem)                                          !
//+-----------------------------------------------------------------------------------------------+
static function criaSX1(cPerg)

putSx1(cPerg, '01', 'Produto de?'          , '', '', 'mv_ch1', 'C', 10, 0, 0, 'G', '', 'SB1', '', '', 'mv_par01')
putSx1(cPerg, '02', 'Produto at??'         , '', '', 'mv_ch2', 'C', 10, 0, 0, 'G', '', 'SB1', '', '', 'mv_par02')
putSx1(cPerg, '03', 'Dt. Match BOMI'         , '', '', 'mv_ch2', 'D', 8, 0, 0, 'G', '', '', '', '', 'mv_par03')


Return
*/
