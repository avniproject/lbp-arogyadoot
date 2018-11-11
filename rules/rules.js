const {RuleFactory, FormElementStatusBuilder, FormElementsStatusHelper} = require('rules-config/rules');

const moment = require("moment");
const _ = require("lodash");
import {
    FormElementStatus,
    VisitScheduleBuilder
} from 'rules-config/rules';

const EnrolmentChecklists = RuleFactory("1608c2c0-0334-41a6-aab0-5c61ea1eb069", "Checklists");

@EnrolmentChecklists("e92d9b5a-8596-4784-8142-04be4f1b1485", "LBP Child Vaccination checklists", 100.0)
class ChildChecklists {
    static exec(enrolment, checklistDetails) {
        let vaccination = checklistDetails.find(cd => cd.name === 'Vaccination');
        if (vaccination === undefined) return [];
        const vaccinationList = {
            baseDate: enrolment.individual.dateOfBirth,
            detail: {uuid: vaccination.uuid},
            items: vaccination.items.map(vi => ({
                detail: {uuid: vi.uuid}
            }))
        };
        return [vaccinationList];
    }
}

const RegistrationFormHandler = RuleFactory("881f0ddb-ce35-4372-abae-622fb04bc236", "ViewFilter");

@RegistrationFormHandler("f9d02ea8-af32-4e08-8564-2023a532cccf", "[LBP] Registration View Form Handler", 1.0, {})
class RegistrationFormHandlerLBP {
    education(individual, formElement) {
        return this._showBasedOnAge(individual, formElement, 5);
    }

    _showBasedOnAge(individual, formElement, age) {
        const statusBuilder = new FormElementStatusBuilder({individual, formElement});
        statusBuilder.show().when.ageInYears.is.greaterThanOrEqualTo(age);
        return statusBuilder.build();
    }

    doYouConsumeAnyTobaccoProducts(individual, formElement) {
        return this._showBasedOnAge(individual, formElement, 5);
    }

    doYouConsumeAnyAlcoholicProducts(individual, formElement) {
        return this._showBasedOnAge(individual, formElement, 5);
    }

    static exec(individual, formElementGroup, today) {
        return FormElementsStatusHelper
            .getFormElementsStatusesWithoutDefaults(new RegistrationFormHandlerLBP(), individual, formElementGroup, today);
    }
}


module.exports = {RegistrationFormHandlerLBP,ChildChecklists};