package client;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.Reader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map.Entry;
import java.util.Set;

import org.apache.commons.io.FileUtils;
import org.json.JSONObject;

public class JsonClient {

	public static void main(String[] args) {
		System.out.println("start");
		try {
			
			DbAdapter dbAdapter = DbAdapter.GetInstance();
			
			HashMap<String, HashMap<String, Float>> submissions = 
					Get_TotalScores(dbAdapter.Get_ResultSet(DBQuery.GetTotalScore(733)));
			
			String inputText = GenerateInputText(submissions);
			
			/*String inputText = "{";
			inputText += "\"expert_grades\": {\"submission1\": 70, \"submission2\":60, \"submission3\":80},";
			inputText += "\"submission1\": {\"stu1\":91, \"stu3\":61},";
			inputText += "\"submission2\": {\"stu1\":62, \"stu2\":90},";
			inputText += "\"submission3\": {\"stu2\":92, \"stu3\":81}}";*/
			
			GetJsonObject(inputText);
			System.out.println("exit");
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	@SuppressWarnings("unchecked")
	public static HashMap<String, HashMap<String, Float>> Get_TotalScores(ResultSet _resultset)
			throws SQLException, IOException {
		HashMap<String, Float> reviewer_records = new HashMap<String, Float>();
		HashMap<String, HashMap<String, Float>> submissions = new HashMap<String, HashMap<String, Float>>();
		int reviewer_id = 0;
		int submission_id = 0;
		float total_score = 0.0f;
		while (_resultset.next()) {
			reviewer_id = _resultset.getInt(1);
			total_score = _resultset.getFloat(3);
			if (_resultset.isFirst()){
				submission_id = _resultset.getInt(2);
			}
			//if this submission is the same as last one
			if (submission_id == _resultset.getInt(2)){
				reviewer_records.put("stu" + Integer.toString(reviewer_id), total_score);
			}
			else{
				submissions.put("submission" + Integer.toString(submission_id), (HashMap<String, Float>) reviewer_records.clone());
				submission_id = _resultset.getInt(2);
				reviewer_records.clear();
				reviewer_records.put("stu" + Integer.toString(reviewer_id), total_score);
			}
			
		}
		//put last reviewer_records into `submission` hash map!!!
		submissions.put("submission" + Integer.toString(submission_id), (HashMap<String, Float>) reviewer_records.clone());
		reviewer_records.clear();
		/*for (Entry<String, HashMap<String, Float>> entry : submissions.entrySet()) {
			System.out.println(entry.getKey()+" : "+entry.getValue());
		}*/

		return submissions;
	}
	
	public static String readFile(String filename) throws IOException{
		String result = null;
		try {
			File file = new File(filename);
			result = FileUtils.readFileToString(file);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return result;
	}
	
	public static String GenerateInputText(HashMap<String, HashMap<String, Float>> submissions){
		/*String inputText = "{\"expert_grades\": {" +
						   "\"submission23910\": 86, \"submission23926\":88, \"submission23913\":93," +
						   "\"submission23907\": 90, \"submission23924\":90, \"submission23906\":95," +
						   "\"submission23917\": 89, \"submission23908\":82},";*/
		String inputText = "{";
		//"{"expert_grades": {"submission1": 90, "submission2":88, "submission3":93},  #optional
		//"submission1": {"stu1":91, "stu3":99},"submission2": {"stu5":92, "stu8":90},"submission3": {"stu2":91, "stu4":88}}"
		Set<String> submission_ids = submissions.keySet();
		Iterator<String> submission_iterator = submission_ids.iterator();
		String submission_key;
		HashMap<String, Float> review_records;
		Set<String> reviewer_ids;
		Iterator<String> reviewer_iterator;
		String reviewer_key;
		Float score;
		//Loop all submissions
		while (submission_iterator.hasNext()) {
			submission_key = submission_iterator.next();
			review_records = submissions.get(submission_key);
			inputText +=  "\"" + submission_key + "\":{";
			reviewer_ids = review_records.keySet();
			reviewer_iterator = reviewer_ids.iterator();
			//Loop all reivew_records
			while (reviewer_iterator.hasNext()) {
				reviewer_key = reviewer_iterator.next();
				score = review_records.get(reviewer_key);
				inputText += "\"" + reviewer_key + "\":" + score;
				//if the last review_records for this submission
				if (!reviewer_iterator.hasNext()){
					inputText += "}";
				}
				else{
					inputText += ",";
				}
			}
			if (!submission_iterator.hasNext()){
				inputText += "}";
			}
			else{
				inputText += ",";
			}
		}
		
		return inputText;
	}
	
	private static JSONObject GetJsonObject(String inputText)
			throws IOException {
		// web service url
		URL url = new URL("http://152.7.99.160:3000//calculations/reputation_algorithms");
		HttpURLConnection conn = (HttpURLConnection) url.openConnection();
		conn.setDoOutput(true);
		conn.setRequestMethod("POST");
		conn.setRequestProperty("Content-Type", "application/json");
		OutputStream os = conn.getOutputStream();
		os.write(inputText.getBytes());
		os.flush();
		JSONObject json = null;
		try {
			BufferedReader br = new BufferedReader(new InputStreamReader(
					(conn.getInputStream())));
			String jsonText = readAll(br);
			System.out.println("Send msg:" + inputText);
			System.out.println("Received msg:" + jsonText.toString());
			System.out.println();
			json = new JSONObject(jsonText);
		} catch (Exception e) {
			// to-do logging
		}
		conn.disconnect();
		return json;

	}

	private static String readAll(Reader rd) throws IOException {
		StringBuilder sb = new StringBuilder();
		int cp;
		while ((cp = rd.read()) != -1) {
			sb.append((char) cp);
		}
		return sb.toString();
	}
}
