import { LightningElement, api } from 'lwc';

export default class CustomIcon extends LightningElement {

    @api value;

    @api dynamicValuesInfo;

    icon;

    connectedCallback() {
        if (this.dynamicValuesInfo) {
            this.icon = this.dynamicValuesInfo.find(element => element.value === this.value)?.icon
        }
    }

}