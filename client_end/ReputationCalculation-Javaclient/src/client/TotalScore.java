package client;

public class TotalScore {
	public int reviewer_id;
	public int submission_id;
	public float total_score;
	public TotalScore(int reviewer_id, int submission_id, float total_score) {
		this.reviewer_id = reviewer_id;
		this.submission_id = submission_id;
		this.total_score = total_score;
	}
	
}
