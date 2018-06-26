const {
    RuleFactory
} = require('rules-config/rules');


// args Form UUID and type of rule "Decision" or "VisibilityRule" etc
const ANCFormProgramEncounterDecisions = RuleFactory("3a95e9b0-731a-4714-ae7c-10e1d03cebfe", "Decision");
const AnthroDecision = RuleFactory("d062907a-690c-44ca-b699-f8b2f688b075", "Decision");

//Unique Rule UUID, Rule Name, Rule Metadata if required
@ANCFormProgramEncounterDecisions("d35e3039-eeb7-4c1b-b02f-88f492163500", "Calcium 1g/Day", 1.2, {ruleData: "more"})
class Calcium1gDay { //classname of the rule
    static exec(programEncounter, decisions, context, today) { //mandatory exec function
        decisions.encounterDecisions.push({"name": "Treatment", "value": ["Calcium 1g/day"]});
        return decisions;
    }
}

@AnthroDecision("5b75c23a-9d42-42fc-a072-dcee37ba4f8f", "A", 1.3, {})
class AB {
    static exec(programEncounter, decisions, context, today) {
        console.log(decisions);
        console.log(programEncounter.encounterType);
        return decisions;
    }
}

module.exports = {Calcium1gDay, AB};