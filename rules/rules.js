import {RuleFactory, FormElementStatusBuilder, FormElementsStatusHelper, complicationsBuilder as ComplicationsBuilder} from 'rules-config/rules';
import lib from '../lib';

const moment = require("moment");
const _ = require("lodash");
import {
    FormElementStatus,
    VisitScheduleBuilder
} from 'rules-config/rules';

const EnrolmentChecklists = RuleFactory("1608c2c0-0334-41a6-aab0-5c61ea1eb069", "Checklists");
const DeliveryFilter = RuleFactory("cc6a3c6a-c3cc-488d-a46c-d9d538fcc9c2", 'ViewFilter');

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

@DeliveryFilter("9a133cd1-f26d-47e9-9dd0-1af6869df982", "[LBP] Delivery Form Handler", 100.0, {})
class DeliveryFormHandlerLBP {
    static exec(programEncounter, formElementGroup, today) {
        return FormElementsStatusHelper
            .getFormElementsStatusesWithoutDefaults(new DeliveryFormHandlerLBP(), programEncounter, formElementGroup, today);
    }

    whetherEpisiotomyGiven(programEncounter, formElement) {
        const statusBuilder = new FormElementStatusBuilder({programEncounter, formElement});
        statusBuilder.show().when.valueInEncounter("Type of delivery")
            .containsAnyAnswerConceptName("Normal", "Instrumental");
        return statusBuilder.build();

    }
}

const ANCDecisionRule = RuleFactory("3a95e9b0-731a-4714-ae7c-10e1d03cebfe", "Decision");

const inchIncrease = (enrolment, encounter, multiplicationFactor, conceptName, toDate = new Date()) => {
    const lastEncounter = enrolment.findLastEncounterOfType(encounter, [_.get(encounter, "encounterType.name")]);
    const previousVal = lastEncounter && lastEncounter.getObservationValue(conceptName);
    const currentVal = encounter && encounter.getObservationValue(conceptName);
    const numberOfWeeksSinceLastEncounter = _.round(FormElementsStatusHelper.weeksBetween(toDate, _.get(lastEncounter, "encounterDateTime")));
    return ([previousVal, currentVal, numberOfWeeksSinceLastEncounter].some(k => _.isNil(k))) ||
        (_.every([previousVal, currentVal, numberOfWeeksSinceLastEncounter], (k) => !_.isNil(k))
            && (currentVal - previousVal) === (numberOfWeeksSinceLastEncounter * multiplicationFactor));
};

const isNormalAbdominalGirthIncrease = (enrolment, encounter, toDate = new Date()) => {
    return inchIncrease(enrolment, encounter, 1, "Abdominal girth in inches", toDate);
};

const lmp = (programEnrolment) => {
    return programEnrolment.getObservationValue('Last menstrual period');
};

const gestationalAge = (enrolment, toDate = new Date()) => lib.C.weeksBetween(toDate, lmp(enrolment));


@ANCDecisionRule("de0af2f7-69ff-4f7d-82cf-6540f4347640", "LBP ANC Decision", 100.0, {})
class ANCDecisionsLBP {
    static exec(programEncounter, decisions, context, today) {
        const highRiskBuilder = new ComplicationsBuilder({
            programEnrolment: programEncounter.programEnrolment,
            programEncounter: programEncounter,
            complicationsConcept: 'High Risk Conditions'
        });

        highRiskBuilder.addComplication("Irregular abdominal girth increase")
            .whenItem(gestationalAge(programEncounter.programEnrolment, today)).greaterThan(30)
            .and.whenItem(isNormalAbdominalGirthIncrease(programEncounter.programEnrolment, programEncounter, programEncounter.encounterDateTime)).is.not.truthy;

        let abdominalGirthHighRisk = highRiskBuilder.getComplications();
        let highRiskConditions = lib.C.findValue(decisions['encounterDecisions'], 'High Risk Conditions');
        [].push.apply(highRiskConditions,abdominalGirthHighRisk.value);


        const referralAdvice = new ComplicationsBuilder({
            programEnrolment: programEncounter.programEnrolment,
            programEncounter: programEncounter,
            complicationsConcept: 'Refer to the hospital for'
        });

        referralAdvice.addComplication("Irregular abdominal girth increase")
            .whenItem(gestationalAge(programEncounter.programEnrolment, today)).greaterThan(30)
            .and.whenItem(isNormalAbdominalGirthIncrease(programEncounter.programEnrolment, programEncounter, programEncounter.encounterDateTime)).is.not.truthy;


        let adominalGirthreferralAdvice = referralAdvice.getComplications();
        let referralAdvices = lib.C.findValue(decisions['encounterDecisions'], 'Refer to the hospital for');
        [].push.apply(referralAdvices,adominalGirthreferralAdvice.value);

        return decisions;

    }

}

module.exports = {RegistrationFormHandlerLBP, ChildChecklists, DeliveryFormHandlerLBP, ANCDecisionsLBP};