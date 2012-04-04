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

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.NoSuchAlgorithmException;
import java.sql.SQLException;
import java.util.Map.Entry;
import java.util.concurrent.Callable;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.FutureTask;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactoryConfigurationError;

import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.vivoweb.harvester.util.InitLog;
import org.vivoweb.harvester.util.args.ArgDef;
import org.vivoweb.harvester.util.args.ArgList;
import org.vivoweb.harvester.util.args.ArgParser;
import org.vivoweb.harvester.util.repo.RecordHandler;
import org.w3c.dom.DOMException;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

public class SymplecticFetch {

	/**
	 * boolean arg, if true, lists will be re-fetched and anything that is new
	 * will get fetched, default is false
	 */
	private static final String UPDATE_LIST_ARG = "updateList";
	/**
	 * Integer Argument name: The max number of pages that should be loaded from
	 * a list, default is 20
	 */
	private static final String LIMIT_LIST_PAGES_ARG = "limitListPages";
	/**
	 * Integer Argument name: The maximum number of URLs to get in a single run,
	 * default is 10000
	 */
	private static final String MAX_URL_GET_ARG = "maxUrlGet";
	/**
	 * String Argument name: The URL of the categories in the Elements server,
	 * no default, required
	 */
	private static final String URL_ARG = "url";
        private static final String OBJECT_TYPES_ARG = "categories";
	private static final Logger LOGGER = LoggerFactory
			.getLogger(SymplecticFetch.class);
	private static String database = "symplectic";
	private RecordHandler rh;
	private String baseUrl;
	private int maxUrlFetch;
	private int limitListPages;
	private boolean updateLists;
    private String[] objectTypes;
    private long lastLog = System.currentTimeMillis();

	protected SymplecticFetch(RecordHandler rh, String database) {
		if (rh == null) {
			throw new RuntimeException("Record Handler cant be null");
		}
		System.err.println("Using record handler "+rh);
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
		baseUrl = argList.get(URL_ARG);
		maxUrlFetch = Integer.parseInt(argList.get(MAX_URL_GET_ARG));
		limitListPages = Integer.parseInt(argList.get(LIMIT_LIST_PAGES_ARG));
		updateLists = Boolean.parseBoolean(argList.get(UPDATE_LIST_ARG));
		objectTypes = StringUtils.split(argList.get(OBJECT_TYPES_ARG),",");
		LOGGER.info("Config: Elements API at {} ",baseUrl);
		LOGGER.info("Config: Max Number of URLs to fetch {} ",maxUrlFetch);
		LOGGER.info("Config: Max Number of Pages to list {} ",limitListPages);
		LOGGER.info("Config: Refetch lists {} ",updateLists);
		LOGGER.info("To change any of these edit {} ",argList.get("X"));
	}

	public static void main(String[] args) {
		try {
			InitLog.initLogger(args, getParser("SymplecticFetch", database));
			LOGGER.info("SymplecticFetch: Start");
			SymplecticFetch sf = new SymplecticFetch(getParser(
					"SymplecticFetch", database).parse(args));
			sf.execute();
		} catch (Exception e) {
			LOGGER.error(e.getMessage(), e);
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

	private void execute() throws DOMException, NoSuchAlgorithmException,
			UnsupportedEncodingException, IOException, SAXException,
			ParserConfigurationException, TransformerFactoryConfigurationError,
			TransformerException {
		ProgressTracker progress = null;
		try {
			progress = new JDBCProgressTrackerImpl(rh, limitListPages, updateLists, objectTypes);
		} catch (SQLException e) {
			LOGGER.info(e.getMessage(),e);
			progress = new FileProgressTrackerImpl("loadstate", rh,
					limitListPages, updateLists, objectTypes);
		} catch (IOException e ) {
			LOGGER.info(e.getMessage(),e);
			progress = new FileProgressTrackerImpl("loadstate", rh,
					limitListPages, updateLists, objectTypes);			
		}
		
		// re-scan relationships to extract API objects
		// reScanRelationships(progress);
		progress.toload(baseUrl + "/objects?categories=user", new APIObjects(rh, "users", progress,
				limitListPages, objectTypes));
		// progress.toload(baseUrl+"publication", new APIObjects(rh,
		// "publications", progress));
		int i = 0;
		int threadPoolSize = 20;
		ExecutorService executorService = Executors.newFixedThreadPool(threadPoolSize);
		final ConcurrentHashMap<String, FutureTask<String>> worklist = new ConcurrentHashMap<String, FutureTask<String>>();
		while ( i < maxUrlFetch) {
			Entry<String, AtomEntryLoader> next = progress.next();
			LOGGER.info("Got Next {} ", next);
		        if ( next == null ) {
		            int startingWorklistSize = worklist.size();
                            while ( worklist.size() > 0 && worklist.size() >= startingWorklistSize ) {
                                try {
                                    Thread.sleep(500);
                                } catch (InterruptedException e) {
                                }
                                consumeTasks(worklist, progress);
                            }
                            if (!progress.hasPending() && worklist.size() == 0) {
                                break; // there are none left to come, the workers are empty, and so is pending
                            }
		        } else {	                        
	                        final AtomEntryLoader loader = next.getValue();
        		        final String key = next.getKey();
        		        FutureTask<String> task = new FutureTask<String>(new Callable<String>() {
        
                                        @Override
                                        public String call() throws Exception {
                                          
                                            try {
                                                    loader.loadEntry(key);
                                            } catch (Exception e) {
                                                    LOGGER.error(e.getMessage(), e);
                                            }
                                            return "Done Loading "+key;
                                        }
                                });
                                worklist.put(key, task);
                                executorService.execute(task);
                                i++;
                                // dont overfill the queue
        		        while ( worklist.size() > threadPoolSize*2 ) {
        		            try {
        		                 Thread.sleep(500);
                                    } catch (InterruptedException e) {
                                    }
                                    consumeTasks(worklist, progress);
        		        }
		        }
		}
                while ( worklist.size() > 0) {
                    consumeTasks(worklist, progress);
                    Thread.yield();
                }
		executorService.shutdown();
		LOGGER.info("End ToDo list contains {} urls ", progress.pending());
		progress.dumpLoaded();
		progress.checkpoint();

	}


    private void consumeTasks(ConcurrentHashMap<String, FutureTask<String>> worklist, ProgressTracker tracker) {
        for ( Entry<String, FutureTask<String>>  e : worklist.entrySet()) {
            if ( e.getValue().isDone() ) {
                try {
                    LOGGER.info("Recieved "+e.getValue().get());
                } catch (Exception e1) {
                    LOGGER.info("Failed {} ",e.getKey(),e1);
                }
                worklist.remove(e.getKey());
            }
        }
        if ( System.currentTimeMillis() > lastLog+5000 ) {
            LOGGER.info("Current Worklist Backlog {} In Pending or Loading state {} ",worklist.size(), tracker.pending());
            lastLog = System.currentTimeMillis();
        }
    }

    @SuppressWarnings("unused")
	private void reScanRelationships(ProgressTracker tracker) {
		File publicationsXml = new File("data/raw-records");
		APIObject userObject = new APIObject(rh, "user", tracker, limitListPages, objectTypes);
		APIObject publicationObject = new APIObject(rh, "publication", tracker, limitListPages, objectTypes);
		for (File f : publicationsXml.listFiles()) {
			if (f.getName().startsWith("relationship")) {
				try {
					Document doc = XmlAide.loadXmlDocument(f.toURI().toURL()
							.toString());
					userObject.loadEntrys(doc);
					publicationObject.loadEntrys(doc);
				} catch (Exception e) {
					LOGGER.error(e.getMessage(), e);
				}
			}
		}
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
		parser.addArgument(new ArgDef().setLongOpt(URL_ARG).setRequired(true)
				.withParameter(true, "url")
				.setDescription("URL of the Symplectic Elements API"));
                parser.addArgument(new ArgDef().setLongOpt(OBJECT_TYPES_ARG).setRequired(false)
                        .withParameter(true, "category")
                        .setDefaultValue("user,publication,grant,activity")
                        .setDescription("Categories to extract"));
		parser.addArgument(new ArgDef()
				.setLongOpt(UPDATE_LIST_ARG)
				.setRequired(false)
				.setDefaultValue("false")
				.withParameter(true, "num")
				.setDescription(
						"If true, Atom Feeds that return lists will be rescanned for changes"));
		parser.addArgument(new ArgDef()
				.setLongOpt(LIMIT_LIST_PAGES_ARG)
				.setRequired(false)
				.setDefaultValue("20")
				.withParameter(true, "num")
				.setDescription(
						"The maximum number of pages in a list that will be retrieved"));
		parser.addArgument(new ArgDef()
				.setLongOpt(MAX_URL_GET_ARG)
				.setRequired(false)
				.setDefaultValue("1000")
				.withParameter(true, "num")
				.setDescription(
						"The maximum number of urls that will be retrieved in a run"));
		return parser;
	}

}
