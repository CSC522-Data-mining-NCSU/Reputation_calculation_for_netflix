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
					Get_TotalScores(dbAdapter.Get_ResultSet(DBQuery.GetTotalScore(736, true)));
			
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
		String inputText = "{";
		//expert grades of Wiki 1a and 1b (724, 733)
		//inputText += "\"expert_grades\": {\"submission23967\":93, \"submission23969\":89, \"submission23971\":95, \"submission23972\":86, \"submission23973\":91, \"submission23975\":94, \"submission23979\":90, \"submission23980\":94, \"submission23981\":87, \"submission23982\":79, \"submission23983\":91, \"submission23986\":92, \"submission23987\":91, \"submission23988\":93, \"submission23991\":98, \"submission23992\":91, \"submission23994\":87, \"submission23995\":93, \"submission23998\":92, \"submission23999\":87, \"submission24000\":93, \"submission24001\":93, \"submission24006\":96, \"submission24007\":87, \"submission24008\":92, \"submission24009\":92, \"submission24010\":93, \"submission24012\":94, \"submission24013\":96, \"submission24016\":91, \"submission24018\":93, \"submission24024\":96, \"submission24028\":88, \"submission24031\":94, \"submission24040\":93, \"submission24043\":95, \"submission24044\":91, \"submission24046\":95, \"submission24051\":92, \"submission24100\":90, \"submission24079\":92, \"submission24298\":86, \"submission24545\":92, \"submission24082\":96, \"submission24080\":86, \"submission24284\":92, \"submission24534\":93, \"submission24285\":94, \"submission24297\":91},";
		//expert grades of program 1 (735)
		//inputText += "\"expert_grades\": {\"submission24083\":96.084,\"submission24085\":88.811,\"submission24086\":100,\"submission24087\":100,\"submission24088\":92.657,\"submission24091\":96.783,\"submission24092\":90.21,\"submission24093\":100,\"submission24097\":90.909,\"submission24098\":98.601,\"submission24101\":99.301,\"submission24278\":98.601,\"submission24279\":72.727,\"submission24281\":54.476,\"submission24289\":94.406,\"submission24291\":99.301,\"submission24293\":93.706,\"submission24296\":98.601,\"submission24302\":83.217,\"submission24303\":91.329,\"submission24305\":100,\"submission24307\":100,\"submission24308\":100,\"submission24311\":95.804,\"submission24313\":91.049,\"submission24314\":100,\"submission24315\":97.483,\"submission24316\":91.608,\"submission24317\":98.182,\"submission24320\":90.21,\"submission24321\":90.21,\"submission24322\":98.601},";
		//initial hamer reputation of Wiki 1a and 1b (724, 733)
		//inputText += "\"initial_hamer_reputation\":{\"stu5687\":1.267,\"stu5787\":2.15,\"stu5790\":3.426,\"stu5791\":1.48,\"stu5795\":1.121,\"stu5796\":0.643,\"stu5797\":2.159,\"stu5800\":1.269,\"stu5801\":2.659,\"stu5804\":2.16,\"stu5806\":0.809,\"stu5807\":2.096,\"stu5808\":4.223,\"stu5810\":1.034,\"stu5811\":3.765,\"stu5814\":0.931,\"stu5815\":2.504,\"stu5818\":0.257,\"stu5820\":2.477,\"stu5822\":2.31,\"stu5824\":2.113,\"stu5825\":2.856,\"stu5826\":2.296,\"stu5827\":0.438,\"stu5828\":0.729,\"stu5829\":3.388,\"stu5830\":0.893,\"stu5832\":2.551,\"stu5835\":1.579,\"stu5837\":0.578,\"stu5839\":0.743,\"stu5840\":0.996,\"stu5841\":0.506,\"stu5843\":2.432,\"stu5846\":1.633,\"stu5848\":0.757,\"stu5849\":0.299,\"stu5850\":2.272,\"stu5855\":0.334,\"stu5856\":0.672,\"stu5857\":2.415,\"stu5859\":2.427,\"stu5860\":0.627,\"stu5862\":0.884,\"stu5863\":0.723,\"stu5864\":1.534,\"stu5866\":0.505,\"stu5867\":2.2,\"stu5868\":2.005,\"stu5869\":0.755,\"stu5870\":0.252,\"stu5871\":2.144,\"stu5873\":0.528,\"stu5874\":0.923,\"stu5875\":1.974,\"stu5876\":1.33,\"stu5880\":0.782},";
		//initial hamer reputation of program 1 (735)
		inputText += "\"initial_hamer_reputation\":{\"stu4381\":2.649, \"stu5415\":3.022, \"stu5687\":3.578, \"stu5787\":3.142, \"stu5788\":2.424, \"stu5789\":0.134, \"stu5790\":2.885, \"stu5792\":2.27, \"stu5793\":2.317, \"stu5794\":2.219, \"stu5795\":1.232, \"stu5796\":0.832, \"stu5797\":2.946, \"stu5798\":0.225, \"stu5799\":5.365, \"stu5800\":2.749, \"stu5801\":4.161, \"stu5802\":4.78, \"stu5803\":0.366, \"stu5804\":0.262, \"stu5805\":3.016, \"stu5806\":0.561, \"stu5807\":3.028, \"stu5808\":3.435, \"stu5810\":3.664, \"stu5812\":2.638, \"stu5813\":2.621, \"stu5814\":3.035, \"stu5815\":2.985, \"stu5816\":0.11, \"stu5817\":2.16, \"stu5818\":0.448, \"stu5821\":0.294, \"stu5822\":1.874, \"stu5823\":3.339, \"stu5824\":3.597, \"stu5825\":4.033, \"stu5826\":2.962, \"stu5827\":1.49, \"stu5828\":3.208, \"stu5830\":1.211, \"stu5832\":0.406, \"stu5833\":3.04, \"stu5836\":3.396, \"stu5838\":4.519, \"stu5839\":2.974, \"stu5840\":1.952, \"stu5843\":3.515, \"stu5844\":0.627, \"stu5845\":2.355, \"stu5846\":3.604, \"stu5847\":3.847, \"stu5848\":1.488, \"stu5849\":2.078, \"stu5850\":2.957, \"stu5851\":2.774, \"stu5852\":2.345, \"stu5853\":1.717, \"stu5854\":2.275, \"stu5855\":2.216, \"stu5856\":1.4, \"stu5857\":3.463, \"stu5858\":3.132, \"stu5859\":3.327, \"stu5860\":0.965, \"stu5861\":1.683, \"stu5862\":1.647, \"stu5863\":0.457, \"stu5864\":3.901, \"stu5866\":2.402, \"stu5867\":1.509, \"stu5868\":0.198, \"stu5869\":1.434, \"stu5870\":0.43, \"stu5871\":0.654, \"stu5872\":0.854, \"stu5873\":2.645, \"stu5874\":1.988, \"stu5875\":0.089, \"stu5876\":3.438, \"stu5878\":3.763, \"stu5880\":2.444, \"stu5881\":0.316},";
				
		//Eg.
		//"{"initial_hamer_reputation": {"stu1": 0.90, "stu2":0.88, "stu3":0.93, "stu4":0.8, "stu5":0.93, "stu8":0.93},  #optional
		//"initial_lauw_reputation": {"stu1": 1.90, "stu2":0.98, "stu3":1.12, "stu4":0.94, "stu5":1.24, "stu8":1.18},  #optional
		//"expert_grades": {"submission1": 90, "submission2":88, "submission3":93},  #optional
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
