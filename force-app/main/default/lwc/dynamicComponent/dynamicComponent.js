// Salesforce decorators
import { LightningElement, api, track } from 'lwc';
// Custom method (Apex)
import wireGetWrapperModel from '@salesforce/apex/CustomComponent.wireGetWrapperModel';

import {
    DEFUALT_HEADER_CLASS, DEFAULT_CARD_CLASS, HEADER_STYLES, NESTED_STYLE
} from './constants'
import { isEmpty } from 'c/dataUtils';

export default class DynamicComponent extends LightningElement {

    @api recordId;
    @api developerName;
    @api selectedRows = [];

    title;
    icon;
    type;
    serviceEndpoint;
    apexClass;
    wiredFields;

    maxRowSelection;
    displayCheckboxColumn;
    calloutParamsPath;

    // loading indications
    isDataLoaded = false
    isWrapperLoaded = false

    // card style
    isNestedCard
    hideHeader
    headerStyle

    disableActions = true

    get headerClass() {
        return `${DEFUALT_HEADER_CLASS} ${HEADER_STYLES[this.headerStyle]}`
    }

    get cardClass() {
        return `${DEFAULT_CARD_CLASS} ${this.isNestedCard ? NESTED_STYLE : ''}`
    }

    get modalClass() {
        return 'slds-modal slds-fade-in-open slds-modal_small'
    }

    get isTable() {
        return this.type === 'Table'
    }

    get isDetailPage() {
        return this.type === 'Detail Page'
    }

    get isCompactLayout() {
        return this.type === 'Compact Layout'
    }

    get stensilType() {
        if (this.isTable) {
            return 'table'
        } else if (this.isDetailPage) {
            return 'activity'
        } else if (this.isCompactLayout) {
            return ''
        }
    }

    // Global variables (Boolean)
    displayDynamicIllustration;
    hideCheckboxColumn;

    // Global variables (String)
    noDataMessage;
    illustration;
    illustrationSize;

    // Global variables (List)
    @track columns;
    @track actions;

    // Global variables (Object)
    @track data;
    // raw data retrieved from service by path
    resultData;

    _filters;

    @api
    get filters() {
        return this._filters;
    }
    set filters(value) {
        if (value) {
            this._filters = JSON.parse(value);
        }
    }

    @api
    get calloutParams() {
        return this.__calloutParams;
    }
    set calloutParams(value) {
        this.__calloutParams = JSON.parse(value);
    }

    // flow variables
    flowApiName;
    inputVariables;

    connectedCallback() {
        this.handleColumns();
    }

    async handleColumns() {
        const { developerName } = this;
        try {
            const wrapper = await wireGetWrapperModel({ developerName });

            if (wrapper) {
                this.assignWrapperFields(wrapper)
                this.assignActions(wrapper)
                this.assignWiredFields();
                this.isWrapperLoaded = true
            }
        } catch (error) {
            console.error(error);
        }
    }

    assignWrapperFields(wrapper) {
        const { title, icon, type, serviceEndpoint, dataPath, columns,
            illustration, illustrationSize, noDataMessage,
            apexClass, isNestedCard, hideHeader, headerStyle } = wrapper

        console.log('wrapper >> ', JSON.stringify(wrapper, null, 4));
        this.type = type

        // card 
        this.title = title
        this.icon = icon
        this.hideHeader = hideHeader
        this.isNestedCard = isNestedCard
        this.headerStyle = headerStyle

        // illustration    
        this.illustration = illustration
        this.illustrationSize = illustrationSize
        this.noDataMessage = noDataMessage

        // callout
        this.serviceEndpoint = serviceEndpoint
        this.apexClass = apexClass
        this.calloutParamsPath = dataPath

        this.columns = columns
    }

    populateDetailPageData(data) {
        const sections = Object.values(data.reduce((sectionsMap, field) => ({
            ...sectionsMap,
            [field.section || '']: {
                id: field.section?.id || 0,
                title: field.section?.title,
                order: field.section?.order || 0,
                isDefaultOpen: field.section?.isDefaultOpen !== false,
                fields: [...sectionsMap[field.section?.title || '']?.fields || [], field]
            }
        }), {})).sort((a, b) => a.order - b.order);

        const activeSections = sections.filter(({ isDefaultOpen }) => isDefaultOpen).map(({ title }) => title); // list of section names
        console.log('section >> ', sections);

        const index = sections.findIndex((element) => element.id === 0);
        let mainData = []
        if (index > -1) {
            mainData = sections.splice(index, 1)[0].fields;
            console.log('main >> ', mainData);
        }

        this.data = { sections, mainData, activeSections }
    }

    assignActions(wrapper) {
        const { actions } = wrapper

        if (isEmpty(actions)) { return; }

        let rowActions = []
        let listActions = []

        for (var action of actions) {
            if (this.isTable && action.type === 'Row') {
                rowActions.push(action);
            } else if (action.type === 'List') {
                listActions.push(action)
            }
        }

        if (!isEmpty(rowActions)) {
            this.columns = [...this.columns, { type: 'action', typeAttributes: { rowActions } }]
        }

        if (!isEmpty(listActions) && !this.isTable) {
            this.disableActions = false
        }

        this.actions = listActions;
    }

    assignWiredFields() {
        if (this.isTable) {
            return;
        }

        var wiredFields = this.columns.reduce((wiredFields, field) => {
            if (field.source === 'SF') {
                wiredFields.push(field.fieldName);
            }
            return wiredFields;
        }, []);

        this.wiredFields = wiredFields;
    }

    handleCalloutResult(e) {
        e.stopPropagation();

        const { detail: { calloutResult, errorMessage } } = e;

        if (errorMessage) {
            this.displayDynamicIllustration = true;
            this.noDataMessage = errorMessage;
            this.isDataLoaded = true;
            return;
        }
        try {
            const resultData = this.fetch_data_by_path(calloutResult, this.calloutParamsPath);
            this.resultData = resultData;

            if (resultData && !this.isTable) {
                const data = this.columns?.map(column => ({ ...column, value: resultData[column.fieldName] }));
                if (this.isDetailPage) {
                    this.populateDetailPageData(data);
                } else {
                    this.data = data
                }
            } else {
                this.data = resultData;
            }
        }
        catch (e) {
            console.log('catch', e)
        }
        this.isDataLoaded = true
        this.displayDynamicIllustration = !this.data;
    }

    fetch_data_by_path(obj, path) {
        if (!path) {
            return obj
        }

        for (var i = 0, path = path.split('.'), len = path.length; i < len; i++) {
            obj = obj[path[i]];
        };
        return obj;
    }

    handleRowSelection({ detail: { selectedRows } }) {
        console.log('selectedRows >> ', selectedRows);
        this.selectedRows = selectedRows;
        this.disableActions = isEmpty(this.selectedRows)
    }

    handleRowAction(event) {
        const { action, row } = event.detail

        let inputVariables = [{
            name: 'data',
            type: 'String',
            value: JSON.stringify(row)
        }]

        this.openFlow(action.flowName, inputVariables)
    }

    handleListActionClicked(e) {
        const { name, label } = e.target
        console.log('e >> ', name, label)
        // GET flowName by name
        const { flowName } = this.actions.find((action) => action.name === name)
        let inputVariables;

        if (this.isTable) {
            const dataRows = { rows: this.selectedRows }
            inputVariables = [{
                name: 'data',
                type: 'String',
                value: JSON.stringify(dataRows)
            }]
        } else {
            inputVariables = [{
                name: 'data',
                type: 'String',
                value: JSON.stringify(this.resultData)
            }]
        }

        this.openFlow(flowName, inputVariables)
    }

    openFlow(flowName, inputVariables) {
        const { recordId } = this

        this.inputVariables = inputVariables
        this.inputVariables.push({
            name: 'recordId',
            type: 'String',
            value: recordId
        })

        this.flowApiName = flowName
    }

    handleFlowStatusChange(event) {
        const { status } = event.detail

        if (status === 'FINISHED') {
            // set behavior after a finished flow interview
            this.closeModal()
        } else if (status === 'ERROR') {
            // set behavior after a finished flow interview
            console.log('event >> ', event);
        }
    }

    closeModal() {
        this.flowApiName = '';
        this.inputVariables = ''
    }

    onSectionClicked(event) {
        console.log(event.target)
    }
}