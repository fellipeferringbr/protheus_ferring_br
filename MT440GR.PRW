#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT440GR  ºAutor  ³Cleyton Leal        º Data ³   14/09/2013 º±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºDesc.     ³ Ponto de Entrada para validação de lotes usados na Liber.  º±±
±±º          ³ do pedido de vendas.     								  º±±
±±º          ³ Envio de e-mail para aprovadores							  º±±
±±º          ³ 						    								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ferring                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function MT440GR()


Local _lRet		:=.T.     
Local _nPCodig 	:= AScan( aHeader, { |x| AllTrim( x[2] ) == "C6_PRODUTO"} )
Local _nPQtLib 	:= AScan( aHeader, { |x| AllTrim( x[2] ) == "C6_QTDLIB"	} )
Local nx		:=0
Local _Rastro	:=""   
Local _cProd	:=""  
Local _cLote	:=""
Local _qtdProd	:=""   
Local _cLocal 	:=""
Local _cTes		:=""
Local _cEst		:=""                       


For nX := 1 to Len (acols)

	_cProd		:=aCols[nX][aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})] 
	_cLote		:=aCols[nX][aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOTECTL"})] 
	_qtdProd	:=aCols[nX][aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})]
	_cLocal		:=aCols[nX][aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})] 
	_cTes		:=aCols[nX][aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})]  
	


	DbSelectarea('SF4')
	DbSetOrder(1) //
	DbSeek(xFilial('SF4')+_cTes)   
	
	_cEst	:= SF4->F4_ESTOQUE
	
	If _cEst <> "S"
		Return(_lRet)
	EndIf
	
		
	
	DbSelectarea('SB1')
	DbSetOrder(1) //B1_FILIAL+B1_COD
	DbSeek(xFilial('SB1')+_cProd)
	
	_Rastro		:= SB1->B1_RASTRO
	
	
	/*--- Verifica se o Lote foi informado ---*/
	If empty(alltrim(_cLote)).OR."INDEF"$_cLote 
		If _Rastro $ ('L|S')
			MsgAlert("Atenção: Produtos rastreados. Numero do Lote não foi informado. Faça Liberação novamente.")
			_lRet := .F. 
		EndIf
	EndIf
		
Next Nx           

Return(_lRet)
