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

import ch.qos.logback.core.util.Loader;

public class SymplecticFetch {

	private static final String UPDATED_ENV = "updated";
	private static final String SCHEMA_VERSION_ENV = "api:schema-version";
	private static final String ITEMS_PER_PAGE_ENV = "items-per-page";
	private static final String RESULTS_COUNT_ENV = "results-count";
	private static final Logger LOGGER = LoggerFactory
			.getLogger(SymplecticFetch.class);
	private static String database = "symplectic";
	private RecordHandler rh;
	private OutputStreamWriter osWriter;


	protected SymplecticFetch(RecordHandler rh, String database) {
		if (rh == null) {
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
		this(RecordHandler.parseConfig(argList.get("o"),
				argList.getValueMap("O")), database);
	}

	public static void main(String[] args) {
		try {
			InitLog.initLogger(args, getParser("SymplecticFetch", database));
			LOGGER.info("SymplecticFetch: Start");
			SymplecticFetch sf = new SymplecticFetch(getParser(
					"SymplecticFetch", database).parse(args));
			sf.execute();
		} catch (Exception e) {
			LOGGER.error(e.getMessage());
			LOGGER.debug("Stacktrace:", e);
			System.out.println(getParser("SymplecticFetch", database)
					.getUsage());
			System.exit(1);
		}
		LOGGER.info("SymplecticFetch: End");
	}

	private OutputStreamWriter getOsWriter()
			throws UnsupportedEncodingException {
		return osWriter;
	}

	/**
	 * Executes the task
	 * 
	 * @throws UnsupportedEncodingException
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

	private void execute() throws DOMException, NoSuchAlgorithmException,
			UnsupportedEncodingException, IOException, SAXException,
			ParserConfigurationException, TransformerFactoryConfigurationError,
			TransformerException {
		execute(new UserCategory(rh));
		execute(new PublicationCategory(rh));
	}

	private void execute(Category category) throws IOException, DOMException,
			SAXException, ParserConfigurationException,
			TransformerFactoryConfigurationError, TransformerException,
			NoSuchAlgorithmException {
		Map<String, Object> queryEnv = runESearch(false, category);
		int nrecords = Integer.parseInt(String.valueOf(queryEnv
				.get(RESULTS_COUNT_ENV)));
		int itemsPerPage = Integer.parseInt(String.valueOf(queryEnv
				.get(ITEMS_PER_PAGE_ENV)));
		int npages = nrecords / itemsPerPage;
		if (nrecords % itemsPerPage > 0) {
			npages++;
		}
		
		// for the moment, limit to 20 pages.
		npages = Math.min(npages, 20);

		LOGGER.info("Fetching " + nrecords + " records from search");
		for (int page = 1; page <= npages; page++) {
			fetchRecords(page, category);
		}
	}

	private void fetchRecords(int page, Category category) throws IOException,
			SAXException, ParserConfigurationException, DOMException,
			TransformerFactoryConfigurationError, TransformerException,
			NoSuchAlgorithmException {
		StringBuilder urlSb = new StringBuilder();
		urlSb.append("http://fashion.symplectic.org:2020/publications-cantab-api/objects?categories=");
		urlSb.append(category.getId());
		urlSb.append("&page=");
		urlSb.append(page);
		try {
			loadRecords(urlSb.toString(), category);
		} catch (MalformedURLException e) {
			throw new IOException("Query URL incorrectly formatted", e);
		}
	}

	private void loadRecords(String url, Category requestedCategory)
			throws SAXException, IOException, ParserConfigurationException,
			DOMException, TransformerFactoryConfigurationError,
			TransformerException, NoSuchAlgorithmException {
		Document doc = XmlAide.loadXmlDocument(url);

		NodeList results = doc.getElementsByTagName("api:object");
		LOGGER.info("Got {}", results.getLength() + " results ");
		for (int i = 0; i < results.getLength(); i++) {
			Node result = results.item(i);
			NamedNodeMap attributes = result.getAttributes();
			String category = attributes.getNamedItem("category")
					.getNodeValue();
			if (requestedCategory.handles(category)) {
				requestedCategory.loadCategory(attributes.getNamedItem("href")
						.getNodeValue());
				requestedCategory.loadRelationships(XmlAide.findAttribute(
						result, "api:relationships", "href"));
			} else {
				LOGGER.warn("Unexpected Category [{}] != [{}] ", requestedCategory.getId(), category);
			}
		}

	}

	/**
	 * Find out about the target system, getting parameters.
	 * 
	 * @param category
	 * @param searchTerm2
	 * @return
	 * @throws ParserConfigurationException
	 * @throws IOException
	 * @throws SAXException
	 * @throws MalformedURLException
	 */
	private Map<String, Object> runESearch(boolean logMessage, Category category)
			throws MalformedURLException, SAXException, IOException,
			ParserConfigurationException {

		String firstPageURL = "http://fashion.symplectic.org:2020/publications-cantab-api/objects?categories="
				+ category.getId();
		Map<String, Object> queryEnv = new HashMap<String, Object>();

		Document doc = XmlAide.loadXmlDocument(firstPageURL);

		Node pagination = doc.getElementsByTagName("api:pagination").item(0);
		NamedNodeMap nnmap = pagination.getAttributes();
		queryEnv.put(RESULTS_COUNT_ENV, nnmap.getNamedItem(RESULTS_COUNT_ENV)
				.getNodeValue());
		queryEnv.put(ITEMS_PER_PAGE_ENV, nnmap.getNamedItem(ITEMS_PER_PAGE_ENV)
				.getNodeValue());
		queryEnv.put(SCHEMA_VERSION_ENV,
				doc.getElementsByTagName(SCHEMA_VERSION_ENV).item(0)
						.getNodeValue());
		queryEnv.put(UPDATED_ENV, doc.getElementsByTagName(UPDATED_ENV).item(0)
				.getNodeValue());

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
				.withParameter(true, "CONFIG_FILE").setRequired(false));
		parser.addArgument(new ArgDef()
				.setShortOption('O')
				.setLongOpt("outputOverride")
				.withParameterValueMap("RH_PARAM", "VALUE")
				.setDescription(
						"override the RH_PARAM of output recordhandler using VALUE")
				.setRequired(false));
		return parser;
	}

}
