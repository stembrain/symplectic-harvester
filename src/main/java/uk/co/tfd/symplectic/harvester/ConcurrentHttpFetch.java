package uk.co.tfd.symplectic.harvester;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.MultiThreadedHttpConnectionManager;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.io.IOUtils;

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
        InputStream in = getMethod.getResponseBodyAsStream();
        // Force the input stream to be UTF-8. This is wrong, but if the Elements server is misconfigured 
        // With no charset defined then its the only way of getting UTF-8 data
        String content = IOUtils.toString(in, "UTF-8");
        in.close();
        return content;
    }
}
