UPDATE "NAVA"."QUIZ_447_HIST" SET CORRECT = &2, WRONG= &3, SCORE_PRCNT= &4 WHERE NAME = UPPER ('&1') AND ATTEMPT = (SELECT MAX(ATTEMPT) FROM "NAVA"."QUIZ_447_HIST" WHERE NAME = UPPER ('&1')) ;
COMMIT;
