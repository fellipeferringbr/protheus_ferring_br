#include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IVENTARIO ºAutor  ³Leandro Duarte      º Data ³  03/16/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Roda o gerador de iventario da tabela sb8 Saldo por Lote   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P10                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Iventario()
Local cPerg	:= "IVENTARIO1"
Local nQtdd := 0
ValidPerg(cPerg) //cria grupo de perguntas para a impressao
if Pergunte(cPerg,.t.)
	nQtdd := BuscDad()
	Processa({|| RodExpt(nQtdd) })
endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg ºAutor  ³Leandro Duarte      º Data ³  03/16/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria as perguntas                                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P10                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidPerg(cPerg)

Local _sAlias	:= Alias()
Local aRegs		:= {}
Local nY, nX    := 0

SX1->( dbSetOrder(1) )
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05

Aadd(aRegs,{cPerg,"01","Periodo			    ",	"",	"",	"mv_ch1",	"D",	8					,	0,	0,	"G",	"",	"mv_par01",	"",  		"",	"",	"",	"",				"",  					"",	"",	"",	"",  		"",  					"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",		"","","",""	})
Aadd(aRegs,{cPerg,"02","Do Produto			",	"",	"",	"mv_ch2",	"C",	TamSx3('B1_COD')[1]	,	0,	0,	"G",	"",	"mv_par02",	"",  		"",	"",	"",	"",				"",  					"",	"",	"",	"",  		"",  					"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"SB1",		"","","",""	})
Aadd(aRegs,{cPerg,"03","Até Produto			",	"",	"",	"mv_ch3",	"C",	TamSx3('B1_COD')[1]	,	0,	0,	"G",	"",	"mv_par03",	"",  		"",	"",	"",	"",				"",  					"",	"",	"",	"",  		"",  					"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"SB1",			"","","",""	})
Aadd(aRegs,{cPerg,"04","Do almoxerifado		",	"",	"",	"mv_ch4",	"C",	2					,	0,	0,	"G",	"",	"mv_par04",	"",  		"",	"",	"",	"",				"",  					"",	"",	"",	"",  		"",  					"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",			"","","","@!"	})
Aadd(aRegs,{cPerg,"05","Até Almoxerifado   ",	"",	"",	"mv_ch5",	"C",	2					,	0,	0,	"G",	"",	"mv_par05",	"",  		"",	"",	"",	"",				"",  					"",	"",	"",	"",  		"",  					"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",			"","","","@!"	})
Aadd(aRegs,{cPerg,"06","Local\Nome Arquivo ",	"",	"",	"mv_ch6",	"C",	60					,	0,	0,	"G",	"",	"mv_par06",	"",  		"",	"",	"",	"",				"",  					"",	"",	"",	"",  		"",  					"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",	"",			"","","","@!"	})

For nX := 1 to Len(aRegs)
	If !SX1->(dbSeek(cPerg+aRegs[nX,2]))
		RecLock('SX1',.T.)
		For nY:=1 to FCount()
			If nY <= Len(aRegs[nX])
				SX1->(FieldPut(nY,aRegs[nX,nY]))
			Endif
		Next nY
		MsUnlock()
	Endif
Next nX


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BuscDad   ºAutor  ³Leandro Duarte      º Data ³  03/16/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca os dados na query conforme o documento                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P10                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BuscDad()
Local nQtd	:= 0
Local cQuery := ""
cQuery += " SELECT	'2354LE' AS COGNOS,B1_CODFERR, B1_DESFERR, ' ' AS FIXO1, ' ' AS FIXO2, '2031' AS FIXO3, SUM(B9_QINI) AS B9_QINI, "
cQuery += " 		'0' AS FIXO4, '0' AS FIXO5, SUM(B9_VINI1) AS B9_VINI1, ' ' AS FIXO6, ' ' AS FIXO7, ' ' AS FIXO8, B9_COD          "
cQuery += "   FROM "+RETSQLNAME("SB9")+" A, "+RETSQLNAME("SB1")+" B                                                                "
cQuery += "  WHERE A.B9_COD = B.B1_COD                                                                                              "
cQuery += "    AND A.B9_FILIAL = '"+XFILIAL("SB9")+"'                                                                                        "
cQuery += "    AND B.B1_FILIAL = '"+XFILIAL("SB1")+"'                                                                                        "
cQuery += "    AND A.D_E_L_E_T_ = ' '                                                                                        "
cQuery += "    AND B.D_E_L_E_T_ = ' '                                                                                        "
cQuery += "    AND A.B9_DATA = '"+dtos(mv_par01)+"'                                                                                       "
cQuery += "    AND A.B9_COD BETWEEN '"+mv_par02+"' AND '"+mv_par03+"'                                                               "
cQuery += "    AND A.B9_LOCAL BETWEEN '"+mv_par04+"' AND '"+mv_par05+"'                                                             "
cQuery += " GROUP BY B9_COD, B1_CODFERR, B1_DESFERR                                                                                  "
cQuery := ChangeQuery(cQuery)
iif(select("TRB_RT2")>0,TRB_RT2->(dbclosearea()),nil)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB_RT2", .F., .T.)
TRB_RT2->(dbeval({|| nQtd++ }))

Return(nQtd)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RodExpt   ºAutor  ³LEANDRO DUARTE      º Data ³  03/16/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³RODA O EXPORTADOR                                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P10                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RodExpt(ntot)
Local cArquivo := mv_par06
Local nHdl
Local cEOL    := "CHR(13)+CHR(10)"

IF EMPTY(cArquivo)
	AVISO('Arquivo Sem nome','Atenção o Arquivo esta sem nome Por favor informe o local e o seu nome!',{"Ok"})
	RETURN()
ENDIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processando o nome do arquivo caso esteja sem extenção³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if at('.',cArquivo)==0                      
	cArquivo:= cArquivo+'.csv'
endif

nHdl    := fCreate(cArquivo) 

If Empty(cEOL)
    cEOL := CHR(13)+CHR(10)
Else
    cEOL := Trim(cEOL)
    cEOL := &cEOL
Endif

If nHdl == -1
    MsgAlert("O arquivo de nome "+cArquivo+" nao pode ser executado! Verifique os parametros.","Atencao!")
    Return
Endif

TRB_RT2->(dbgotop()) 
ProcRegua(ntot) // Numero de registros a processar
WHILE TRB_RT2->(!EOF())
 	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Incrementa a regua                                                  ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    IncProc()

    //ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
    //º Lay-Out do arquivo Texto gerado:                                º
    //ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
    //ºCampo           ³ Inicio ³ Tamanho                               º
    //ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
    //º COGNOS         ³ 01     ³ 06                                    º
    //º ';'			   ³ 07     ³ 01                                    º
    //º B1_CODFERR     ³ 08     ³ 15                                    º
    //º ';'			   ³ 23     ³ 01                                    º
    //º B1_DESFERR     ³ 24     ³ 80                                    º
    //º ';'            ³ 104    ³ 01                                    º
    //º FIXO1          ³ 105    ³ 06                                    º
    //º ';'            ³ 111    ³ 01                                    º
    //º FIXO2          ³ 112    ³ 04                                    º
    //º ';'            ³ 116    ³ 01                                    º
    //º FIXO3          ³ 117    ³ 04                                    º
    //º ';'            ³ 121    ³ 01                                    º
    //º B9_QINI        ³ 122    ³ 14                                    º
    //º ';'            ³ 136    ³ 01                                    º
    //º FIXO4          ³ 137    ³ 01                                    º
    //º ';'            ³ 138    ³ 01                                    º
    //º FIXO5          ³ 139    ³ 01                                    º
    //º ';'            ³ 140    ³ 01                                    º
    //º B9_VINI1       ³ 141    ³ 14                                    º
    //º ';'            ³ 155    ³ 01                                    º
    //º FIXO6          ³ 156    ³ 01                                    º
    //º ';'            ³ 157    ³ 01                                    º
    //º FIXO7          ³ 158    ³ 01                                    º
    //º ';'            ³ 159    ³ 01                                    º
    //º FIXO8          ³ 160    ³ 01                                    º
    //ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

    nTamLin := 161
    cLin    := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Substitui nas respectivas posicioes na variavel cLin pelo conteudo  ³
    //³ dos campos segundo o Lay-Out. Utiliza a funcao STUFF insere uma     ³
    //³ string dentro de outra string.                                      ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    cCpo := PADR(TRB_RT2->COGNOS,06)    
    cCpo += PADR(';',01)
    cCpo += PADR(TRB_RT2->B1_CODFERR,15)
    cCpo += PADR(';',01)
    cCpo += PADR(TRB_RT2->B1_DESFERR,80)
    cCpo += PADR(';',01)
    cCpo += PADR(TRB_RT2->FIXO1,01)     
    cCpo += PADR(';',01)
    cCpo += PADR(TRB_RT2->FIXO2,01)
    cCpo += PADR(';',01)
    cCpo += PADR(TRB_RT2->FIXO3,04)
    cCpo += PADR(';',01)
    cCpo += PADR(TRB_RT2->B9_QINI,14)
    cCpo += PADR(';',01)
    cCpo += PADR(TRB_RT2->FIXO4,01)
    cCpo += PADR(';',01)
    cCpo += PADR(TRB_RT2->FIXO5,01)
    cCpo += PADR(';',01)
    cCpo += PADR(TRB_RT2->B9_VINI1,14)
    cCpo += PADR(';',01)
    cCpo += PADR(TRB_RT2->FIXO6,01)
    cCpo += PADR(';',01)
    cCpo += PADR(TRB_RT2->FIXO7,01)
    cCpo += PADR(';',01)
    cCpo += PADR(TRB_RT2->FIXO8,01)

    cLin := Stuff(cLin,01,161,cCpo)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Gravacao no arquivo texto. Testa por erros durante a gravacao da    ³
    //³ linha montada.                                                      ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
        If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
            Exit
        Endif
    Endif

    TRB_RT2->(dbSkip())
end
Aviso('Gravação','Gravação concluida, no local: '+cArquivo+CRLF+'Processados '+TRANSFORM(ntot,'@E 99,999,999,999,999')+' Registros',{'Ok'})
Return(.t.)
