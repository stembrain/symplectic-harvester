package uk.co.tfd.symplectic.harvester;


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

	
	String getType();


}
