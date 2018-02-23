CREATE ROLE lokbiradari_prakalp
  NOINHERIT
  NOLOGIN;

GRANT lokbiradari_prakalp TO openchs;

GRANT ALL ON ALL TABLES IN SCHEMA public TO lokbiradari_prakalp;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO lokbiradari_prakalp;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO lokbiradari_prakalp;

INSERT INTO organisation (name, db_user, uuid)
VALUES ('Lokbiradari Prakalp', 'lokbiradari_prakalp', '3de82517-7a60-4b83-b98a-53d9c89eba02');