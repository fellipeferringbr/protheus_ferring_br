#Include 'Protheus.ch'
 
User Function MT103CPO()
 
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//? Altera a forma padr?o de carregamento de campos dos itens da nota fiscal . ?
//? quando o c?digo do produto ? inserido. Correspondencia abaixo:                    ?
//? D1_CONTA    -> B1_CONTA                                                       ?
//? D1_CC       -> B1_CC                                                          ?
//? D1_ITEMCTA  -> B1_ITEMCC                                                      ?
//? D1_CLVL         -> B1_CLVL                                                        ?
//? D1_TES      -> B1_TE                                                          ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
 
Local aCpo:= PARAMIXB[1] //Padrao = D1_CONTA
 
AADD(aCpo,  "D1_CONTA"   ) // Faz com que seja mantido o conteudo pre-existente no campo

 
Return aCpo