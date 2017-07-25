package ejb3inaction.example;

import javax.ejb.EJB;
import javax.naming.*;

public class HelloUserClient {
      
        private static HelloUser helloUser;

    	public  static void main(String[] args) {
             System.out.println("Invoking EJB");     

             try
             {
              Context ctx = new InitialContext();
              helloUser = (HelloUser) ctx.lookup("HelloUser#ejb3inaction.example.HelloUser");
     
             
             helloUser.sayHello("Curious George");
             System.out.println("Invoked EJB successfully .. see server console for output");     
            }
            catch (Exception e)
            {
              e.printStackTrace();
             }
}
}
