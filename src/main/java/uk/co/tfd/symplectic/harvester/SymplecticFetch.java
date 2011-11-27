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

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.NoSuchAlgorithmException;
import java.util.Map.Entry;

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
import org.xml.sax.SAXException;

public class SymplecticFetch {

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
		ProgressTracker progress = new ProgressTracker("loadstate",rh);
		progress.toload(baseUrl+"publication", new APIObjects(rh, "publications", progress));
		progress.toload(baseUrl+"user", new APIObjects(rh, "users", progress));
		int i = 0;
		while(progress.hasPending() && i < 200 ) {
			LOGGER.info("ToDo list contains {} urls ",progress.pending());
			Entry<String, AtomEntryLoader> next = progress.next();
			AtomEntryLoader loader = next.getValue();
			LOGGER.info("Loading Object {} ",next.getKey());
			loader.loadEntry(next.getKey());
			i++;
		}
		LOGGER.info("End ToDo list contains {} urls ",progress.pending());
		progress.dumpLoaded();
		progress.checkpoint();
		
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
