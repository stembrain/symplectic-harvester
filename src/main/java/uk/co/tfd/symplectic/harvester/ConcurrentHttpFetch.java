package uk.co.tfd.symplectic.harvester;

import java.io.IOException;
import java.net.MalformedURLException;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.MultiThreadedHttpConnectionManager;
import org.apache.commons.httpclient.methods.GetMethod;

/**
 * @author ieb
 */
public class ConcurrentHttpFetch {

    private static HttpClient client;
    static {
        MultiThreadedHttpConnectionManager connectionManager = new MultiThreadedHttpConnectionManager();
        client = new HttpClient(connectionManager);
    }
    public static String get(String url) throws MalformedURLException, IOException {
        GetMethod getMethod = new GetMethod(url);
        getMethod.setFollowRedirects(true);
        client.executeMethod(getMethod);
        return getMethod.getResponseBodyAsString();
    }
}
