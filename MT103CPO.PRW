#Include 'Protheus.ch'
 
User Function MT103CPO()
 
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Altera a forma padrЦo de carregamento de campos dos itens da nota fiscal . Ё
//Ё quando o cСdigo do produto И inserido. Correspondencia abaixo:                    Ё
//Ё D1_CONTA    -> B1_CONTA                                                       Ё
//Ё D1_CC       -> B1_CC                                                          Ё
//Ё D1_ITEMCTA  -> B1_ITEMCC                                                      Ё
//Ё D1_CLVL         -> B1_CLVL                                                        Ё
//Ё D1_TES      -> B1_TE                                                          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
 
Local aCpo:= PARAMIXB[1] //Padrao = D1_CONTA
 
AADD(aCpo,  "D1_CONTA"   ) // Faz com que seja mantido o conteudo pre-existente no campo

 
Return aCpo