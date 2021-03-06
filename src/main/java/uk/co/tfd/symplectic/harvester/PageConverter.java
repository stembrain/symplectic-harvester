/*
 *  Copyright (c) 2011 Ian Boston for Symplectic, relicensed under the AGPL license in repository https://github.com/ieb/symplectic-harvester
 *  Please see the LICENSE file for more details
 */
package uk.co.tfd.symplectic.harvester;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class PageConverter {
	private static final String ITEMS_PER_PAGE_ENV = "items-per-page";
	private static final String RESULTS_COUNT_ENV = "results-count";
	private static final Logger LOGGER = LoggerFactory
			.getLogger(PageConverter.class);

	private AtomEntryListLoader loader;
	private int limitListPages;

	public PageConverter(AtomEntryListLoader loader, int limitListPages) {
		this.loader = loader;
		this.limitListPages = limitListPages;
	}

	public void addAll(String firstPageUrl) throws AtomEntryLoadException {
		try {
		Document doc = XmlAide.loadXmlDocument(firstPageUrl);
		Node pagination = doc.getElementsByTagName("api:pagination").item(0);

		int nrecords = Integer.parseInt(XmlAide.findAttribute(pagination,
				RESULTS_COUNT_ENV));
		int itemsPerPage = Integer.parseInt(XmlAide.findAttribute(pagination,
				ITEMS_PER_PAGE_ENV));
		int npages = nrecords / itemsPerPage;
		if (nrecords % itemsPerPage > 0) {
			npages++;
		}

		// for the moment, limit to 20 pages.
		npages = Math.min(npages, limitListPages);

		LOGGER.debug("Fetching {} records from search {} ", nrecords, firstPageUrl);
		for (int page = 1; page <= npages; page++) {
			StringBuilder urlSb = new StringBuilder();
			urlSb.append(firstPageUrl);
			if (firstPageUrl.contains("?")) {
				urlSb.append("&page=");
			} else {
				urlSb.append("?page=");
			}
			urlSb.append(page);

			doc = XmlAide.loadXmlDocument(urlSb.toString());

			NodeList results = doc.getElementsByTagName("entry");
			LOGGER.debug("Got {} results from {} ", results.getLength(), urlSb.toString());
			for (int i = 0; i < results.getLength(); i++) {
				loader.addPage(results.item(i));
			}
		}
		} catch ( Exception e ) {
			throw new AtomEntryLoadException(e.getMessage(), e);
		}
	}

}
