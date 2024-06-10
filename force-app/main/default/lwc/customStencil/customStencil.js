import { LightningElement, api } from 'lwc';

export default class CustomStencil extends LightningElement {

    _type;
    @api get type() {
        return this._type
    };

    set type(value) {
        if (value) {
            this._type = value.toLowerCase()
        }
    }

    @api spinner = false;

    items = [];
    fields = [];
    rows = [];
    columns = [];

    get isActivity() {
        return this.type === 'activity';
    }
    get isPath() {
        return this.type === 'path';
    }
    get isTable() {
        return this.type === 'table';
    }
    get isList() {
        return this.type === 'list';
    }
    get isCompact() {
        return this.type === 'compact layout';
    }

    get isDetail() {
        return this.type === 'detail page';
    }

    get showSpinner() {
        return this.spinner === true;
    }
    connectedCallback() {
        this.items = Array.from(Array(5).keys());
        this.rows = Array.from(Array(10).keys());
        this.fields = Array.from(Array(10).keys());
    }
}