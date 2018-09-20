const {RuleFactory, FormElementStatusBuilder, FormElementsStatusHelper} = require('rules-config/rules');

const RegistrationFormHandler = RuleFactory("881f0ddb-ce35-4372-abae-622fb04bc236", "ViewFilter");

@RegistrationFormHandler("f9d02ea8-af32-4e08-8564-2023a532cccf", "[LBP] Registration View Form Handler", 1.0, {})
class RegistrationFormHandlerLBP {
    education(individual, formElement) {
        return this._showBasedOnAge(individual, formElement, 5);
    }

    _showBasedOnAge(individual, formElement, age) {
        const statusBuilder = new FormElementStatusBuilder({individual, formElement});
        statusBuilder.show().when.age.is.greaterThan(age);
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

module.exports = {RegistrationFormHandlerLBP};