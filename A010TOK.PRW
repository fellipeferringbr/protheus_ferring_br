#INCLUDE "RWMAKE.CH"

/*
	ExecBlock.......:	A010TOK
	Ponto...........:	Validacao da Inclusao/Alteracao do Produto
	Observações.....:	Verifica se o B1_CODBAR ou o B1_CODGTIN foi preenchido e o produto exige Cód. Barras
	Retorno Esperado: .T. ou .F.
*/	
/*
User Function A010TOK() 
Local lRet			:= .T.
Local cProdutos	:= AllTrim(GetMV("ES_CODBAR",.F.,"25/50"))
Local lExigeGtin	:= Left(M->B1_COD,2) $ cProdutos // Parâmetro para especificar os produtos que deverão exigir código GTIN

If lExigeGtin .and. (INCLUI .Or. ALTERA)
	
	If Empty( M->B1_CODBAR ) .and. Empty( M->B1_CODGTIN )
		lRet := .F.
		Help('',1,'A010TOK',,'O produto requer o preenchimento do campo Cod Barras, Cod. GTIN ou ambos.'+Chr(10)+Chr(10)+;
				'O Cod Barras é de uso interno/NFe e o Cod. GTIN é utilizado exclusivamente na NFe.'+Chr(10)+Chr(10)+;
				'Os produtos que exigem os códigos são '+cProdutos+' que estão listados no parâmetro ES_CODBAR. ',1,0)

	Endif
	
Endif

Return lRet
*/
User Function Item()
  Local aParam     := PARAMIXB
    Local xRet       := .T.
    Local oObj       := ''
    Local cIdPonto   := ''
    Local cIdModel   := ''
    
	
	
    If aParam <> NIL
        oObj       := aParam[1]
        cIdPonto   := aParam[2]
        cIdModel   := aParam[3]
         nOpera:=  oObj:nOperation //3 inclusa - 4 alteracao  - 5 exclusao
        If     cIdPonto == 'MODELPOS'
        ElseIf cIdPonto == 'FORMPOS'
        ElseIf cIdPonto == 'FORMLINEPRE'
        ElseIf cIdPonto == 'FORMLINEPOS'
        ElseIf cIdPonto == 'MODELCOMMITTTS'
                 cProdutos	:= AllTrim(GetMV("ES_CODBAR",.F.,"25/50"))
                 lExigeGtin	:= Left(M->B1_COD,2) $ cProdutos // Parâmetro para especificar os produtos que deverão exigir código GTIN

                If lExigeGtin .and. nOpera==3 .or. nOpera==4
                    
                    If Empty( M->B1_CODBAR ) .and. Empty( M->B1_CODGTIN )
                        xRet := .F.
                        Help('',1,'A010TOK',,'O produto requer o preenchimento do campo Cod Barras, Cod. GTIN ou ambos.'+Chr(10)+Chr(10)+;
                                'O Cod Barras é de uso interno/NFe e o Cod. GTIN é utilizado exclusivamente na NFe.'+Chr(10)+Chr(10)+;
                                'Os produtos que exigem os códigos são '+cProdutos+' que estão listados no parâmetro ES_CODBAR. ',1,0)

                    Endif
                    
                Endif
        ElseIf cIdPonto == 'MODELCOMMITNTTS'
        ElseIf cIdPonto == 'FORMCOMMITTTSPOS'
        ElseIf cIdPonto == 'MODELCANCEL'
        ElseIf cIdPonto == 'BUTTONBAR'
        EndIf
    EndIf

Return xRet
