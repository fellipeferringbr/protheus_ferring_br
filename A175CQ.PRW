#INCLUDE "PROTHEUS.CH"
/*/
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????Ŀ??
???Programa  A175CQ   ? Autor ? Renato Takao          ? Data ?08/05/2008???
?????????????????????????????????????????????????????????????????????????Ĵ??
???Descri??o ?Ponto de entrada gravacao baixas CQ            ???
???          ? para alimentar data de fabrica??o                                                           ???
?????????????????????????????????????????????????????????????????????????Ĵ??
???Retorno   ?Nenhum                                                      ???
?????????????????????????????????????????????????????????????????????????Ĵ??
???Parametros?Nenhum                                                      ???
???          ?                                                            ???
?????????????????????????????????????????????????????????????????????????Ĵ??
???   DATA   ? Programador   ?Manutencao efetuada                         ???
?????????????????????????????????????????????????????????????????????????Ĵ??
???          ?               ?                                            ???
??????????????????????????????????????????????????????????????????????????ٱ?
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
/*/

User Function A175CQ()

//query de update data de fabrica??o para lotes gravados no SB8 sem data de fabrica??o
tcsqlexec("UPDATE SB8010 SET B8_DTFABR = (SELECT MAX(SB82.B8_DTFABR) FROM SB8010 SB82 WHERE SB82.D_E_L_E_T_=SB8010.D_E_L_E_T_ AND SB82.B8_PRODUTO=SB8010.B8_PRODUTO AND SB82.B8_LOTECTL=SB8010.B8_LOTECTL AND SB82.B8_DTVALID=SB8010.B8_DTVALID AND SB82.B8_FILIAL=SB8010.B8_FILIAL) WHERE SB8010.D_E_L_E_T_=' ' AND SB8010.B8_DTFABR=' '")

return