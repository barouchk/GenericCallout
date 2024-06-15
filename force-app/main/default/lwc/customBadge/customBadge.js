import { LightningElement, api } from 'lwc';

export default class CustomBadge extends LightningElement {

    @api value;

    @api dynamicValuesInfo;

    badgeClass;

    icon;

    colors = {
        gray: 'slds-badge',
        lightgray: 'slds-badge_lightest',
        darkgray: 'slds-badge_inverse',
        green: 'slds-theme_success',
        orange: 'slds-theme_warning',
        red: 'slds-theme_error'
    }

    connectedCallback() {

        if (this.dynamicValuesInfo) {
            const dynamicValue = this.dynamicValuesInfo.find(element => element.value === this.value)
            this.badgeClass = this.colors[dynamicValue?.color || this.colors.gray]
            this.icon = dynamicValue?.icon || ''
        }

    }
}