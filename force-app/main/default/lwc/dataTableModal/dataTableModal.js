import { LightningElement, api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class DataTableModal extends LightningModal {

  @api
  columns

  @api
  recordList

  @api
  label

  selectedRow;

  handleRowSelection = event => {
    let selectedRows=event.detail.selectedRows;
    console.log('selectedRows', selectedRows);
    if ( selectedRows.length > 0 ) {
      this.selectedRow = selectedRows[0];
    }
  }

  handleClose() {
    this.close('canceled');
  }

  handleSelect() {
    this.close({
      'selectedRow': this.selectedRow
    });
  }
}