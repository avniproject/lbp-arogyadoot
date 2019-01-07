
CREATE ROLE lokbiradari_prakalp NOINHERIT PASSWORD 'password';

GRANT lokbiradari_prakalp TO openchs;

GRANT ALL ON ALL TABLES IN SCHEMA public TO lokbiradari_prakalp;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO lokbiradari_prakalp;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO lokbiradari_prakalp;

INSERT into organisation(name, db_user, uuid, parent_organisation_id)
    SELECT 'Lokbiradari Prakalp', 'lokbiradari_prakalp', '3de82517-7a60-4b83-b98a-53d9c89eba02', id FROM organisation WHERE name = 'OpenCHS';

--              name             |           db_user            |                 uuid                 | is_voided |        parent
-- ------------------------------+------------------------------+--------------------------------------+-----------+---------------------
--  Lokbiradari Prakalp Training | lokbiradari_prakalp_training | 17ceb192-ce03-4e08-b934-53b0c8d74034 | f         | Lokbiradari Prakalp
