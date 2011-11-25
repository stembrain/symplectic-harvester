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
	void loadEntry(Node item) throws AtomEntryLoadException;

	/**
	 * @return is this a list or a single entry
	 */
	boolean isList();

	/**
	 * @param url the url of the list page to add to the pending list of pages to load.
	 */
	void addPage(String url);

}
