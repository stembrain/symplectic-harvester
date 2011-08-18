/**
 *   Symplectic to Vivo Connector
 *   Copyright (c) 2011  Ian Boston
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU Affero General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Affero General Public License for more details.
 *
 *   You should have received a copy of the GNU Affero General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
package uk.co.tfd.symplectic.harvester;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.StringReader;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.apache.commons.codec.binary.Base64;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.vivoweb.harvester.util.InitLog;
import org.vivoweb.harvester.util.WebAide;
import org.vivoweb.harvester.util.args.ArgDef;
import org.vivoweb.harvester.util.args.ArgList;
import org.vivoweb.harvester.util.args.ArgParser;
import org.vivoweb.harvester.util.repo.RecordHandler;
import org.vivoweb.harvester.util.repo.RecordStreamOrigin;
import org.vivoweb.harvester.util.repo.XMLRecordOutputStream;
import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

public class SymplecticFetch implements RecordStreamOrigin {

	private static final String UPDATED_ENV = "updated";
	private static final String SCHEMA_VERSION_ENV = "api:schema-version";
	private static final String ITEMS_PER_PAGE_ENV = "items-per-page";
	private static final String RESULTS_COUNT_ENV = "results-count";
	private static final Logger LOGGER = LoggerFactory
			.getLogger(SymplecticFetch.class);
	private static String database = "symplectic";
	private RecordHandler rh;
	private OutputStreamWriter osWriter;
	
	protected static XMLRecordOutputStream baseXMLROS = new XMLRecordOutputStream(new String[]{"api:object"}, 
			"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<object xmlns=\"http://www.symplectic.co.uk/vivo/\" xmlns:api=\"http://www.symplectic.co.uk/publications/api\">\n",
			"</object>", 
			".*?id=\"(.*?)\".*?", 
			null);


	protected SymplecticFetch( RecordHandler rh,
			String database) {
		if ( rh == null ) {
			throw new RuntimeException("Record Handler cant be null");
		}
		this.rh = rh;
	}

	/**
	 * Constructor
	 * 
	 * @param argList
	 *            parsed argument list
	 * @param database
	 *            database name
	 * @throws IOException
	 *             error creating task
	 */
	protected SymplecticFetch(ArgList argList) throws IOException {
		this( RecordHandler.parseConfig(argList.get("o"),
				argList.getValueMap("O")), database);
	}

	public static void main(String[] args) {
		try {
			InitLog.initLogger(args, getParser("SymplecticFetch", database));
			LOGGER.info("SymplecticFetch: Start");
			new SymplecticFetch(getParser("SymplecticFetch", database).parse(
					args)).execute();
		} catch (Exception e) {
			LOGGER.error(e.getMessage());
			LOGGER.debug("Stacktrace:", e);
			System.out.println(getParser("SymplecticFetch", database)
					.getUsage());
			System.exit(1);
		}
		LOGGER.info("SymplecticFetch: End");
	}

	/**
	 * Executes the task
	 * 
	 * @throws IOException
	 *             error processing search
	 * @throws TransformerException 
	 * @throws TransformerFactoryConfigurationError 
	 * @throws ParserConfigurationException 
	 * @throws SAXException 
	 * @throws DOMException 
	 * @throws NoSuchAlgorithmException 
	 */
	private void execute() throws IOException, DOMException, SAXException, ParserConfigurationException, TransformerFactoryConfigurationError, TransformerException, NoSuchAlgorithmException {
		Map<String, Object> queryEnv = runESearch(false);
		int nrecords = Integer.parseInt(String.valueOf(queryEnv.get(RESULTS_COUNT_ENV)));
		int itemsPerPage = Integer.parseInt(String.valueOf(queryEnv.get(ITEMS_PER_PAGE_ENV)));
		int npages = nrecords/itemsPerPage;
		if  (nrecords%itemsPerPage > 0 ) {
			npages++;
		}

		LOGGER.info("Fetching " + nrecords + " records from search");
		for (int page = 1; page <= npages; page++) {
			fetchRecords(page);
		}
	}

	private void fetchRecords(int page) throws IOException, SAXException, ParserConfigurationException, DOMException, TransformerFactoryConfigurationError, TransformerException, NoSuchAlgorithmException {
		StringBuilder urlSb = new StringBuilder();
		urlSb.append("http://fashion.symplectic.org:2020/publications-cantab-api/objects?categories=users");
		urlSb.append("&page=");
		urlSb.append(page);
		try {
			loadUserRecords(urlSb.toString());
		} catch(MalformedURLException e) {
			throw new IOException("Query URL incorrectly formatted", e);
		}
	}
	

	
	private void loadUserRecords(String url) throws SAXException, IOException, ParserConfigurationException, DOMException, TransformerFactoryConfigurationError, TransformerException, NoSuchAlgorithmException {
		Document doc = loadXmlDocument(url);
		
		NodeList results = doc.getElementsByTagName( "api:object");
		LOGGER.info("Got {}",results.getLength()+" results ");
		for ( int i = 0; i < results.getLength(); i++ ) {
			Node result = results.item(i);
			NamedNodeMap attributes = result.getAttributes();
			String category = attributes.getNamedItem("category").getNodeValue();
			if ( "user".equals(category)) {
				loadUser(attributes.getNamedItem("href").getNodeValue());
				loadRelationships(findAttribute(result, "api:relationships","href"));
			} else {
				LOGGER.warn("Unexpected Category {} ",category);
			}
		}

		
/*		
		<api:object category="user" id="157" proprietary-id="brody" authenticating-authority="Internal" username="dorje" last-modified-when="2011-07-28T01:54:03.127+01:00" is-deleted="false" href="http://fashion.symplectic.org:2020/publications-cantab-api/users/157" created-when="2010-01-28T10:05:27.313+00:00" type-id="1">
	      <api:relationships href="http://fashion.symplectic.org:2020/publications-cantab-api/users/157/relationships"/>
	    </api:object>
*/
	}
	
	


	private void loadRelationships(String url) throws MalformedURLException, SAXException, IOException, ParserConfigurationException {		
	}

	
	private void loadUser(String userUrl) throws MalformedURLException, SAXException, IOException, ParserConfigurationException, TransformerFactoryConfigurationError, TransformerException, DOMException, NoSuchAlgorithmException {
		Document doc = loadXmlDocument(userUrl);
		Element user = (Element) doc.getElementsByTagName("api:object").item(0);
		user.setAttribute("uriref", hash(userUrl));
		String userAsString = getXmlFromNode(user);
		LOGGER.info("Got User XML as {} ",userAsString);
		if(osWriter == null) {
			osWriter = new OutputStreamWriter(baseXMLROS.clone().setRso(this), "UTF-8");
		}
		osWriter.write(userAsString);
		//file close statements.  Warning, not closing the file will leave incomplete xml files and break the translate method
		osWriter.write("\n");
		osWriter.flush();
		LOGGER.info("Writing complete");
	}
	
	public void test() {
	}

	private String hash(String userUrl) throws UnsupportedEncodingException, NoSuchAlgorithmException {
		MessageDigest md = MessageDigest.getInstance("SHA1");
		return Base64.encodeBase64URLSafeString(md.digest(userUrl.getBytes("UTF-8")));
	}

	private String getXmlFromNode(Node node) throws TransformerFactoryConfigurationError, TransformerException {
		StringWriter writer = new StringWriter();
		Transformer transformer = TransformerFactory.newInstance().newTransformer();
		transformer.transform(new DOMSource(node), new StreamResult(writer));
		String s = writer.toString().trim();
		if ( s.startsWith("<?xml")) {
			int i = s.indexOf(">");
			s = s.substring(i+1);
		}
		return s;
	}

	private Document loadXmlDocument(String url) throws MalformedURLException, SAXException, IOException, ParserConfigurationException {
		DocumentBuilderFactory docBuildFactory = DocumentBuilderFactory.newInstance();
		docBuildFactory.setIgnoringComments(true);
		String xmlDoc = WebAide.getURLContents(url);
		// doing this fixes makes it work with UTF8 chars
		return docBuildFactory.newDocumentBuilder().parse(new InputSource(new StringReader(xmlDoc)));
	}

	private String findAttribute(Node n,
			String elementName, String attrName) {
		NodeList nl = n.getChildNodes();
		for ( int i = 0; i < nl.getLength(); i++) {
			Node cn = nl.item(i);
				if ( elementName.equals(cn.getNodeName()) ) {
					return cn.getAttributes().getNamedItem(attrName).getNodeValue();
				}
		}
		return null;
	}


	/**
	 * Find out about the target system, getting parameters.
	 * @param searchTerm2
	 * @return
	 * @throws ParserConfigurationException 
	 * @throws IOException 
	 * @throws SAXException 
	 * @throws MalformedURLException 
	 */
	private Map<String, Object> runESearch( boolean logMessage) throws MalformedURLException, SAXException, IOException, ParserConfigurationException {
       		
		String firstPageURL = "http://fashion.symplectic.org:2020/publications-cantab-api/objects?categories=users";
		Map<String, Object> queryEnv = new HashMap<String, Object>();
		
		Document doc = loadXmlDocument(firstPageURL);
		
		Node pagination = doc.getElementsByTagName("api:pagination").item(0);
		NamedNodeMap nnmap = pagination.getAttributes();
		queryEnv.put(RESULTS_COUNT_ENV, nnmap.getNamedItem(RESULTS_COUNT_ENV).getNodeValue());
		queryEnv.put(ITEMS_PER_PAGE_ENV, nnmap.getNamedItem(ITEMS_PER_PAGE_ENV).getNodeValue());
		queryEnv.put(SCHEMA_VERSION_ENV, doc.getElementsByTagName(SCHEMA_VERSION_ENV).item(0).getNodeValue());
		queryEnv.put(UPDATED_ENV, doc.getElementsByTagName(UPDATED_ENV).item(0).getNodeValue());
		
		return queryEnv;
	}


	/**
	 * Get the ArgParser for this task
	 * 
	 * @param appName
	 *            the application name
	 * @param database
	 *            the database name
	 * @return the ArgParser
	 */
	protected static ArgParser getParser(String appName, String database) {
		ArgParser parser = new ArgParser(appName);
		parser.addArgument(new ArgDef().setShortOption('o')
				.setLongOpt("output")
				.setDescription("RecordHandler config file path")
				.withParameter(true, "CONFIG_FILE")
				.setRequired(false));
		parser.addArgument(new ArgDef()
				.setShortOption('O')
				.setLongOpt("outputOverride")
				.withParameterValueMap("RH_PARAM", "VALUE")
				.setDescription(
						"override the RH_PARAM of output recordhandler using VALUE")
				.setRequired(false));
		return parser;
	}

	@Override
	public void writeRecord(String id, String data) throws IOException {
		LOGGER.info("Adding Record " + id);
		rh.addRecord(id, data, getClass());
	}

}
