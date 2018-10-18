const {RuleFactory, FormElementStatusBuilder, FormElementsStatusHelper} = require('rules-config/rules');

const RegistrationFormHandler = RuleFactory("881f0ddb-ce35-4372-abae-622fb04bc236", "ViewFilter");
const ChildPNCFormHandler = RuleFactory("e09dddeb-ed72-40c4-ae8d-112d8893f18b","ViewFilter");

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

@ChildPNCFormHandler("8ec8cd68-dbae-46f1-b739-e8849c90eaa2", "[LBP] Child PNC View Form Handler", 1.0, {})
class childPNCFormHandlerLBP{

    stoolRelatedComplaints(programEncounter, formElement) {
        let formElementStatusBuilder = new FormElementStatusBuilder({programEncounter, formElement});
        formElementStatusBuilder.skipAnswers("Loose stools");
        return formElementStatusBuilder.build();
    }

    static exec(programEncounter, formElementGroup, today) {
        return FormElementsStatusHelper
            .getFormElementsStatusesWithoutDefaults(new childPNCFormHandlerLBP(), programEncounter, formElementGroup, today);
    }
}

module.exports = {RegistrationFormHandlerLBP, childPNCFormHandlerLBP};