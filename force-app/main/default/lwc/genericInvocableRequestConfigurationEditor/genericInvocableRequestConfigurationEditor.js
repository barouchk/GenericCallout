import { LightningElement, api, track } from 'lwc';
import getCustomMetadata from '@salesforce/apex/GenericRequestConfigurationController.getCustomMetadata';

export default class GenericInvocableRequestConfigurationEditor extends LightningElement {
    @api inputVariables;
    @api builderContext;
    @api automaticOutputVariables;

    @track inputVariablesMap;
    @track outputSections;

    openSections = ['request'];
    disableResourceExplorer = true;
    serviceEndpointId;
    textAreaStyle;
    isLoading;

    @track serviceEndpointOptions = []

    fetchCustomMetadata() {
        getCustomMetadata()
            .then((result) => {
                this.serviceEndpointOptions = result.map((obj) => {
                    return { label: obj.DeveloperName, value: obj.Id };
                });
            })
            .catch((error) => {
                console.error(error);
            });
    }

    handleServiceEndpointChange(event) {
        const { value } = event.target
        this.serviceEndpointId = value
        this.handleParamChange({ target: { name: 'serviceEndpoint', value } });
    }

    get resourceExplorerLabel() {
        const { lastSelectedInput } = this;
        const destination = lastSelectedInput ? `${lastSelectedInput} Flow Variable` : 'A Dynamic Variable';
        return `Add Resource From Flow to ${destination}`;
    }

    handleToggleSection({ detail: { openSections } }) {
        this.openSections = openSections;
        this.handleDisableResourceExplorer();
    }

    handleDisableResourceExplorer() {
        this.setLastSelectedInput({ target: {} });
    }

    setLastSelectedInput({ target: { dataset } }) {
        this.lastSelectedInput = dataset?.name;
        this.disableResourceExplorer = !this.lastSelectedInput;
    }

    async handleParamChange({ target: { name, value, type, checked, dataset } }) {
        const { inputVariablesMap, inputsOfTypeBoolean, booleanToGlobalConstant, isReference, addedWordToMoveCursor, findFirstDiffPos } = this;
        let previousValue, inputVariable = inputVariablesMap[name];
        if (inputVariable) {
            previousValue = inputVariable.value;
        } else {
            inputVariable = {};
            inputVariablesMap[name] = inputVariable;
        }

        let newValue, newValueDataType;
        if (inputsOfTypeBoolean.includes(type)) {
            newValue = booleanToGlobalConstant[checked];
            newValueDataType = 'Boolean';
        } else if (isReference(value)) {
            newValue = value;
            newValueDataType = 'reference';
        } else {
            newValue = value;
            newValueDataType = 'String';
        }

        const isChanged = newValue !== inputVariable.value;
        if (isChanged) {
            inputVariable.name = name;
            inputVariable.value = newValue;
            inputVariable.valueDataType = newValueDataType;
        }

        let element;
        if (addedWordToMoveCursor) {
            element = this.template.querySelector(`[data-name="${name}"]`);
            if (element && element.setRangeText) {
                const changePosition = findFirstDiffPos(previousValue, newValue); // find index of added string
                if (changePosition > -1) {
                    // move cursor to end of the added string
                    element.setRangeText(addedWordToMoveCursor, changePosition, changePosition + addedWordToMoveCursor.length, 'end');
                }
            }

            this.addedWordToMoveCursor = null;
        }

        this.handleParamChangeDebounced(isChanged, name, previousValue, newValue, newValueDataType, dataset, element);
    }

    // this method will work only when user hasn't typed anything within a certain short time
    // the purpose is that it makes too much work and firing an event which makes the typing to have a delay
    handleParamChangeDebounced(isChanged, name, previousValue, newValue, newValueDataType, dataset, element) {
        const { outputSectionsMap, outputSections, doneTypingInterval } = this;
        if (isChanged) {
            this.reportChangedValue(name, newValue, newValueDataType);
        }

        if (name === 'paramsJson') {
            const paramsJson = element || this.template.querySelector(`[data-name="${name}"]`);
            if (!paramsJson.checkValidity()) {
                paramsJson.setCustomValidity('');
                paramsJson.reportValidity();
            }

            this.setParamsJsonHeight();
        } else if (name === 'serviceEndpoint') {
            this.serviceEndpoint = newValue;
        } else if (dataset?.section) {
            const section = outputSectionsMap[dataset.section];
            if (dataset.top) {
                section.topFieldsMap[name].value = newValue;
            } else if (name === section.fields.at(-1).name) { // is last element in array
                section.disableAdd = isEmpty(newValue);
                this.outputSections = [...outputSections]; // doesn't render without this 🤷
            }
        }
    }

    handleResourceSelected({ detail: { id, newValue } }) {
        if (newValue) {
            const input = this.template.querySelector(`[data-name="${id}"]`);
            const { setRangeText, value, selectionStart } = input;
            if (setRangeText) {
                this.addedWordToMoveCursor = `{!${newValue}}`;
                input.setRangeText(this.addedWordToMoveCursor); // add substring in lightning-textarea
            } else {
                input.value = `${value.slice(0, selectionStart)}{!${newValue}}${value.slice(selectionStart)}`; // add substring in lightning-input
                input.selectionStart += newValue.length; // move cursor to the right of the added substring
            }

            this.handleParamChange({ target: input });
            input.focus();
        }
    }

    reportChangedValue(name, newValue, newValueDataType) {
        this.dispatchEvent(new CustomEvent('configuration_editor_input_value_changed', {
            bubbles: true,
            cancelable: false,
            composed: true,
            detail: { name, newValue, newValueDataType }
        }));
    }

    validateParamsJson() {
        const { value } = this.inputVariablesMap.paramsJson;
        let parsedValue, validityMsg = '';
        if (!this.isReference(value)) {
            try {
                parsedValue = JSON.parse(value);
            } catch (jsonParseError) {
                validityMsg = jsonParseError.message;
            }
        }

        const paramsJson = this.template.querySelector('[data-name="paramsJson"]');
        paramsJson.setCustomValidity(validityMsg);
        paramsJson.reportValidity();
        this.handleDisableResourceExplorer();

        return { parsedValue, validityMsg };
    }

    prettifyParamsJson() {
        const { parsedValue } = this.validateParamsJson();
        if (parsedValue) {
            this.handleParamChange({ target: { name: 'paramsJson', value: JSON.stringify(parsedValue, null, 4) } });
        }
    }

    findFirstDiffPos = (a, b) => [a, b].sort((a, b) => b.length - a.length).reduce((a, b) => [...a].findIndex((c, i) => c !== b[i]));

    handleJsonParamsKeyDown(event) {
        const { key, currentTarget } = event;
        if (key === 'Tab') {
            // add indentation to the line in JSON instead of going to the next field in DOM
            event.preventDefault();
            this.addedWordToMoveCursor = '    ';
            currentTarget.setRangeText(this.addedWordToMoveCursor);
            this.handleParamChange({ target: currentTarget });
        }
    }

    isReference(fieldValue) {
        return fieldValue && fieldValue.startsWith('{!') && fieldValue.endsWith('}');
    }

    setParamsJsonHeight() {
        const { value = '' } = this.inputVariablesMap.paramsJson;
        this.textAreaStyle = `--slds-c-textarea-sizing-min-height:${25 + value.split(/\r\n|\r|\n/).length * 18}px`;
    }

    handleAddOutput({ target: { name } }) {
        const section = this.outputSectionsMap[name];
        const { fields } = section;
        const newOutput = { name: this.getOutputFieldName(name, fields.length + 1), valueDataType: 'String' };
        section.disableAdd = true;
        section.disableRemove = false;
        section.fields = [...fields, newOutput];
        this.inputVariablesMap[newOutput.name] = newOutput;
        this.handleParamChange({ target: { name: newOutput.name } });
        this.outputSections = [...this.outputSections]; // doesn't render without this 🤷
        this.handleDisableResourceExplorer();
    }

    handleRemoveOutput({ target: { name } }) {
        const section = this.outputSectionsMap[name];
        const { fields } = section;
        const fieldName = fields.pop().name;
        section.disableRemove = fields.length === 0;
        section.disableAdd = false;
        this.handleParamChange({ target: { name: fieldName } });
        this.outputSections = [...this.outputSections]; // doesn't render without this 🤷
        this.handleDisableResourceExplorer();
    }

    getOutputFieldName(outputArrayType, count) {
        const { name, index } = this.outputFieldByArrayType[outputArrayType];
        return `${name.slice(0, index)}${count}${name.slice(index)}`;
    }

    async connectedCallback() {
        this.fetchCustomMetadata();
        const inputVariablesMap = this.inputVariables.reduce((result, { name, value, valueDataType }) => ({ ...result, [name]: { name, valueDataType, value: valueDataType === 'reference' ? `{!${value}}` : value } }), {});
        const outputSectionsTopFieldsMap = {
            statusCodePath: { name: 'statusCodePath', label: 'Status Code Path', value: inputVariablesMap.statusCodePath?.value },
            statusDescPath: { name: 'statusDescPath', label: 'Status Desc Path', value: inputVariablesMap.statusDescPath?.value }
        };

        const outputSectionsMap = {
            outputFieldPaths: {
                name: 'outputFieldPaths',
                label: 'Output Field Paths',
                fields: [],
                topFieldsMap: outputSectionsTopFieldsMap,
                topFields: Object.values(outputSectionsTopFieldsMap)
            },
            collectionPaths: {
                name: 'collectionPaths',
                label: 'Output Collection Paths',
                fields: []
            },
            outputCollectionKeys: {
                name: 'outputCollectionKeys',
                label: 'Output Collection Keys',
                fields: []
            }
        };

        this.serviceEndpointId = inputVariablesMap.serviceEndpoint?.value;

        Object.assign(this, {
            inputVariablesMap,
            outputSectionsMap,
            outputSections: Object.values(outputSectionsMap),
            inputsOfTypeBoolean: ['checkbox', 'toggle'],
            booleanToGlobalConstant: { true: '$GlobalConstant.True', false: '$GlobalConstant.False' },
            outputFieldByArrayType: {
                outputFieldPaths: { name: 'outputPath', index: 6 },
                collectionPaths: { name: 'collectionPath', index: 10 },
                outputCollectionKeys: { name: 'outputCollectionKeys', index: 16 }
            }
        });

        this.populateOutputSections();
        this.setParamsJsonHeight();
    }

    outputSectionByInputVariable = {
        output1Path: 'outputFieldPaths',
        output2Path: 'outputFieldPaths',
        output3Path: 'outputFieldPaths',
        output4Path: 'outputFieldPaths',
        output5Path: 'outputFieldPaths',
        output6Path: 'outputFieldPaths',
        output7Path: 'outputFieldPaths',
        output8Path: 'outputFieldPaths',
        output9Path: 'outputFieldPaths',
        output10Path: 'outputFieldPaths',
        output11Path: 'outputFieldPaths',
        output12Path: 'outputFieldPaths',
        output13Path: 'outputFieldPaths',
        collection1Path: 'collectionPaths',
        collection2Path: 'collectionPaths',
        outputCollection1Keys: 'outputCollectionKeys',
        outputCollection2Keys: 'outputCollectionKeys'
    };

    isOutputSectionFull({ name, fields: { length } }) {
        return length === Object.values(this.outputSectionByInputVariable).filter(sectionName => sectionName === name).length;
    }

    populateOutputSections() {
        const { inputVariables, outputSectionsMap, outputSectionByInputVariable, outputSections } = this;
        inputVariables.filter(({ value }) => value).forEach(inputVariable => {
            outputSectionsMap[outputSectionByInputVariable[inputVariable.name]]?.fields?.push(inputVariable);
        });

        for (const section of outputSections) {
            const lastOutputField = section.fields.at(-1);
            section.disableAdd = lastOutputField && (isEmpty(lastOutputField.value) || this.isOutputSectionFull(section));
            section.disableRemove = section.fields.length === 0;
        }
    }

    @api validate() {
        const { validityMsg } = this.validateParamsJson();
        return {
            isValid: this.isEmpty(validityMsg),
            errorMessage: validityMsg
        }
    }

    isEmpty(data) {
        const typeOfData = typeof data;
        if (typeOfData === "number" || typeOfData === "boolean") {
            return false;
        }
        if (typeOfData === "undefined" || data === null) {
            return true;
        }
        if (typeOfData !== "undefined") {
            if (typeOfData === "object") {
                return Object.keys(data).length === 0;
            }
            return data.length === 0;
        }

        let count = 0;
        for (let i in data) {
            if (data.hasOwnProperty(i)) {
                count++;
            }
        }

        return count === 0;
    };
}