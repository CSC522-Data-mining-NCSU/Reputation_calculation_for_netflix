package client;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class DbAdapter {
	static DbAdapter dbAdapter;
	static Connection m_Connection;
	private DbAdapter()
	{
		
			
	}
	public static DbAdapter GetInstance() throws InstantiationException, IllegalAccessException, ClassNotFoundException, SQLException
	{
		if (dbAdapter==null)
		{
			get_Connection();
			dbAdapter=new DbAdapter();
		}
		return dbAdapter;
	}
	private static void get_Connection() throws SQLException, InstantiationException, IllegalAccessException, ClassNotFoundException
	{
		//Class.forName("com.mysql.jdbc.Driver").newInstance();
		 m_Connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/expertiza_development?user=root&password=winbobob");
	}
	@SuppressWarnings("finally")
	public ResultSet Get_ResultSet(String query)
	{
		Statement m_Statement;
		ResultSet m_ResultSet=null;
		try {
			m_Statement = m_Connection.createStatement();
			m_ResultSet = m_Statement.executeQuery(query);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally
		{
			return m_ResultSet;
		}
		
	}
	public boolean InsertQuery(String query)
	{
		Statement m_Statement;
		try {
			m_Statement = m_Connection.createStatement();
			m_Statement.execute(query);
			
			return true;
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return false;
		
	}

}
