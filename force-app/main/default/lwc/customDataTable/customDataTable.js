import LightningDatatable from 'lightning/datatable';
import linkToObject from './linkToObject';
import customBoolean from './customBoolean.html';

export default class CustomDataTable extends LightningDatatable {

    static customTypes = {
        'link-to-object': {
            template: linkToObject,
            typeAttributes: ['targetId', 'linkToObject', 'linkLabel', 'styleClass', 'isLinkToObject']
        },

        // Standart 'boolean' type of lightning-datatable has not a 'variant' option
        // Use 'customBoolean' custom type instead
        'customBoolean': {
            template: customBoolean,
            typeAttributes: ['iconName', 'variant', 'class']
        },
    }

}