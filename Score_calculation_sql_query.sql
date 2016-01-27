SELECT 
    U.id as user_id,
    RM.reviewee_id AS submission_id,
    T.name,
    SUM(A.answer * Q.weight) / SUM(QN.max_question_score * Q.weight) * 100 AS total_score
FROM
    answers A
        INNER JOIN
    questions Q ON A.question_id = Q.id
        INNER JOIN
    questionnaires QN ON Q.questionnaire_id = QN.id
        INNER JOIN
    responses R ON A.response_id = R.id
        INNER JOIN
    response_maps RM ON R.map_id = RM.id
        INNER JOIN
    participants P ON P.id = RM.reviewer_id
        INNER JOIN
    users U ON U.id = P.user_id
        INNER JOIN
    Teams T ON T.id = RM.reviewee_id
        INNER JOIN
    signed_up_teams SU_team ON SU_team.team_id = T.id
WHERE
    RM.type = 'ReviewResponseMap'
        AND RM.reviewed_object_id = 733
        AND A.answer IS NOT NULL
        AND Q.type = 'Criterion'
        AND R.round = 2
        AND SU_team.is_waitlisted = 0
GROUP BY RM.id
ORDER BY RM.reviewee_id;