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

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactoryConfigurationError;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.vivoweb.harvester.util.InitLog;
import org.vivoweb.harvester.util.args.ArgDef;
import org.vivoweb.harvester.util.args.ArgList;
import org.vivoweb.harvester.util.args.ArgParser;
import org.vivoweb.harvester.util.repo.RecordHandler;
import org.w3c.dom.DOMException;
import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

public class SymplecticFetch {

	private static final String UPDATED_ENV = "updated";
	private static final String SCHEMA_VERSION_ENV = "api:schema-version";
	private static final String ITEMS_PER_PAGE_ENV = "items-per-page";
	private static final String RESULTS_COUNT_ENV = "results-count";
	private static final Logger LOGGER = LoggerFactory
			.getLogger(SymplecticFetch.class);
	private static String database = "symplectic";
	private RecordHandler rh;


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
			sf.execute("http://fashion.symplectic.org:2020/publications-cantab-api/objects?categories=");
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
	 * @param baseUrl 
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
	 * @throws AtomEntryLoadException 
	 */

	private void execute(String baseUrl) throws DOMException, NoSuchAlgorithmException,
			UnsupportedEncodingException, IOException, SAXException,
			ParserConfigurationException, TransformerFactoryConfigurationError,
			TransformerException, AtomEntryLoadException {
		Map<String, AtomEntryLoader> toLoad = new LinkedHashMap<String,AtomEntryLoader>() {
			@Override
			public AtomEntryLoader put(String url, AtomEntryLoader loader) {
				LOGGER.info("ToLoad Added {} {}",url,loader);
				return super.put(url, loader);
			}
			
			@Override
			public AtomEntryLoader remove(Object url) {
				LOGGER.info("ToLoad Removed {} {}",url);
				return super.remove(url);
			}
		};
		Set<String> loaded = new HashSet<String>(){
			@Override
			public boolean add(String e) {
				LOGGER.info("Loaded {} ",e);
				return super.add(e);
			}
		};
		load(toLoad,loaded);
		toLoad.put(baseUrl+"user", new APIObject(rh, "user", toLoad, loaded, true));
		int i = 0;
		while(toLoad.size() > 0 && i < 200 ) {
			LOGGER.info("ToDo list contains {} urls ",toLoad.size());
			Entry<String, AtomEntryLoader> next = toLoad.entrySet().iterator().next();
			AtomEntryLoader loader = next.getValue();
			if ( loader.isList() ) {
				LOGGER.info("Loading List {} ",next.getKey());
				execute(loader, next.getKey());
				loaded.add(next.getKey());
				toLoad.remove(next.getKey());							
			} else {
				LOGGER.info("Loading Object {} ",next.getKey());
				loadRecords(next.getKey(),loader);
				loaded.add(next.getKey());
				toLoad.remove(next.getKey());							
			}
			i++;
			checkpoint(toLoad, loaded);
		}
		LOGGER.info("End ToDo list contains {} urls ",toLoad.size());
		for (String l : loaded ) {
			LOGGER.info("Loaded {} ",l);
		}
		checkpoint(toLoad, loaded);
		
	}

	private void checkpoint(Map<String, AtomEntryLoader> toLoad,
			Set<String> loaded) throws IOException {
		File f = new File("loadstate.chk");
		DataOutputStream out = new DataOutputStream(new FileOutputStream(f));
		out.writeLong(System.currentTimeMillis());
		out.writeInt(toLoad.size());
		out.writeInt(loaded.size());
		for ( Entry<String, AtomEntryLoader> e : toLoad.entrySet()) {
			out.writeUTF(e.getKey());
			out.writeUTF(e.getValue().getType());
			out.writeBoolean(e.getValue().isList());
		}
		for ( String s : loaded) {
			out.writeUTF(s);
		}
		out.close();
		File loadstate = new File("loadstate");
		File loadstateSafe = new File("loadstate.safe");
		loadstateSafe.delete();
		loadstate.renameTo(loadstateSafe);
		f.renameTo(new File("loadstate"));
		loadstateSafe.delete();
		LOGGER.info("Checkpoint done");
	}

	private void load(Map<String, AtomEntryLoader> toLoad, Set<String> loaded) throws IOException {
		File loadstate = new File("loadstate");
		File loadstateSafe = new File("loadstate.safe");
		File toloadFile = null;
		if ( loadstate.exists()) {
			toloadFile = loadstate;
		} else if ( loadstateSafe.exists()) {
			toloadFile = loadstateSafe;
		} else {
			return;
		}
		DataInputStream in = new DataInputStream(new FileInputStream(toloadFile));
		long lastSave = in.readLong();
		int ntoload = in.readInt();
		int nloaded = in.readInt();
		toLoad.clear();
		loaded.clear();
		for ( int i = 0; i < ntoload; i++) {
			String url = in.readUTF();
			String type = in.readUTF();
			boolean list = in.readBoolean();
			if ( "relationship".equals(type)) {
				toLoad.put(url, new APIRelationship(rh, toLoad, loaded, list));
			} else {
				toLoad.put(url, new APIObject(rh, type, toLoad, loaded, list));
			}
		}
		for ( int i = 0; i < nloaded; i++) {
			loaded.add(in.readUTF());
		}
		LOGGER.info("Checkpoint Loaded {} {}",toLoad.size(), loaded.size());
		
	}

	private void execute(AtomEntryLoader category, String firstPageUrl) throws IOException, DOMException,
			SAXException, ParserConfigurationException,
			TransformerFactoryConfigurationError, TransformerException,
			NoSuchAlgorithmException, AtomEntryLoadException {
		Map<String, Object> queryEnv = runESearch(false, firstPageUrl);
		int nrecords = Integer.parseInt(String.valueOf(queryEnv
				.get(RESULTS_COUNT_ENV)));
		int itemsPerPage = Integer.parseInt(String.valueOf(queryEnv
				.get(ITEMS_PER_PAGE_ENV)));
		int npages = nrecords / itemsPerPage;
		if (nrecords % itemsPerPage > 0) {
			npages++;
		}
		
		// for the moment, limit to 20 pages.
		npages = Math.min(npages, 1);

		LOGGER.info("Fetching " + nrecords + " records from search");
		for (int page = 1; page <= npages; page++) {
			fetchRecords(page, category, firstPageUrl);
		}
	}

	private void fetchRecords(int page, AtomEntryLoader category, String firstPageUrl) throws IOException,
			SAXException, ParserConfigurationException, DOMException,
			TransformerFactoryConfigurationError, TransformerException,
			NoSuchAlgorithmException, AtomEntryLoadException {
		StringBuilder urlSb = new StringBuilder();
		urlSb.append(firstPageUrl);
		if ( firstPageUrl.contains("?"))  {
		    urlSb.append("&page=");
		} else {
			urlSb.append("?page=");		
		}
		urlSb.append(page);
		category.addPage(urlSb.toString());
	}

	private void loadRecords(String url, AtomEntryLoader requestedCategory)
			throws AtomEntryLoadException, MalformedURLException, SAXException, IOException, ParserConfigurationException {
		Document doc = XmlAide.loadXmlDocument(url);

		NodeList results = doc.getElementsByTagName("entry");
		LOGGER.info("Got {}", results.getLength() + " results ");
		for (int i = 0; i < results.getLength(); i++) {
			requestedCategory.loadEntry(results.item(i));
		}

	}

	/**
	 * Find out about the target system, getting parameters.
	 * 
	 * @param category
	 * @param firstPageURL 
	 * @param searchTerm2
	 * @return
	 * @throws ParserConfigurationException
	 * @throws IOException
	 * @throws SAXException
	 * @throws MalformedURLException
	 */
	private Map<String, Object> runESearch(boolean logMessage, String firstPageURL)
			throws MalformedURLException, SAXException, IOException,
			ParserConfigurationException {
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
