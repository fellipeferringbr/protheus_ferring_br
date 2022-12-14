#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ?GTESAuto  ?Autor  ?Microsiga           ? Data ?  10/21/09   ???
?????????????????????????????????????????????????????????????????????????͹??
???Desc.     ? Gatilho do Codigo do produto do Pedido de Vendas.          ???
???          ? Retorna a TES                                              ???
???          ? C6_PRODUTO -> C6_TES                                       ???
???          ?                                                            ???
???          ?                                                            ???
?????????????????????????????????????????????????????????????????????????͹??
???Uso       ?                                                            ???
?????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/

User Function GTESAUTO()
Local _cTES := ""
Local _aAreaBKP
Local _cContrib ,_cOper, _cTpCli, _cEstado


_aAreaBKP := GetArea()

_nPosOper := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "C6_OPER"})
_nPosProd := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "C6_PRODUTO"})
_nPosTES  := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "C6_TES"})


_cTES     := aCols[n,_nPosTES]
_cContrib := ""
_cOper    := ""
_cTpCli   := ""
_cEstado  := ""

If !(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]$"01|01" .And. (FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2])$"01|03|05")
   Return(_cTES)
Endif

SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1")+aCols[n,_nPosProd]))

SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))

//// Alterado Marcelo Klopfer Leme - 21/01/2016
//// Para Clientes do Estado de GOIAS e produto PRICOPREP ( 50.017.001 )
IF SA1->A1_EST = "GO" .AND. ALLTRIM(aCols[n,_nPosProd]) = "50.017.001"
	_cTES :="554"
ELSE
	
	If Substr(SA1->A1__TIPO,1,2)=="OP" // Publico
		If Substr(SA1->A1_ATIVIDA,1,1)<>"2" // Publico
			GtAviso("Aten??o","No cadastro de clientes o campo Tipo de Cliente n?o est? condizente com o campo Atividade!",{"Ok"})
		Endif
		_lPublico := .T.
		_cPublico := "?org?o P?blico"
	Else                                // Privado
		If Substr(SA1->A1_ATIVIDA,1,1)=="2" // Publico
			GtAviso("Aten??o","No cadastro de clientes o campo Tipo de Cliente n?o est? condizente com o campo Atividade!",{"Ok"})
		Endif
		_lPublico := .F.
		_cPublico := "Empresa Privada"
	Endif
	
	If FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTCOB'})[1][2]==SA1->A1_EST
		_lDentroEst := .T.
		_cEstado := "Opera??o Dentro do Estado - "+SA1->A1_EST
	Else
		_lDentroEst := .F.
		_cEstado := "Opera??o Fora do Estado - "+SA1->A1_EST
	Endif
	
	If M->C5_TIPOCLI=="R"
		_cTpCli   := "Revenda"
	Elseif M->C5_TIPOCLI=="F"
		_cTpCli   := "Consumidor Final"
	Else
		_cTpCli   := "Solidario"
	Endif
	
	_cCR := Chr(13)+Chr(10)
	
	//???????????????????????????????????????????????????????????Ŀ
	//?Tipos de Opera?oes                                         ?
	//?????????????????????????????????????????????????????????????
	If aCols[n,_nPosOper] == "01"  // Venda Mercantil
		_cOper := "Opera??o de Venda"
		
		// Analisa a TES de sugestao.
		
		// Nao contribuinte
		//   If "ISENTO" $ SA1->A1_INSCR  .OR. Empty(SA1->A1_INSCR)  // Nao Contribuinte.
		If "ISENTO" $ SA1->A1_INSCR  .OR. Empty(SA1->A1_INSCR) .OR. SA1->A1_CONTRIB == "2"  // Nao Contribuinte. //GILDESIO 23/08/12
			_cContrib := "N?o Contribuinte I.E."
			// Substituicao Tributaria
		Else       // Contribuinte
			_cContrib := "Contribuinte I.E."
		Endif
		
		If _lPublico
			If M->C5__PERC>0  // Com convenio
				//_cTES :="502"                          // Orgao publico com convenio
				_cTES :="517"                          // Orgao publico com convenio
				_cPublico += " Conveniado"
			Else
				
				//// Alterado por Marcelo Klopfer Leme - 21/01/2015
				//// Varifica se e Consumidor Final M->C5_TIPOCLI = "F" e fora do estado
				IF M->C5_TIPOCLI = "F" .AND. FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTCOB'})[1][2]<>SA1->A1_EST
					_cTES :="528" // Orgao publico sem convenio
					_cPublico += " n?o Conveniado"
					
				ELSEIF M->C5_TIPOCLI = "F" .AND. FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTCOB'})[1][2]==SA1->A1_EST
					//_cTES :="501"                          // Orgao publico sem convenio
					_cTES :="516"                          // Orgao publico sem convenio
					_cPublico += " n?o Conveniado"
				ENDIF
			Endif
		Else
			//// Alterado por Marcelo Klopfer Leme - 21/01/2015
			//// Varifica se e Consumidor Final M->C5_TIPOCLI = "F" e fora do estado
			IF M->C5_TIPOCLI = "F" .AND. FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTCOB'})[1][2]<>SA1->A1_EST
				If ALLTRIM(SubStr(aCols[n,_nPosProd],1,10))== "50.009.001" //adicionado condi??o para que venda a Consumidor Final
					_cTES :="523"													//Gona Depot fora do estado, seja desonerado de ICMS
				Else
					_cTES :="528"
				Endif
			ELSE
				If M->C5_TIPOCLI=="S"  .AND. ALLTRIM(SubStr(aCols[n,_nPosProd],1,10))<>"50.009.001" .AND. ALLTRIM(SubStr(aCols[n,_nPosProd],1,10))<>"50.017.001"
					_cTES :="506"  // Privado com ICMS-ST
				ElseIf M->C5_TIPOCLI=="S"  .AND. ALLTRIM(SubStr(aCols[n,_nPosProd],1,10)) == "50.017.001" .AND. FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTCOB'})[1][2]==SA1->A1_EST
					_cTES :="506"   
				ElseIf M->C5_TIPOCLI=="S"  .AND. ALLTRIM(SubStr(aCols[n,_nPosProd],1,10)) == "50.017.001" .AND. FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTCOB'})[1][2]<>SA1->A1_EST
					_cTES :="535"                       
				ElseIf SubStr(aCols[n,_nPosProd],1,2)=="52" .AND. _lDentroEst == .T.  // BioGaia
					_cTES :="521"
				ElseIf SubStr(aCols[n,_nPosProd],1,2)=="52" .AND. _lDentroEst == .F.  // BioGaia
					_cTES :="520"
				ElseIf SubStr(aCols[n,_nPosProd],1,2)=="58" //Servi?os
					_cTES :="700"
				ElseIf ALLTRIM(SubStr(aCols[n,_nPosProd],1,10))=="50.009.001"
					_cTES :="523"
				ElseIf ALLTRIM(SubStr(aCols[n,_nPosProd],1,10))=="50.017.001" .AND. FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTCOB'})[1][2]<>SA1->A1_EST .AND. _cContrib == "Contribuinte I.E." .AND. M->C5_TIPOCLI<>"S"
					_cTES :="529"
				Else
					_cTES :="516"                         // Privado sem ICMS-ST
				Endif
			ENDIF
		Endif
		
		GtAviso("Resumo",_cOper + _cCr + _cPublico + _cCr +_cContrib + " - " +_cTpCli + _cCR + _cEstado +_cCR  ,{"Ok"} )
		
	ElseIf aCols[n,_nPosOper] == "02"  // Remessa para conserto
		
		_cOper := "Remessa para Conserto"
		_cTES :="541"
		GtAviso("Resumo",_cOper + _cCr + _cPublico + _cCr +_cContrib + " - " +_cTpCli + _cCR + _cEstado +_cCR  ,{"Ok"} )
		
	ElseIf aCols[n,_nPosOper] == "04"  // Remessa de Bonificacao Docaco ou Brindes
		
		//// Alterado por Marcelo Klopfer Leme - 21/01/2015
		//// Varifica se e Consumidor Final M->C5_TIPOCLI = "F" e fora do estado
		IF M->C5_TIPOCLI = "F" .AND. FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTCOB'})[1][2]<>SA1->A1_EST
			_cTES :="935"
		ELSE
			_cTES :="930"
		ENDIF
		
		_cOper := "Rem.Bonif.Doa?ao/Brindes"
		GtAviso("Resumo",_cOper + _cCr + _cPublico + _cCr +_cContrib + " - " +_cTpCli + _cCR + _cEstado +_cCR  ,{"Ok"} )
		
	ELSEIF aCols[n,_nPosOper] == "12"  // Amostra Gr?tis
		
		//// Alterado por Marcelo Klopfer Leme - 21/01/2015
		//// Varifica se e Consumidor Final M->C5_TIPOCLI = "F" e fora do estado
		IF M->C5_TIPOCLI = "F" .AND. FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTCOB'})[1][2]<>SA1->A1_EST
			_cTES :="558"
		ELSE
			_cTES :="531"
		ENDIF
		
		_cOper := "Amostra Gr?tis"
		GtAviso("Resumo",_cOper + _cCr + _cPublico + _cCr +_cContrib + " - " +_cTpCli + _cCR + _cEstado +_cCR  ,{"Ok"} )
		
	ELSEIF aCols[n,_nPosOper] == "13"  // Material Promocional
		
		//// Alterado por Marcelo Klopfer Leme - 21/01/2015
		//// Varifica se e Consumidor Final M->C5_TIPOCLI = "F" e fora do estado
		IF M->C5_TIPOCLI = "F" .AND. FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTCOB'})[1][2]<>SA1->A1_EST
			_cTES :="559"
		ELSE
			_cTES :="549"
		ENDIF
		
		_cOper := "Material Promocional"
		GtAviso("Resumo",_cOper + _cCr + _cPublico + _cCr +_cContrib + " - " +_cTpCli + _cCR + _cEstado +_cCR  ,{"Ok"} )
		
	ENDIF
	
	If Empty(M->C5_ESPECI1)
		GtAviso("Aten??o","Preencha o Campo Especie",{"Ok"} )
	Endif
	
ENDIF

RestArea(_aAreaBKP)
Return(_cTES)


/**************************************************************************************************
Fun??o:
GtAviso

Autor:
Tiago Bandeira Brasiliano

Data:
23/06/2015

Descri??o:
Fun??o de aviso customizada, utilizada para inibir a informa??o caso o pedido de venda seja inclu?do
via rotina autom?tica

Par?metros:
cTitulo   => String contendo o t?tulo da tela.
cMensagem => Mensagem de aviso que ser? exibida na tela.
aButtons  => Array contendo os bot?es.

Retorno:
nRet      => Informa qual foi o bot?o selecionado.
**************************************************************************************************/
Static Function GtAviso(cTitulo, cMensagem, aButtons)

Local nRet     := 0
Local lRotAuto := Type("l410Auto") <> "U" .And. l410Auto

If !lRotAuto
	nRet := Aviso(cTitulo, cMensagem, aButtons)
EndIf

Return nRet
