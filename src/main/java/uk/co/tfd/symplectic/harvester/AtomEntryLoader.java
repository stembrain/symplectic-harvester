package uk.co.tfd.symplectic.harvester;

import org.w3c.dom.Node;

/**
 * Generic interface to load Atom Entries
 * @author ieb
 *
 */
public interface AtomEntryLoader {

	/**
	 * @param item the Atom Entry to be parsed
	 * @throws AtomEntryLoadException
	 */
	void loadEntry(String url) throws AtomEntryLoadException;

	
	void addPage(Node item) throws AtomEntryLoadException;

	/**
	 * @param url the url of the list page to add to the pending list of pages to load.
	 */
	void addPage(String url);

	String getType();


}
