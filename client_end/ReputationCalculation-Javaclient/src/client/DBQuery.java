package client;

public class DBQuery {

	public static String GetTotalScore(int assignment_id)
	{
		String query="SELECT U.id, RM.reviewee_id as submission_id, "+
					"sum(A.answer * Q.weight) / sum(QN.max_question_score * Q.weight) * 100 as total_score "+
					"from answers A  "+
					"inner join questions Q on A.question_id = Q.id "+
					"inner join questionnaires QN on Q.questionnaire_id = QN.id  "+
					"inner join responses R on A.response_id = R.id  "+
					"inner join response_maps RM on R.map_id = RM.id  "+
					"inner join participants P on P.id = RM.reviewer_id "+
					"inner join users U on U.id = P.user_id "+
					"inner join Teams T on T.id = RM.reviewee_id "+
					"inner join signed_up_teams SU_team on SU_team.team_id = T.id "+
					"where RM.type='ReviewResponseMap'  "+
					"and RM.reviewed_object_id = "+  Integer.toString(assignment_id) + " " +
					"and A.answer is not null "+
					"and Q.type ='Criterion' "+
					"and R.round=2 "+
					"and SU_team.is_waitlisted = 0 "+
					"group by RM.id  "+
					"order by RM.reviewee_id";
		return query;
	}
}
