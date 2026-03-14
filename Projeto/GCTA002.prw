#include 'totvs.ch'
#include'tbiconn.ch'

/*/{Protheus.doc} U_GCTA002M
    
    'Cadastro de contratos - Prototipo Modelo 3'
    @type Tela MVC Modelo 3 Advpl Tradicional
    @author Dario Leandro
    @since 19/02/2026

    @see https://tdn.totvs.com/pages/viewpage.action?pageId=24346981 (mBrowse   )
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=23889143 (axPesqui  )
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=23889145 (axVisual  )
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=23889141 (axInclui  )
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=23889132 (axAltera  )
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=23889138 (axDeleta  )
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=23889136 (axCadastro)
    /*/

Function U_GCTA002

	Private cTitulo := 'Cadastro de contratos - Prototipo Modelo 3'
	Private aRotina [0]

	//-- Montagem do array de itens de menu
	aadd(aRotina,{"Pesquisar" ,"axPesqui"    ,0,1})
	aadd(aRotina,{"Visualizar","U_GCTA002M"  ,0,2})
	aadd(aRotina,{"Incluir"   ,"U_GCTA002M"  ,0,3})
	aadd(aRotina,{"Alterar"   ,"U_GCTA002M"  ,0,4})
	aadd(aRotina,{"Excluir"   ,"U_GCTA002M"  ,0,5})

	Z51->(dbSetOrder(1),mBrowse(,,,,alias()))

Return

Function U_GCTA002M(cAlias,nReg,nOpc)

	Local oDlg,oGet
	Local aAdvSize    := msAdvSize()
	Local aInfo       := {aAdvSize[1],aAdvSize[2],aAdvSize[3],aAdvSize[4],3,3}
	Local aObj        := {{100,120,.T.,.F.},{100,100,.T.,.T.},{100,010,.T.,.F.}}
	Local aPObj       := msObjSize(aInfo,aObj)
	Local nStyle      := GD_INSERT+GD_UPDATE+GD_DELETE
	Local nSalvar     := 0
	Local bSalvar     := {||  if(obrigatorio(aGets,aTela),(nSalvar := 1, oDlg:end()),nil)}
	Local bCancelar   := {||  (nSalvar := 0, oDlg:end())}
	Local aButtons    := array(0)
	Local aHeader     := fnGetHeader()
	Local aCols       := fnGetCols(nOpc,aHeader)

	Private oGet
	Private aGets := array(0)
	Private aTela := array(0)



	oDlg           := tDialog():new( 0            ,;
		                             0            ,;
		                             aAdvSize[6]  ,;
		                             aAdvSize[5]  ,;
		                             cTitulo      ,;
		                             Nil          ,;
		                             Nil          ,;
		                             Nil          ,;
		                             Nil          ,;
		                             CLR_BLACK    ,;
		                             CLR_WHITE    ,;
		                             Nil          ,;
		                             NIl          ,;
		                             .T.           )

    /*for x := 1 To nCampos
        cCampo      := fieldname(x)
        xConteudo   := if(nOpc == 3,criavar(cCampo,.T.,.T.),fieldget(x))
        M->&(cCampo):= xConteudo
    Next*/ 

    //--enchoice(cAlias,nReg,nOpc,,,,,aPObj[1])

    //-- Montagem do Cabeçalho

    regToMemory(cAlias,if(nOpc == 3,.T.,.F.),.T.)
    M->Z51_NUMERO := IF(nOpc == 3, getSxeNum('Z51','Z51_NUMERO'),Z51->Z51_NUMERO)
    msmGet():new(cAlias,nReg,nOpc,,,,,aPObj[1])
    enchoicebar(oDlg,bSalvar,bCancelar,,aButtons)

    //-- Area de itens

    oGet  := msNewGetDados():new(aPObj[2,1]           ,;
                                 aPObj[2,2]           ,;
                                 aPObj[2,3]           ,;
                                 aPObj[2,4]           ,;
                                 nStyle               ,;
                                 'U_GCTA002V(1)'      ,;
                                 'U_GCTA002V(2)'      ,;
                                 '+Z52_ITEM'          ,;
                                 NIL                  ,;
                                 0                    ,;
                                 9999                 ,;
                                 'U_GCTA002V(3)'      ,;
                                 NIL                  ,;
                                 'U_GCTA002V(4)'      ,;
                                 oDlg                 ,;
                                 aHeader              ,;
                                 aCols      )

    oDlg:activate()

    //-- FUNCAO DE GRAVAR DADOS
    IF nSalvar = 1 
        fnGravar(nOpc,aHeader,oGet:aCols)

        IF __lSX8 
            confirmSX8()
        EndIF

    else
        
        IF __lSX8
            rollbackSX8()

        EndIF
            
      
    EndIF

Return 

/*/{Protheus.docn U_GCTA002V
    (long_description)
    @type  Function
/*/

Function U_GCTA002V(nOpcao)
    
    Local lValid  := .T.

    IF nOpcao == 1
        lValid := oGet:chkObrigat(n)
    elseif nOpcao  == 2     //--  VALIDACAO FINAL
    elseif nOpcao  == 3     // -- VALIDACAO DE CAMPOS
    elseif nOpcao  == 4     //--  VALIDACAO DE DELECAO DA LINHA
    EndIF


Return lValid

/*/{Protheus.doc} fnGravar()
    funcao auxiliar para gravar dados
    @type  Static Function
*/

Static Function fnGravar(nOpc,aHeader,aCols)

	Local x,y
	Local nCampos
	Local cCampo
	Local xConteudo
	Local aLinha[0]
	Local lDelete
	Local lFound

	BEGIN TRANSACTION

		DO CASE
		CASE nOpc == 3 //-- Inclusao

			nCampos := Z51->(fCount())

			//-- Gravacao dos dados do cabecalho
			Z51->(reclock(alias(),.T.))
			For x := 1 To nCampos
				Z51->&(fieldname(x)) := M->&(fieldname(x))
			Next
			Z51->Z51_FILIAL := xFilial('Z51')
			Z51->(msunlock())

			For x := 1 To Len(aCols)

				aLinha  := aClone(aCols[x])
				lDelete := aLinha[Len(aLinha)]

				IF lDelete
					Loop
				EndIF

				Z52->(reclock(alias(),.T.))
				For y := 1 To Len(aHeader)
					cCampo 			:= aHeader[y,2]
					xConteudo		:= aCols[x,y]
					Z52->&(cCampo) 	:= xConteudo
				Next

				Z52->Z52_FILIAL		:= xFilial('Z52')
				Z52->Z52_NUMERO		:= M->Z51_NUMERO
				Z52->(msunlock())

			Next

		CASE nOpc == 4 //-- ALTERACAO DOS DADOS

			nCampos := Z51->(fCount())

			//--POSICIONA NO REGISTRO
			Z51->(dbSetOrder(1),dbSeek(xFilial(alias())+M->Z51_NUMERO))

			//-- Gravacao dos dados do cabecalho
			Z51->(reclock(alias(),.F.))
			For x := 1 To nCampos
				Z51->&(fieldname(x)) := M->&(fieldname(x))
			Next
			Z51->Z51_FILIAL := xFilial('Z51')
			Z51->(msunlock())

			For x := 1 To Len(aCols)

				Z52->(dbSetOrder(1),dbSeek(xFilial(alias())+M->Z51_NUMERO+aCols[x,1]))

				lFound  := Z52->(Found())
				aLinha  := aClone(aCols[x])
				lDelete := aLinha[Len(aLinha)]

				IF lDelete
					IF lFound
						Z52->(reclock(alias(),.F.),dbDelete(),msunlock())

					EndIF

					Loop
				EndIF

				lInc := .not. lFound

				Z52->(reclock(alias(),lInc))
				For y := 1 To Len(aHeader)
					cCampo 			:= aHeader[y,2]
					xConteudo		:= aCols[x,y]
					Z52->&(cCampo) 	:= xConteudo
				Next

				Z52->Z52_FILIAL		:= xFilial('Z52')
				Z52->Z52_NUMERO		:= M->Z51_NUMERO
				Z52->(msunlock())

			Next
		CASE nOpc == 5

			Z52->(dbSetOrder(),dbSeek(xFilial(alias())+Z51->Z51_NUMERO))

			while .not. Z52->(eof()) .and. Z52->(Z52_FILIAL+Z52_NUMERO) == Z51->(Z51_FILIAL+Z51_NUMERO)

				Z52->(reclock(alias(),.F.), dbDelete(),msunlock(),dbSkip())

			Enddo

			Z51->(reclock(alias(),.F.),dbDelete(),msunlock() )

		END CASE

	END TRANSACTION

Return


/*/{Protheus.doc} fnGetHeader
    funcao que gera as configuracao dos campos da msNewGet Dados
    @type  Static Function
*/

Static Function fnGetHeader
   
    Local aHeader  := array(0)
    Local aAux     := array(0)

    SX3->(dbSetOrder(1),dbSeek("Z52"))

    while .not. SX3->(eof()) .and. SX3->X3_ARQUIVO == 'Z52'

        IF alltrim(SX3->X3_CAMPO) $ 'Z52_FILIAL|Z52_NUMERO'

            SX3->(dbSkip())
            Loop

        EndIF


        aAux := {} 
        aadd(aAux,SX3->X3_TITULO   )
        aadd(aAux,SX3->X3_CAMPO    )
        aadd(aAux,SX3->X3_PICTURE  )
        aadd(aAux,SX3->X3_TAMANHO  )
        aadd(aAux,SX3->X3_DECIMAL  )
        aadd(aAux,SX3->X3_VALID    )
        aadd(aAux,SX3->X3_USADO    )
        aadd(aAux,SX3->X3_TIPO     )
        aadd(aAux,SX3->X3_F3       )
        aadd(aAux,SX3->X3_CONTEXT  )
        aadd(aAux,SX3->X3_CBOX     )
        aadd(aAux,SX3->X3_RELACAO  )
        aadd(aAux,SX3->X3_WHEN     )
        aadd(aAux,SX3->X3_VISUAL   )
        aadd(aAux,SX3->X3_VLDUSER  )
        aadd(aAux,SX3->X3_PICTVAR  )
        aadd(aAux,SX3->X3_OBRIGAT  )

        aadd(aHeader,aAux)
        SX3->(dbSkip())
        
    Enddo

    

Return aHeader

/*/{Protheus.doc} fnGetCols
    RETORNO O CONTEUDO DO VETOR ACOLS
    @type  Static Function 
*/

Static Function fnGetCols(nOpc,aHeader)

        Local  aCols  := array(0)
        Local  aAux   := array(0)

        IF nOpc == 3 
            aEval(aHeader,{|x| aadd(aAux,criavar(x[2],.T.))})
            aAux[1] := '001'
            aadd(aAux,.F.)
            aadd(aCols,aAux)
            Return aCols
        EndIF

        //- ALTERAÇÃO + VISUALIZAÇÃO + EXCLUSÃO

        Z52->(dbSetOrder(1),dbSeek(Z51->Z51_FILIAL+Z51->Z51_NUMERO))

        while .not. Z52->(eof()) .and. Z52->(Z52_FILIAL+Z52_NUMERO) == Z51->(Z51_FILIAL+Z51_NUMERO)
            aAux  := {}
            aEval(aHeader,{|x| aadd(aAux,Z52->&(x[2]))})
            aadd(aAux,.F.)
            aadd(aCols,aAux)
            Z52->(dbSkip())
        Enddo

Return aCols
