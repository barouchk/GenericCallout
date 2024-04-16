import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import { isEmpty, promise } from 'c/dataUtils';

import getClassResult from '@salesforce/apex/CustomComponent.getClassResult';

const APEX_CLASS_METHOD = 'GenericInvocableRequest';

export default class UtilMakeCallout extends LightningElement {

    @api recordId
    @api serviceEndpoint;
    @api calloutParams;
    @api apexClass;
    @api wiredFields

    connectedCallback() {
        this.getResult();
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: '$wiredFields',
    })
    recordObj;

    async getResult() {
        const { recordId, serviceEndpoint, calloutParams = {}, apexClass } = this;
        let errorMessage = '';
        let calloutResult
        try {
            calloutResult = await promise(getClassResult, {
                apexClass: apexClass ? apexClass : APEX_CLASS_METHOD,
                recordId,
                serviceEndpoint,
                calloutParams
            });

            // calloutResult = await getClassResult({
            //     apexClass: apexClass ? apexClass : APEX_CLASS_METHOD,
            //     recordId,
            //     serviceEndpoint,
            //     calloutParams
            // });
        }
        catch (e) {
            errorMessage = e.body.message;
        }

        if (isEmpty(calloutResult)) {
            this.fireCalloutEvent(null, errorMessage);
            return;
        }

        const { data, error } = this.recordObj
        if (data && this.wiredFields) {
            this.wiredFields.forEach(function (fieldApiName) {
                calloutResult[fieldApiName] = getFieldValue(data, fieldApiName);
            });
        } else if (error) {
            errorMessage = 'wired error: ' + error.body.message;
            console.log(JSON.stringify(error, null, 4));
        }

        this.fireCalloutEvent(calloutResult, errorMessage);
    }

    fireCalloutEvent(calloutResult, errorMessage) {

        const event = new CustomEvent("calloutresult", {
            bubbles: true,
            composed: true,
            cancelable: true,
            detail: { calloutResult, errorMessage }
        });
        this.dispatchEvent(event);
    }
}