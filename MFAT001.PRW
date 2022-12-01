#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
/**************************************************************************************************
Função:
MFAT001

Autor:
Marcelo Klopfer Leme - Farinelli Sistemas

Data:
14/11/2016

Descrição:
Tela para seleção de Notas Fiscais para Incineração.
Esta rotina é responsável por efetuar de maneira automática a transferência de produtos entre
armazéns.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
USER FUNCTION MFAT001()

PRIVATE cPerg    := "MFAT001"
PRIVATE nTotNota := 0
PRIVATE nTotQtd  := 0
PRIVATE aBrowse  := {}
PRIVATE aRegSD3  := {}

VALIDPERG(cPerg)
IF !PERGUNTE(cPerg,.T.)
	RETURN NIL
ENDIF

MsgMeter({|oMeter,oText,oDlgP,lEnd| MFAT01A(oMeter,oText,oDlgP,lEnd)}, "Gerando Relatório...", "Gerando Relatório...")

RETURN NIL


/**************************************************************************************************
Função:
MFAT01A

Autor:
Marcelo Klopfer Leme - Farinelli Sistemas

Data:
14/11/2016

Descrição:
Função principal de execução da rotina. Responsável por selecionar os dados de acordo com os
parâmetros informados pelo usuário.

Parâmetros:
oMeter => Referência do objeto de barra de progresso.
oText  => Referência do objeto de texto da barra de progresso.
oDlgP  => Referência da tela contendo a barrra de progresso.
lEnd   => Variável lógica que deve ser passada como referência para a função. É utilizada para
cancelar a execução da rotina

Retorno:
Nenhum
**************************************************************************************************/
STATIC FUNCTION MFAT01A(oMeter,oText,oDlgP,lEnd)

LOCAL cQuery    := ""
LOCAL nMeter    := 0
LOCAL nMeterTot := 0
local CTRANSF := ""
// Seleciona as notas fiscais Somente da Série "I"
private __LESTORNO := 0



CQUERY := " SELECT	D2_DOC, "+CHR(13)+CHR(10)
CQUERY += "			D2_SERIE, "+CHR(13)+CHR(10)
CQUERY += "			D2_EMISSAO, "+CHR(13)+CHR(10)
CQUERY += "			D2_CLIENTE, "+CHR(13)+CHR(10)
CQUERY += "			D2_LOJA, "+CHR(13)+CHR(10)
CQUERY += "			A1_NOME, "+CHR(13)+CHR(10)
CQUERY += "			CASE F4.F4_ESTOQUE 	WHEN 'S' 	THEN 'DIRETA' WHEN 'N' 	THEN 'INDIRETA' END TIPO,"+CHR(13)+CHR(10)
CQUERY += "			CASE D2_LOCAL 		WHEN '86' 	THEN 'DIRETA' WHEN '85' THEN 'INDIRETA' END TIPOARM "+CHR(13)+CHR(10)




CQUERY += " FROM "+RETSQLNAME("SD2")+" D2 "+CHR(13)+CHR(10)

__LESTORNO := iif(MV_PAR06==2, .T. , .F. )
CTRANSF := iif(__LESTORNO,"S","")

if __LESTORNO




    CQUERY += "		INNER JOIN "+RETSQLNAME("SF2")+" F2 ON F2.F2_FILIAL = '"+XFILIAL("SF2")+"' "+CHR(13)+CHR(10)
    CQUERY += "			AND F2.F2_DOC 		= D2.D2_DOC "+CHR(13)+CHR(10)
    CQUERY += "			AND F2.F2_SERIE 	= D2.D2_SERIE "+CHR(13)+CHR(10)
    CQUERY += "			AND F2.F2_CLIENTE	= D2.D2_CLIENTE "+CHR(13)+CHR(10)
    CQUERY += "			AND F2.F2_LOJA 		= D2.D2_LOJA "+CHR(13)+CHR(10)
    CQUERY += "			AND F2.F2_TRANSF 	= '"+CTRANSF+"' "+CHR(13)+CHR(10)
    CQUERY += "			AND F2.D_E_L_E_T_	= '' "+CHR(13)+CHR(10)	
ENDIF
CQUERY += "		INNER JOIN "+RETSQLNAME("SF4")+" F4 ON F4.F4_FILIAL = '"+XFILIAL("SF4")+"' "+CHR(13)+CHR(10)
CQUERY += "			AND F4.F4_CODIGO = D2.D2_TES "+CHR(13)+CHR(10)


if MV_PAR05==1
    CQUERY += "			AND F4.F4_ESTOQUE = 'S' "+CHR(13)+CHR(10)
elseif MV_PAR05==2
    CQUERY += "			AND F4.F4_ESTOQUE = 'N' "+CHR(13)+CHR(10)
endif
CQUERY += "				AND F4.D_E_L_E_T_ = '' "+CHR(13)+CHR(10)



CQUERY += "		INNER JOIN "+RETSQLNAME("SA1")+" A1 ON A1.A1_FILIAL = '"+XFILIAL("SA1")+"' "+CHR(13)+CHR(10)
CQUERY += "			AND A1.A1_COD 		= D2.D2_CLIENTE "+CHR(13)+CHR(10)
CQUERY += "			AND A1.A1_LOJA 		= D2.D2_LOJA "+CHR(13)+CHR(10)
CQUERY += "			AND A1.D_E_L_E_T_ 	= '' "+CHR(13)+CHR(10)
CQUERY += " WHERE 	D2.D2_FILIAL 		= '"+XFILIAL("SD2")+"' "+CHR(13)+CHR(10)
CQUERY += "			AND D2.D2_DOC 		>= '"+MV_PAR01+"' AND D2.D2_DOC <= '"+MV_PAR02+"' "+CHR(13)+CHR(10)
CQUERY += "			AND D2.D2_EMISSAO 	>= '"+dtos(MV_PAR03)+"' AND D2.D2_EMISSAO <= '"+dtos(MV_PAR04)+"' "+CHR(13)+CHR(10)
CQUERY += "			AND D2.D2_SERIE 	= 'I  ' "+CHR(13)+CHR(10)
CQUERY += "			AND D2.D2_LOCAL 	IN ('85','86') "+CHR(13)+CHR(10)
CQUERY += "			AND D2.D_E_L_E_T_ 	= '' "+CHR(13)+CHR(10)
cQuery += "GROUP BY D2_DOC,D2_SERIE,D2_EMISSAO,D2_CLIENTE,D2_LOJA,A1_NOME,F4_ESTOQUE,D2_LOCAL "
dbusearea( .T. ,"TOPCONN",TCGenQry(CQUERY),"TSD2", .F. , .T. )

DBSELECTAREA("TSD2")

// Define o tamanho do Contador da barra
Count To nMeterTot
oMeter:SetTotal(nMeterTot)
oMeter:Set(0)

TSD2->(DBGOTOP())
WHILE TSD2->(!EOF())
	
	// Incrementa o Contador da Barra
	oMeter:Set(++nMeter)
	
	AADD(aBrowse,{.F.,;
	TSD2->D2_DOC,;
	TSD2->D2_SERIE,;
	DTOC(STOD(TSD2->D2_EMISSAO)),;
	TSD2->D2_CLIENTE,;
	TSD2->D2_LOJA,;
	TSD2->A1_NOME,;
	TSD2->TIPO,;
	TSD2->TIPOARM,;
	.T.})
	
	TSD2->(DBSKIP())
	
ENDDO

TSD2->(DBCLOSEAREA())

IF LEN(aBrowse) > 0
	MFAT01B()
ELSE
	MSGALERT("Não foi possível encontrar notas fiscais!")
ENDIF

RETURN NIL


/**************************************************************************************************
Função:
MFAT01B

Autor:
Marcelo Klopfer Leme - Farinelli Sistemas

Data:
14/11/2016

Descrição:
Função responsável por montar o browse de acordo com estas informações obtidas na função MFAT01A.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
STATIC FUNCTION MFAT01B()

local OSIZE := NIL
local OPANELCAB := NIL
local OPANELGRID := NIL
local CIDCAB := ""
local CIDGRID := ""
local CTITLE := ""
local CCOLOR := ""

PRIVATE aTitles1     := {"Notas Fiscais para Incineração - Série I"}
PRIVATE aTitles2     := {"Ações"}
PRIVATE aPages       := {}
PRIVATE aPosGet1     := {}
PRIVATE oBrowse
PRIVATE oPanel1
PRIVATE oFolder1
PRIVATE oFolder2

PRIVATE oOk          := LoadBitmap( GetResources(), "LBOK" )
PRIVATE oNo          := LoadBitmap( GetResources(), "LBNO" )
PRIVATE oOk1         := LoadBitmap( GetResources(), "BR_VERDE" )
PRIVATE oNo1         := LoadBitmap( GetResources(), "BR_VERMELHO" )
PRIVATE oBtOK
PRIVATE oBtSair
PRIVATE oBtRegra
PRIVATE aColsEx      := {}
PRIVATE aHeaderEx    := {}
PRIVATE aFieldFill   := {}
PRIVATE aFields      := {}
PRIVATE aAlterFields := {}
PRIVATE nQtdLin      := 0

PRIVATE oCheckBox
PRIVATE lCheckBox    := .F.
private ARETRFAT001 := {}
PRIVATE oDirExp
PRIVATE cDirExp      := SPACE(100)
PRIVATE oBtDir
PRIVATE aVetAux      := {}



OSIZE := FWDEFSIZE():NEW( .F. )

OSIZE:ADDOBJECT("CABECALHO",OSIZE:AWINDSIZE[4],OSIZE:AWINDSIZE[3], .F. , .F. )
OSIZE:AMARGINS := {3,3,3,3}
OSIZE:LPROP :=  .F. 
OSIZE:PROCESS()



ODLG := MSDIALOG():NEW(OSIZE:AWINDSIZE[1],OSIZE:AWINDSIZE[2],OSIZE:AWINDSIZE[3],OSIZE:AWINDSIZE[4],OemToAnsi("Notas Fiscais para Incineração - Série I"),,, .F. ,nOr(268435456,2147483648),,,,OMAINWND, .T. ,,, .F. )



OTELA := FWFORMCONTAINER():NEW(ODLG)
CIDCAB := OTELA:CREATEHORIZONTALBOX(15)
CIDGRID := OTELA:CREATEHORIZONTALBOX(85)

OTELA:ACTIVATE(ODLG, .F. )


OPANELCAB := OTELA:GETPANEL(CIDCAB)
OPANELGRID := OTELA:GETPANEL(CIDGRID)



CTITLE := '<span style="color: #187bb6;"><strong>         NOTAS FISCAIS PARA INCINERAÇÃO - SÉRIE I     </strong></span>:</p>'

OSAY := TSAY():NEW(8,5,{ ||CTITLE},OPANELCAB,,,,,, .T. ,,,400,120,,,,,, .T. )

OCHECKBOX := TCHECKBOX():NEW(24,10,"Marcar/Desmarcar Todos",{ | U |iif(pcount()==0,LCHECKBOX,LCHECKBOX := U)},OPANELCAB,110,8,,{ ||iif(LCHECKBOX,MARCA(LCHECKBOX),MARCA(LCHECKBOX))},,,,, .F. , .T. ,, .F. ,)


CBUTTON := iif(__LESTORNO,"Estornar","Confirmar")

ODIREXP := TGET():NEW(24,110,{ | U |iif(pcount()==0,CDIREXP,CDIREXP := U)},OPANELCAB,98,10,,,,,, .F. ,, .T. ,, .F. ,, .F. , .F. ,, .F. , .F. ,,"cDirExp",,,,)
OBTDIR := TBUTTON():NEW(24,210,"Dir...",OPANELCAB,{ ||MFAT01E()},40,12,,, .F. , .T. , .F. ,, .F. ,,, .F. )
OBTOK := TBUTTON():NEW(24,310,CBUTTON,OPANELCAB,{ ||iif(MFAT01D(__LESTORNO),ODLG:END(),"")},73,15,,, .F. , .T. , .F. ,, .F. ,,, .F. )
OBTSAIR := TBUTTON():NEW(24,410,"X - Fechar",OPANELCAB,{ ||ODLG:END()},73,15,,, .F. , .T. , .F. ,, .F. ,,, .F. )











CCOLOR := iif(__LESTORNO,"#fc5429","#2891CC")




















CCSSBUTTON := "QPushButton { font-weight: bold; "+"    font-family: Arial; "+"    font-size: 11px; "+"    color: #FFFFFF; "+"    background-color: "+CCOLOR+"; "+"    padding: 2px; "+"    border-radius: 3px; "+"    border-style:solid; "+"    border-width: 1px; "+"    border-color: #01669F }"+"QPushButton:disabled {	font-weight: bold; "+"    font-family: Arial; "+"    font-size: 11px; "+"    color: #FFFFFF; "+"    background: #777878; "+"    padding: 2px; "+"    border-radius: 3px; "+"    border-style:solid; "+"    border-width: 1px; "+"    border-color: #5A6163 }"
OBTOK:SETCSS(CCSSBUTTON)
OBTSAIR:SETCSS(CCSSBUTTON)

ODIREXP:SETCSS("QPushButton { background: #35ACCA; border: 1px solid #096A82;outline:0; border-radius: 5px; font: normal 10px Arial; padding: 6px;color: #ffffff;} QPushButton:pressed {background-color: #3AAECB;border-style: inset; border-color: #35ACCA; color: #ffffff; }")



















OBTDIR:SETCSS("QPushButton { font: bold; "+"    color: #FFFFFF; "+"    border-image: url(rpo:fwstd_btn_focal.png) 3 3 3 3 stretch; "+"    border-top-width: 3px; "+"    border-left-width: 3px; "+"    border-right-width: 3px; "+"    border-bottom-width: 3px }"+"QPushButton:pressed {	color: #FFFFFF; "+"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+"    border-top-width: 3px; "+"    border-left-width: 3px; "+"    border-right-width: 3px; "+"    border-bottom-width: 3px }"+"QPushButton:disabled {	color: #FFFFFF; "+"    border-image: url(rpo:fwstd_btn_focal_dld.png) 3 3 3 3 stretch; "+"    border-top-width: 3px; "+"    border-left-width: 3px; "+"    border-right-width: 3px; "+"    border-bottom-width: 3px }")






OBROWSE := TWBROWSE():NEW(0,0,0,0,,{"","Status","Nota Fiscal","Série","Emissão","Cliente","Loja","Nome","Tipo","TipoArm"},{10,50,20,50,50,20,250,50},OPANELGRID,,,,,{ ||},,,,,,, .F. ,, .T. ,, .F. ,,,)

OBROWSE:ALIGN := 5
oBrowse:SetArray(aBrowse)
OBROWSE:ADDCOLUMN(TCCOLUMN():NEW("",{ ||iif(ABROWSE[OBROWSE:NAT][1],OOK,ONO)},"",,,"CENTER",10, .T. , .T. ,,,, .F. ,))
OBROWSE:ADDCOLUMN(TCCOLUMN():NEW("Status     ",{ ||iif(ABROWSE[OBROWSE:NAT][2],OOK1,ONO1)},"",,,"CENTER",10, .T. , .T. ,,,, .F. ,))
OBROWSE:ADDCOLUMN(TCCOLUMN():NEW("Nota Fiscal",{ ||ABROWSE[OBROWSE:NAT][3]},"@!",,,"LEFTH",50, .F. , .T. ,,,, .F. ,))
OBROWSE:ADDCOLUMN(TCCOLUMN():NEW("Série      ",{ ||ABROWSE[OBROWSE:NAT][4]},"@!",,,"LEFTH",20, .F. , .T. ,,,, .F. ,))
OBROWSE:ADDCOLUMN(TCCOLUMN():NEW("Emissão    ",{ ||ABROWSE[OBROWSE:NAT][5]},"",,,"CENTER",50, .F. , .T. ,,,, .F. ,))
OBROWSE:ADDCOLUMN(TCCOLUMN():NEW("Cliente    ",{ ||ABROWSE[OBROWSE:NAT][6]},"@!",,,"LEFTH",50, .F. , .T. ,,,, .F. ,))
OBROWSE:ADDCOLUMN(TCCOLUMN():NEW("Loja       ",{ ||ABROWSE[OBROWSE:NAT][7]},"@!",,,"LEFTH",50, .F. , .T. ,,,, .F. ,))
OBROWSE:ADDCOLUMN(TCCOLUMN():NEW("Nome       ",{ ||ABROWSE[OBROWSE:NAT][8]},"@!",,,"LEFTH",250, .F. , .T. ,,,, .F. ,))
OBROWSE:ADDCOLUMN(TCCOLUMN():NEW("Tipo       ",{ ||ABROWSE[OBROWSE:NAT][9]},"@!",,,"LEFTH",50, .F. , .T. ,,,, .T. ,))
OBROWSE:ADDCOLUMN(TCCOLUMN():NEW("TipoArm    ",{ ||ABROWSE[OBROWSE:NAT][10]},"@!",,,"LEFTH",50, .F. , .T. ,,,, .T. ,))

// Troca a imagem no duplo click do mouse
oBrowse:bLDblClick := {|| aBrowse[oBrowse:nAt][1] := !aBrowse[oBrowse:nAt][1]}

// Folder2





//DEFINE SBUTTON oBtDir FROM 010,415 TYPE 17 OF oFolder2:aDialogs[1] ACTION(MFAT01E()) ENABLE

ACTIVATE MSDIALOG oDlg CENTERED

RETURN NIL


/**************************************************************************************************
Função:
MFAT01D

Autor:
Marcelo Klopfer Leme - Farinelli Sistemas

Data:
14/11/2016

Descrição:
Efetua a impressão do relatório de declaração de transferência para incineração e formata os dados
para transferência.

Parâmetros:
Nenhum

Retorno:
lRet => Indica se a rotina prosseguiu corretamente (.T.) ou não (.F.).
**************************************************************************************************/
STATIC FUNCTION MFAT01D(__LESTORNO)
local LRET :=  .T. 
local NSALDO := 0
local ASEMSALDO := {}
local CSTRING := ""
local CSC6FILTER := ""
local CALIASSB8 := ""
local NX := 0
local NY := 0
local LBUSCASB8 :=  .F. 
local CMESSAGE := ""
local LCONTINUE :=  .T.

	
LCONTINUE := iif(__LESTORNO, .T. ,iif(.not. (empty(CDIREXP)), .T. , .F. ))

if LCONTINUE

    if __LESTORNO
        CMESSAGE := "Atenção, Deseja efetuar o estorno das transferências de incineração?"+CHR(13)+CHR(10)+""+CHR(13)+CHR(10)
        CMESSAGE += "Atenção - Os produtos das notas fiscais do tipo INDIRETA "+CHR(13)+CHR(10)+""+CHR(13)+CHR(10)
        CMESSAGE += "serão transferidos do Armazêm Origem 87 para 85 ou Origem 92 para 86."
    else 
        CMESSAGE := "Atenção, Imprimir declarações para incineração?"+CHR(13)+CHR(10)+""+CHR(13)+CHR(10)
        CMESSAGE += "Atenção - Os produtos das notas fiscais do tipo INDIRETA "+CHR(13)+CHR(10)+""+CHR(13)+CHR(10)
        CMESSAGE += "serão transferidos do seu Armazêm atual para o Armazêm Origem 85 para 87 ou Origem 86 para 92."
    endif


    if iif(FindFunction("MsgYesNo"),MSGYESNO(CMESSAGE,"Atenção"),(CMSGYESNO := "MsgYesNo", &CMSGYESNO.(CMESSAGE,"Atenção")))

        for NX := 1 to ( len(ABROWSE)) step 1


            if ABROWSE[NX][1]= .T. 


                if ABROWSE[NX][9]="DIRETA"			
					U_RFAT001(aBrowse,cDirExp)
				ELSE
					
					ASEMSALDO := {}
					
                    CQUERY := " SELECT D2_FILIAL,D2_ITEM,D2_DOC,D2_COD,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_LOCAL,D2_QUANT,D2_LOTECTL,D2__LOTBOM,D2_ITEMPV "
                    CQUERY += " FROM "+RETSQLNAME("SD2")+" D2 "
                    CQUERY += " WHERE 	D2.D2_FILIAL 	= '"+XFILIAL("SD2")+"' AND "
                    CQUERY += "			D2.D2_DOC 		= '"+ABROWSE[NX][3]+"' AND "
                    CQUERY += "			D2.D2_SERIE 	= 'I  ' AND "
                    CQUERY += "			D2.D_E_L_E_T_ 	= ''"
                    CQUERY += " ORDER BY D2_ITEM,D2_COD,D2_LOCAL,D2_QUANT "

                    dbusearea( .T. ,"TOPCONN",TCGenQry(CQUERY),"TSD2", .F. , .T. )

                   while (TSD2)->(.not. (eof())) 
                        dbselectarea("SB1")
                        (SB1)->(dbsetorder(1))
                        if (SB1)->(MSSEEK(XFILIAL("SB1")+TSD2->D2_COD))
                            if (SB1->B1_RASTRO) $ ("L/S")

                                CSC6FILTER := ""
                                CSC6FILTER += " SC6->C6_FILIAL 	    = '"+TSD2->D2_FILIAL+"'"
                                CSC6FILTER += " .AND. SC6->C6_NOTA  = '"+TSD2->D2_DOC+"'"
                                CSC6FILTER += " .AND. SC6->C6_SERIE = '"+TSD2->D2_SERIE+"'"

                                CSC6FILTER += " .AND. SC6->C6_ITEM  = '"+TSD2->D2_ITEMPV+"'"
                                CSC6FILTER += " .AND. SC6->C6_CLI   = '"+TSD2->D2_CLIENTE+"'"
                                CSC6FILTER += " .AND. SC6->C6_LOJA  = '"+TSD2->D2_LOJA+"'"
                                CSC6FILTER += " .AND. SC6->C6_LOCAL  = '"+TSD2->D2_LOCAL+"'"
                                CSC6FILTER += " .AND. SC6->C6_PRODUTO  = '"+TSD2->D2_COD+"'"
                                CSC6FILTER += " .AND. SC6->C6__LOTBOM  = '"+TSD2->D2__LOTBOM+"'"
                                //(SC6)->(dbsetfilter({ ||&CSC6FILTER}CSC6FILTER))
                                (SC6)->(dbgotop())


                                LBUSCASB8 :=  .F. 


                               while .not. ((SC6)->(eof()))

                                    CQUERY := " SELECT "
                                    CQUERY += "   SUM(B8_SALDO) B8_SALDO "
                                    CQUERY += " FROM "
                                    CQUERY += "        "+RETSQLNAME("SB8")+" SB8 "
                                    CQUERY += " WHERE "
                                    CQUERY += "        B8_FILIAL  			= '"+FWXFILIAL("SB8")+"' "
                                    CQUERY += "        AND B8_PRODUTO 		= '"+SC6->C6_PRODUTO+"'"
                                    CQUERY += "        AND B8_LOCAL 		= '"+SC6->C6_LOCAL+"'"
                                    CQUERY += "        AND B8_LOTECTL 		= '"+SC6->C6__LOTBOM+"'"
                                    CQUERY += "        AND SB8.D_E_L_E_T_ 	= ' ' "

                                    LBUSCASB8 :=  .T. 
                                    (SC6)->(dbskip())
                                    
                                    endDo

                                (SC6)->(dbclearfilter())

                                if LBUSCASB8

                                    CALIASSB8 := MPSYSOPENQUERY(CHANGEQUERY(CQUERY))					
						nSaldo := 0
						
					while .not. ((CALIASSB8)->(eof())) 

                                        NSALDO += CALIASSB8->B8_SALDO

                                        (CALIASSB8)->(dbskip())
                                        
                                        endDo



                                    (CALIASSB8)->(dbclosearea())
                                endif





                                if TSD2->D2_QUANT>NSALDO
                                    aadd(ASEMSALDO,{TSD2->D2_ITEM,TSD2->D2_COD,TSD2->D2_LOCAL,TSD2->D2_QUANT,NSALDO})
                                endif
                            else 
                                NSALDO := 0
                                (SB2)->(dbsetorder(1))
                                if (SB2)->(dbseek(XFILIAL("SB2")+TSD2->D2_COD+TSD2->D2_LOCAL))
						
						
							nSaldo := SaldoSb2()
							if TSD2->D2_QUANT>NSALDO
								aadd(ASEMSALDO,{TSD2->D2_ITEM,TSD2->D2_COD,TSD2->D2_LOCAL,TSD2->D2_QUANT,NSALDO})
							ENDIF
						ENDIF
					ENDIF
				ENDIF
						TSD2->(DBSKIP())
					ENDDO
					TSD2->(DBCLOSEAREA())
					if  len(ASEMSALDO)=0
						aVetAux  := {}
						aadd(AVETAUX,{ABROWSE[NX][1],ABROWSE[NX][3],ABROWSE[NX][4],ABROWSE[NX][5],ABROWSE[NX][6],ABROWSE[NX][7],ABROWSE[NX][8],ABROWSE[NX][9],ABROWSE[NX][10]})
						
						IF LEN(aVetAux) > 0
							ARETRFAT001 := U_RFAT001(AVETAUX,CDIREXP)
							MFAT01F()
						ENDIF
					ELSE
						CSTRING := "Nota número: "+ABROWSE[NX][3]+" Série: I"+CHR(13)+CHR(10)
						
						CSTRING += "It.NF - Produto - Armazém - Qtd. Transferência - Saldo em Estoque"+CHR(13)+CHR(10)
						for NY := 1 to ( len(ASEMSALDO)) step 1
							
							
							CSTRING += ASEMSALDO[NY][1]+"   - "+ASEMSALDO[NY][2]+" - "+ASEMSALDO[NY][3]+" - "+transform(ASEMSALDO[NY][4],"@E 99,999,999,999.99")+" - "+transform(ASEMSALDO[NY][5],"@E 99,999,999,999.99")+CHR(13)+CHR(10)
						NEXT
						AVISO("Transferência para Incineração",CSTRING,{"Ok"},3,"Nota com itens sem saldo em estoque",,"ENGRENAGEM", .F. )
					ENDIF
				ENDIF
			ENDIF
		NEXT
	ELSE
		lRet := .F.
	ENDIF
ELSE
	MSGALERT("Informe um diretório de Destino!")
	lRet := .F.
ENDIF
RETURN(lRet)


/**************************************************************************************************
Função:
MFAT01E

Autor:
Marcelo Klopfer Leme - Farinelli Sistemas

Data:
14/11/2016

Descrição:
Abre a tela de definição do diretório para exportação em PDF do relatório.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
STATIC FUNCTION MFAT01E()



cDirExp := cGetFile(cDirExp,"*.PDF",,,,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)
oDirExp:Refresh()

RETURN NIL


/**************************************************************************************************
Função:
MFAT01F

Autor:
Marcelo Klopfer Leme - Farinelli Sistemas

Data:
14/11/2016

Descrição:
Função responsável por executar efetivamente a transferência do produto entre os armazéns.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
STATIC FUNCTION MFAT01F()
local CPRODUTO := ""
local CLOCALORI := ""
local CLOCALDEST := ""
local NQTDADE := 0
local CDOC := ""
local CLOTE := ""

local LRET :=  .T. 
local CLOCAL := ""
local DDTVALID := ""
local NDOC := GetMv("MV_MFAT001")
local N1 := 0
local N2 := 0
PRIVATE cCusMed := GETMV("MV_CUSMED")

// Verifica se existe o armazém 87 para todos os produtos
IF LEN(aVetAux) > 0
	
	for N1 := 1 to ( len(AVETAUX)) step 1
		
		if AVETAUX[N1][8]="INDIRETA"
			
			(SF2)->(dbsetorder(1))
			if (SF2)->(dbseek(XFILIAL("SF2")+AVETAUX[N1][2]+AVETAUX[N1][3]))
				
				if (SF2->F2_TRANSF<>"S") .or. (__LESTORNO)
					
					CLOCAL := iif(__LESTORNO,"85","87")

                    for N2 := 2 to ( len(ARETRFAT001[N1])) step 1
                        (SB2)->(dbsetorder(1))
                        if .not. ((SB2)->(dbseek(XFILIAL("SB2")+ARETRFAT001[N1][N2][1]+CLOCAL)))
                            CRIASB2(ARETRFAT001[N1][N2][1],CLOCAL)							
						ENDIF
					NEXT
					
					CLOCAL := iif(__LESTORNO,"86","92")
					//RODRIGO CRIA PRODUTO NO ARMAZEM 92 - RODRIGO 22/10/18     AVSYSTEM FERRING
					for N2 := 2 to ( len(ARETRFAT001[N1])) step 1
						(SB2)->(dbsetorder(1))
						if .not. ((SB2)->(dbseek(XFILIAL("SB2")+ARETRFAT001[N1][N2][1]+CLOCAL)))
							CRIASB2(ARETRFAT001[N1][N2][1],CLOCAL)
						ENDIF
					NEXT
					
					nDoc++
					cDoc	:= SF2->F2_DOC							
						
						
						for N2 := 2 to ( len(ARETRFAT001[N1])) step 1

                        CPRODUTO := ARETRFAT001[N1][N2][1]
                        CLOCALORI := ARETRFAT001[N1][N2][4]
                        NQTDDEST := ARETRFAT001[N1][N2][3]
                        CLOCALDEST := ""
                        NQTDADE := ARETRFAT001[N1][N2][3]
                        CLOTE := ARETRFAT001[N1][N2][2]


                        do case 
                        case CLOCALORI=="85"

                        CLOCALDEST := "87"

                        case CLOCALORI=="86"

                        CLOCALDEST := "92"
                        endcase


                        LRET := TRANSFERALMX(CPRODUTO,CLOCALORI,CLOCALDEST,NQTDADE,CDOC,CLOTE,DDTVALID,__LESTORNO)					
						
					
					NEXT
					
					//// Verifica se ocorreu tudo bem com a transferência.
					//// Grava na tabela SF2 que foi transferido
					if LRET
					
					
		
						(SF2)->(dbsetorder(1))
						if (SF2)->(dbseek(XFILIAL("SF2")+AVETAUX[N1][2]+AVETAUX[N1][3]))
							RECLOCK("SF2",.F.)
							SF2->F2_TRANSF := iif(__LESTORNO,"","S")
							MSUNLOCK()
							PUTMV("MV_MFAT001",nDoc)
						ENDIF
					ENDIF
				ENDIF
			ENDIF
		ENDIF
	NEXT
ENDIF

return LRET


/**************************************************************************************************
Função:
MARCA

Autor:
Marcelo Klopfer Leme - Farinelli Sistemas

Data:
14/11/2016

Descrição:
Rotina para Marcar/Desmarcar os itens do browse.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
STATIC FUNCTION MARCA(lMarca)

LOCAL nI := 0

for NI := 1 to ( len(ABROWSE)) step 1
	aBrowse[nI][1] := lMarca
NEXT nI

oBrowse:Refresh()

RETURN NIL


/**************************************************************************************************
Função:
VALIDPERG

Autor:
Marcelo Klopfer Leme - Farinelli Sistemas

Data:
14/11/2016

Descrição:
Valida as perguntas no arquivo SX1.

Parâmetros:
cPerg => Grupo de perguntas que será validado no SX1.

Retorno:
Nenhum
**************************************************************************************************/
STATIC FUNCTION VALIDPERG(cPerg)

LOCAL aAlias := Alias()
LOCAL aRegs  := {}
local LINSORUPD :=  .T. 
local NI,NJ := 0

DBSELECTAREA("SX1")
DBSETORDER(1)
cPerg := PADR(cPerg, 10)
AAdd(aRegs,{cPerg,"01","Nota Fiscal de  ?","","","MV_CH1","C",09,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AAdd(aRegs,{cPerg,"02","Nota Fiscal até ?","","","MV_CH2","C",09,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AAdd(aRegs,{cPerg,"03","Emissão de      ?","","","MV_CH3","D",08,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AAdd(aRegs,{cPerg,"04","Emissão até     ?","","","MV_CH4","D",08,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(AREGS,{CPERG,"05","Tp Movimentação ?","","","MV_CH5","N",1,0,0,"C","","MV_PAR05","Direta","Direta","Direta","","","Indireta","Indireta","Indireta","","","Ambas","Ambas","Ambas","","","","","","","","","","","","",""})
aadd(AREGS,{CPERG,"06","Operacao  ?		","","","MV_CH6","N",1,0,0,"C","","MV_PAR06","Normal","Normal","Normal","","","Estorno","Estorno","Estorno","","","","","","","","","","","","","","","","","",""})

for NI := 1 to ( len(AREGS)) step 1
	
	CREGISTRO := CPERG+AREGS[NI][2]
	LINSORUPD := (SX1)->(.not. (dbseek(CREGISTRO)))
		RECLOCK("SX1",LINSORUPD)
		for NJ := 1 to (fcount()) step 1
			if NJ<= len(AREGS[NI])
				fieldput(NJ,AREGS[NI][NJ])
			ENDIF
		NEXT nJ
		MsUnlock()
	
NEXT

DBSELECTAREA(aAlias)

RETURN NIL




static function TRANSFERALMX(CPRODUTO,CLOCALORI,CLOCALDEST,NQTDADE,CDOC,CLOTE,DDTVALID,__LESTORNO)

local CLOCALBKP := ""
local LRET :=  .F. 





if __LESTORNO
    CLOCALBKP := CLOCALORI
    CLOCALORI := CLOCALDEST
    CLOCALDEST := CLOCALBKP
endif

DDTVALID := ""
if RASTRO(CPRODUTO)
    (SB8)->(dbsetorder(3))
    (SB8)->(dbseek(XFILIAL("SB8")+CPRODUTO+CLOCALORI+CLOTE))
    DDTVALID := SB8->B8_DTVALID
endif




















LRET := A260PROCESSA(CPRODUTO,CLOCALORI,NQTDADE,CDOC,date(),NQTDADE,"",CLOTE,DDTVALID,"","",CPRODUTO,CLOCALDEST,"", .F. ,NIL,NIL,"MATA260",NIL,"",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,0,CLOTE,DDTVALID,NIL,NIL)
return LRET

