#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M410SOLI ºAutor  ³Gildesio Campos     º Data ³  03/13/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±Este ponto de entrada retorna o valor do ICMS Solidario para ser 		   ±±
±±demonstrado na planilha financeira do pedido de vendas.				   ±±
±±																		   ±±
±±Para realizar todo o processo corretamente deve utilizar em conjunto com ±±
±±o ponto de entrada M460SOLI com o mesmo tratamento do ponto M410SOLI.    ±±
±±																	 	   ±±
±±Para que as informações do pedido de vendas e da nota fiscal de saída    ±±
±±fiquem iguais.														   ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ferring                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                   
/*
-----------------------------------------------------------------------------
**  ALTERAÇÕES NESSA ROTINA DEVERÃO SER FEITAS TAMBÉM NA ROTINA M460SOLI   **
----------------------------------------------------------------------------*/
User Function M410SOLI()
Local _aArea        := GetArea()
Local _nIcmsSoli    := 0
Local _nBaseICMS    := 0
Local _nMargIVA     := GetMv("MV_X_IVAST",,0)
Local _nAliquota    := 0
Local _nVlrST       := 0
Local _nIcmsUnt     := 0     
Local _nVlrIcmsOper := 0
Local _nItem        := ParamIXB[1]
Local _cProd        := GDFieldGet("C6_PRODUTO", _nItem)

Local _nPosQtdVen := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_QTDVEN" })
Local _nPosPrcVen := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_PRCVEN"})
Local _nPosValor  := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_VALOR"})
Local _nPosPrcTab := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_PRUNIT"})	//Preco Unitario de Tabela 

Local _nPosBCICMS := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6__BASICM"})	//BC ICMS OPERAÇÃO
Local _nPosValICM := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6__VALICM"})	//VALOR ICMS OPERAÇÃO
Local _nPosBCSOLI := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6__BASSOL"})	//BC ICMS RET    
Local _nPosValSol := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6__VALSOLM"})	//VALOR ICM RET    

dbSelectArea("SB1")
SB1->(dbSetOrder(1)) // FILIAL + CODIGO
SB1->(msSeek(xFilial("SB1") + _cProd))

_nRet := {}  
_nBaseICMS    := aCols[_nItem,_nPosValor]		//SC6->C6_VALOR    
_nVlrIcmsOper := MaFisRet(_nItem, "IT_VALICM")     //C6__VALICM
_nAliquota    := MaFisRet(_nItem, "IT_ALIQICM")

If SA1->A1_TIPO=="S" .And. SA1->A1_EST=="MT" .And. SF4->F4_INCSOL=="S"

		_nIcmsSoli := Round(_nBaseICMS * 0.15   ,2)
		_nBaseICMS := Round((_nVlrIcmsOper + _nIcmsSoli )/  0.17 ,2)
	
	_nRet := {_nBaseICMS, _nIcmsSoli }  
Else
	_nRet := {}  
Endif


RestArea(_aArea)                         

 Return(_nRet)
           