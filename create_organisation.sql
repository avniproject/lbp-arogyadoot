
CREATE ROLE lokbiradari_prakalp NOINHERIT PASSWORD 'password';

GRANT lbp TO openchs;

GRANT ALL ON ALL TABLES IN SCHEMA public TO lbp;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO lbp;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO lbp;

INSERT into organisation(name, db_user, uuid, parent_organisation_id)
    SELECT 'Lokbiradari Prakalp', 'lokbiradari_prakalp', '3de82517-7a60-4b83-b98a-53d9c89eba02', id FROM organisation WHERE name = 'OpenCHS';
