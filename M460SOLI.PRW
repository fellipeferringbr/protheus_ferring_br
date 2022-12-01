#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M460SOLI ºAutor  ³Walter Matsui       º Data ³  03/13/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada para ajuste no calculo de ICMS Substituicaoº±±
±±º          ³tributaria para MT (temporariamente)                        º±±
±±º          ³BOPS: CHAMADO TECNICO N.o SBZBLH                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ferring  //MATA461.PRX                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
/*
-----------------------------------------------------------------------------
**  ALTERAÇÕES NESSA ROTINA DEVERÃO SER FEITAS TAMBÉM NA ROTINA M410SOLI   **
----------------------------------------------------------------------------*/
User Function M460SOLI()
Local _aArea     := GetArea()
Local _nIcmsSoli := 0
Local _nBaseICMS := 0
Local _nMargIVA  := GetMv("MV_X_IVAST",,0) 
Local _nAliquota    := 0
Local _nVlrST       := 0
Local _nIcmsUnt     := 0     
Local _nVlrIcmsOper := 0
Local _cProd        := SC6->C6_PRODUTO

//+-------------------------------------------------------+
//| Salva e inicia função fiscal para obter impostos      |
//+-------------------------------------------------------+
MaFisSave()
MaFisEnd()
MaFisIni(SA1->A1_COD,;          // 1-Codigo Cliente/Fornecedor
	     SA1->A1_LOJA,;         // 2-Loja do Cliente/Fornecedor
	     "C",;                  // 3-C:Cliente , F:Fornecedor
	     "N",;                  // 4-Tipo da NF
	     SA1->A1_TIPO,;         // 5-Tipo do Cliente/Fornecedor
	     Nil,;                  // 6-Relacao de Impostos que suportados no arquivo
	     Nil,;                  // 7-Tipo de complemento
	     Nil,;                  // 8-Permite Incluir Impostos no Rodape .T./.F.
	     "SB1",;                // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
	     "MATA461")             // 10-Nome da rotina que esta utilizando a funcao    
	     
MaFisAdd(SC6->C6_PRODUTO,;  // 1-Codigo do Produto ( Obrigatorio )
         SC6->C6_TES,;      // 2-Codigo do TES ( Opcional )
         SC6->C6_QTDVEN,;   // 3-Quantidade ( Obrigatorio )
         SC6->C6_VALOR,;    // 4-Preco Unitario ( Obrigatorio )
         0,; //SC6->C6_VALDESC,; // 5-Valor do Desconto ( Opcional )
         ,;                 // 6-Numero da NF Original ( Devolucao/Benef )
         ,;                 // 7-Serie da NF Original ( Devolucao/Benef )
         0,;                // 8-RecNo da NF Original no arq SD1/SD2
         0,;                // 9-Valor do Frete do Item ( Opcional )
         0,;                // 10-Valor da Despesa do item ( Opcional )
         0,;                // 11-Valor do Seguro do item ( Opcional )
         0,;                // 12-Valor do Frete Autonomo ( Opcional )
         SC6->C6_VALOR,;         // 13-Valor da Mercadoria ( Obrigatorio )
         0,;                // 14-Valor da Embalagem ( Opiconal )
         0,;                // 15-RecNo do SB1
         0)                 // 16-RecNo do SF4
         	      
_nRet := {}  // O MATA460 vai calcular base e valor do solidário

_nBaseICMS    := SC6->C6_VALOR
_nVlrIcmsOper := MaFisRet(1, "IT_VALICM")     //C6__VALICM
_nAliquota    := MaFisRet(1, "IT_ALIQICM")

If SA1->A1_TIPO=="S" .And. SA1->A1_EST=="MT" .And. SF4->F4_INCSOL=="S"

		_nIcmsSoli := Round(_nBaseICMS * 0.15   ,2)
		_nBaseICMS := Round((_nVlrIcmsOper + _nIcmsSoli )/  0.17 ,2)
	
	_nRet := {_nBaseICMS, _nIcmsSoli }  // O MATA460 vai considerar a base e valor do solidário contidos neste retorno
	
Else
	_nRet := {}  // O MATA460 vai calcular base e valor do solidário
Endif

// Restaura a função fiscal
MaFisRestore()

RestArea(_aArea)

Return(_nRet)
