#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GFAT001  ³ Autor ³ gildesio campos  ³ Data ³26/12/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Esta rotina ira verificar no momento da confirmacao do campo³±±
±±³          ³Loja(C5_LOJA) do cliente se existe Inscricao Estadual.      ³±±
±±³          ³Para efetuar o calculo do Repasse de ICMS Conforme Resolucao³±±
±±³          ³RDC N.2 de 8 de novembro de 2002, Art.4. que regulamenta a  ³±±
±±³          ³Lei 10.213/2001.											  ³±±
±±³          ³------------------------------------------------------------³±±
±±³Descric.2 ³O percentual do Repasse varia conforme o Produto, em função ³±±
±±³          ³da aplicação da aliquota de 4% nas Op.Interestaduais, a par-³±±
±±³          ³tir de 01.01.2013-conf. Res.13/12 Senado Federal  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FERRING PHARMACEUTICALS                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/   
/*
-----------------------------------------------------------------------------
GATILHO: C6_PRODUTO - 005 - C6_XPCTREP - Calcula o preço de venda aplicando o 
         desconto do REPASSE conforme o Produto (Resol. 13/12 Senado Fed.)
-----------------------------------------------------------------------------*/
User Function GFAT001()
Local _nRet	:= 0
Local aArea	:= GetArea()     
Local cCliOut := GetMv("MV_XCODSAI",,"00021601")    
 
Local cCodProd  := aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})] 
Local nPosItem  := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_ITEM"})
Local nPosProd  := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_PRODUTO"})
Local nPosPrcVen:= aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_PRCVEN"})
Local nPosPrcTab:= aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_PRUNIT"})
Local nPValdesc := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_VALDESC"})
Local nPPercRep := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_XPCTREP"})

//Desconsidera a propria Ferring - NFs simbolicas
If SA1->A1_COD+SA1->A1_LOJA == cCliOut 
	Return(0)
EndIf

dbSelectArea("SA1") 
dbSetOrder(1)
dbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI)

dbSelectArea("SZ1")	// Cadastro de Repasse de ICMS
dbSetOrder(1)		// Z1_FILIAL+Z1_UF
dbSeek(xFilial("SZ1")+SA1->A1_EST)	

If SZ1->(!Found())
	If SA1->A1_EST <> "SP" 
		If !l410Auto
			GtAviso("Atenção","Nao Tem Cadastrado o Percentual de Repasse da UF do Cliente. UF: "+SA1->A1_EST+". Verifique.",{"Ok"} )
		EndIf
	EndIf	
	_nRet := 0
Else
	If !Eof() .And. !Empty(SA1->A1_INSCR); 
		.And. SA1->A1_INSCR <> "ISENTO";
		.And. SA1->A1_EST <> "SP" ;
		.And. SA1->A1_EST = SZ1->Z1_UF;
        .AND. AllTrim(SA1->A1__TIPO) <> "OP";  
     	.And. SA1->A1_CONTRIB <> '2'		


		If Substr(cCodProd,1,6) $ '50.001|50.009' .AND. ALLTRIM(cCodProd) <> "50.009.001"//DDAVP (todos) e GONAPEPTYL Depot/Daily
			_nRet := SZ1->Z1_REPASSE
 		Else                         
 		//CRIADO O IF PARA TRATAR A DESONERAÇÃO DO ICMS PARA O PRODUTO 50.009.001 GONAPEPTYL Depot/Daily CONFORME A SOLICITAÇÃO DO ERCIO 23/07/2014 //ALTERADO POR LEANDRO SILVA
 			If ALLTRIM(cCodProd) <> "50.009.001"
 			
 				_nRet := SZ1->Z1_PERCREP
 			Endif
 		EndIf	
   			M->C5_MENPAD :=	'006'   
   	Else
   		If !l410Auto
			GtAviso("Atenção","Nao Tem Cadastrado o Percentual de Repasse da UF do Cliente, Favor Cadastrar no Modulo de Faturamento--> Atualizações--> Cadastros--> Tabela de Repasse de ICMS!",{"Ok"} )
		EndIf
		M->C5_MENPAD :=	""

	
	EndIf
Endif
RestArea(aArea)   

Return(_nRet)


/**************************************************************************************************
Função:
GtAviso

Autor:
Tiago Bandeira Brasiliano

Data:
23/06/2015

Descrição:
Função de aviso customizado do gatilho, utilizada para inibir a informação caso o pedido de venda 
seja incluído via rotina automática.

Parâmetros:
cTitulo   => String contendo o título da tela.
cMensagem => Mensagem de aviso que será exibida na tela.
aButtons  => Array contendo os botões.

Retorno:
nRet      => Informa qual foi o botão selecionado.
**************************************************************************************************/
Static Function GtAviso(cTitulo, cMensagem, aButtons)

Local nRet     := 0
Local lRotAuto := Type("l410Auto") <> "U" .And. l410Auto

If !lRotAuto
	nRet := Aviso(cTitulo, cMensagem, aButtons)
EndIf 

Return nRet