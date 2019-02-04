const IDI = require('openchs-idi');
const secrets = require('../secrets.json');
secrets.prod = secrets['lbp-arogyadoot'].prod;

module.exports = IDI.configure({
    "name": "lbp-arogyadoot",
    "chs-admin": "admin",
    "org-name": "Lokbiradari Prakalp",
    "org-admin": "lbp-admin",
    "secrets": secrets,
    "files": {
        "adminUsers": {
            "prod": ["admin-user.json"],
            "dev": ["users/dev-admin-user.json"]
        },
        "forms": [
            "child/checklistForm.json",
            "registrationForm.json"
        ],
        "formDeletions": [
            "child/exitDeletions.json",
            "mother/enrolmentDeletions.json"
        ],
        "formAdditions": [
            "mother/deliveryAdditions.json",
            "mother/enrolmentAdditions.json",
            "mother/pncAdditions.json"
        ],
        "catchments": [
            "catchments.json"
        ],
        "checklistDetails": [
            "child/checklist.json"
        ],
        "concepts": [
            "concepts.json"
        ],
        "locations": [
            "locations.json"
        ],
        "operationalEncounterTypes": [
            "operationalModules/operationalEncounterTypes.json"
        ],
        "operationalPrograms": [
            "operationalModules/operationalPrograms.json"
        ],
        "operationalSubjectTypes": [
            "operationalModules/operationalSubjectTypes.json"
        ],
        "users": {
            "dev": ["users/dev-users.json"]
        },
        "rules": [
            require('path').resolve("./rules/rules.js")
        ],
        "organisationSql": [
            "create_organisation.sql"
        ]
    }
});