import { api, LightningElement } from 'lwc';

export default class DynamicIllustration extends LightningElement {

    // Api variables
    @api dynamicLabel = '';
    @api dynamicImg = '';

    // Global variables (Object)
    srcImgList = {
        OpenRoad: '/img/chatter/OpenRoad.svg',
        Desert: '/img/chatter/Desert.svg',
        NoEvents: '/projRes/ui-home-private/emptyStates/noEvents.svg',
        NoTasks: '/projRes/ui-home-private/emptyStates/noTasks.svg',
        NoAssistant: '/projRes/ui-home-private/emptyStates/noAssistant.svg'
    };

    // Global variables (String)
    dynamicSrc = '';

    renderedCallback() {
        this.dynamicSrc = this.srcImgList[this.dynamicImg];
    }
}