import LightningDatatable from 'lightning/datatable';
import customBoolean from './customBoolean.html';
import customIcon from './customIcon.html';
import customBadge from './customBadge.html';

export default class CustomDataTable extends LightningDatatable {

    static customTypes = {
        'boolean': {
            template: customBoolean,
            typeAttributes: []
        },
        'icon': {
            template: customIcon,
            typeAttributes: ['dynamicValuesInfo']
        },
        'badge': {
            template: customBadge,
            typeAttributes: ['dynamicValuesInfo']
        }
    }

}