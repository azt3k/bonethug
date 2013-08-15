<?php

/**
 * AddModelAdmin is an extension of ModelAdmin designed to allow some customisation to the edit form etc.
 * 
 * @author AzT3k
 */
class AbcModelAdmin extends ModelAdmin {
	
	/**
	 * This method generates the list view form
	 * Individual items are handled by the gridfielddetailform - this is is defined in GridFieldDetailForm_ItemRequest::ItemEditForm() and has been overloaded in the subclass
	 * 
	 * @param type $id
	 * @param type $fields
	 * @return \AbcModelAdminForm
	 */
	function getEditForm($id = null, $fields = null) {
				
		$list = $this->getList();
		$exportButton = new GridFieldExportButton('before');
		$exportButton->setExportColumns($this->getExportFields());
		$listField = GridField::create(
			$this->sanitiseClassName($this->modelClass),
			false,
			$list,
			$fieldConfig = AddGridFieldConfig_RecordEditor::create($this->stat('page_length'))
				->addComponent($exportButton)
				->removeComponentsByType('GridFieldFilterHeader')
				->addComponents(new GridFieldPrintButton('before'))
		);

		// Validation
		if(singleton($this->modelClass)->hasMethod('getCMSValidator')) {
			$detailValidator = singleton($this->modelClass)->getCMSValidator();
			$listField->getConfig()->getComponentByType('GridFieldDetailForm')->setValidator($detailValidator);
		}

		$form = new AbcModelAdminForm(
			$this,
			'EditForm',
			new FieldList($listField),
			new FieldList
		);
		$form->addExtraClass('cms-edit-form cms-panel-padded center');
		$form->setTemplate($this->getTemplatesWithSuffix('_EditForm'));
		$form->setFormAction(Controller::join_links($this->Link($this->sanitiseClassName($this->modelClass)), 'EditForm'));
		$form->setAttribute('data-pjax-fragment', 'CurrentForm');

		$this->extend('updateEditForm', $form);
		
		return $form;
	}
	
}
