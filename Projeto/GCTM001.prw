#include 'totvs.ch'
#include 'fwmvcdef.ch'



/*/{Protheus.doc} U_GCTM001 
    (long_description)
    @type  Function
    @author user
    @since 25/02/2026
/*/


Function U_GCTM001

	Private aRotina         :=menudef()
	Private oBrowse         :=fwMBrowse():new()

	oBrowse:setAlias('Z50')
	oBrowse:setDescription('Tipos De Contratos')
	oBrowse:setExecuteDef(4)
	oBrowse:addLegend("Z50_TIPO == 'V' ", "BR_AMARELO","Vendas"       )
	oBrowse:addLegend("Z50_TIPO == 'C' ", "BR_LARANJA","Compras"      )
	oBrowse:addLegend("Z50_TIPO == 'S' ", "BR_CINZA","Sem Integracao" )
	oBrowse:activate()


Return

Static Function menudef

	Local aRotina := array(0)

	ADD OPTION aRotina TITLE 'Pesquisar'   ACTION 'axPesqui'         OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar'  ACTION 'VIEWDEF.GCTM001'  OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'     ACTION 'VIEWDEF.GCTM001'  OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'     ACTION 'VIEWDEF.GCTM001'  OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'     ACTION 'VIEWDEF.GCTM001'  OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'imprimir'    ACTION 'VIEWDEF.GCTM001'  OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'      ACTION 'VIEWDEF.GCTM001'  OPERATION 9 ACCESS 0


Return aRotina

Static Function viewdef

	Local oView
	Local oModel
	Local oStruct

	oStruct       := FWFormStruct(2,'Z50')
	oModel        := FWLoadModel('GCTM001')
	oView         := fWFormView():new()

	oView:setModel(oModel)
	oView:addField('Z50MASTER',oStruct,'Z50MASTER')
	oView:createHorizontalBox('BOXZ50',100)
	oView:setOwnerView('Z50MASTER','BOXZ50')

Return oView

Static Function modeldef

	Local oModel
	Local oStruct
	local aTrigger
	Local bModelPre := {|x| fnModPre(x)}
	Local bModelPos := {|x| fnModPos(x)}
	Local bCommit   := {|x| fnCommit(x)}
	lOCAL bCancel   := {|x| fnCancel(x)}

	oStruct         := FWFormStruct(1,'Z50')
	oModel          := mpFormModel():new('MODEL_GCTM001',bModelPre,bModelPos,bCommit,bCancel)

	aTrigger        := FwStruTrigger('Z50_TIPO', 'Z50_CODIGO','U_GCTT001()',.F.,Nil,Nil,Nil,Nil)

	oStruct:addTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])
	oStruct:setProperty('Z50_TIPO',MODEL_FIELD_WHEN,{||INCLUI})

	oModel:addFields('Z50MASTER',,oStruct)
	oModel:setDescription('Tipos De Contratos')
	oModel:setPrimarykey({'Z50_FILIAL','Z50_CODIGO'})

Return oModel

/*/{Protheus.doc} fnModPre
    (Funcao de pre validacao do modelo de dados)
    @type  Function
    /*/
Static function fnModPre(oModel)

	Local lValid      := .T.
    Local nOperation  := oModel:getOperation()
    Local cCampo      := strtran(readvar(), "M->","")

    If nOperation == 4 
        If cCampo == "Z50_DESCRI" 
           oModel:setErrorMessage('','','','','ERRO DE VALIDACAO', 'ESSE CAMPO NAO PODE SER EDITADO!')
           lValid := .F.
        EndIf

    EndIf

Return lValid

/*/{Protheus.doc} fnModPos
    (funcao de validação fina do modelo de dados , tudook)
    @type  Function
    /*/
Static function fnModPos(oModel)

	Local lValid          := .T.
	Local cAliasSQL       := ''
	Local lExist          := .F.
    Local nOperation      := oModel:getOperation()

    If nOperation == 5 
    


	      cAliasSQL       := getNextAlias()
      
	      BeginSQL alias cAliasSQL
              SELECT * FROM %table:Z51% Z51
              WHERE Z51.%notdel%
              AND Z51_FILIAL = %exp:xFilial('Z51')%
              AND Z51_TIPO = %exp:Z50->Z50_CODIGO%
              LIMIT 1
	      EndSQL
      
	      (cAliasSQL)->(dbEval({|| lExist := .T.}),dbCloseArea())
      
	      IF lExist
	      	oModel:setErrorMessage(,,,,'REGISTRO UTILIZADO','REGISTRO JA UTILIZADO NÃO PODE SER EXCLUIDO,!')
	      	return .F.
	      EndIF
    
    EndIF

Return lValid

/*/{Protheus.doc} fnCommit
    (funcao executada para gravar dados)
    @type  Function
    /*/
Static function fnCommit(oModel)

	Local lCommit := FWFormCommit(oModel)

Return lCommit

/*/{Protheus.doc} fnCancel
    (Funcao executada para cancelamento de preenchimento de dados)
    @type  Function
    /*/
Static function fnCancel(oModel)

	Local lCancel := FWFormCancel(oModel)

Return lCancel



/*/{Protheus.doc} nomeFunction
    (long_description)
    @type  Function
    /*/

Function U_GCTT001

	Local cNovoCod    := ''
	Local cAliasSQL   := ''
	Local oModel      := FWModelActive()
	Local nOperation  := 0

	nOperation        := oModel:getOperation()

	If .not.(nOperation == 3 .or. nOperation == 9)
		cNovoCod  := oModel:getModel('Z50MASTER'):getValue('Z50_CODIGO')
		Return cNovoCod

	EndIf


	cAliasSQL         := getNextAlias()

	BeginSql Alias cAliasSQL
            SELECT COALESCE(MAX(Z50_CODIGO),'00') Z50_CODIGO
            FROM %table:Z50% Z50
            WHERE Z50.%notdel%
            AND Z50_FILIAL = %exp:xFilial('Z50')%
            AND Z50_TIPO   = %exp:M->Z50_TIPO%  
	EndSql

	(cAliasSQL)->(DBEval({|| cNovoCod := alltrim(Z50_CODIGO)}),DBCloseArea())

	If cNovoCod == '00'
		cNovoCod := M-> Z50_TIPO +'01'
	Else
		cNovoCod := soma1(cNovoCod)
	EndIf

Return cNovoCod
