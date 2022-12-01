#include 'protheus.ch'

USER FUNCTION FCFGV001(lEndereco)
   Local aArea       := GetArea()
    Local cCampo      := ReadVar()
    Local cConteudo   := &(cCampo)
    Local nTamOrig    := Len(cConteudo)
    Local cRet        := ""
    Local nI          := 0
    Default lEndereco := .F.
    
     
    //Retirando caracteres
    cConteudo := StrTran(cConteudo, "'", "")
    cConteudo := StrTran(cConteudo, "#", "")
    cConteudo := StrTran(cConteudo, "%", "")
    cConteudo := StrTran(cConteudo, "*", "")
    cConteudo := StrTran(cConteudo, "&", "E")
    cConteudo := StrTran(cConteudo, ">", "")
    cConteudo := StrTran(cConteudo, "<", "")
    cConteudo := StrTran(cConteudo, "!", "")
    cConteudo := StrTran(cConteudo, "@", "")
    cConteudo := StrTran(cConteudo, "$", "")
    //cConteudo := StrTran(cConteudo, "(", "")
    //cConteudo := StrTran(cConteudo, ")", "")
    cConteudo := StrTran(cConteudo, "_", "")
    cConteudo := StrTran(cConteudo, "=", "")
    cConteudo := StrTran(cConteudo, "+", "")
    cConteudo := StrTran(cConteudo, "{", "")
    cConteudo := StrTran(cConteudo, "}", "")
    cConteudo := StrTran(cConteudo, "[", "")
    cConteudo := StrTran(cConteudo, "]", "")
    //cConteudo := StrTran(cConteudo, "/", "")
    cConteudo := StrTran(cConteudo, "?", "")
    //cConteudo := StrTran(cConteudo, ".", "")
    //cConteudo := StrTran(cConteudo, "\", "")
    cConteudo := StrTran(cConteudo, "|", "")
    cConteudo := StrTran(cConteudo, ":", "")
    cConteudo := StrTran(cConteudo, ";", "")
    cConteudo := StrTran(cConteudo, '"', '')
    cConteudo := StrTran(cConteudo, '°', '')
    cConteudo := StrTran(cConteudo, '?', '')
    cConteudo := StrTran(cConteudo, '´', '')
    cConteudo := StrTran(cConteudo, '`', '')
    cConteudo := StrTran(cConteudo, '¨', '')
    cConteudo := StrTran(cConteudo, '¬', '')
    cConteudo := StrTran(cConteudo, '~', '')
    cConteudo := StrTran(cConteudo, '^', '')
     
    //Se n?o for endereço, retira também o - e a ,
    If !lEndereco
        //cConteudo := StrTran(cConteudo, ",", "")
        cConteudo := StrTran(cConteudo, "-", "")
    EndIf
     
    //Adicionando os espaços a direita
    cConteudo := Alltrim(cConteudo)
    cConteudo += Space(nTamOrig - Len(cConteudo))
     
    //Definindo o conte?do do campo
    &(cCampo+" := '"+cConteudo+"' ")

	cRet := FwNoAccent(cConteudo)
	_cEspCarc := "170;a#186;o#176;o"
	
	If ";" $ _cEspCarc .And. "#" $ _cEspCarc
		aMapCar := StrToKarr(_cEspCarc,"#")
		For nI:=1 to Len(aMapCar)
			aCaract := StrToKarr(aMapCar[nI],";")
			If Alltrim(Chr(Val(Alltrim(aCaract[1])))) $ cRet
				cRet := StrTran( cRet, Alltrim(Chr(Val(Alltrim(aCaract[1])))), Alltrim(aCaract[2]) )	
			EndIf
		Next nI
	EndIf

    &(cCampo+" := '"+cRet+"' ")
     
    RestArea(aArea)
RETURN .T.
