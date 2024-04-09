import { api, LightningElement } from 'lwc';

export default class DynamicIllustration extends LightningElement {

    // Api variables
    @api label = '';
    @api illustrationName = '';
    @api size;

    // Global variables (Object)
    srcIllustrationList = {
        OpenRoad: '/img/chatter/OpenRoad.svg',
        Desert: '/img/chatter/Desert.svg',
        NoEvents: '/projRes/ui-home-private/emptyStates/noEvents.svg',
        NoTasks: '/projRes/ui-home-private/emptyStates/noTasks.svg',
        NoAssistant: '/projRes/ui-home-private/emptyStates/noAssistant.svg'
    };

    // Global variables (String)
    dynamicSrc = '';
    illustrationClass = 'slds-illustration'

    connectedCallback() {
        this.dynamicSrc = this.srcIllustrationList[this.illustrationName];
        this.illustrationClass += ` ${`slds-illustration_${this.size || 'large'}`}`
    }
}