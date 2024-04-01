import { api, LightningElement } from 'lwc';

export default class EventPasser extends LightningElement {

	@api 
	passEvent(event) {
		this.dispatchEvent(event);
	}
}